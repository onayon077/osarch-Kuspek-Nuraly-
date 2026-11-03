# Ticket 1 — Multi-OS Development VM Architecture & Build Report

## 1. What was asked
> "Hi, we have someone starting on Monday and he needs a test computer set up. Nothing special, just so he can try things without breaking anything. Can you write down how to do it so I can do the next one myself? Thanks"  
> — Aigerim T. (Office Manager)

## 2. What was actually needed
* **What the request left out:**
  * Target OS architectures (developer requires testing across Linux and Windows environments).
  * Hypervisor choice, firmware baseline (UEFI/TPM 2.0 requirements for modern guests), and CPU virtualization acceleration.
  * Virtual network topology (isolated inter-guest communication vs. shared internet uplink).
  * Host resource sizing limits and point-in-time recovery strategy (snapshots).
* **Where the request is wrong:**
  * Implies bare-metal hardware setup, which lacks instant rollback capabilities after breaking experiments.
  * Assumes a plain NAT setup is sufficient; plain NAT isolates guests from each other under private namespaces, preventing guest-to-guest testing.
* **What I would have asked the requester:**
  1. What host hardware specs (CPU cores, RAM, free SSD space) are available on the physical machine?
  2. Does the workflow require testing multi-node network services or isolated desktop client behavior?
  3. Is Windows 11 Enterprise/Dev testing required alongside Linux?
* **What I assumed instead:**
  1. **Hypervisor:** Oracle VM VirtualBox 7.x with VT-x/AMD-V virtualization extensions enabled.
  2. **Dual-Guest Architecture:** 
     * Guest A: Ubuntu 26.04.1 LTS (Linux server/development stack).
     * Guest B: Windows 11 Evaluation (Client runtime with EFI & TPM 2.0).
  3. **Inter-Guest Connectivity:** Configured a dedicated `NatNetwork` (`10.0.2.0/24`) with internal DHCP enabled to allow bi-directional ICMP/TCP traffic between VMs while providing outbound internet access.
  4. **Host Resource Budget:** Dedicated 8 GB RAM and 4 vCPUs total from the host pool without starving host OS services.

### Host Sizing & Resource Allocation Matrix

| Parameter | Host Physical Total | VM 1: Ubuntu 26.04 LTS | VM 2: Windows 11 Eval | Total Allocated | Host Headroom (Free) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **RAM** | 16,384 MB (16 GB) | 4,096 MB (4 GB) | 4,096 MB (4 GB) | 8,192 MB (8 GB) | 8,192 MB (50%) |
| **vCPU** | 8 Cores / 16 Threads | 2 vCPUs | 2 vCPUs | 4 vCPUs | 12 Threads (75%) |
| **Disk Type** | 512 GB NVMe SSD | 40.00 GB Dynamically Allocated VDI | 64.00 GB Dynamically Allocated VDI | ~25 GB actual written | >400 GB |
| **Firmware** | BIOS / UEFI | Standard BIOS | UEFI (Special EFI enabled) + TPM 2.0 | — | — |
| **Network** | Physical NIC (Wi-Fi/Eth) | NAT Network (`NatNetwork`) | NAT Network (`NatNetwork`) | Shared Virtual Switch | Host bridge isolated |

## 3. What I did
1. **Virtual Infrastructure Preparation:**
   * Created a centralized virtual network `NatNetwork` via VirtualBox Network Manager (CIDR: `10.0.2.0/24`, DHCP active).
2. **Ubuntu 26.04 LTS Guest Provisioning:**
   * Sized VM with 4,096 MB RAM, 2 vCPUs, and a 40.00 GB dynamically expanding VDI disk.
   * Attached NIC 1 to `NatNetwork`.
   * Installed Ubuntu base packages and verified system identity (`uname -a`, `lsb_release -a`).
3. **Windows 11 Evaluation Guest Provisioning:**
   * Enabled **EFI (special OSes only)** and selected **TPM 2.0 (v2.0)** module in motherboard settings to satisfy Windows 11 installer checks.
   * Allocated 4,096 MB RAM, 2 vCPUs, and a 64.00 GB VDI drive.
   * Attached NIC 1 to the same `NatNetwork`.
4. **Inter-Guest Network Verification:**
   * Assigned IP `10.0.2.15` to Ubuntu and `10.0.2.16` to Windows 11.
   * Allowed ICMPv4 through Windows Defender Firewall (`netsh advfirewall firewall add rule name="ICMP Allow incoming V4 trace" protocol=icmpv4:8,any dir=in action=allow`).
   * Executed mutual ping checks confirming 0% packet loss.
5. **Baseline Snapshot Creation:**
   * Created baseline recovery states for both virtual machines labeled `clean-install`.
6. **Encountered Issues & Troubleshooting (What went wrong):**
   * *Issue 1 (Network Isolation):* Initial setup on default "NAT" prevented VMs from discovering and pinging each other because default NAT places each guest behind an isolated private gateway.  
     *Fix:* Switched both adapters from plain NAT to `NAT Network` named `NatNetwork`.
   * *Issue 2 (Windows Firewall blocking ICMP):* Ping from Ubuntu to Windows timed out despite valid DHCP leases.  
     *Fix:* Enabled File and Printer Sharing / ICMPv4 echo requests in Windows Defender Firewall rules.
   * *Issue 3 (Broken dependency test & Rollback):* Simulating a broken test script corrupting apt libraries, restored the Ubuntu VM back to `clean-install` snapshot within 10 seconds via VirtualBox Snapshot Manager.

## 4. Evidence
* [evidence/01-new-vm-wizard.png](evidence/01-new-vm-wizard.png) — Initial hardware wizard configuration (RAM and CPU sizing).
* [evidence/02-disk-settings.png](evidence/02-disk-settings.png) — Virtual disk configuration showing 40.00 GB dynamically allocated storage.
* [evidence/03-network-adapter.png](evidence/03-network-adapter.png) — Network adapter set to shared NAT Network mode.
* [evidence/04-guest-uname.txt](evidence/04-guest-uname.txt) — Log containing `uname -a` and `lsb_release -a` command output.
* [evidence/05-ping-between-guests.txt](evidence/05-ping-between-guests.txt) — Verified ping log between Ubuntu and Windows 11.
* [evidence/06-snapshot-list.png](evidence/06-snapshot-list.png) — Snapshot tree illustrating the `clean-install` baseline.

## 5. What I would do differently
In a production deployment, I would avoid manual GUI clicks completely by deploying an infrastructure-as-code workflow with **Vagrant + VirtualBox provider** or **Packer**, using predefined `Vagrantfile` configs to spin up both Ubuntu and Windows 11 with network bridges and provisioning scripts automatically.