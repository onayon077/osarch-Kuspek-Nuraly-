# Lab 0 - Inventory your own machine

Pair: Kuspek / [Фамилия напарника]
Driver first half: Kuspek
Machine: Host, Acer Nitro ANV15-41 (Windows 11 Pro)
Date: 20.10.2026

## What I did

Собрал информацию о системе, используя PowerShell. Для записи результатов в файлы использовал операторы перенаправления вывода `>` (создание/перезапись) и `>>` (добавление в конец файла).

## Result

| What | Value | Where I got it |
| :--- | :--- | :--- |
| **CPU** (Model, Cores, Threads) | *AMD Ryzen 5 7535HS, 6 Cores, 12 Threads* | `Get-CimInstance Win32_Processor` |
| **Memory** (Total, Modules count, Speed) | *16 GB, 2 modules, 4800 MHz* | `Get-CimInstance Win32_PhysicalMemory` |
| **Disk** (Model, Type, Free space on VM vol) | *WD PC SN740 NVMe SSD, SSD, 245 GB free* | `Get-PhysicalDisk` и `Get-Volume -DriveLetter C` |
| **Firmware** (Type: BIOS/UEFI, Version, Date) | *UEFI, INSYDE Corp. V1.20, 23.10.2025* | `Get-CimInstance Win32_BIOS` |
| **Virtualization** (Present and enabled?) | *Yes (True)* | `(Get-CimInstance Win32_ComputerSystem).HypervisorPresent` |

## What did not work the first time

What I saw: При сохранении информации о диске в файл `disk.txt` записался только размер свободного места, а данные о модели накопителя исчезли.
What it turned out to be: Я случайно использовал оператор `>` во второй команде (`Get-Volume`), который полностью перезаписал файл вместо того, чтобы дополнить его.
What I did: Я заменил `>` на `>>` во второй команде, чтобы новые строки корректно дописались в конец файла.

## Evidence

- [evidence/cpu.txt](evidence/cpu.txt) - вывод команды с характеристиками процессора (6 ядер, 12 потоков)
- [evidence/memory.txt](evidence/memory.txt) - вывод с емкостью, скоростью и расположением модулей оперативной памяти
- [evidence/disk.txt](evidence/disk.txt) - вывод с типом диска (NVMe SSD) и объемом свободного места
