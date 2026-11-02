# Lab 02: Windows Guest, Network Both Ways, Overcommitment

## Student Information
- **Name:** Kuspek Nuraly
- **Date:** 2026-10-31

---

## 1. Network Mode & Architectural Rationale

### Selected Mode: NAT Network (`NatNetwork`)
We configured Oracle VirtualBox using the **NAT Network** mode rather than standard per-VM NAT, Bridged, or Host-Only adapters:

- **Why standard NAT was not chosen:** Under default NAT, each VM resides behind its own separate, isolated NAT gateway. Direct guest-to-guest IP communication is impossible without defining manual port-forwarding rules on the host.
- **Why Bridged Adapter was avoided:** Bridged networking assigns each guest directly to the physical LAN. On many university/campus Wi-Fi or secured enterprise networks, strict MAC address filtering, 802.1X security, or router DHCP policies block guest VMs from acquiring IP addresses.
- **Why NAT Network fits all requirements:** A shared NAT Network creates an internal virtual software bridge with an integrated DHCP server (`10.0.2.0/24`). Both guest VMs obtain IP leases within the exact same broadcast and routing domain, enabling bidirectional peer-to-peer traffic while routing external packets through a shared host NAT interface for outbound internet connectivity.

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
                 +---------------------------------------------+
                        |                               |
        [ IP: 10.0.2.3/24 ]             [ IP: 10.0.2.15/24 ]
        [ enp0s3          ]             [ Ethernet         ]
                |                               |
+-------------------------------+   +-------------------------------+
|     Guest 1: Ubuntu Linux     |   |    Guest 2: Windows 11 VM     |
|   Ubuntu 26.04.1 LTS (tty1)   |<->| Windows 11 Enterprise (Eval)  |
|   2 vCPU | 2 GB RAM (base)    |   | 2 vCPU | 4 GB RAM (base)      |
+-------------------------------+   +-------------------------------+
                \                               /
                 \-----> [ Internet Gateway ] <
                         ping ubuntu.com (OK)