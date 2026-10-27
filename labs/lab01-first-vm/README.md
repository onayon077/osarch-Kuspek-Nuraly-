# Lab 1 — Your first virtual machine

**Pair:** Kuspek Nuraly (Solo)  
**Driver first half:** Kuspek Nuraly  
**Machine:** Laptop running Windows 11 (AMD Ryzen 5 7535HS, 6 cores/12 threads, 16 GB RAM), guest Ubuntu 26.04.1 LTS  
**Date:** 24.10.2026  

## What I did

1. Installed Oracle VirtualBox 7.2. Licence: [GPL 3.0](https://www.gnu.org/licenses/gpl-3.0.html).
2. Created VM `Linux Ubuntu`: 2 vCPU, 4 GB RAM, 25 GB dynamic disk, NAT network with SSH port forwarding (Host 2222 -> Guest 22).
3. Installed Ubuntu 26.04.1 LTS, verified SSH connectivity, and took snapshot `clean-install`.
4. Broke it: brought down the network interface (`sudo ip link set enp0s3 down`), causing network unreachability.
5. Rolled back to `clean-install`: restored snapshot `clean-install` in VirtualBox; verified network restoration inside the guest with `ping`.

## Resource justification

My physical host machine is equipped with an AMD Ryzen 5 7535HS processor (6 physical cores / 12 threads) and 16 GB of physical RAM running Windows 11. I allocated 2 vCPUs (16.6% of host logical execution threads) and 4 GB of RAM (25% of total system memory) to the virtual machine. This allocation is optimal for a headless Linux server running minimal CLI utilities without risking memory starvation or paging on the host OS, leaving 10 threads and 12 GB of RAM entirely free for Windows 11 background processes. A 25 GB dynamic virtual disk was selected to provision storage on demand while providing ample capacity for OS files and temporary packages.

## Result

The VM boots; the break-and-rollback cycle is shown in the evidence below.

## What did not work the first time

Initially, the VM configuration had 5 vCPUs assigned, and the fault was tested by modifying hostname configuration instead of breaking network connectivity. After restoring the clean snapshot, the VM CPU allocation was adjusted to 2 vCPUs to balance host resources, network breakdown was properly executed via `sudo ip link set enp0s3 down`, and network recovery was verified with ping after rollback.

## Evidence

* [evidence/vm-settings.png](evidence/vm-settings.png) — CPU (2 vCPU), memory (4 GB) and disk (25 GB) as configured
* [evidence/port-forwarding.png](evidence/port-forwarding.png) — Port forwarding rule (Host 2222 to Guest 22)
* [evidence/guest-release.txt](evidence/guest-release.txt) — Ubuntu 26.04.1 LTS running in the guest
* [evidence/broken.png](evidence/broken.png) — the guest in its broken state showing network failure
* [evidence/snapshot-list.png](evidence/snapshot-list.png) — the snapshot list after rollback
* [evidence/restored-check.png](evidence/restored-check.png) — ping check inside the guest confirming network restoration