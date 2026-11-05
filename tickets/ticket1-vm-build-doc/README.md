# Ticket 1 — New developer starts Monday, needs a test machine

> **DRAFT.** Every `[TODO: …]` needs your own real value or wording. Delete this note and every TODO marker before submitting.

## 1. What was asked

> **From:** Aigerim T. (Office Manager)
> **Subject:** test machine for new dev
>
> Hi, we have someone starting on Monday and he needs a test computer
> set up. Nothing special, just so he can try things without breaking
> anything. Can you write down how to do it so I can do the next one
> myself? Thanks

## 2. What was actually needed

### What the request left out

| Missing detail | What I would have asked Aigerim | What I assumed instead |
| :-- | :-- | :-- |
| Which OS the developer works on | "Linux, Windows, or both?" | Both: one Ubuntu guest and one Windows 11 guest. [TODO: your own reason] |
| Physical PC or virtual machine | "Can it be a virtual machine on a computer you already have?" | A VM. "Try things without breaking anything" means going back to a clean state in seconds (a snapshot), which a physical PC cannot do. |
| What the host can carry | "How much RAM and free disk does the host computer have?" | My host: 16 GB RAM, 12 logical CPUs, [TODO: free disk]. Sizing in 3.2. |
| Network needs | "Does the developer need internet? Must the two systems talk to each other?" | Yes to both. Plain NAT is out (guests cannot see each other); Bridged is out (exposes test machines to the office network). |
| Licences and money | "Who pays for Windows? How long is the machine needed?" | Free software only: Ubuntu LTS and Windows 11 Enterprise Evaluation. |
| Who follows the guide | "Has the reader ever used VirtualBox?" | No. BUILD.md is written for someone who has never opened a hypervisor. |

### Where the request is wrong or incomplete

- **"Nothing special."** Windows 11 will not install without UEFI and a TPM 2.0 chip. In a VM both must be switched on by hand, and this is exactly where a first-time reader gets stuck.
- **"So I can do the next one myself."** The Windows evaluation licence lasts 90 days. A machine the developer keeps longer needs a paid licence or a rebuild every 90 days, and Aigerim has to be told that now, not on day 91. [TODO: check what actually happens when the evaluation ends]
- **"Without breaking anything."** This is a rollback requirement, not only an isolation one. It is met by a clean snapshot, so BUILD.md has a step to take one and a step to go back to it.

### Licences

| Component | Licence | Consequence for Aigerim |
| :-- | :-- | :-- |
| Ubuntu 26.04.1 LTS | Free, open source | No cost, no subscription for this use. |
| Windows 11 Enterprise Evaluation | Free from Microsoft, 90 days, for testing only | Expires. Not for production. |
| Oracle VM VirtualBox 7.x | Free; open-source base package. The proprietary PUEL covers only the optional Extension Pack, which this build does not install. | No cost. [TODO: check the exact GPL version and your VirtualBox version at virtualbox.org/wiki/Licensing_FAQ] |

## 3. What I did

### 3.1 Steps in order

Full click-by-click version: [`BUILD.md`](./BUILD.md).

1. Checked the host (RAM, CPUs, free disk) and downloaded the three installers.
2. Created one shared NAT Network, `NatNetwork`.
3. Built the Ubuntu guest and attached it to `NatNetwork`.
4. Built the Windows 11 guest: UEFI and TPM 2.0 switched on, attached to `NatNetwork`.
5. Checked that both guests reach the internet and can see each other.
6. Took a `clean-install` snapshot of each guest.

[TODO: confirm this is the order you actually worked in]

### 3.2 Resources, calculated from the host

Host figures: **16 GB RAM** and **12 logical CPUs** (the maximums on the sliders in `evidence/01-new-vm-wizard.png`), and **[TODO: SSD size] total / [TODO: free] free** on the drive that holds the VM folder.

| | RAM | vCPUs | Disk, maximum (virtual size) | Disk, used right now |
| :-- | :-- | :-- | :-- | :-- |
| Ubuntu guest | 4096 MB | 2 | [TODO] GB | [TODO] GB |
| Windows 11 guest | 4096 MB | 2 | 64 GB | [TODO] GB |
| Left for the host | 16384 − 2 × 4096 = **8192 MB** | shared (see below) | [TODO: free space − worst case] GB | |

- **RAM.** The guests take 8 GB, half of the host. With a browser and editor open the host uses [TODO: measured GB, from Task Manager before starting the guests], so about [TODO] GB stay free. Giving each guest 8 GB would leave the host nothing and start swapping. 4 GB is the Windows 11 minimum and Ubuntu's recommended amount for a desktop.
- **CPUs.** Two vCPUs per guest is the Windows 11 minimum. vCPUs are threads scheduled on the host's 12 logical CPUs, not cores taken away from the host, so with both guests busy at most 4 of the 12 are in use.
- **Disk.** Both disks are dynamically allocated, so they grow only as files are written. Worst case, both fill up: [TODO: Ubuntu max] + 64 = **[TODO] GB**, which must be less than the [TODO] GB free. Measured actual sizes are in `evidence/` [TODO: add a Media Manager screenshot or `VBoxManage list hdds` output]. 64 GB for Windows is Microsoft's minimum storage for Windows 11. [TODO: Ubuntu's published minimum for 26.04, if you keep the 25 GB default]

### 3.3 Settings that differ from the default

Check the "Default" column against a fresh wizard on your own VirtualBox before submitting.

| Setting | Value used | Default | Why |
| :-- | :-- | :-- | :-- |
| Skip Unattended Installation | ticked | not ticked | I wanted to see every installer screen so the guide can describe it, and to set my own username and password. |
| Memory (each guest) | 4096 MB | [TODO] | See 3.2. |
| CPUs (each guest) | 2 | [TODO] | See 3.2. |
| Windows disk size | 64 GB | [TODO] | Windows 11 minimum. |
| UEFI (Windows) | on | [TODO: may be set automatically for "Windows 11"] | Windows 11 does not install in legacy BIOS mode. |
| TPM (Windows) | v2.0 | [TODO] | Windows 11 requires TPM 2.0. |
| Network, Attached to | NAT Network `NatNetwork` | NAT | Guests must see each other and still reach the internet. |
| Video memory / 3D acceleration (Windows) | [TODO] | [TODO] | [TODO: keep only if you can say what it fixed. If it fixed nothing, remove it from BUILD.md and this table.] |

Settings I deliberately left at the default: adapter type Intel PRO/1000 MT Desktop, promiscuous mode Deny, dynamic disk allocation (VDI).

### 3.4 Decisions and the alternatives I rejected

| Decision | Alternative | Why this one |
| :-- | :-- | :-- |
| NAT Network | Bridged | Bridged puts untrusted test machines on the office network and depends on the office DHCP server. [TODO: if your lab network filters by MAC address, say so: it is the stronger reason.] |
| NAT Network | Plain NAT | Plain NAT gives every guest the same address (10.0.2.15) behind its own gateway, so guests cannot reach each other. |
| Dynamic disk | Fixed size | Uses host disk only as it fills. Trade-off: the disk can grow later and must fit in the free space (3.2). |
| Evaluation Windows | Paid licence | Free for a test machine. Trade-off: 90 days. |
| Manual VirtualBox steps | Vagrant / scripts | Aigerim is not a developer. A script she cannot read or repair is worse for her than a document she can follow. |

### 3.5 One thing that went wrong

[TODO: replace this with the real problem you hit. A candidate that is already in your own notes: the first version of BUILD.md used plain NAT, so the two guests could not see each other; the fix was a shared NAT Network. Keep it only if that is what happened, and add what you saw (which command failed, with what output) and how you found the cause. If you had to allow ping through Windows Firewall, that is also a real problem worth writing up.]

## 4. Evidence

| File | What it proves |
| :-- | :-- |
| `evidence/01-new-vm-wizard.png` | Hardware step of the VM wizard: 4096 MB RAM, 2 CPUs. [TODO: retake so the VM name and OS are visible, and so it matches the VM it claims to document. EFI is unticked in the current screenshot, but BUILD.md tells the reader to tick it for Windows.] |
| `evidence/02-disk-settings.png` | Disk step: VDI, "Pre-allocate full size" unticked (dynamic). [TODO: the current screenshot is VM `Dev-Test-Ubuntu-2` at 40 GB, while the VM list shows `Linux Ubuntu.vdi` at 25 GB. Make the screenshot and the table in 3.2 describe the same VM.] |
| `evidence/03-network-adapter.png` | Ubuntu adapter 1 on NAT Network `NatNetwork`, MAC 08:00:27:70:CB:61, the same MAC as `altname enx08002770cb61` in file 04. [TODO: add the Windows guest's adapter.] |
| `evidence/04-guest-uname.txt` | Ubuntu guest: address 10.0.2.3/24, kernel 7.0.0-38, Ubuntu 26.04.1 LTS, with the commands that produced it. |
| `evidence/05-ping-between-guests.txt` | Ubuntu to Windows and Windows to Ubuntu, 4 of 4 replies, 0% loss. [TODO: add `ping 8.8.8.8` and `ping google.com` from both guests. The ticket requires proof of internet access as well as guest-to-guest.] |
| `evidence/06-snapshot-list.png` | Snapshot tree of the guest. [TODO: show the VM name; add the Windows guest's snapshots; explain why the baseline is `clean-install` rather than the earlier `clean setup`.] |

## 5. What I would do differently

[TODO: write these from what actually happened to you. Draft, to edit.]

1. Follow `BUILD.md` literally on a fresh VM before submitting. The week-5 review does exactly that, and the first version of my guide assumed `NatNetwork` already existed and never mentioned the firewall.
2. Measure the host before choosing numbers (idle RAM, free disk) and write the figures down at the time. I first assumed "8 GB for the host" instead of measuring it.
3. Name the machines and snapshots consistently from the start (`dev-test-ubuntu`, `dev-test-win11`, `clean-install`) and take the baseline snapshot immediately after the first clean install, not a week later.
4. Tell Aigerim about the 90-day Windows evaluation limit in the first message, not at the end of the guide.
