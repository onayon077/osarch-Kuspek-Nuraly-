# IFT 103 — Operating System Architecture

**Student:** Nuraly Kuspek  
**Course:** IFT 103 — Operating System Architecture  
**Environment:** Windows 11, Ubuntu Server, Oracle VirtualBox, Git Bash  
**Repository:** [osarch-Kuspek-Nuraly-](https://github.com/onayon077/osarch-Kuspek-Nuraly-)

This repository contains my laboratory assignments, support tickets, technical reports, and evidence for the Operating System Architecture course. Each task has its own folder with instructions, results, and supporting files.

## Laboratory work

| Lab | Topic | Report / files | Evidence |
|---|---|---|---|
| **Lab 01** | First virtual machine | [Open Lab 01](labs/lab01-first-vm/) | [Lab 01 folder](labs/lab01-first-vm/) |
| **Lab 02** | Windows virtual machine, networking, and resource allocation | [Open Lab 02](labs/lab02-windows-vm/) | [Lab 02 folder](labs/lab02-windows-vm/) |
| **Lab 03** | Hardware teardown and system information | [README](labs/lab03-teardown/README.md) | [Evidence](labs/lab03-teardown/evidence/) |
| **Lab 04** | Partitioning, RAID 1, failure, and recovery | [README](labs/lab04-storage/README.md) | [Evidence](labs/lab04-storage/evidence/) |
| **Lab 05** | Encoding forensics and CSV repair | [README](labs/lab05-encoding/README.md) | [Evidence](labs/lab05-encoding/evidence/) |
| **Lab 06** | Live processes and memory pressure | [README](labs/lab06-processes/README.md) | [Evidence](labs/lab06-processes/evidence/) |

> Lab 01 and Lab 02 link to their **folders**, not to incorrectly formed `blob` URLs. Open each folder to see the files stored there.

## Support tickets

| Ticket | Topic | Documentation | Evidence |
|---|---|---|---|
| **Ticket 01** | Reproducible virtual-machine test environment | [README](tickets/ticket1-vm-build-doc/README.md) · [BUILD.md](tickets/ticket1-vm-build-doc/BUILD.md) | [Evidence](tickets/ticket1-vm-build-doc/evidence/) |
| **Ticket 02** | Four office computer specifications within a 3,000,000 KZT budget | [README](tickets/ticket2-office-spec/README.md) · [builds.md](tickets/ticket2-office-spec/builds.md) · [budget.csv](tickets/ticket2-office-spec/budget.csv) | [Evidence](tickets/ticket2-office-spec/evidence/) |

### Ticket 02 — Additional resources

- [PCPartPicker comparison and compatibility notes](tickets/ticket2-office-spec/evidence/pcpartpicker-links.md)
- [Vendor price screenshots and ready-made PC comparisons](tickets/ticket2-office-spec/evidence/vendor-quotes/)
- [Accountant PCPartPicker build](https://pcpartpicker.com/list/pDF5R4)
- [Sales Manager PCPartPicker build](https://pcpartpicker.com/list/3xj9R4)
- [Web Developer PCPartPicker build](https://pcpartpicker.com/list/VLBtNp)
- [Designer PCPartPicker build](https://pcpartpicker.com/list/Hvk3sK)

The Ticket 02 custom-build proposal totals **2,700,510 KZT** for four computers, including monitors and Windows licenses. This leaves **299,490 KZT** of the 3,000,000 KZT budget, based on prices recorded on **24 November 2026**. See its `README.md` and `budget.csv` for the detailed breakdown and purchasing limitations.

## Selected technical evidence

- **Lab 03:** Windows and Ubuntu system hardware information, and component photographs — [Evidence](labs/lab03-teardown/evidence/)
- **Lab 04:** Disk partitions, healthy/degraded/rebuilt RAID 1, and checksum verification — [Evidence](labs/lab04-storage/evidence/)
- **Lab 05:** Character encoding investigations and repaired CSV files — [Evidence](labs/lab05-encoding/evidence/)
- **Lab 06:** Windows Task Manager, Process Explorer, Ubuntu `htop`, memory-pressure logs, and system event logs — [Evidence](labs/lab06-processes/evidence/)

## How to use this repository

1. Select a lab or ticket from the tables above.
2. Open its `README.md` (or folder) to read the assignment and results.
3. Open the `evidence/` folder for screenshots, command output, and source material.
4. For **Ticket 01**, follow `BUILD.md` for the virtual-machine setup steps.
5. For **Ticket 02**, review `builds.md`, `budget.csv`, and the PCPartPicker documentation together.

## AI assistance disclosure

ChatGPT was used to help structure and edit Markdown documents, explain technical concepts and compatibility warnings, review calculations, and improve the clarity of the written reports. Screenshots and other evidence document the student's own work. Technical details, prices, and compatibility still require verification against the actual tools, local vendors, and submitted evidence.

---

**Author:** Nuraly Kuspek  
**Course:** IFT 103 — Operating System Architecture
