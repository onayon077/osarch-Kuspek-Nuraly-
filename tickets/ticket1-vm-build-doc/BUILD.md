# BUILD.md — How to rebuild the developer test environment

**Ticket 1 · IFT 103 Operating System Architecture**  
**Written for:** Aigerim, an office manager who has a Windows laptop and internet access but has not used a hypervisor before.  
**Last reviewed:** 10 November 2026  
**Goal:** Set up one Ubuntu Server guest and one Windows 11 Enterprise Evaluation guest in Oracle VirtualBox, connect them to the same private NAT Network, test internet and guest-to-guest communication, and save a recoverable guest snapshot.

> **Read before starting.** This is a repeatable **procedure**, not a claim that every step was photographed during the original installation. The submitted VMs already exist: `Linux Ubuntu` and `lab02-windows`. The images and logs in [`evidence/`](evidence/) prove only the things stated beside them. In particular, the image `01-new-vm-wizard.png` is a composite of a **reopened wizard**, not proof of the original VM creation. Snapshot creation is evidenced; a snapshot **restore has not been tested**.
>
> **Do not rebuild existing VMs just to take screenshots.** A fresh build is for another test computer or when the old guests are no longer needed. Always save valuable data outside a VM before deleting or restoring anything.

## Essential words

- **Host:** the real Windows computer; **guest / VM:** a separate operating system inside VirtualBox.
- **ISO:** the downloaded OS installation image. **VDI:** a VirtualBox virtual hard-disk file.
- **NAT Network:** a private VirtualBox network in which the VMs can reach the internet **and each other**.
- **Dynamic VDI:** starts smaller and grows as used (up to its maximum); **fixed VDI:** takes its specified size on the host from the start.
- **Snapshot:** a point in a guest's history that can be restored. It is **not** a backup of the host, and restore may discard later guest changes.

## Before you start: known configuration and capacity

The values below are from **actual VirtualBox settings**, not guessed defaults. Use these values to reproduce the submitted setup; a later project could reasonably use fewer Ubuntu CPUs or a different storage layout if documented.

| Configuration | Ubuntu guest | Windows guest |
|---|---|---|
| Name of existing VM | `Linux Ubuntu` | `lab02-windows` |
| Installed OS | Ubuntu **26.04.1 LTS** (verified inside guest) | Windows **11 Enterprise Evaluation** (desktop watermark) |
| RAM | **2048 MB** | **4096 MB** |
| Virtual processors | **5** | **2** |
| VDI maximum / format | **25 GB**, VDI, **dynamic** | **64 GB**, VDI, **fixed** |
| Firmware | BIOS/legacy (UEFI off) | **UEFI on**, **Secure Boot on**, **TPM 2.0** |
| Adapter 1 | NAT Network → `NatNetwork` | NAT Network → `NatNetwork` |
| Snapshot | `clean-install` (23 Oct 2026; older snapshots also exist) | `clean-install` (10 Nov 2026; taken after setup/DNS fix) |

**Host checks performed:** installed RAM `16,438,312,960` bytes (about **15.31 GiB**), **12** logical processors, about **2.31 GiB** available RAM at measurement, and **72.02 GB** free on C: at measurement. Actual VDI use then was approximately **5.87 GB (Ubuntu) + 64 GB (Windows) = 69.87 GB**. Their *virtual capacities* total **89 GB**. The free C: figure already reflects existing files: **do not subtract 69.87 GB again**. The Ubuntu VDI can still grow by about 19.13 GB, and snapshots also require space.

**Practical decision:** If you are using this same computer, **reuse the existing guests** rather than creating another 64 GB fixed disk. Close unneeded host programs and **recheck free RAM before starting both guests**; the earlier 2.31 GiB free measurement is not sufficient headroom for a new 4 GiB VM without freeing memory. Do not change resource settings solely to make the report match a proposed plan.

---

## Phase A — Prepare VirtualBox and the host

### Step 1 — Download VirtualBox

1. On the **host Windows computer**, open https://www.virtualbox.org/wiki/Downloads.
2. Download the **Windows hosts** VirtualBox installer.
3. Run the installer and follow its on-screen setup prompts.
4. Open **Oracle VirtualBox Manager** from the Start menu.

**Why this choice?** VirtualBox is a graphical hypervisor that Aigerim can use without programming. The open-source **base package** is enough for networking and snapshots. Do not automatically install the separately licensed **Extension Pack**; it is unnecessary for this task.  
**Check:** VirtualBox Manager opens and displays the list of VMs. To check the actual installed version, open **PowerShell on the host** and run:

```powershell
& "$env:ProgramFiles\Oracle\VirtualBox\VBoxManage.exe" --version
```

Record the returned version when building on a new computer. The original installed version was **not captured**.

### Step 2 — Download the two operating-system installers

1. Go to https://ubuntu.com/download/server and download the **Ubuntu Server 64-bit AMD64 ISO** (for the submitted configuration, `ubuntu-26.04.1-live-server-amd64.iso`).
2. Go to https://www.microsoft.com/en-us/evalcenter/evaluate-windows-11-enterprise and obtain the official **Windows 11 Enterprise Evaluation ISO**.
3. Keep the ISO files somewhere easy to find, such as **Downloads**; do not unzip an ISO.

**Why Ubuntu *Server*?** The submitted Linux VM uses a text-console login; Ubuntu Desktop is a different installer and was an error in the earlier draft.  
**Why Windows Evaluation?** It permits **90 days of evaluation**, not a permanent licensed company workstation. If a VM is needed longer, obtain a proper licence and deploy a licensed installation; a snapshot does not restart the evaluation period. Microsoft may require a Microsoft-account sign-in depending on the evaluation build.  
**Check:** Both ISO files exist. The Ubuntu ISO filename was visible in the recreated wizard; the original Windows ISO filename was not recorded. Do not claim it was checked when it was not.

### Step 3 — Measure available host resources

1. On the real Windows computer, press **Win + X → Terminal / Windows PowerShell**.
2. Enter the following commands, **one line at a time**:

```powershell
Get-CimInstance Win32_ComputerSystem | Select-Object TotalPhysicalMemory,NumberOfLogicalProcessors
(Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory
Get-PSDrive C
```

3. Note the installed memory and logical CPU count, available RAM, and disk free space.
4. In VirtualBox **Settings → Storage**, check where the VM disk files will be stored; if not on **C:**, measure that disk instead.

**Why?** A dynamically allocated VDI grows and a fixed VDI occupies its full size immediately. Windows itself and normal applications also need RAM.  
**Check:** Do **not** proceed with a new fixed 64 GB Windows VDI unless the destination disk has enough free space **in addition** to space needed for Ubuntu, snapshots, updates, and the host. For the existing VMs, the measured storage and RAM details are in the accompanying [`README.md`](README.md).

### Step 4 — Create a shared NAT Network

1. In **VirtualBox Manager**, open **File → Tools → Network Manager** (menu placement can vary slightly by VirtualBox version).
2. Open the **NAT Networks** tab.
3. If `NatNetwork` already exists, select it; **do not make a duplicate**.
4. Otherwise click **Create**, name it **`NatNetwork`**, choose **`10.0.2.0/24`** for IPv4, enable **DHCP**, and enable/start the network.

**Why NAT Network, not ordinary NAT?** Ordinary NAT lets each guest access external networks but does not normally allow the two guests to reach each other. NAT Network supports guest-to-guest traffic. **Bridged** networking would make VMs more directly visible on the physical LAN, which is unnecessary here.  
**Check:** The Network Manager displays `NatNetwork` as enabled, with DHCP. During the submitted test, the Ubuntu and Windows guests used `10.0.2.3` and `10.0.2.15` respectively; their IPs **may change** after a reboot.

---

## Phase B — Ubuntu Server

### Step 5 — Create the Ubuntu VM shell

1. In VirtualBox Manager click **New / Создать**.
2. Enter VM name **`Linux Ubuntu`**. If that exact VM already exists, **cancel and reuse it**; do not create a duplicate.
3. Choose the Ubuntu **Server** ISO from Step 2.
4. Choose **Linux → Ubuntu (64-bit)**. If your VirtualBox lists a release such as `Ubuntu 24.04 LTS` or `Ubuntu 25.04` but not `26.04`, use a compatible **64-bit Ubuntu profile**; the *ISO* determines the actual installed guest release.
5. Uncheck **Unattended / Automated installation** to show every installer screen manually.
6. Open **Hardware** and allocate **2048 MB** memory and **5** virtual CPUs for the **observed submitted configuration**.
7. Leave **EFI** disabled for this Ubuntu configuration.
8. Open **Virtual Hard Disk** and create a **25 GB VDI** with **preallocate full size disabled** (dynamic).
9. Click **Finish** only when genuinely creating a new VM.

**Why these settings?** They match the **existing** guest rather than the incorrect older draft (4096 MB and 2 vCPUs). Ubuntu Server normally does not require five vCPUs for light testing; this was the observed setting, not a universal recommendation. A dynamic disk uses less real space initially but still needs a growth budget. Unlike Windows 11, this Ubuntu guest does not need UEFI or TPM 2.0.  
**Check:** In the finished VM's **Settings → System** and **Storage**, verify its name, **2048 MB / 5 CPUs / 25 GB dynamic VDI**. Actual disk verification: [02-disk-settings.png](evidence/02-disk-settings.png). The [01-new-vm-wizard.png](evidence/01-new-vm-wizard.png) is a **composite illustration of re-entered settings**, not an original creation screenshot. A future rebuild should capture a single authentic wizard screenshot during creation.

### Step 6 — Connect Ubuntu to the NAT Network

1. **Power off** Ubuntu if it is running.
2. Select `Linux Ubuntu` → **Settings / Настроить → Network / Сеть → Adapter 1**.
3. Tick **Enable Network Adapter**.
4. Choose **Attached to: NAT Network / Сеть NAT** (not plain `NAT`).
5. Choose **Name: `NatNetwork`**, keep **Cable connected** checked, then select **OK**.

**Why?** Both guests must use the **same named** NAT Network to exchange traffic.  
**Check / screenshot:** [03-network-adapter.png](evidence/03-network-adapter.png) shows Ubuntu adapter 1 on `NatNetwork`. Its MAC address corresponds to the interface identifier from the Ubuntu log.

### Step 7 — Install Ubuntu Server from ISO

1. Select `Linux Ubuntu` and click **Start**.
2. At the boot menu select **Try or Install Ubuntu Server**.
3. Choose your **language**, confirm the **keyboard layout**, and continue.
4. On the **network** screen, keep the wired interface on **DHCP** unless the office has a specific network plan.
5. Leave the **proxy** blank unless your network administrator gives you one.
6. Accept a working Ubuntu **package mirror**.
7. At **Storage configuration**, select the **25 GB virtual disk** for this VM and the guided whole-disk setup; read the confirmation before applying it. **Do not select a host physical disk.**
8. Create a normal user, set a secure private password, and choose a hostname. The submitted terminal shows user `nuralubuntu` and hostname `Linux-Ubuntu`; other rebuilds may choose their own credentials.
9. On **SSH setup**, leave SSH unselected unless remote login is actually necessary.
10. Finish installation, select **Reboot**, and if prompted remove the installer ISO through **Devices → Optical Drives**.
11. Log in at the black text-console prompt using the new user and password.

**Why manual installation?** It makes each choice visible and reproducible for a beginner instead of silently supplying values through unattended setup.  
**Check:** Successful Ubuntu login, then run:

```bash
uname -a
lsb_release -a
ip -4 addr
```

The submitted [04-guest-uname.txt](evidence/04-guest-uname.txt) identifies **Ubuntu 26.04.1 LTS**, kernel `7.0.0-38-generic`, and `10.0.2.3/24` at the time of the test. These commands **do not prove** the original installer wizard selections.

---

## Phase C — Windows 11 Enterprise Evaluation

### Step 8 — Create the Windows VM

1. In VirtualBox Manager click **New / Создать**.
2. Enter **`lab02-windows`** as the name. If it already exists, **cancel and reuse it**.
3. Select the official **Windows 11 Enterprise Evaluation** ISO downloaded in Step 2.
4. Choose **Microsoft Windows → Windows 11 (64-bit)**.
5. Disable **Unattended installation**, if offered, to follow the visible setup screens.
6. Set **RAM to 4096 MB** and **Processors to 2**.
7. Create a new **64 GB VDI** and choose **preallocate full size / fixed-size** to reproduce the real submitted VM.
8. Click **Finish** only on a genuinely new build.

**Why fixed disk?** The current `lab02-windows.vdi` is an actual **64 GB fixed/preallocated** VDI, not dynamic as the earlier guide claimed. Fixed-size disks reserve storage immediately; a dynamic VDI is a reasonable space-saving alternative for a future build **but would not match this submission**.  
**Check / screenshot:** [windows-disk-settings.png](evidence/windows-disk-settings.png) (if present in the evidence folder) should show `lab02-windows`, **64.00 GB virtual and actual**, with the fixed-size attribute. **Check storage capacity before creating**: do not create a second 64 GB VDI unnecessarily.

### Step 9 — Enable Windows 11 firmware requirements

1. **Shut down** the VM fully before modifying hardware settings.
2. Open `lab02-windows` → **Settings → System → Motherboard**.
3. Enable **UEFI**.
4. Enable **Secure Boot**, when offered by your VirtualBox version.
5. Choose **TPM version 2.0**.
6. Select **OK**.

**Why?** Windows 11 expects UEFI/Secure Boot-capable firmware and TPM 2.0. These are not required for this Ubuntu guest.  
**Check / screenshot:** [windows-system-settings.png](evidence/windows-system-settings.png) shows the real `lab02-windows` configured with **4096 MB RAM, UEFI on, Secure Boot on, and TPM 2.0**.

### Step 10 — Connect Windows to the same NAT Network

1. With Windows powered off, open **Settings → Network → Adapter 1**.
2. Check **Enable Network Adapter**.
3. Choose **NAT Network / Сеть NAT**.
4. Choose **Name: `NatNetwork`** and check **Cable connected**.
5. Click **OK**.

**Why?** Selecting regular NAT here would isolate the Windows guest from Ubuntu, even though both might reach the internet.  
**Check / screenshot:** [windows-network-adapter.png](evidence/windows-network-adapter.png) shows `lab02-windows` on `NatNetwork`; compare with Ubuntu's [03-network-adapter.png](evidence/03-network-adapter.png).

### Step 11 — Install Windows 11 Enterprise Evaluation

1. Click **Start** on `lab02-windows`.
2. If **Press any key to boot from CD or DVD** appears, press a key.
3. Select installation **language**, **time/region** and **keyboard** as prompted.
4. Choose **Install Windows** (wording varies with the evaluation build).
5. If setup requests a product key, use the officially supported evaluation flow; the evaluation ISO does **not** require purchasing a separate key for installation.
6. Accept the **licence terms**.
7. Select **Custom installation** if asked which installation type to use.
8. Select the **unallocated 64 GB disk inside the VM** and continue. This is the *virtual* disk, not your host's C: drive.
9. Let setup install and restart. If it boots the installer again, remove the ISO in **Devices → Optical Drives** and restart the guest.
10. Complete the initial region, network, privacy, and sign-in pages shown by **that specific build**. Use a **Microsoft account** if required; only use a local-account path if the actual setup explicitly offers one. Do not rely on undocumented `oobe\bypassnro` shortcuts.
11. Reach the Windows desktop; open **Settings → System → About** or run `winver` to confirm the edition/build.

**Why Enterprise Evaluation?** It is for a temporary test environment. The desktop in the observed guest displays **Windows 11 Enterprise Evaluation** with an evaluation watermark. This is not evidence of a permanent licence.  
**Check:** Windows loads to desktop, has the expected account, and `winver` shows the installed edition. Do not assume an edition solely from the VM's name. Screenshot an actual `winver` screen in a *new* build if you need build-specific proof.

### Step 12 — Verify the installed Windows hardware configuration

1. In VirtualBox Manager, open `lab02-windows` → **Details / Детали** or **Settings**.
2. Confirm RAM **4096 MB**, CPU count **2**, and disk **64 GB fixed VDI**.
3. Confirm **UEFI**, **Secure Boot** and **TPM 2.0** under System.
4. Confirm Adapter 1 is **NAT Network `NatNetwork`**.

**Why?** A guest can boot while its documented values still disagree with the real settings; a reader must be able to check each value.  
**Check:** Compare the screenshots [windows-system-settings.png](evidence/windows-system-settings.png), [windows-disk-settings.png](evidence/windows-disk-settings.png) and [windows-network-adapter.png](evidence/windows-network-adapter.png). They are evidence of **existing settings**, not of the Windows installer screens.

---

## Phase D — Test internet and guest-to-guest networking

### Step 13 — Check Ubuntu's address and internet

1. Start Ubuntu and sign in at the terminal.
2. Run:

```bash
ip -4 addr
ping -c 4 8.8.8.8
ping -c 4 google.com
```

**Why both pings?** The first checks external IP reachability; the second tests reachability by a DNS name. Some networks filter ICMP, so if a public ping fails, also test normal HTTPS before concluding the internet is down.  
**Check:** The captured repeat Ubuntu internet tests showed **4/4 replies** to `8.8.8.8` and `google.com`. An earlier `8.8.8.8` attempt showed **75% loss**; do not conceal it or claim that every test succeeded. For a fresh build, save **unedited terminal output** with the actual commands using:

```bash
{
  echo '$ ip -4 addr'; ip -4 addr
  echo '$ ping -c 4 8.8.8.8'; ping -c 4 8.8.8.8
  echo '$ ping -c 4 google.com'; ping -c 4 google.com
} 2>&1 | tee ~/ubuntu-internet-proof.txt
```

The submitted `05-ping-between-guests.txt` includes Ubuntu's internet output **transcribed from a screenshot**, not the original guest TXT. The primary TXT could not be retrieved from the host during this revision.

### Step 14 — Check Windows's address and internet

1. Sign in to `lab02-windows` and open **PowerShell inside the guest** (not the host).
2. Run:

```powershell
ipconfig
ping -n 4 8.8.8.8
ping -n 4 google.com
nslookup google.com
```

**Why?** `ipconfig` identifies the address; the two pings check external IP traffic and DNS-name reachability; `nslookup` diagnoses DNS if the hostname check fails.  
**Check:** In the successful captured test Windows got **4 replies and 0% loss** to both `8.8.8.8` and `google.com`, and `nslookup google.com` used DNS **8.8.8.8**. The native source file `windows-internet-proof.txt` was supplied separately. Capture a screenshot of the terminal and save its **unedited text output** in the evidence folder.

### Step 15 — Test Ubuntu → Windows and Windows → Ubuntu

1. On Ubuntu, read its current IPv4 address from `ip -4 addr`.
2. On Windows, read its current IPv4 address from `ipconfig`.
3. On **Ubuntu**, run `ping -c 4 <windows-ip>` using the **actual current** Windows guest address.
4. On **Windows**, run `ping -n 4 <ubuntu-ip>` using the **actual current** Ubuntu guest address.

For example, **only if the addresses still match those captured earlier**:

```bash
# Ubuntu guest
ping -c 4 10.0.2.15
```

```powershell
# Windows guest
ping -n 4 10.0.2.3
```

**Why?** Working internet alone does not prove that the guests can talk to one another.  
**Check:** In the original [05-ping-between-guests.txt](evidence/05-ping-between-guests.txt), the two guest-to-guest directions each have **4 replies and 0% loss**. That combined evidence file also includes internet checks, with its source limitations stated in the file header. Ensure commands and actual unedited outputs are captured on future runs.

### Step 16 — Fix Windows DNS only if a real failure occurs

1. If `ping 8.8.8.8` works but `ping google.com` fails, run `nslookup google.com` in **Windows guest PowerShell**.
2. If its configured server times out, check a known alternate resolver: `nslookup google.com 8.8.8.8`.
3. If this succeeds and changing DNS is permitted on that test network, open **Windows guest PowerShell as Administrator**.
4. Set DNS on the **actual adapter name** (the submitted guest uses `Ethernet`):

```powershell
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 8.8.8.8
```

5. Check the result:

```powershell
nslookup google.com
ping -n 4 google.com
```

6. If restoring automatic DNS is later required, use:

```powershell
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ResetServerAddresses
```

**What really happened in this ticket:** Windows could ping `8.8.8.8`, but `nslookup google.com` timed out against DNS `192.168.0.1`. An explicit lookup against `8.8.8.8` worked. After changing the DNS server to `8.8.8.8`, both `nslookup google.com` and `ping google.com` succeeded. This is a documented troubleshooting event, **not** a generic imagined failure. The original failed checks and later successful screenshots should remain distinguishable in the report.  
**Check:** the corrected DNS address is `8.8.8.8` and name resolution succeeds; this changed setting must be documented rather than presented as a VirtualBox default.

### Step 17 — Add a narrowly scoped Windows Firewall rule only if Linux → Windows ping fails

1. First verify **both guests are on `NatNetwork`** and have valid IP addresses.
2. If Ubuntu cannot ping Windows but Windows can ping Ubuntu, inspect Windows Firewall. Do not disable the entire firewall.
3. **Only for this observed failure**, open **Windows guest PowerShell as Administrator** and run (replace `10.0.2.3` with Ubuntu's current IP):

```powershell
New-NetFirewallRule -DisplayName "Ticket1 allow Ubuntu ping" -Direction Inbound -Protocol ICMPv4 -IcmpType 8 -RemoteAddress 10.0.2.3 -Action Allow
```

4. Repeat `ping -c 4 <windows-ip>` from Ubuntu and save the before/after output.
5. Remove the rule when it is no longer needed:

```powershell
Remove-NetFirewallRule -DisplayName "Ticket1 allow Ubuntu ping"
```

**Why this rule instead of disabling the firewall?** It permits only inbound ICMPv4 echo requests from one specified guest address, a narrower exception than turning off protection.  
**What happened in the submitted test:** **Both directions already worked. No firewall rule is claimed to have been created or needed.** The above is a reproducible troubleshooting procedure, not submitted evidence of a firewall change.

---

## Phase E — Save and restore clean baselines

### Step 18 — Create a clean Ubuntu snapshot

1. After installation and initial network checks, **shut down Ubuntu from the guest** with `sudo shutdown -h now`.
2. In VirtualBox Manager select **`Linux Ubuntu` → Snapshots / Снимки**.
3. Click **Take / Сделать**, name the snapshot **`clean-install`**, and describe the guest/OS/date.
4. Capture the **entire Manager window** with the Ubuntu VM name and snapshot tree visible.

**Why?** A labelled baseline allows the guest to be returned to a known earlier state after an experiment.  
**Check / screenshot:** [06-snapshot-list.png](evidence/06-snapshot-list.png) shows `clean-install` for `Linux Ubuntu`, dated **23 October 2026**, **below two earlier entries** named `clean setup` and `Снимок 1`. They have not been removed, and should not be called separate clean baselines without evidence.

### Step 19 — Create a clean Windows snapshot

1. Shut down Windows **from Start → Power → Shut down**.
2. In VirtualBox Manager select **`lab02-windows` → Snapshots / Снимки**.
3. Click **Take / Сделать**, name it **`clean-install`**, and describe that it includes Windows Enterprise Evaluation, NAT Network, UEFI, TPM 2.0 and working DNS.
4. Capture the whole Manager window showing the **Windows VM name** and `clean-install`.

**Why?** Windows needs its **own** baseline. Ubuntu's snapshots do not protect a separate VM.  
**Check / screenshot:** [windows-snapshot-list.png](evidence/windows-snapshot-list.png) shows `clean-install` on `lab02-windows`, created **10 November 2026**, **after** Windows was configured and the DNS failure was fixed. Do not call it a snapshot taken immediately after first installing Windows.

### Step 20 — Restore a baseline if an experiment breaks the guest

1. **Save or export important work** from the guest outside the VM first: restoring can remove all guest changes made after the snapshot.
2. Fully **shut down** the guest to restore.
3. In VirtualBox Manager select the **correct VM** → **Snapshots** → the correct **`clean-install`** entry.
4. Click **Restore / Восстановить**, read the warning carefully, and confirm only if you intend to discard later guest changes.
5. Start the guest and repeat its login and network checks.

**Why?** A snapshot is a fast guest rollback point, but it does not protect against losing the entire host disk, and restoring it does not extend the Windows evaluation licence.  
**Check:** The original work proves **snapshot creation**, **not a successful restore**. The student has **not** demonstrated executing Step 20 on either guest. Do not report that rollback was tested until a controlled restore is actually performed and documented.

---

## Troubleshooting: what to do when a check fails

| Symptom | First thing to inspect | Action |
|---|---|---|
| VM will not start | Free host RAM and running programs | Close host applications; check the Windows host memory before launching both guests; reduce allocation only if documented and suitable |
| `NatNetwork` not listed | Network Manager → NAT Networks | Create/start `NatNetwork`, enable DHCP; reconnect *both* guests to the same named network |
| Guest has no IP | VirtualBox adapter and cable checkbox | Enable Adapter 1 and cable; restart DHCP or the guest and check its address |
| Ubuntu can ping internet but not Windows | Windows firewall and adapter mode | Confirm both `NatNetwork`; use Step 17 only if firewall is actually blocking ICMP |
| Windows can ping IP but not `google.com` | `nslookup google.com` and DNS server | Follow Step 16; in this test `192.168.0.1` timed out and `8.8.8.8` worked |
| Ubuntu installer will not boot | ISO mounted under Storage | Attach actual **Ubuntu Server ISO**; ensure new VM boots from it |
| Windows setup rejects hardware | Windows VM System → EFI / TPM / Secure Boot | Confirm UEFI, Secure Boot capability and TPM 2.0 before retrying |
| Windows setup returns to installer | ISO still first in boot order | Eject installer ISO and boot the guest disk |
| Windows setup wants an account | Edition/build-specific supported sign-in path | Use Microsoft account where required; avoid undocumented local-account bypasses |
| Host C: loses free space | Fixed Windows VDI, growing Ubuntu VDI, snapshots | Check current free disk; do not create a second fixed 64 GB Windows VDI by accident |
| Shared folder reports permission denied | Guest shared-folder mount permissions | Check mount and guest additions; avoid assuming `vboxsf` exists. The original attempt required `sudo cp`, and the host target path was not found |
| Snapshot shows old names | Snapshot tree belongs to selected VM | Identify the selected VM first, preserve older snapshots, and create one clearly labelled baseline for each guest |
| Windows evaluation expires | Evaluation period/licensing | Replace with appropriately licensed Windows or retire the VM; do not use snapshots to evade licence terms |

## Evidence map for the reviewer

The Step-by-Step Guide requires **six specifically named files** in `evidence/`. The additional Windows settings screenshots are useful, but **do not replace** the six required files.

| Evidence file | Relevant steps | What it actually establishes |
|---|---|---|
| [`01-new-vm-wizard.png`](evidence/01-new-vm-wizard.png) | Step 5 | Recreated Ubuntu wizard **composite**, not original creation evidence |
| [`02-disk-settings.png`](evidence/02-disk-settings.png) | Step 5 | Current `Linux Ubuntu.vdi`, 25 GB dynamic, 5.87 GB occupied |
| [`03-network-adapter.png`](evidence/03-network-adapter.png) | Step 6 | Ubuntu connected to NAT Network `NatNetwork` |
| [`04-guest-uname.txt`](evidence/04-guest-uname.txt) | Step 7 | Original Ubuntu `uname` / `lsb_release` / IP output |
| [`05-ping-between-guests.txt`](evidence/05-ping-between-guests.txt) | Steps 13–16 | Both ping directions, both internet tests, with **Ubuntu internet portion transcribed** from a real screenshot; not a fully unedited guest TXT |
| [`06-snapshot-list.png`](evidence/06-snapshot-list.png) | Step 18 | Ubuntu's real snapshot tree with `clean-install` and its VM name |
| [`windows-network-adapter.png`](evidence/windows-network-adapter.png) | Step 10 | Windows uses the same NAT Network (additional) |
| [`windows-system-settings.png`](evidence/windows-system-settings.png) | Step 9 | Real Windows UEFI, TPM, Secure Boot and RAM (additional) |
| [`windows-disk-settings.png`](evidence/windows-disk-settings.png) | Step 8 | Real 64 GB fixed-size Windows VDI (additional) |
| [`windows-snapshot-list.png`](evidence/windows-snapshot-list.png) | Step 19 | Windows snapshot `clean-install` (additional) |
| [`windows-dns-fixed.png`](evidence/windows-dns-fixed.png) | Step 16 | Successful DNS test after the change (additional) |

**Limitations to disclose, not disguise:** The recreated wizard image is illustrative; not every original installer step has an authentic screenshot; original Ubuntu internet TXT did not reach the host during this work; and no snapshot restore was tested. These limits are also explained in the Ticket 1 README. Adding a screenshot later is acceptable only if it actually shows the action in the real VM; do not fabricate or label a reconstructed screen as an original capture.

**Submission:** Commit and push this `BUILD.md`, the matching [`README.md`](README.md), and the evidence folder together. In Canvas submit a **permalink to the exact `tickets/ticket1-vm-build-doc/` folder at the submitted commit**, not a link to the mutable repository homepage. Declare ChatGPT assistance in the **repository-root `README.md`** in accordance with the course instructions.

## Official references

- [Oracle VirtualBox downloads](https://www.virtualbox.org/wiki/Downloads)
- [VirtualBox networking: NAT, NAT Network and Bridged](https://docs.oracle.com/en/virtualization/virtualbox/7.2/user/networkingdetails.html)
- [Oracle VirtualBox user guide](https://docs.oracle.com/en/virtualization/virtualbox/7.2/user/)
- [Ubuntu Server download](https://ubuntu.com/download/server)
- [Ubuntu Server installation documentation](https://ubuntu.com/server/docs/basic-installation/)
- [Windows 11 Enterprise Evaluation](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-11-enterprise)
- [Windows 11 hardware requirements](https://support.microsoft.com/en-us/windows/experience/compatibility/windows-11-system-requirements)
