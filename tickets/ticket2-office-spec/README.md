# Ticket 2 — Office Hardware Specification

**Student:** Nuraly Kuspek  
**Course:** IFT 103 — Operating System Architecture  
**Price check date:** 2026-11-24  
**Budget limit:** 3,000,000 KZT

## 1. What was asked

> We are opening the second office and need four computers — accountant, sales, web developer, designer. Budget 3,000,000 tenge for everything. Everyone says we should just buy the same four machines, is that right? Make sure they last a few years. Monitors included.

## 2. What was actually needed

I do not think four identical computers are a good choice. These employees have different daily tasks. Buying the same expensive CPU and GPU for everyone would waste money, while buying four basic PCs could make the developer and designer slow.

- **Accountant:** Works in Excel, 1C, email, and documents. Needs reliability, a fast SSD, and a suitable Windows OS. A dedicated GPU is not needed.
- **Sales Manager:** Uses CRM, about 30–40 browser tabs, Excel, and video calls. The main risk is running out of RAM, so I planned 32 GB and added a webcam and headset.
- **Web Developer:** Uses VS Code, Docker, local databases, browsers, and sometimes virtual machines. CPU threads and RAM matter most, so I chose a Ryzen 7 with 32 GB RAM.
- **Designer:** Mostly uses Photoshop, Illustrator, and large 2D images. GPU performance and a good monitor matter, so I chose an RTX 5060 and a 27-inch QHD IPS monitor.

Every computer needs **at least 16 GB RAM, a 1 TB SSD, a licensed operating system, and one monitor**. The components must fit together, and the total price must stay under 3,000,000 KZT.

### Questions I would ask Daniyar

1. What exact programs and versions will each employee use? Does the designer also do 3D or video editing?
2. Does the 3,000,000 KZT limit include Windows, monitors, keyboards, mice, webcams, headsets, delivery, and assembly?
3. What does "last a few years" mean: three, four, or five years?
4. Does the office need Windows 11 Pro features, centralized management, company backups, or paid software subscriptions?

### My assumptions and why

- **Four years:** I used four years as a reasonable target because the director did not give an exact number.
- **Full desktop setup:** I included a monitor, a Windows license, and keyboard/mouse for every PC; the sales PC also has a webcam and headset. These are needed for daily work.
- **Windows 11 Home:** I used the licensed Windows 11 Home product in the budget because a specific office management requirement was not given. If the company needs domain joining or centralized management, I would ask to use Windows 11 Pro instead.
- **Mostly 2D design:** I chose an RTX 5060 8 GB rather than a more expensive GPU because I assumed the designer does not regularly render large 3D scenes.
- **Backups and subscriptions:** Office, Adobe, cloud backup subscriptions, assembly, and delivery were not specified, so they are **not included** in the quoted hardware total. They need a separate decision.
- **Upgradeable PCs:** I used standard desktop parts where possible and reserved money in the budget for future needs.

## 3. What I did

I designed four different desktops based on workload, expected bottleneck, and budget trade-off. Full part lists and compatibility notes are in [builds.md](builds.md). Local vendor prices and dates are in [budget.csv](budget.csv).

### Four custom builds

| Employee | Main bottleneck | Main hardware decision | Total, KZT |
|---|---|---|---:|
| Accountant | Memory and storage | Ryzen 5 5600GT, 16 GB RAM, 1 TB SSD, integrated GPU | 491,810 |
| Sales Manager | Many apps and browser tabs | Ryzen 5 5600GT, 32 GB RAM, webcam and headset | 583,390 |
| Web Developer | CPU and RAM | Ryzen 7 5700G, 32 GB RAM, 1 TB SSD | 667,810 |
| Designer | GPU and display | Ryzen 5 5600, RTX 5060 8 GB, 32 GB RAM, 27-inch QHD IPS | 957,500 |
| **GRAND TOTAL** | | | **2,700,510** |

**Budget remaining: 299,490 KZT** (3,000,000 minus 2,700,510). All four custom build totals include their monitor and licensed Windows. The budget is an estimate, not a paid purchase invoice.

### Compatibility checked with PCPartPicker

| Build | PCPartPicker link | Special note |
|---|---|---|
| Accountant | [PCPartPicker — Accountant](https://pcpartpicker.com/list/pDF5R4) | MSI A520M-A PRO needs BIOS 7C96v1G or newer for Ryzen 5 5600GT |
| Sales Manager | [PCPartPicker — Sales](https://pcpartpicker.com/list/3xj9R4) | Same CPU/motherboard BIOS requirement |
| Web Developer | [PCPartPicker — Developer](https://pcpartpicker.com/list/VLBtNp) | MSI B550M PRO-VDH WIFI needs BIOS 7C95v28 or newer for Ryzen 7 5700G |
| Designer | [PCPartPicker — Designer](https://pcpartpicker.com/list/Hvk3sK) | MSI B550M PRO-VDH WIFI needs BIOS 7C95v2A or newer for Ryzen 5 5600 |

PCPartPicker does not list every exact Kazakhstan part. For example, I used Corsair RAM instead of Hiksemi, Cooler Master Q300L instead of 1Stplayer DK-3-BK, and ASUS/Dell monitors instead of Acer/AOC. Some power supplies and the Windows format also differ. These are **test substitutes only**, not changes to the KZT budget. All details are explained in [evidence/pcpartpicker-links.md](evidence/pcpartpicker-links.md).

A BIOS warning means I must confirm that the board has a supported version **before purchase or assembly**. I also need to verify the physical dimensions of the actual case, GPU, CPU cooler, and power supply, since substituting a case in PCPartPicker cannot prove the real case will fit. The developer's Ryzen 7 5700G may run the Kingston NV3 SSD at PCIe 3.0 rather than its advertised PCIe 4.0 maximum.

### Director's question 1: What would I upgrade first in 18 months?

I would first check the **Web Developer** PC. If Docker containers, virtual machines, and local databases start using all 32 GB of RAM, I would upgrade it to **64 GB RAM**, after checking the motherboard's memory support. When RAM runs out, the system may start swapping data to disk and become slower. If 32 GB is still enough, I would not upgrade unnecessarily.

### Director's question 2: Pre-built PCs versus my builds

I compared the same four roles with real ready-made desktop offers from Kazakhstan vendors on **2026-11-24**. Each desktop needs a monitor for a fairer comparison because the custom builds already include one. For Sales, I also added a webcam and headset using our local accessory prices; the HP seller lists a keyboard and mouse with the PC.

| Employee | Ready-made PC and vendor | PC alone, KZT | Added equipment | Pre-built comparison, KZT | Our build, KZT |
|---|---|---:|---|---:|---:|
| Accountant | [HP OmniDesk M03-0020ci, Shop.kz](https://shop.kz/offer/kompyuter-hp-omnidesk-desktop-ai-m03-0020ci-e1xt3ea/) | 799,990 | Acer monitor 58,990 | **858,980** | **491,810** |
| Sales Manager | [HP OmniDesk M03-0019ci, Shop.kz](https://shop.kz/offer/kompyuter-hp-omnidesk-desktop-ai-m03-0019ci-e1xt2ea/) | 889,990 | Acer monitor 58,990; webcam 11,990; headset 6,590 | **967,560** | **583,390** |
| Web Developer | [HP ProDesk 4 Tower G1i, Sauda24](https://www.sauda24.kz/products/sistemnyj-blok-hp-prodesk-4-tower-g1i-core-ultra-5-235-32-gb-ssd-1-tb-windows-11-pro-9h7r6et) | 967,406 | AOC QHD monitor 114,990 | **1,082,396*** | **667,810** |
| Designer | [HP EliteDesk 8 Tower G1i, Flexcom](https://flexcom.kz/p136555427-sistemnyj-blok-elitedesk.html) | 1,110,900 | AOC QHD monitor 114,990 | **1,225,890*** | **957,500** |
| **TOTAL** | | | | **4,134,826*** | **2,700,510** |

**Difference:** The custom builds are **1,434,316 KZT cheaper** than this set of selected ready-made offers, using the additions shown above. This is a comparison of these specific vendor offers, not a claim that all pre-built PCs are more expensive.

\* The Web Developer and Designer pre-built comparison totals include a monitor but **do not yet include any separately needed keyboard/mouse or other unlisted accessories**; their package contents must be confirmed. Extra items would increase the final pre-built cost.

**How well do the pre-built offers fit the roles?**

- **Accountant:** HP OmniDesk M03-0020ci has Core Ultra 5, 32 GB RAM, 1 TB SSD and Windows 11 Home SL. It meets the minimum desktop memory, storage, and OS requirements, but needs a monitor.
- **Sales Manager:** HP OmniDesk M03-0019ci has Core Ultra 7, 32 GB RAM, 1 TB SSD and Windows 11 Home SL. It also needs a monitor, webcam, and headset for the assumed work.
- **Web Developer:** HP ProDesk 4 Tower G1i has Core Ultra 5, 32 GB RAM, 1 TB SSD and Windows 11 Pro. It can handle development work, but its performance and upgrade options for specific Docker/VM workloads should be evaluated.
- **Designer:** HP EliteDesk 8 Tower G1i has Core Ultra 7, 32 GB RAM, 1 TB SSD, RTX 5060 8 GB and Windows 11 Pro. It fits the main design workload, but still needs a suitable monitor. Actual color accuracy should be checked or calibrated.

**What the company gains with pre-built PCs:** less assembly work, one vendor contact for warranty/service, a standard factory configuration, and in some cases business support and Windows 11 Pro.

**What it loses:** less control over the exact case, board, power supply and upgrade path; some office PCs have limited RAM expansion; and the specific chosen pre-built offers cost more than the workload-focused custom builds. The pre-built machines are not identical in CPU or service terms, so this is a practical purchasing comparison rather than a controlled performance benchmark.

**My decision:** Choose the four custom builds for better budget use, provided the seller confirms BIOS and physical compatibility, genuine Windows licenses, delivery, and assembly arrangements.

### Director's question 3: Who might complain within a month?

I think the **Designer** might complain first if the work changes from 2D graphics to large 3D scenes or 4K video. The RTX 5060 has **8 GB VRAM**, which can become a limit. I accepted that trade-off to stay under budget because I assumed the job is mainly 2D design. If the real workload is heavier, I would revise the GPU choice before buying.

## 4. Evidence

- [builds.md](builds.md) — four loads, bottlenecks, chosen parts, trade-offs, and totals.
- [budget.csv](budget.csv) — every selected component with price in KZT, Kazakhstan vendor link, and date.
- [PCPartPicker links](evidence/pcpartpicker-links.md) — four lists, model substitutions, BIOS warnings, and limitations.
- [Component vendor quotes](evidence/vendor-quotes/) — dated screenshots of Shop.kz product pages used for the custom build prices.
- [Accountant ready-made quote](evidence/vendor-quotes/accountant-prebuilt.png) — HP OmniDesk M03-0020ci price and product page.
- [Sales ready-made quote](evidence/vendor-quotes/sales-prebuilt.png) — HP OmniDesk M03-0019ci price and product page.
- [Developer ready-made quote](evidence/vendor-quotes/developer-prebuilt.png) — HP ProDesk 4 Tower G1i price and product page.
- [Designer ready-made quote](evidence/vendor-quotes/designer-prebuilt.png) — HP EliteDesk 8 Tower G1i price and product page.

The vendor screenshots record the offers on 2026-11-24. PCPartPicker helps check compatibility, but its US dollar prices are **not** used in the Kazakhstan budget. The final purchase should include a new stock and price check. The four ready-made quote image links above require the four PNG files to be saved using those exact names.

## 5. What I would do differently

Next time, I would ask Daniyar for a clear software list and expected workload before selecting hardware. I would also get written quotes for assembly, delivery, warranty, and genuine OS licenses. I would check all BIOS versions and physical dimensions of the **exact** local parts, not only the PCPartPicker substitutes. I would set aside money for backup storage, because important accounting and company files should not exist on one computer only.

---

**AI use disclosure:** I used ChatGPT to help structure the report, explain the technical trade-offs, check the arithmetic, and draft English text. The product pages, screenshot evidence, part choices and final submission need to be reviewed by me. AI assistance should also be declared in the **root repository README** as required by the course.
