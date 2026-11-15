
# Lab 4 — Partition, Mirror, Fail, Recover

**Student:** Nuraly Kuspek  
**Course:** IFT 103 — Operating System Architecture  
**Date:** 15 November 2026  
**Hypervisor:** Oracle VirtualBox  
**Guest systems:** Ubuntu Server 26.04 LTS and Windows 11

## 1. What I did

In this lab, I created and formatted a new partition in Windows 11, built a RAID 1 mirror in Ubuntu Server, deliberately failed one member of the mirror, verified that the data remained intact using SHA-256 checksums, and rebuilt the mirror using a third virtual disk. I recorded the healthy, degraded, and rebuilt RAID states separately, at the time each state occurred.

### Windows: partition, format, and drive letter

I attached a new **1 GB** virtual hard disk (`lab04-win.vdi`) to the Windows VM in VirtualBox. In an elevated PowerShell session, I used these commands:

```powershell
Get-Disk
Get-Disk -Number 1 | Format-List Number, Size, PartitionStyle, OperationalStatus
Initialize-Disk -Number 1 -PartitionStyle GPT
New-Partition -DiskNumber 1 -UseMaximumSize -AssignDriveLetter
Get-Partition -DiskNumber 1
Format-Volume -DriveLetter E -FileSystem NTFS -NewFileSystemLabel LAB04 -Confirm:$false
Get-Disk | Select-Object Number, FriendlyName, PartitionStyle, Size
Get-Volume -DriveLetter E
```

**Actual Windows results:**

| Property | Result |
|---|---|
| New disk | Disk 1 |
| Disk size | 1,073,741,824 bytes (1 GiB) |
| Partition style | GPT |
| Main data partition | Partition 2 |
| Drive letter | E: |
| File system | NTFS |
| Volume label | LAB04 |
| Volume size | 1,056,894,976 bytes |
| Volume health | Healthy / OK |

**MBR or GPT, and why?**

I chose **GPT** because it supports modern disk partitioning, stores a backup partition table, and uses checksums to help detect partition-table corruption. MBR would be sufficient for this small 1 GB data disk, but GPT is a better modern default and is consistent with UEFI-based systems.

Evidence: [lab04-windows.txt](evidence/lab04-windows.txt).

### Linux: disk layout before

I attached three new **1 GB** virtual disks to the Ubuntu VM. Before changing their partitions, I saved the original output of `lsblk`.

```bash
mkdir -p ~/lab04/evidence
cd ~/lab04
{ echo '$ lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS'; lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS; } > evidence/lsblk-before.txt
```

| Device | Initial state | Purpose |
|---|---|---|
| `/dev/sda` | 25 GB, with the Ubuntu system partition | System disk; not modified |
| `/dev/sdb` | Empty 1 GB disk | First RAID 1 member |
| `/dev/sdc` | Empty 1 GB disk | Second RAID 1 member |
| `/dev/sdd` | Empty 1 GB disk | Replacement for the failed member |

Evidence: [lsblk-before.txt](evidence/lsblk-before.txt).

### Partitioning the three new disks

I installed `parted` and created one GPT RAID partition on each new disk. I ran the commands individually after an incorrectly entered Bash loop failed.

```bash
sudo apt install -y parted
sudo parted -s /dev/sdb mklabel gpt mkpart primary 1MiB 100% set 1 raid on
sudo parted -s /dev/sdc mklabel gpt mkpart primary 1MiB 100% set 1 raid on
sudo parted -s /dev/sdd mklabel gpt mkpart primary 1MiB 100% set 1 raid on
lsblk
```

The three new partitions were `/dev/sdb1`, `/dev/sdc1`, and `/dev/sdd1` (about 1022 MB each). The Ubuntu system disk `/dev/sda` was not changed.

### Creating the RAID 1 mirror — healthy state

I used the first two partitions to create a Linux software RAID 1 mirror:

```bash
sudo apt install -y mdadm
sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1
cat /proc/mdstat
sudo mdadm --detail /dev/md0
```

After synchronization finished, `/proc/mdstat` showed **`[2/2] [UU]`**. The detailed report showed **`State : clean`**, **`Active Devices : 2`**, and both `/dev/sdb1` and `/dev/sdc1` as active members.

I saved this state **before** simulating the failure.

Evidence: [array-healthy.txt](evidence/array-healthy.txt).

### Formatting, mounting, and writing test files

I formatted the RAID device itself (not an individual RAID member), mounted it, and wrote two test files:

```bash
sudo mkfs.ext4 -L mirror /dev/md0
sudo mkdir -p /mnt/mirror
sudo mount /dev/md0 /mnt/mirror
sudo chown "$USER":"$USER" /mnt/mirror
echo "Lab 4 proof file - $(whoami) - $(date)" > /mnt/mirror/proof.txt
head -c 20M /dev/urandom > /mnt/mirror/random.bin
```

I recorded SHA-256 hashes for both files before the failure:

```bash
{ echo '$ cd /mnt/mirror && sha256sum proof.txt random.bin'; (cd /mnt/mirror && sha256sum proof.txt random.bin); } > ~/lab04/evidence/checksum-before.txt
```

Evidence: [checksum-before.txt](evidence/checksum-before.txt).

### Failing one RAID disk — degraded state

I simulated a disk failure by marking `/dev/sdc1` as faulty and removing it from the array:

```bash
sudo mdadm /dev/md0 --fail /dev/sdc1
sudo mdadm /dev/md0 --remove /dev/sdc1
cat /proc/mdstat
sudo mdadm --detail /dev/md0
```

The array changed to **`[2/1] [U_]`**.

Its detailed status was **`State : clean, degraded`** and **`Active Devices : 1`**.

The remaining active member was `/dev/sdb1`.

I saved the degraded-state output immediately, before repairing the array.

Evidence: [array-degraded.txt](evidence/array-degraded.txt).

### Checking data integrity after failure

The test text was still readable from the mounted RAID filesystem:

```bash
cat /mnt/mirror/proof.txt
```

I recorded the hashes again and compared them with the original hashes:

```bash
(echo '$ cd /mnt/mirror && sha256sum proof.txt random.bin'; cd /mnt/mirror && sha256sum proof.txt random.bin) > ~/lab04/evidence/checksum-after-failure.txt

diff <(tail -n +2 ~/lab04/evidence/checksum-before.txt) <(tail -n +2 ~/lab04/evidence/checksum-after-failure.txt) && echo "Checksums match"
```

The comparison printed:

```text
Checksums match
```

This demonstrates that the contents of `proof.txt` and `random.bin` did not change when one RAID 1 member failed.

Evidence: [checksum-before.txt](evidence/checksum-before.txt) and [checksum-after-failure.txt](evidence/checksum-after-failure.txt).

### Rebuilding the array — rebuilt state

I added the third prepared disk partition as a replacement:

```bash
sudo mdadm /dev/md0 --add /dev/sdd1
cat /proc/mdstat
sudo mdadm --detail /dev/md0
```

I observed recovery in progress.

After the rebuild finished, `/proc/mdstat` again showed **`[2/2] [UU]`** and the detail command reported **`State : clean`**, **`Active Devices : 2`**.

The working members were now `/dev/sdb1` and `/dev/sdd1`, rather than `/dev/sdb1` and `/dev/sdc1`.

Evidence: [array-rebuilt.txt](evidence/array-rebuilt.txt).

I also recorded the RAID definition and updated the initramfs:

```bash
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
sudo update-initramfs -u
```

These commands completed successfully. I did not record a separate post-reboot verification.

### Linux: disk layout after

I recorded the final layout with:

```bash
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS | tee ~/lab04/evidence/lsblk-after.txt
```

| Device | Final state |
|---|---|
| `/dev/sda` | Ubuntu system disk, unchanged |
| `/dev/sdb1` | Active RAID 1 member |
| `/dev/sdc1` | Removed from the array; still has RAID metadata |
| `/dev/sdd1` | Active replacement RAID 1 member |
| `/dev/md0` | RAID 1, EXT4, mounted on `/mnt/mirror` |

Evidence: [lsblk-after.txt](evidence/lsblk-after.txt).

## 2. Result

| RAID state | Observed status | Active members | Evidence |
|---|---|---|---|
| Healthy | `[2/2] [UU]`, `State : clean` | `sdb1`, `sdc1` | [array-healthy.txt](evidence/array-healthy.txt) |
| Degraded | `[2/1] [U_]`, `State : clean, degraded` | `sdb1` | [array-degraded.txt](evidence/array-degraded.txt) |
| Rebuilt | `[2/2] [UU]`, `State : clean` | `sdb1`, `sdd1` | [array-rebuilt.txt](evidence/array-rebuilt.txt) |

**Data survival:**

Both SHA-256 checksums matched before and after the simulated disk failure. The three RAID states were documented in separate files when they occurred.

### RAID 1 is not a backup — three-sentence answer

No, RAID 1 cannot recover a file that a colleague accidentally deleted an hour ago. The deletion is mirrored to both disks, so RAID 1 protects against the failure of a single disk but not against accidental deletion or unwanted changes. Recovering the file requires an independent backup or another versioned copy from before the deletion.

## 3. What did not work the first time

**Interrupted package configuration.**

While preparing Ubuntu, `apt` reported `dpkg was interrupted`. I corrected the package state with `sudo dpkg --configure -a`, then verified that `parted` was available using `parted --version`.

**Partitioning command entered incorrectly.**

My first attempt at the Bash `for` loop produced `syntax error near unexpected token 'do'`, and the malformed input also caused a `parted` error.

I avoided the typing/pasting issue by running the `parted` commands individually for `/dev/sdb`, `/dev/sdc`, and `/dev/sdd`; `lsblk` then showed all three partitions.

**Evidence transfer.**

An initial `scp` attempt failed with `Connection to 127.0.0.1 port 2222: Software caused connection abort`.

I restored the SSH connection to the Ubuntu VM and repeated `scp`; all Linux evidence files then transferred to the host repository successfully.

## 4. Evidence

All files below were produced from the actual Windows or Ubuntu virtual machines:

- [lab04-windows.txt](evidence/lab04-windows.txt) — Windows Disk 1, GPT, drive E:, NTFS, LAB04
- [lsblk-before.txt](evidence/lsblk-before.txt) — disk layout before Linux partitioning
- [array-healthy.txt](evidence/array-healthy.txt) — healthy RAID 1 state
- [array-degraded.txt](evidence/array-degraded.txt) — degraded RAID 1 state
- [checksum-before.txt](evidence/checksum-before.txt) — SHA-256 checksums before failure
- [checksum-after-failure.txt](evidence/checksum-after-failure.txt) — SHA-256 checksums after failure
- [array-rebuilt.txt](evidence/array-rebuilt.txt) — RAID rebuilt and healthy again
- [lsblk-after.txt](evidence/lsblk-after.txt) — final Linux disk layout
