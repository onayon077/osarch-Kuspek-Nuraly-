# PCPartPicker Links - Ticket 2

**Student:** Nuraly Kuspek  
**Date checked:** 2026-11-24  
**Project:** New office computers (four different roles)

PCPartPicker is used here to check the main hardware choices, connectors, and estimated power. The final parts and prices in Kazakhstan are documented in `../builds.md`, `../budget.csv`, and `vendor-quotes/`. **Do not use the US dollar prices from PCPartPicker as the Kazakhstan budget.** Some listed parts are substitutes because the exact Shop.kz models are not present in the PCPartPicker catalog.

## Build 1 - Accountant

**List:** https://pcpartpicker.com/list/pDF5R4

- CPU: AMD Ryzen 5 5600GT (integrated graphics, no dedicated GPU)
- CPU cooler: DeepCool AG200
- Motherboard: MSI A520M-A PRO (AM4)
- Memory: Corsair Vengeance LPX 16 GB (2 x 8 GB), DDR4-3200 CL16, as a substitute for Hiksemi Sword 16 GB (2 x 8 GB)
- SSD: Kingston NV3 1 TB M.2 NVMe
- Case: Cooler Master MasterBox Q300L, as a substitute for 1Stplayer DK-3-BK
- PSU: DeepCool PF500 500 W, as a substitute for DeepCool PF500D-HA 500 W
- OS: Windows 11 Home OEM/DVD listed instead of the Shop.kz electronic-key product
- Monitor: ASUS VA24EHF 23.8-inch FHD, as a substitute for Acer KA242YEbi

**BIOS warning:** MSI A520M-A PRO requires BIOS version **7C96v1G** or newer to support Ryzen 5 5600GT. Ask the seller to confirm or update the BIOS before assembly.

## Build 2 - Sales Manager

**List:** https://pcpartpicker.com/list/3xj9R4

- CPU: AMD Ryzen 5 5600GT (integrated graphics, no dedicated GPU)
- CPU cooler: DeepCool AG200
- Motherboard: MSI A520M-A PRO (AM4)
- Memory: Corsair Vengeance LPX 32 GB (2 x 16 GB), DDR4-3200 CL16, as a substitute for Hiksemi Sword 32 GB (2 x 16 GB)
- SSD: Kingston NV3 1 TB M.2 NVMe
- Case: Cooler Master MasterBox Q300L, as a substitute for 1Stplayer DK-3-BK
- PSU: DeepCool PF500 500 W, as a substitute for DeepCool PF500D-HA 500 W
- OS: Windows 11 Home OEM/DVD listed instead of the Shop.kz electronic-key product
- Monitor: ASUS VA24EHF 23.8-inch FHD, as a substitute for Acer KA242YEbi

**BIOS warning:** The motherboard needs BIOS version **7C96v1G** or newer for Ryzen 5 5600GT.

**Additional equipment:** The webcam, headset, and keyboard/mouse are included in the Kazakhstan `budget.csv`, even though they are not shown as selected parts in this PCPartPicker list.

## Build 3 - Web Developer

**List:** https://pcpartpicker.com/list/VLBtNp

- CPU: AMD Ryzen 7 5700G (integrated graphics, no dedicated GPU)
- CPU cooler: DeepCool AG200
- Motherboard: MSI B550M PRO-VDH WIFI (AM4)
- Memory: Corsair Vengeance LPX 32 GB (2 x 16 GB), DDR4-3200 CL16, as a substitute for Hiksemi Sword 32 GB (2 x 16 GB)
- SSD: Kingston NV3 1 TB M.2 NVMe
- Case: Cooler Master MasterBox Q300L, as a substitute for 1Stplayer DK-3-BK
- PSU: DeepCool PF500 500 W, as a substitute for DeepCool PF500D-HA 500 W
- OS: Windows 11 Home OEM/DVD listed instead of the Shop.kz electronic-key product
- Monitor: Dell Plus S2725DSM 27-inch 2560 x 1440, 144 Hz, as a substitute for AOC Q27B3CF2/01 27-inch QHD

**BIOS warning:** MSI B550M PRO-VDH WIFI requires BIOS version **7C95v28** or newer to support Ryzen 7 5700G.

**Speed limitation:** Ryzen 7 5700G uses PCIe 3.0 for this SSD connection, so the Kingston NV3 may run below its PCIe 4.0 maximum speed. It will still function as an NVMe SSD.

## Build 4 - Designer

**List:** https://pcpartpicker.com/list/Hvk3sK

- CPU: AMD Ryzen 5 5600 (no integrated graphics)
- CPU cooler: DeepCool AG200
- Motherboard: MSI B550M PRO-VDH WIFI (AM4)
- Memory: Corsair Vengeance LPX 32 GB (2 x 16 GB), DDR4-3200 CL16, as a substitute for Hiksemi Sword 32 GB (2 x 16 GB)
- SSD: Kingston NV3 1 TB M.2 NVMe
- GPU: Gigabyte GAMING OC V2 GeForce RTX 5060 8 GB (dedicated graphics required)
- Case: Cooler Master MasterBox Q300L, as a substitute for 1Stplayer DK-3-BK
- PSU: Corsair RM650e (2025) 650 W, as a substitute for DeepCool GamerStorm PF650D V2 650 W
- OS: Windows 11 Home OEM/DVD listed instead of the Shop.kz electronic-key product
- Monitor: Dell Plus S2725DSM 27-inch 2560 x 1440, 144 Hz, as a substitute for AOC Q27B3CF2/01 27-inch QHD

**BIOS warning:** MSI B550M PRO-VDH WIFI requires BIOS version **7C95v2A** or newer to support Ryzen 5 5600.

**Power and physical fit:** PCPartPicker estimates **319 W** and shows the required GPU 8-pin power connector supplied by the Corsair PSU. It notes that the chosen GPU leaves only 79 mm of front-radiator depth in the substitute Q300L case; this list does not use a front radiator. Before purchasing the *actual* Shop.kz parts, check the length of RTX 5060 against the 1Stplayer case and confirm the DeepCool 650 W PSU has the correct GPU cable.

## Limitations and final checks

1. **Substitutes are not purchases.** The real Kazakhstan configurations and their KZT costs remain in `builds.md` and `budget.csv`. PCPartPicker's US prices and availability are not used for the assignment budget.
2. **BIOS versions must be confirmed with the seller.** The orange warning is not proof that the boards will work without an update.
3. **PCPartPicker does not check all physical constraints.** Verify case dimensions, cooler height, GPU length, RAM clearance, and front-panel connections using the actual products before ordering.
4. **Windows licensing must be checked.** The listings used for compatibility are OEM/DVD variants, while the planned Shop.kz purchases are electronic Windows 11 Home keys. Confirm each purchased key is a legitimate license appropriate for business use.
5. **Evidence:** See the dated screenshots in `vendor-quotes/` for Shop.kz item prices. The PCPartPicker links are evidence of the main selected components and reported compatibility notes, not independent evidence of Kazakhstan prices.
