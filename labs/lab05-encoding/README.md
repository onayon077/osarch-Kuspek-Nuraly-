# Lab 5 — Encoding Forensics

**Name:** Nuraly Kuspek  
**Date:** 15 November 2026  
**Course:** IET 103 — Operating System Architecture  
**Tools:** Git Bash, Microsoft Excel, LibreOffice Calc, iconv, file, xxd

## 1. What I Received

I received a CSV file named `staff-broken.csv` containing information about 15 employees, including Russian and Kazakh names.

The file contains six columns: ID, Surname, Name, Department, Position, and City.

Before making any changes, I opened the original file in three applications:

- **Microsoft Excel:** The file opened, but some Kazakh characters were displayed incorrectly.
- **LibreOffice Calc:** The automatic encoding detection selected Windows-1251. Some Kazakh letters were incorrect.
- **Git Bash terminal:** The `cat` command displayed unreadable characters because the file was not encoded in UTF-8.

The original file was kept unchanged in the `evidence` directory.

**Evidence:** `evidence/excel-before.png` and `evidence/libreoffice-before.png`

## 2. Diagnosis — Before the Fix

I examined the original file using the `file`, `xxd`, and `iconv` commands before converting it.

### File command

`file evidence/staff-broken.csv`

Output:

`Non-ISO extended-ASCII text, with CRLF line terminators`

This indicates that the file contains non-ASCII characters and uses Windows-style CRLF line endings.

### First bytes

Command:

`xxd evidence/staff-broken.csv | head -n 8`

The first six bytes were:

`49 44 3B D4 E0 EC`

The first 16 bytes were:

`49 44 3B D4 E0 EC E8 EB E8 FF 3B C8 EC FF 3B CE`

The beginning of the file does not contain a byte order mark (BOM).

### Encoding identification

I compared two possible encodings using iconv:

`iconv -f WINDOWS-1251 -t UTF-8 evidence/staff-broken.csv | head -n 5`

`iconv -f RK1048 -t UTF-8 evidence/staff-broken.csv | head -n 5`

Windows-1251 displayed some Kazakh characters incorrectly. For example, the letter Ә in the surname Әбдірахманова appeared as Ј.

RK1048 displayed the Russian and Kazakh characters correctly, including names such as Әбдірахманова, Қасымов, and Нұрлан.

Therefore, the source encoding is **RK1048 (KZ-1048)**.

### Final diagnosis

| Property | Original file |
|---|---|
| Filename | staff-broken.csv |
| Encoding | RK1048 (KZ-1048) |
| Line endings | CRLF (0D 0A) |
| BOM | No |
| Separator | Semicolon (;) |
| Data records | 15 |
| Main problem | Incorrect interpretation of Kazakh characters |

The problem was caused by the applications interpreting the RK1048 file using a different character encoding.

## 3. Fix

I converted the file from RK1048 to UTF-8 using Git Bash.

The following command was used:

```bash
( printf '\xEF\xBB\xBF'; iconv -f RK1048 -t UTF-8 evidence/staff-broken.csv ) > evidence/staff-fixed.csv
```

This command performs the following operations:

1. Converts the source encoding from RK1048 to UTF-8.
2. Adds the UTF-8 BOM (`EF BB BF`).
3. Preserves the original CRLF line endings.
4. Saves the result as `staff-fixed.csv`.
5. Leaves the original `staff-broken.csv` unchanged.

### Why I chose UTF-8 with BOM

I chose UTF-8 with BOM because Microsoft Excel on Windows can use the BOM to recognize UTF-8 automatically when opening a CSV file.

The BOM consists of three bytes:

`EF BB BF`

Although some Unix tools prefer files without BOM, Excel compatibility was important for this task.

### Why I kept CRLF

I kept CRLF because the file is intended to be opened in Windows applications, including Excel.

CRLF was also present in the original file, so retaining it avoided unnecessary changes.

### Separator

I kept the semicolon (`;`) separator because the original file used it, and the CSV columns opened correctly in the tested applications.

## 4. Verification — After the Fix

After conversion, I checked the new file using the terminal.

Command:

`file evidence/staff-fixed.csv`

Output:

`Unicode text, UTF-8 (with BOM) text, with CRLF line terminators`

I also examined the first bytes using:

`xxd -l 32 evidence/staff-fixed.csv`

The output begins with `EF BB BF`, confirming that the UTF-8 BOM is present.

Finally, I used:

`cat evidence/staff-fixed.csv`

All Russian and Kazakh text was readable in the terminal.

### Application verification

I opened the corrected file in three applications.

**1. Microsoft Excel**

The file opened successfully. Russian and Kazakh characters were displayed correctly, and the data appeared in separate columns.

**2. LibreOffice Calc**

I opened the file using UTF-8 encoding and the semicolon separator. The text and the table structure were displayed correctly.

**3. Git Bash terminal**

The `cat` command displayed the converted UTF-8 file correctly, including Kazakh names and city names.

All three applications successfully displayed the corrected file.

**Evidence:** `evidence/file-after.txt` and `evidence/opens-correctly.png`

### Before and after comparison

| Property | Before | After |
|---|---|---|
| Encoding | RK1048 | UTF-8 |
| BOM | No | Yes, EF BB BF |
| Line endings | CRLF | CRLF |
| Separator | ; | ; |
| Kazakh text in Excel | Incorrect characters | Correct |
| Kazakh text in LibreOffice | Incorrect characters | Correct |
| Git Bash display | Unreadable characters | Readable |

## 5. What Did Not Work the First Time

During the laboratory, I encountered several problems.

**Problem 1: Incorrect terminal directory**

Initially, Git Bash could not locate the CSV file and displayed the error `No such file or directory`.

I discovered that the actual folder was named `lab05-encoding`, not `lab5-encoding`.

I corrected the path and successfully accessed the file.

**Problem 2: Opening the CSV in LibreOffice Writer**

At first, the CSV file opened in LibreOffice Writer instead of LibreOffice Calc.

I closed Writer and opened the file using LibreOffice Calc, which allowed me to inspect the CSV import settings and table structure.

**Problem 3: Incorrect character encoding**

When the original CSV was interpreted as Windows-1251, some Kazakh letters appeared incorrectly.

I compared Windows-1251 and RK1048 using `iconv`, identified RK1048 as the correct encoding, and converted the file to UTF-8.

These problems helped me understand the importance of file paths, application selection, and character encodings.

## 6. Evidence Files

The following evidence files are included in the repository:

- `staff-broken.csv` — original CSV file, unchanged.
- `staff-fixed.csv` — corrected UTF-8 CSV file.
- `file-before.txt` — original file identification.
- `hexdump-before.txt` — original file bytes.
- `file-after.txt` — verification of the corrected file.
- `excel-before.png` — original file opened in Excel.
- `libreoffice-before.png` — original file opened in LibreOffice Calc.
- `opens-correctly.png` — corrected CSV displayed in Excel, LibreOffice Calc, and Git Bash.

## 7. Conclusion

In this laboratory, I investigated and fixed a CSV character encoding problem.

I identified the original encoding as RK1048 using hexadecimal byte analysis and comparisons with iconv.

I converted the file to UTF-8 with BOM while preserving its CRLF line endings and semicolon separators.

Finally, I verified that the corrected file displayed Russian and Kazakh characters correctly in Microsoft Excel, LibreOffice Calc, and Git Bash.

The original file was preserved, and the corrected file and supporting evidence were saved in the GitHub repository.