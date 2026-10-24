# Lab 1 — Your first virtual machine

**Pair:** Kuspek Nuraly (Solo)
**Driver first half:** Kuspek Nuraly
**Machine:** Laptop running Windows 11 (4 cores/8 threads, 16 GB RAM), guest Ubuntu 26.04.1 LTS
**Date:** 24.10.2026

## What I did

1. Installed Oracle VirtualBox 7.2. Licence: [GPL 3.0](https://www.gnu.org/licenses/gpl-3.0.html).
2. Created VM `lab01-ubuntu`: 2 vCPU, 4 GB RAM, 25 GB dynamic disk, NAT network with SSH port forwarding (Host 2222 -> Guest 22).
3. Installed Ubuntu 26.04.1 LTS, verified SSH connectivity, and took snapshot `clean-install`.
4. Broke it: broke network configuration using Netplan / link down command, making guest network unreachable.
5. Rolled back to `clean-install`: restored snapshot `clean-install` in VirtualBox; verified network restoration and SSH access.

## Resource justification

My physical host machine is equipped with a 4-core/8-thread CPU and 16 GB of physical RAM running Windows 11. I allocated 2 vCPUs (25% of host logical cores) and 4 GB of RAM (25% of total system memory) to the virtual machine. This allocation is optimal for a headless Linux server running minimal CLI utilities and background daemons without risking memory starvation or paging on the host OS, leaving enough physical cores and 12 GB of RAM entirely free for Windows 11 background processes. A 25 GB dynamic virtual disk was selected so that the VM only consumes disk space on demand while providing ample capacity for OS files and temporary packages.

## Result

The VM boots; the break-and-rollback cycle is shown in the evidence below.

## What did not work the first time

During the initial setup and SSH forwarding configuration, duplicate file extensions (e.g., double `.png.png` extensions) occurred during evidence file naming in Windows Explorer. In addition, command chaining during remote output redirection required precise path adjustments to correctly stream `lsb_release -a` into `labs/lab01-first-vm/evidence/guest-release.txt`. After renaming files directly via shell commands and checking the relative working directory, the evidence was properly recorded and snapshot rollback verified.

## Evidence

* [evidence/port-forwarding.png](evidence/port-forwarding.png) — Port forwarding rule (Host 2222 to Guest 22)
* [evidence/guest-release.txt](evidence/guest-release.txt) — Ubuntu 26.04.1 LTS is running in the guest
* [evidence/broken.png](evidence/broken.png) — the guest in its broken state showing network failure
* [evidence/snapshot-list.png](evidence/snapshot-list.png) — the snapshot list, after the rollback