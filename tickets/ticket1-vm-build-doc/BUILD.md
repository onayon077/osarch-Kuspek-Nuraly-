# VM Build Document: Test Machine Setup Guide

This guide is written for setting up a developer test environment from scratch using Oracle VM VirtualBox.

---

## Prerequisites
* Download and install **Oracle VM VirtualBox**: [virtualbox.org](https://www.virtualbox.org)
* Download the **Ubuntu 26.04 LTS ISO** installation image.  
  *(Why LTS: Long Term Support releases receive verified security patches and do not introduce unexpected breaking updates).*

---

## Step 1. Create the Virtual Machine
1. Open VirtualBox and click the blue **New** button.
2. Enter the VM Name: `Linux Ubuntu`.
3. Set **Base Memory** to `4096 MB` (4 GB) and **Processors** to `2 CPUs`.

![](evidence/01-new-vm-wizard.png)

> **Why this setting:** Modern development tools and web browsers require at least 4 GB of RAM to run without freezing. Allocating 4 GB leaves sufficient RAM on your physical computer so the host operating system remains responsive.

---

## Step 2. Configure Virtual Hard Disk
1. Choose **Create a Virtual Hard Disk Now**.
2. Select **VDI (VirtualBox Disk Image)** format.
3. Make sure the box for **Pre-allocate Full Size** is unchecked (Dynamically allocated).
4. Set the disk size to **25.00 GB** and click **Finish**.

![](evidence/02-disk-settings.png)

> **Why dynamically allocated:** A fixed disk would instantly consume 25 GB of your physical drive. A dynamically allocated disk only uses actual written data space on your drive and expands as needed up to 25 GB.

---

## Step 3. Configure the Network Adapter
1. Select the virtual machine and click **Settings** -> **Network**.
2. Under **Adapter 1**, ensure **Enable Network Adapter** is checked.
3. For **Attached to:**, select **NAT**. Click **OK**.

![](evidence/03-network-adapter.png)

> **Why NAT instead of Bridged:** Our network filters traffic by MAC address on physical switch ports. A "Bridged" adapter generates a separate virtual MAC address which the router drops. Under NAT, the virtual machine shares the physical host computer's authenticated address, giving internet access immediately.

---

## Step 4. Verification & Baseline Snapshot
1. Launch the machine, log in, and run the following command in the terminal to verify internet connectivity:
   ```bash
   ping -c 4 8.8.8.8