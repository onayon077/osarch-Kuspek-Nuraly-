# IFT 103 — Operating System Architecture

**Student:** Nuraly Kuspek  
**Course:** IFT 103 — Operating System Architecture  
**Environment:** Windows 11, Ubuntu Server, Oracle VirtualBox  
**Repository:** [osarch-Kuspek-Nuraly-](https://github.com/onayon077/osarch-Kuspek-Nuraly-)

This repository contains laboratory reports, supporting evidence, and technical documentation for the Operating System Architecture course.

## Laboratory work

| Lab | Topic | Open |
| --- | --- | --- |
| **Lab 01** | First virtual machine | [Open Lab 01](labs/lab01-first-vm/) |
| **Lab 02** | Windows guest, networking, and overcommitment | [Open Lab 02](labs/lab02-windows-vm/) |
| **Lab 03** | Hardware teardown and system information | [README](labs/lab03-teardown/README.md) · [Evidence](labs/lab03-teardown/evidence/) |
| **Lab 04** | Partitioning, RAID 1, failure, and recovery | [README](labs/lab04-storage/README.md) · [Evidence](labs/lab04-storage/evidence/) |
| **Lab 05** | Encoding forensics and CSV repair | [README](labs/lab05-encoding/README.md) · [Evidence](labs/lab05-encoding/evidence/) |
| **Lab 06** | Live processes and memory pressure | [README](labs/lab06-processes/README.md) · [Evidence](labs/lab06-processes/evidence/) |

## Support ticket

| Ticket | Topic | Documentation |
| --- | --- | --- |
| **Ticket 01** | Reproducible virtual-machine test environment | [README](tickets/ticket1-vm-build-doc/README.md) · [BUILD.md](tickets/ticket1-vm-build-doc/BUILD.md) · [Evidence](tickets/ticket1-vm-build-doc/evidence/) |

You can also [browse all tickets](tickets/).

## Selected evidence

### Lab 04 — Storage and RAID

- [Windows disk/partition output](labs/lab04-storage/evidence/lab04-windows.txt)
- [Linux disks — before](labs/lab04-storage/evidence/lsblk-before.txt)
- [RAID 1 — healthy](labs/lab04-storage/evidence/array-healthy.txt)
- [Checksum — before failure](labs/lab04-storage/evidence/checksum-before.txt)
- [RAID 1 — degraded](labs/lab04-storage/evidence/array-degraded.txt)
- [Checksum — after failure](labs/lab04-storage/evidence/checksum-after-failure.txt)
- [RAID 1 — rebuilt](labs/lab04-storage/evidence/array-rebuilt.txt)
- [Linux disks — after](labs/lab04-storage/evidence/lsblk-after.txt)

### Lab 06 — Processes and memory pressure

- [Windows Task Manager](labs/lab06-processes/evidence/task-manager.png)
- [Windows Process Explorer](labs/lab06-processes/evidence/process-explorer.png)
- [Linux htop](labs/lab06-processes/evidence/htop.png)
- [Linux memory-pressure log](labs/lab06-processes/evidence/memory-pressure.txt)
- [Linux kernel log extract](labs/lab06-processes/evidence/kernel-log-extract.txt)
- [Windows Event Viewer](labs/lab06-processes/evidence/windows-event-viewer.png)
- [Windows PowerShell original output](labs/lab06-processes/evidence/windows-powershell-original.png)

## How to use this repository

1. Choose a laboratory or ticket from the tables above.
2. Read the corresponding `README.md` for the steps, results, and explanations.
3. Open its `evidence/` folder to inspect screenshots and command outputs.
4. For Ticket 01, follow `BUILD.md` for the virtual-machine setup instructions.

**Note:** GitHub links are case-sensitive and require the linked files to exist. Lab 01 and Lab 02 folder paths use the exact URLs provided for this repository.

## AI assistance disclosure

ChatGPT was used to help organize Markdown documentation, navigation, and explanatory text. Commands, screenshots, and results should be checked against the actual environment.
