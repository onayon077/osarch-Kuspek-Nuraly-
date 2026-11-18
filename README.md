# IFT 103 — Operating System Architecture

**Student:** Nuraly Kuspek  
**Course:** IFT 103 — Operating System Architecture  
**Environment:** Windows 11, Ubuntu Server, Oracle VirtualBox  
**Repository purpose:** Laboratory reports, technical evidence, and support tickets.

## Repository navigation

This is the main index for the course repository. Select a report to view its explanation, results, and evidence. Links below are **relative to the repository root** and work on GitHub when the corresponding files have been committed and pushed.

### Laboratory work

| Lab | Topic | Report | Evidence folder |
| --- | --- | --- | --- |
| Lab 01 | First virtual machine | [Open Lab 01](labs/lab01/README.md) | [Files](labs/lab01/evidence/) |
| Lab 02 | Windows guest, networking, and overcommitment | [Open Lab 02](labs/lab02/README.md) | [Files](labs/lab02/evidence/) |
| Lab 03 | Hardware teardown and system information | [Open Lab 03](labs/lab03-teardown/README.md) | [Files](labs/lab03-teardown/evidence/) |
| Lab 04 | Partitioning, RAID 1, failure, and recovery | [Open Lab 04](labs/lab04-storage/README.md) | [Files](labs/lab04-storage/evidence/) |
| Lab 05 | Encoding forensics and CSV repair | [Open Lab 05](labs/lab05-encoding/README.md) | [Files](labs/lab05-encoding/evidence/) |
| Lab 06 | Live processes and memory pressure | [Open Lab 06](labs/lab06-processes/README.md) | [Files](labs/lab06-processes/evidence/) |

### Support tickets

| Ticket | Topic | Documentation | Evidence |
| --- | --- | --- | --- |
| Ticket 01 | Reproducible virtual-machine test environment | [Report](tickets/ticket1-vm-build-doc/README.md) · [Build guide](tickets/ticket1-vm-build-doc/BUILD.md) | [Files](tickets/ticket1-vm-build-doc/evidence/) |

## Selected evidence

These direct links provide quick access to important files. The detailed evidence tables remain in each lab's own `README.md`.

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

1. Open a laboratory or ticket from the tables above.
2. Read its `README.md` for the procedure, observations, results, and limitations.
3. Open the linked `evidence/` files for the actual screenshots, command output, and data.
4. For Ticket 01, use `BUILD.md` for the step-by-step virtual-machine setup guide.

**Note about links:** GitHub can only open a link if its target has been pushed to the repository with the **exact same path and filename**, including capitalization. If Lab 01 or Lab 02 has a longer local folder name, update those two table rows to match. This index does not replace the individual lab reports.

## AI assistance disclosure

ChatGPT was used to help organize Markdown documentation, navigation, and some explanatory text. Lab commands, screenshots, and outputs should be checked against the actual environment; assistance with documentation does not constitute independent verification of technical evidence.
