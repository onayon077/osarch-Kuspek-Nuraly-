## Phase 3: Windows 11 Evaluation VM Provisioning

### Step 1: Hardware Wizard & TPM/UEFI Requirements
*Rationale: Windows 11 installation media enforces mandatory hardware checks for UEFI Secure Boot and a Trusted Platform Module (TPM 2.0). If these are not explicitly provisioned in VirtualBox, the installer will abort with an incompatibility error before disk partitioning begins.*

1. On the main VirtualBox toolbar, click **New** (or press `Ctrl + N`).
2. Configure basic machine attributes:
   * **Name:** `lab02-windows`
   * **Folder:** Leave default VM directory.
   * **ISO Image:** Browse and attach the Windows 11 Enterprise / Evaluation ISO image.
   * **Type:** `Microsoft Windows`
   * **Version:** `Windows 11 (64-bit)`
   * Check **Skip Unattended Installation** to retain full manual control over user creation and storage configuration.
3. Click **Next** to proceed to hardware sizing:
   * **Base Memory:** Set to `4096 MB` (4 GB) to prevent memory ballooning and ensure adequate OS caching.
   * **Processors:** Assign `2 CPUs` (virtual cores) to maintain fluid background task execution.
   * Check the box for **Enable EFI (special OSes only)**.
4. Open the VM system properties (**Settings** -> **System** -> **Motherboard** tab):
   * Verify **Boot Order:** Optical drive first, Hard Disk second, Floppy disabled.
   * Ensure **TPM Version** is set to **v2.0**.
   * Under the **Processor** tab, ensure **Enable PAE/NX** is checked.
5. In **Display** settings:
   * Increase **Video Memory** to `128 MB`.
   * Set **Graphics Controller** to `VBoxSVGA` and enable **3D Acceleration** for smoother interface rendering.

### Step 2: Virtual Hard Disk Configuration
1. In the virtual drive creation dialog, choose **Create a Virtual Hard Disk Now**.
2. Set the capacity to **64.00 GB** (sufficient for Windows 11 core system files, pagefile, and testing utilities).
3. Select **VDI (VirtualBox Disk Image)** file type.
4. Ensure **Pre-allocate Full Size** remains unchecked, allowing the host SSD to store only actual written data rather than consuming 64 GB immediately.
5. Confirm by clicking **Finish**.

### Step 3: Network Interface Assignment
1. Highlight `lab02-windows` in the VirtualBox Manager and open **Settings** (`Ctrl + S`).
2. Navigate to the **Network** category -> **Adapter 1** tab.
3. Check **Enable Network Adapter**.
4. Set **Attached to** to **NAT Network**.
5. Select `NatNetwork` from the **Name** dropdown list.
6. Expand the **Advanced** section:
   * **Adapter Type:** Keep default `Intel PRO/1000 MT Desktop (82540EM)`.
   * **Promiscuous Mode:** `Deny`.
   * Ensure **Cable Connected** is checked.
7. Click **OK** to save configuration changes.

### Step 4: Windows 11 Installation & Local Account Creation
1. Start the VM. When the prompt `"Press any key to boot from CD or DVD..."` appears, press any key immediately to enter the Windows setup environment.
2. Select language, time, and keyboard layout preferences, then click **Next** -> **Install Now**.
3. If prompted for a product key, select **I don't have a product key** (or pick the Windows 11 Enterprise/Pro Evaluation edition).
4. Accept the Microsoft Software License Terms and click **Next**.
5. Choose **Custom: Install Windows only (advanced)**.
6. Select the 64.0 GB unallocated drive and click **Next** without creating manual partitions; the Windows installer will automatically generate the required EFI System Partition (ESP), MSR, and Primary NTFS volume.
7. Wait for file copying, installation, and initial system reboot.
8. Complete the Out-of-Box Experience (OOBE):
   * Select Country/Region and Keyboard Layout.
   * To create an offline local account without a mandatory Microsoft account, when prompted for sign-in, press `Shift + F10` to open Command Prompt, type `oobe\bypassnro`, and press `Enter`. The VM will reboot.
   * After reboot, click **I don't have internet** at the network screen, select **Continue with limited setup**, and define the local username (e.g., `User` or `Tester`) and password.

### Step 5: VirtualBox Guest Additions & System Validation
1. Once on the Windows desktop, mount the guest integrations via the top VirtualBox menu: **Devices** -> **Insert Guest Additions CD Image...**.
2. Open File Explorer, browse to the virtual CD drive, run `VBoxWindowsAdditions.exe`, and complete the setup wizard to install dynamic display drivers and shared clipboard components.
3. Reboot the guest operating system.
4. Open Windows PowerShell and run `ipconfig` to verify IP lease acquisition from `NatNetwork` (assigned address in range `10.0.2.x`).