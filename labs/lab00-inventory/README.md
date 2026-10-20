# Lab 0 - Inventory your own machine

Pair: Kuspek / [Фамилия напарника]
Driver first half: Kuspek
Machine: Host, Windows 11
Date: 20.10.2026

## What I did

Собрал информацию о системе, используя PowerShell. Для записи результатов в файлы использовал операторы перенаправления вывода `>` (создание/перезапись) и `>>` (добавление в конец файла).

## Result

| What | Value | Where I got it |
| :--- | :--- | :--- |
| **CPU** (Model, Cores, Threads) | *[вставьте ваши значения]* | `Get-CimInstance Win32_Processor` |
| **Memory** (Total, Modules count, Speed) | *[вставьте ваши значения]* | `Get-CimInstance Win32_PhysicalMemory` |
| **Disk** (Model, Type, Free space on VM vol) | *[вставьте ваши значения]* | `Get-PhysicalDisk` и `Get-Volume -DriveLetter C` |
| **Firmware** (Type: BIOS/UEFI, Version, Date) | *[вставьте ваши значения]* | `Get-CimInstance Win32_BIOS` |
| **Virtualization** (Present and enabled?) | *[вставьте ваши значения]* | `(Get-CimInstance Win32_ComputerSystem).HypervisorPresent` |

## What did not work the first time

What I saw: При сохранении информации о диске в файл `disk.txt` записался только размер свободного места, а данные о модели накопителя исчезли. 
What it turned out to be: Я случайно использовал оператор `>` во второй команде (`Get-Volume`), который полностью перезаписал файл вместо того, чтобы дополнить его.
What I did: Я заменил `>` на `>>` во второй команде, чтобы новые строки корректно дописались в конец файла.

## Evidence

- [evidence/cpu.txt](evidence/cpu.txt) - вывод команды с характеристиками процессора
- [evidence/memory.txt](evidence/memory.txt) - вывод с емкостью, скоростью и расположением модулей оперативной памяти
- [evidence/disk.txt](evidence/disk.txt) - вывод с типом диска и объемом свободного места
