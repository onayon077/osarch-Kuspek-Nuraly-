# Lab 0 — Inventory your own machine

Author: Nuraly Kuspek (Solo)
Machine: Laptop, Windows 11
Date: 20.10.2026

## What I did
1. Determined CPU model, physical core count, logical thread count, and verified hardware virtualization support via PowerShell CLI.
2. Retrieved total RAM capacity, physical slot count, installed module count, and operational frequency.
3. Identified storage drive model, bus/media type (NVMe SSD), and measured the actual free space on volume C:.
4. Verified the system firmware interface (UEFI) along with BIOS version and release date.
5. Exported raw CLI execution outputs into `evidence/cpu.txt`, `evidence/memory.txt`, and `evidence/disk.txt`.

## Inventory

| What | Value | Where I got it |
| :--- | :--- | :--- |
| **CPU model** | AMD Ryzen 5 7535HS with Radeon Graphics | `Get-CimInstance Win32_Processor \| Select-Object Name` |
| **CPU core count** | 6 | `Get-CimInstance Win32_Processor \| Select-Object NumberOfCores` |
| **CPU thread count** | 12 | `Get-CimInstance Win32_Processor \| Select-Object NumberOfLogicalProcessors` |
| **Total memory** | 16 GB (17,179,869,184 bytes) | `Get-CimInstance Win32_PhysicalMemory \| Select-Object Capacity` |
| **Number of installed modules** | 1 module (DIMM 0) | `Get-CimInstance Win32_PhysicalMemory \| Select-Object DeviceLocator` |
| **Memory speed** | 5600 MT/s | `Get-CimInstance Win32_PhysicalMemory \| Select-Object Speed` |
| **Disk model** | KINGSTON OM8SEP4512Q-AA | `Get-PhysicalDisk \| Select-Object FriendlyName` |
| **Disk type** | NVMe SSD | `Get-PhysicalDisk \| Select-Object MediaType, BusType` |
| **Free space on volume C:** | ~148.89 GiB (159,869,906,944 bytes) | `Get-Volume \| Select-Object DriveLetter, SizeRemaining` |
| **Firmware type** | UEFI | `$env:firmware_type` |
| **Firmware version and date** | Version: V1.20, Date: 10/23/2025 | `Get-CimInstance Win32_BIOS \| Select-Object SMBIOSBIOSVersion, ReleaseDate` |
| **Hardware virtualization** | Present and Enabled (True) | `Get-CimInstance Win32_Processor \| Select-Object VirtualizationFirmwareEnabled` |

## Result
All specifications were retrieved strictly from the command line without opening graphical system utilities. The host machine runs an AMD Ryzen 5 7535HS with 6 cores and 12 threads. Memory consists of a single 16 GB DDR5 module in slot DIMM 0 running at 5600 MT/s, confirming an open slot remains for future hardware upgrades. Storage is backed by a Kingston NVMe SSD with ~148.9 GB of free space on partition C:. Hardware virtualization is enabled at the firmware level, confirming system readiness for hypervisors.

## What did not work the first time
- **What I saw:** Standard drive queries (`Get-Disk` or `Win32_DiskDrive`) returned total drive capacity rather than available free space. In addition, general OS memory commands reported total memory without revealing physical module count.
- **What it turned out to be:** Disk capacity refers to the entire hardware drive, whereas free space belongs to a mounted logical volume. Similarly, logical system memory abstracts away the physical slot topology.
- **What I
