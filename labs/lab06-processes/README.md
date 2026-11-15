# Lab 6 — Live processes and memory pressure

**Student:** Nuraly Kuspek  
**Pair:** Individual work (change this if you worked with a partner)  
**Driver first half:** Nuraly Kuspek (change if you worked in a pair)  
**Machine:** Oracle VirtualBox — Windows 11 and Ubuntu 26.04.1 LTS  
**Date:** 15 November 2026

## What I did

### Part 1 — One process, three tools

**1. Chose the same type of process on both operating systems: a Python HTTP server.**

Windows Command Prompt:

```cmd
py -m http.server 8000 --bind 127.0.0.1
```

Ubuntu:

```bash
python3 -m http.server 8000 --bind 127.0.0.1
```

Both terminals displayed a message that the HTTP server was serving on `127.0.0.1:8000`.

**2. Inspected the Windows process using Task Manager (Details tab).**

Recorded for `python.exe` (PID `9272`):

```text
Working set (memory):          27,108 K
Memory (private working set):  15,464 K
Commit size:                   18,296 K
Handles:                       124
Threads:                       3
```

**3. Inspected the same Windows process using Process Explorer.**

Recorded for `python.exe` (PID `9272`):

```text
Private Bytes: 18,232 K
Working Set:   27,076 K
WS Private:    15,404 K
Handles:       124
```

Opened the lower pane in **Handles** view to see the objects held by the process. The values varied slightly because the measurements were taken at different times.

**4. Inspected the Ubuntu process using `htop`, `ps`, and `/proc`.**

```bash
ps -o pid,ppid,user,rss,vsz,nlwp,cmd -p 2106
ls /proc/2106/fd | wc -l
ls -l /proc/2106/fd | head
```

Observed output (trimmed):

```text
PID   PPID  USER         RSS    VSZ   NLWP  CMD
2106  1529  nuralubuntu  22556  35408 1     python3 -m http.server 8000 --bind 127.0.0.1

File descriptors: 4
```

`htop` showed approximately `VIRT = 35,408 KiB`, `RES = 22,556 KiB`, `SHR = 10,828 KiB`, and `MEM% = 1.3%`.

### Part 2 — Memory pressure

**5. Created a VirtualBox snapshot named `before-lab6` before starting the stress test.**

**6. Checked available memory and swap in Ubuntu.**

```bash
free -h
swapon --show
```

Output before the experiment (trimmed):

```text
Mem:  total 1.6 GiB | used 378 MiB | available 1.2 GiB
Swap: 0 B
```

**7. Logged memory usage in a separate SSH terminal.**

```bash
mkdir -p ~/lab06
cd ~/lab06
{ echo "=== BEFORE $(date) ==="; free -h; } > memory-pressure.txt
while true; do echo "=== $(date) ==="; free -h; sleep 3; done | tee -a memory-pressure.txt
```

The logging command was restarted and appended to the same file after an Ubuntu restart and between experiment runs. At the end, the final memory state was appended:

```bash
{ echo "=== AFTER $(date) ==="; free -h; } >> ~/lab06/memory-pressure.txt
```

**8. Ran progressively stronger memory workloads.**

```bash
stress-ng --vm 2 --vm-bytes 70% --timeout 60s
stress-ng --vm 2 --vm-bytes 90% --timeout 60s
stress-ng --vm 2 --vm-bytes 120% --timeout 90s
stress-ng --vm 2 --vm-bytes 165% --timeout 90s
```

The 70%, 90%, and 120% runs completed without reporting failed stressors. During the 165% run, Ubuntu became temporarily unresponsive and the kernel killed `stress-ng-vm` worker processes.

**9. Checked and saved kernel out-of-memory messages.**

```bash
sudo journalctl -k -b --no-pager | grep -i -E -B3 -A8 'out of memory|oom-kill|killed process' > ~/lab06/kernel-log-extract.txt
wc -l ~/lab06/kernel-log-extract.txt
head -n 25 ~/lab06/kernel-log-extract.txt
```

Example observed message:

```text
Out of memory: Killed process 2229 (stress-ng-vm)
```

**10. Checked Windows memory-exhaustion events.**

Opened **Event Viewer → Windows Logs → System**, filtered by **Resource-Exhaustion-Detector** and **Event ID 2004**, and also ran in Windows PowerShell:

```powershell
Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Microsoft-Windows-Resource-Exhaustion-Detector'} -MaxEvents 5 | Format-List TimeCreated, Id, Message
```

Output:

```text
No events were found that match the specified selection criteria.
```

## Result

### Process comparison

| Metric | Windows Task Manager | Windows Process Explorer | Ubuntu `htop` / `ps` |
|---|---|---|---|
| Process | `python.exe` | `python.exe` | `python3` |
| PID | 9272 | 9272 | 2106 |
| Parent PID | Not recorded | Not recorded | 1529 |
| Working Set / RES | 27,108 K | 27,076 K | 22,556 KiB |
| Private resident memory | Private working set: 15,464 K | WS Private: 15,404 K | Not measured separately |
| Commit / Private Bytes | Commit size: 18,296 K | Private Bytes: 18,232 K | No direct equivalent in this measurement |
| Virtual size | Not recorded | Not recorded | 35,408 KiB (VSZ / VIRT) |
| Handles / file descriptors | 124 handles | 124 handles | 4 file descriptors |
| Threads | 3 | Not recorded | 1 |

**Interpretation:** The default memory numbers cannot be treated as identical. A Windows working set and Linux resident memory both concern pages in RAM but use different accounting. Windows Private Bytes describes private committed memory, while WS Private / private working set measures private resident pages. Windows handles and Linux file descriptors are related but not equivalent. Even measurements of the same Windows process can change from moment to moment.

### Memory-pressure observations

| Run | Observation |
|---|---|
| Before test | 1.6 GiB RAM; around 378 MiB used; no swap |
| 70% | Used memory observed up to about 990 MiB; available memory down to about 651 MiB |
| 90% | Test completed without reported failed stressors |
| 120% | Test completed without reported failed stressors |
| 165% | Ubuntu became less responsive; Linux logged OOM kills of `stress-ng-vm` workers |
| After test | Ubuntu recovered; exact time-series readings are in `memory-pressure.txt` |

**Kernel behavior:** During the 165% test, Linux detected a severe memory shortage and terminated memory-intensive worker processes. The `stress-ng` summary alone did not tell the whole story: kernel logs provided the evidence of OOM killing. No swap was configured.

**Windows:** The checked Windows System log contained no matching Resource-Exhaustion-Detector events with ID 2004. This does **not** prove that Windows can never have memory pressure; no equivalent Windows stress experiment was performed here.

## What did not work the first time

- **Choosing a common process:** `VBoxService.exe` existed in Windows but `VBoxService` was not found in Ubuntu. I switched to a Python HTTP server that could be run in both systems.
- **Windows Python setup:** `python` / `py` initially did not work. I installed Python in Windows and then started the server successfully.
- **SSH terminal / memory logging:** An SSH session stopped responding and Ubuntu was restarted. I reconnected via Git Bash and restarted memory logging in append mode so the earlier measurements were not overwritten.
- **Triggering OOM:** The first 70%, 90%, and 120% runs did not produce OOM messages. A later 165% run did; I confirmed it in `journalctl` rather than relying only on the stress tool's summary.

## Evidence

- [evidence/task-manager.png](evidence/task-manager.png) — Windows Task Manager process PID, working set, commit, handles, and threads.
- [evidence/process-explorer.png](evidence/process-explorer.png) — Process Explorer private memory metrics and open-handle view for the Windows Python process.
- [evidence/htop.png](evidence/htop.png) — Ubuntu Python HTTP server and its PID, PPID, VIRT, RES, and SHR columns.
- [evidence/memory-pressure.txt](evidence/memory-pressure.txt) — Timestamped `free -h` measurements recorded before, during, and after Ubuntu stress tests.
- [evidence/kernel-log-extract.txt](evidence/kernel-log-extract.txt) — Linux kernel messages showing out-of-memory conditions and killed `stress-ng-vm` processes.
- [evidence/windows-event-viewer.png](evidence/windows-event-viewer.png) — Windows Event Viewer check for Resource-Exhaustion-Detector Event ID 2004.
- [evidence/windows-powershell-original.png](evidence/windows-powershell-original.png) — PowerShell check showing no matching Resource-Exhaustion-Detector events.
