# Ticket 1 — A repeatable VM test environment for a new developer

**Course:** IFT 103 — Operating System Architecture  
**Scope:** `tickets/ticket1-vm-build-doc/`  
**Documentation update:** 10 November 2026  
**Reader:** Aigerim, office manager (no prior hypervisor experience assumed)

## 1. What was asked

> Hi, we have someone starting on Monday and he needs a test computer set up. Nothing special, just so he can try things without breaking anything. Can you write down how to do it so I can do the next one myself? Thanks

**From:** Aigerim T. (Office Manager)  
**Subject:** test machine for new dev

The original message does not specify an operating system, the available hardware, networking requirements, licensing, or a recovery method. The goal is a test environment that a non-technical colleague can rebuild without risking the everyday host system.

## 2. What was actually needed

### 2.1 Missing information, questions, and working assumptions

| Missing detail | Question I would ask Aigerim | Assumption used and reason |
|---|---|---|
| Which operating systems? | Does the developer need Linux, Windows, or both? | **Both** for this coursework: Ubuntu lets the developer test Linux/command-line tools; Windows lets them test Windows-specific software. For an actual employee, I would first confirm whether both are necessary. |
| What does “without breaking anything” mean? | Which host data and services must be protected? How much test work may be discarded? | Run the OSes as **separate VirtualBox guests**; keep host files outside the guests and create snapshots. This reduces risk but does not make unknown software completely safe. |
| How is the computer equipped? | How much RAM, CPU capacity, and free storage are available on the drive holding the VMs? | Measure the host before choosing VM sizes. This host has **16,438,312,960 bytes RAM (about 15.31 GiB)**, **12 logical processors**, and **72.02 GB free on C:** at the time of the captured check. |
| Do guests need networking? | Should they reach the internet, each other, or other office computers? | Both guests need internet and guest-to-guest communication; a **shared NAT Network (`NatNetwork`)** meets this without putting the VMs directly on the office LAN. |
| How long will the test environment be used? | Is a 90-day Windows evaluation sufficient? | Use **Windows 11 Enterprise Evaluation** only for temporary evaluation, not a permanent production workstation. Obtain appropriate licensing for longer use. |
| Who will rebuild the setup? | Has the reader used VirtualBox or installed an operating system before? | Assume no experience. [BUILD.md](BUILD.md) explains clicks, terminology, choices, checks and recovery steps. |

### 2.2 What the request overlooked

- **Windows 11 requirements:** The actual `lab02-windows` VM has 4096 MB RAM, a 64 GB virtual disk, UEFI enabled, Secure Boot enabled, and virtual TPM 2.0. These requirements matter even though the request calls the computer “nothing special”.
- **Snapshots are not backups of the host and not a license reset.** A snapshot can return a guest to an earlier state, losing subsequent changes. Restore should be tested safely and important work kept elsewhere.
- **The Windows evaluation expires.** Microsoft provides a 90-day evaluation. If the evaluation expires or is not activated, it may show licensing notifications, turn the desktop black, and shut down hourly. The correct next action is to use a legitimately licensed Windows installation or retire/rebuild the evaluation VM, not to restore a snapshot to bypass licensing.
- **Isolation is not absolute.** NAT Network limits ordinary direct LAN exposure, but guests can still access external services and shared folders may expose host files. Keep shared-folder permissions minimal.

### 2.3 Software and licence decisions

| Software | Licence / status | Decision for an office user |
|---|---|---|
| Ubuntu 26.04.1 LTS | Free/open-source Linux; version verified from the guest's `lsb_release -a` output | Suitable for the command-line Linux guest. The selected Server ISO is `ubuntu-26.04.1-live-server-amd64.iso`; the initial installation ISO was not independently logged. |
| Windows 11 Enterprise Evaluation | Microsoft 90-day evaluation | Appropriate for time-limited testing; not permanent production licensing. The running guest shows the Enterprise Evaluation watermark. |
| Oracle VirtualBox **base package** | Oracle publishes VirtualBox 7.2 base packages under **GPLv3**; the exact version installed on this host was not captured | Use the free base package, and record the actual installed build with `VBoxManage --version` when rebuilding. Do not mistake the published release for the installed one. |
| VirtualBox Extension Pack | Optional, separately licensed package | Not needed for the tested NAT Network and snapshot workflow; do not add it without checking the applicable office-use licence. |

Official sources: [Oracle VirtualBox downloads and licensing](https://www.oracle.com/virtualization/technologies/vm/downloads/virtualbox-downloads.html), [Microsoft Windows Enterprise Evaluation](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-11-enterprise), [Ubuntu Server download](https://ubuntu.com/download/server), [Oracle VirtualBox networking](https://docs.oracle.com/en/virtualization/virtualbox/7.2/user/networkingdetails.html).

## 3. What I did

### 3.1 Actual VM configuration verified in VirtualBox

| Setting | `Linux Ubuntu` | `lab02-windows` |
|---|---|---|
| Installed guest | Ubuntu 26.04.1 LTS (guest commands) | Windows 11 Enterprise Evaluation (desktop watermark) |
| RAM | **2048 MB** | **4096 MB** |
| Virtual CPUs | **5** | **2** |
| CPU execution cap | 100% | 100% |
| Virtual disk capacity | **25 GB** (`Linux Ubuntu.vdi`) | **64 GB** (`lab02-windows.vdi`) |
| VDI allocation | Dynamically expanding; approximately **5.87 GB** occupied when inspected | **Fixed/preallocated; 64 GB** occupied when inspected |
| Network adapter 1 | **NAT Network** / `NatNetwork` | **NAT Network** / `NatNetwork` |
| UEFI | Disabled | Enabled |
| Virtual TPM | Not present | TPM 2.0 |
| Secure Boot | Not enabled | Enabled |
| Snapshot | `clean-install`, dated **23 October 2026**, within an older snapshot tree | `clean-install`, created **10 November 2026** after configuring and testing Windows |

These are **observed settings**, not recommended defaults for every computer. The repeatable instructions in [BUILD.md](BUILD.md) should use the same values or label any suggested alternative explicitly. The VirtualBox UI described the Ubuntu guest type as “Ubuntu 25.04”, but inside that guest `lsb_release -a` reports **26.04.1 LTS**; the guest command is evidence of the installed OS version, while the GUI label is a VM template setting.

### 3.2 Capacity and actual host measurements

| Host measurement | Result | What it means |
|---|---:|---|
| Installed physical memory | 16,438,312,960 bytes ≈ **15.31 GiB** | Measured in Windows PowerShell |
| Available physical memory at measurement | 2,421,920 KiB ≈ **2.31 GiB** | **Measured free RAM**, not the theoretical amount left after allocating VM memory |
| Logical processors | **12** | Virtual CPUs share the host's processing time |
| Disk C: used | **395.93 GB** | Host PowerShell measurement |
| Disk C: free | **72.02 GB** | Host PowerShell measurement; this is after the existing VM images already occupy storage |

**Memory calculation:** 2048 MB (Ubuntu) + 4096 MB (Windows) = **6144 MiB (6 GiB)** configured guest RAM. Based on installed host RAM, **15.31 − 6 = approximately 9.31 GiB** would remain *nominally*, before the Windows host OS, VirtualBox overhead and other programs. However, only **2.31 GiB was actually reported available** at the captured measurement, so I should close unneeded host applications and re-check memory before running both VMs. Merely subtracting allocations from installed RAM would be misleading.

**CPU calculation:** 5 Ubuntu vCPUs + 2 Windows vCPUs = **7 configured vCPUs** on a host with **12 logical processors**. These are scheduled threads, not seven dedicated physical cores. Five vCPUs is more than Ubuntu Server typically needs for this simple exercise, so I would consider reducing that allocation in a later planned change after checking workload needs.

**Storage calculation:** 25 GB + 64 GB = **89 GB** combined *guest-addressable* capacity. The VDI files occupied approximately **5.87 + 64 = 69.87 GB** at inspection. The dynamic Ubuntu file could grow by up to roughly **19.13 GB**, excluding snapshot files and other overhead. The **72.02 GB free** on C: is a separate measured remaining-space figure and must **not** have 69.87 GB subtracted again. Space should be rechecked as snapshots accumulate.

### 3.3 Non-default settings, choices, and trade-offs

The VirtualBox wizard's exact initial defaults depend on OS profile and installed version. I did not save a before/after record of every wizard default, so I do **not** invent default numbers below.

| Setting | Common/default or alternative | Actual selection | Reason and trade-off |
|---|---|---|---|
| Networking | Ordinary NAT often defaults; Bridged is another choice | Shared **NAT Network** named `NatNetwork` | Both guests communicate while remaining behind NAT; unlike Bridged, they are not directly put on the physical LAN. |
| Ubuntu RAM | Depends on wizard profile | **2048 MB** | Lower memory burden than 4 GB; less room for heavier Linux workloads. |
| Ubuntu CPUs | Depends on wizard profile | **5 vCPUs** | This is the actual older VM configuration, not a proven optimum; fewer vCPUs may be enough for future rebuilds. |
| Windows RAM and CPU | Depends on Windows guest profile | **4096 MB, 2 vCPUs** | Meets the RAM/CPU baseline for this exercise but leaves limited room for heavy Windows applications. |
| Ubuntu disk | Fixed-size VDI is an alternative | **25 GB, dynamic** | Saves host disk space initially but can grow and exhaust free space. |
| Windows disk | Dynamic VDI is an alternative | **64 GB, fixed** | Uses 64 GB of host capacity immediately, but makes allocated host consumption predictable; the earlier draft incorrectly called it dynamic. |
| Windows firmware | Depends on guest profile/version | **UEFI, TPM 2.0, Secure Boot enabled** | Required Windows 11-capable configuration; these settings are shown in the actual Windows VM. |
| Manual installation | Unattended installer can pre-fill details | Manual steps described in BUILD.md | Easier for a beginner to understand and troubleshoot, but slower than automation. The original install flow was not screen-recorded. |
| DNS in Windows | Initially obtained DNS `192.168.0.1` | **Manually set 8.8.8.8** | The default DNS stopped answering in the observed session; public DNS resolved names, though an office may require an approved corporate DNS instead. |

### 3.4 Network checks, snapshots and what went wrong

**Guest-to-guest connectivity:** In the recorded tests, Ubuntu was `10.0.2.3` and Windows was `10.0.2.15`. Ubuntu → Windows and Windows → Ubuntu each received **4 of 4** ICMP replies with **0% loss**. These are addresses from the test session; DHCP may assign different addresses later.

**Internet connectivity:** The Windows proof file shows successful pings to `8.8.8.8` and `google.com`, **4/4 with 0% loss**, followed by a successful `nslookup google.com` against `8.8.8.8`. The Ubuntu console screenshots show a successful `google.com` test (4/4) and a later `8.8.8.8` test (4/4). One earlier Ubuntu `8.8.8.8` attempt received only **1/4** replies; the later retry succeeded. The compiled `05-ping-between-guests.txt` labels the Ubuntu internet portion as a **screenshot transcription**, because the original native Ubuntu TXT was not transferred to the submitted file.

**Actual problem and fix — Windows DNS:** Windows could ping a public IP address, but `ping google.com` failed. `nslookup google.com` using the initially configured DNS server **192.168.0.1** timed out. Querying **8.8.8.8** directly succeeded, so I set the Windows guest's `Ethernet` DNS server to **8.8.8.8**. A subsequent normal `nslookup google.com` and `ping -n 4 google.com` succeeded. This demonstrates a real problem, a targeted change, and a verification step. It does not prove why the original server stopped responding.

**Second problem — shared-folder transfer:** Copying the Ubuntu internet log to `/media/sf_Lab3Transfer/` initially returned `Permission denied`. The `vboxsf` group did not exist, so `usermod -aG vboxsf` did not work. `sudo cp` subsequently wrote the file to the shared-folder mount, but the configured Windows host path could not be opened from the host during this session. Therefore I cannot claim that the original Ubuntu TXT was delivered as evidence.

**Snapshots:** Ubuntu has a `clean-install` snapshot under previous `clean setup` and `Снимок 1` entries; the Windows `clean-install` snapshot was created on **10 November 2026** after setup and DNS testing. Both snapshots are visible with their VM names. **Creating snapshots is proven; restoring either snapshot has not been demonstrated.** No firewall change is claimed: both directions of the earlier ping test succeeded without a recorded need to modify Windows Firewall.

## 4. Evidence

The six required files are in `evidence/`. Screenshots with settings are from VirtualBox; command output comes from the guests. Descriptions below distinguish original evidence from a recreated illustration or a compiled text file.

| File | What it proves / limitation |
|---|---|
| [01-new-vm-wizard.png](evidence/01-new-vm-wizard.png) | **Composite of recreated wizard screens** showing how the Ubuntu configuration would be entered. **Not** a single original screenshot of the creation of the existing VM. |
| [02-disk-settings.png](evidence/02-disk-settings.png) | Actual `Linux Ubuntu.vdi`: 25 GB virtual capacity, approximately 5.87 GB occupied, dynamic VDI. Replaces the unrelated 40 GB `Dev-Test-Ubuntu-2` image. |
| [03-network-adapter.png](evidence/03-network-adapter.png) | Ubuntu adapter connected to NAT Network `NatNetwork`. |
| [04-guest-uname.txt](evidence/04-guest-uname.txt) | Ubuntu command lines and output for IP, kernel and OS release. |
| [05-ping-between-guests.txt](evidence/05-ping-between-guests.txt) | Both directions of guest-to-guest ping and Windows/Ubuntu internet checks. **Ubuntu internet section was transcribed from a real screenshot, not an original unedited terminal export.** |
| [06-snapshot-list.png](evidence/06-snapshot-list.png) | Ubuntu `clean-install` snapshot, with VM name visible; previous snapshots are retained. |

### Additional evidence

- [Windows clean-install snapshot](evidence/windows-snapshot-list.png) — Shows the `clean-install` snapshot for the `lab02-windows` virtual machine, with its name visible.

**Evidence limitations:** Restoring a snapshot was not tested; the exact installed VirtualBox build was not captured; the staged wizard composite is not proof of the original VM creation; and the Ubuntu internet portion of `05-ping-between-guests.txt` was transcribed from console screenshots rather than exported as an unedited terminal log. Additional Windows configuration screenshots were inspected during the work, but are not linked here because they were not added to the submitted `evidence/` folder.

## 5. What I would do differently

1. **Check the host first.** I would measure available RAM and free storage before choosing VM settings. My first documentation assumed 4 GB and 2 vCPUs per guest, which did not match the real Ubuntu allocation of 2 GB and 5 vCPUs.
2. **Use one naming scheme.** A prior screenshot belonged to `Dev-Test-Ubuntu-2` with a 40 GB disk, not the actual `Linux Ubuntu` VM with a 25 GB disk. I would always capture the selected VM name in the same screenshot.
3. **Record the complete tests while performing them.** I had to go back for internet pings and encountered a Windows DNS issue. Next time I would save unedited commands and output for both internet checks and guest-to-guest pings at the moment I run them.
4. **Create one clearly named snapshot for each guest early.** Ubuntu had multiple old names and Windows initially had no snapshot. I would label both baseline snapshots immediately after installation and test a harmless restore with work backed up first.
5. **Check each evidence link and disclose assistance.** I would verify every screenshot/file against the documented VM and put the required AI-use declaration in the repository's **root `README.md`**, not just inside the Ticket 1 folder.

---

**AI-use note for this Ticket 1 report:** ChatGPT assisted with explaining, organizing, and revising the documentation and with troubleshooting commands. VM settings, console screenshots, and observed test results were supplied by the student; a compiled transcription is explicitly labelled. **A separate AI-use table must also be placed in the repository's root `README.md` as the course instructions require.**
