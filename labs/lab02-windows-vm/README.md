# Lab 02: Windows Guest, Network Both Ways, Overcommitment

## Student Information
- **Name:** Kuspek Nuraly
- **Date:** 2026-10-31

---

## 1. Network Mode & Architectural Rationale

### Selected Mode: NAT Network (`NatNetwork`)
Oracle VirtualBox was configured using the shared **NAT Network** mode instead of standard per-VM NAT, Bridged, or Host-Only adapters:

- **Why standard NAT was not chosen:** Under default NAT, each VM sits behind its own independent, isolated NAT gateway engine. Both VMs would typically be assigned the duplicate address `10.0.2.15` in isolated subnets, rendering direct guest-to-guest IP communication impossible without configuring host port-forwarding rules.
- **Why Bridged Adapter was avoided:** Bridged networking attaches each virtual network interface directly to the physical host network. On strict campus, enterprise, or Wi-Fi networks, MAC filtering, 802.1X authentication, or router DHCP leasing limits often prevent secondary virtual interfaces from obtaining IP addresses.
- **Why NAT Network fits all requirements:** A shared NAT Network creates an internal virtual software bridge with an integrated VirtualBox DHCP service (`10.0.2.0/24`). Both guest machines receive unique dynamic IP leases in the same subnet (`10.0.2.3` and `10.0.2.15`), permitting bidirectional peer-to-peer traffic while forwarding outbound traffic via the host's network adapter to the internet.

---

## 2. Network Diagram

```text
               +-------------------------------------------------+
               |                  Host Machine                   |
               |             Windows 11 (16.0 GB RAM)            |
               +-------------------------------------------------+
                                        |
                            [ VirtualBox Hypervisor ]
                                        |
                 +---------------------------------------------+
                 |       VirtualBox NAT Network (NatNetwork)   |
                 |      Subnet: 10.0.2.0/24 | DHCP: Enabled    |
                 |      Gateway / DNS: 10.0.2.1                |
                 +---------------------------------------------+
                        |                               |
        [ IP: 10.0.2.3/24 ]             [ IP: 10.0.2.15/24 ]
        [ Interface: enp0s3 ]           [ Adapter: Ethernet ]
                |                               |
+-------------------------------+   +-------------------------------+
|     Guest 1: Ubuntu Linux     |   |    Guest 2: Windows 11 VM     |
|   Ubuntu 24.04/26.04 LTS      |<->|   Windows 11 Evaluation       |
|   2 vCPU | 2 GB RAM (base)    |   |   2 vCPU | 4 GB RAM (base)    |
+-------------------------------+   +-------------------------------+
                \                               /
                 \-----> [ Internet Gateway ] <
                         ping ubuntu.com (OK)
```

---

## 3. Windows Firewall Rule (ICMPv4)

### Problem
The first ping test from Windows to Ubuntu succeeded. However, the ping from Ubuntu (`10.0.2.3`) to Windows (`10.0.2.15`) initially failed: all 4 packets were lost. This indicated that Windows was not responding to inbound ICMP echo requests, consistent with the inbound Windows Defender Firewall rule blocking ping requests.

### Rule required
To allow Ubuntu to ping the Windows guest, create an inbound rule for ICMPv4 Echo Request. Run PowerShell **as Administrator** inside the Windows guest:

```powershell
New-NetFirewallRule -DisplayName "Allow ICMPv4 Echo Request" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow
```

This command creates an inbound firewall exception for ICMPv4 echo requests. The supplied ping log shows that the Ubuntu-to-Windows test succeeded after the firewall change: 4 packets received and 0% packet loss. The uploaded evidence does not contain the original command or a screenshot of the rule itself; the command above documents how to create the required rule.

---

## 4. Host Memory Usage: Before and After

The Windows Task Manager screenshots show host memory usage before and after the virtual-machine workload.

| Measurement | Before | After |
|---|---:|---:|
| Installed memory | 16.0 GB DDR5 | 16.0 GB DDR5 |
| Usable memory shown by Task Manager | 15.3 GB | 15.3 GB |
| Memory in use | 9.4 GB | 13.8 GB |
| Memory usage | 61% | 90% |
| Available memory | 5.9 GB | 1.5 GB |

**Change:** Memory in use increased by approximately **4.4 GB**, and usage rose by **29 percentage points**. Available memory decreased by approximately **4.4 GB**.

### Evidence screenshots

**Before:**

![Host memory before the VM workload](host-memory-before.png)

**After:**

![Host memory after the VM workload](host-memory-after.png)

These screenshots record host RAM usage at two points in time. They demonstrate increased memory pressure during the workload; by themselves, they do not establish that the host ran out of memory or that paging occurred.

---

## 5. What Did Not Work

1. **Ubuntu to Windows ping before the firewall change:** The command `ping -c 4 10.0.2.15` transmitted 4 packets and received none (100% packet loss). After the inbound ICMPv4 firewall rule was added, all 4 packets received replies (0% packet loss).
2. **Internet ping from Windows was not completely successful:** The Windows test to `ubuntu.com` received 3 of 4 replies (25% packet loss). The reported reply times were 2265–3286 ms, which were unusually high in this test.
3. **Internet ping from Ubuntu was slow:** Ubuntu received all 4 replies from `ubuntu.com` (0% packet loss), but the reported round-trip times were 6787–8878 ms. Connectivity worked, but response times were very high.
4. **Host memory availability decreased:** Task Manager showed 5.9 GB available before and 1.5 GB after the workload. The host was using 90% of the usable memory in the after screenshot, so memory headroom was substantially lower.

### Overall result
The two guest machines were assigned different IP addresses in the same NAT Network subnet. Bidirectional guest-to-guest ping worked after allowing inbound ICMPv4 Echo Request traffic in the Windows firewall. Internet connectivity was demonstrated from both guests, although the recorded internet ping tests had high latency and the Windows test also had packet loss. Host memory usage increased from 61% to 90% during the measured workload.

---

## 6. Evidence Files

- `ip-addr-linux.txt` — Ubuntu network interface and IP address.
- `ipconfig-windows.txt` — Windows guest IP configuration.
- `ping-both-ways.txt` — guest-to-guest ping tests before and after the firewall change, plus internet ping tests.
- `host-memory-before.png` and `host-memory-after.png` — Task Manager memory screenshots.
