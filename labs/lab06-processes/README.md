# Lab 6 — Live Processes and Memory Pressure

**Student:** Nuraly Kuspek  
**Pair:** Individual work  
**Machine:** Oracle VirtualBox; Windows 11 guest and Ubuntu 26.04.1 LTS guest  
**Experiment dates:** 15 November 2026 (original tests); 22 November 2026 (additional parent-process and swap tests)

## What I did

### Part 1 — One process, three tools

**Process chosen:** Python HTTP server. I initially tried VirtualBox Guest Additions (`VBoxService`), but the service was not found in Ubuntu. A Python HTTP server could be started in both operating systems for a like-for-like application comparison.

Windows:

```powershell
py -m http.server 8000 --bind 127.0.0.1
```

Ubuntu:

```bash
python3 -m http.server 8000 --bind 127.0.0.1
```

Both reported that they were serving HTTP on `127.0.0.1:8000`. The servers were separate processes on separate operating systems; their PIDs were not expected to match across guests.

**Windows Task Manager:** Opened **Details**, selected `python.exe`, and enabled PID, Working set (memory), Memory (private working set), Commit size, Handles, and Threads. The original Windows server had PID **9272**.

**Windows Process Explorer:** Found `python.exe` with the same Windows PID **9272**, enabled memory and handle columns, and opened the lower **Handles** pane to inspect the process's open objects.

**Ubuntu htop / ps / proc:** Filtered for `http.server` and inspected PID **2106**. Ran:

```bash
ps -o pid,ppid,user,rss,vsz,nlwp,cmd -p 2106
ls /proc/2106/fd | wc -l
ls -l /proc/2106/fd | head
```

The Linux process had parent PID **1529**, **1** thread, and **4** file descriptors. File descriptors `0`, `1`, and `2` were connected to the terminal; descriptor `3` was a socket.

**Additional Windows parent-process check (22 November):** The original Windows process PID 9272 was no longer running. I restarted the same HTTP server and measured its parent using Windows PowerShell:

```powershell
Get-CimInstance Win32_Process -Filter "Name = 'python.exe'" |
  Select-Object ProcessId, ParentProcessId, CommandLine

Get-CimInstance Win32_Process -Filter "ProcessId=8672" |
  Select-Object Name, ProcessId, ParentProcessId
```

Observed follow-up process tree:

```text
py.exe        PID 8672, parent PID 8404
└── python.exe PID 9444, parent PID 8672
```

Thus the Python HTTP server's **Windows parent process was `py.exe` (PID 8672 in the follow-up run)**. This is a *new measurement*, not the original PID 9272. The original Task Manager and Process Explorer captures still refer to PID 9272; I do not claim that its parent PID was captured at that time.

### Part 1 — Comparison table

| Measurement | Windows Task Manager | Windows Process Explorer | Ubuntu htop / ps |
|---|---|---|---|
| Process | `python.exe` | `python.exe` | `python3 -m http.server 8000` |
| Original PID | 9272 | 9272 | 2106 |
| Parent process and PID | Follow-up Windows measurement: `py.exe`, PID **8672**, for Python PID **9444** | Same follow-up process relationship, verified with PowerShell; not captured in the original Process Explorer screenshot | Parent PID **1529** (terminal/shell process) |
| Default memory column | Private working set: **15,464 K** | Working Set: **27,076 K** | RES: **22,556 KiB** |
| Private resident memory | Private working set: **15,464 K** | WS Private: **15,404 K** | Not separately measured |
| Commit / Private Bytes | Commit size: **18,296 K** | Private Bytes: **18,232 K** | No identical field measured |
| Working set / resident memory | **27,108 K** | **27,076 K** | RES **22,556 KiB** |
| Virtual size | Not recorded in original screenshot | Not recorded in original screenshot | VIRT / VSZ **35,408 KiB** |
| Handles / file descriptors | **124 handles** | **124 handles** | **4 file descriptors** |
| Threads | **3** | Not captured in original Process Explorer screenshot | **1** (NLWP) |

**Why the figures differ:** The tools measure different things, and the Windows screenshots were taken at slightly different moments. **Private Bytes** measures private committed memory, whereas **Private Working Set / WS Private** measures private pages resident in RAM. Linux **RES** reports resident pages and **VIRT** covers virtual address space, so it is incorrect to label all these figures simply as “memory.” Windows **handles** refer to Windows kernel object references; Linux **file descriptors** identify entries in a per-process descriptor table. They are related, but they cannot be compared as equal counts. The Python process had different PIDs in Windows and Linux because the guests run separate kernels.

Evidence: [Task Manager](evidence/task-manager.png), [Process Explorer](evidence/process-explorer.png), [htop](evidence/htop.png), and [Windows parent PID](evidence/windows-parent-pid.png).

### Part 2 — Memory pressure without swap (15 November)

**Setup:** Ubuntu guest with approximately **1.6 GiB RAM**, **0 B swap**. I created a VirtualBox snapshot named `before-lab6` before the tests.

Collected a timestamped log in a separate SSH session:

```bash
mkdir -p ~/lab06
cd ~/lab06
{ echo "=== BEFORE $(date) ==="; free -h; } > memory-pressure.txt
while true; do echo "=== $(date) ==="; free -h; sleep 3; done | tee -a memory-pressure.txt
```

(The logger was restarted in append mode after an Ubuntu restart; the final `AFTER` reading was appended.) In a second terminal, ran:

```bash
stress-ng --vm 2 --vm-bytes 70% --timeout 60s
stress-ng --vm 2 --vm-bytes 90% --timeout 60s
stress-ng --vm 2 --vm-bytes 120% --timeout 90s
stress-ng --vm 2 --vm-bytes 165% --timeout 90s
```

The first three runs completed without showing OOM kills in the checked kernel log. During the **165%** run, the guest became slow and the kernel recorded multiple OOM kills of `stress-ng-vm` workers. The stress-ng summary subsequently reported success, but that does not erase the kernel's records of killed and recreated workers.

#### 165% run — Before / During / After (UTC, 15 November 2026)

| Stage | Timestamp (UTC) | RAM used | RAM available | Swap used | Observation |
|---|---|---:|---:|---:|---|
| Before | 15:42:45 | **360 MiB** | **1.3 GiB** | **0 B** | Baseline immediately before the 165% attempt |
| During, peak recorded | 15:42:58 | **1.6 GiB** | **29 MiB** | **0 B** | Very little memory remained available |
| After recovery | 15:48:23 | **364 MiB** | **1.2 GiB** | **0 B** | Memory use returned near baseline |

The measurements above are from [memory-pressure.txt](evidence/memory-pressure.txt). Not all moments were captured: there was a gap in updates while the guest was under extreme pressure. The listed peak is the **highest recorded sample**, not a claim about every instant during the run.

#### What the Linux kernel did

I queried kernel messages using:

```bash
sudo journalctl -k -b --no-pager |
  grep -i -E -B3 -A8 'out of memory|oom-kill|killed process' \
  > ~/lab06/kernel-log-extract.txt
```

The kernel log includes the following event at **15:42:59 UTC on 15 November 2026**, just **one second after** the 15:42:58 memory sample with **29 MiB available**:

```text
stress-ng-vm invoked oom-killer: ... oom_score_adj=1000
Out of memory: Killed process 2229 (stress-ng-vm) ... anon-rss:933596kB ... oom_score_adj:1000
```

**Which process?** The kernel selected `stress-ng-vm` **PID 2229**, one of the worker processes consuming memory. Other `stress-ng-vm` workers were killed shortly afterward.

**Why that process?** Severe memory pressure left very little reclaimable memory, and the selected worker held approximately **933,596 kB of anonymous resident memory** (about 912 MiB). Its **`oom_score_adj=1000`** strongly increased its likelihood of being selected by the OOM Killer. The aim was to reclaim RAM so the rest of the system could continue.

**When?** The log's **15:42:59 UTC** kill closely follows the **15:42:58 UTC** `free -h` reading. By **15:48:23 UTC**, RAM used had fallen to **364 MiB**. These timestamps establish the sequence: memory exhaustion → kernel kill → recovery. The full evidence is in [kernel-log-extract.txt](evidence/kernel-log-extract.txt).

### Part 2 — Follow-up experiment with swap (22 November)

To demonstrate **swapping** separately from the original no-swap OOM run, I configured a **temporary 2 GiB swap file**. I did **not** add it to `/etc/fstab`.

```bash
sudo fallocate -l 2G /swapfile-lab06
sudo chmod 600 /swapfile-lab06
sudo mkswap /swapfile-lab06
sudo swapon /swapfile-lab06
free -h
swapon --show
```

Then I recorded `free -h` every two seconds in [swap-experiment.txt](evidence/swap-experiment.txt), while running a single memory worker:

```bash
stress-ng --vm 1 --vm-bytes 1400M --vm-keep --timeout 45s --metrics-brief
```

#### Swap run — Before / During / After (UTC, 22 November 2026)

| Stage | Timestamp (UTC) | RAM used | RAM available | Swap used / total |
|---|---|---:|---:|---|
| Before | 16:48:44 | **391 MiB** | **1.2 GiB** | **0 B / 2.0 GiB** |
| During | 16:49:19 | **1.5 GiB** | **72 MiB** | **241 MiB / 2.0 GiB** |
| After | 16:51:03 | **375 MiB** | **1.2 GiB** | **10 MiB / 2.0 GiB** |

The appearance of **241 MiB of used swap** proves that Ubuntu wrote some memory pages to the swap file during the test. Swap remained at approximately **10 MiB** after the workload ended; swap usage does not have to return immediately to zero. `stress-ng` reported **1 passed** and **0 failed** workers and completed successfully. A warning that its operation counters were zero concerns those performance counters, not the recorded `free -h` memory and swap usage.

Evidence: [swap enabled](evidence/swap-enabled.png), [swap during](evidence/swap-during.png), and [swap experiment log](evidence/swap-experiment.txt).

### Windows comparison — Event Viewer

On the Windows guest, I opened **Event Viewer → Windows Logs → System**, checked for **Event ID 2004** from **Microsoft-Windows-Resource-Exhaustion-Detector**, and ran:

```powershell
Get-WinEvent -FilterHashtable @{
  LogName='System'
  ProviderName='Microsoft-Windows-Resource-Exhaustion-Detector'
} -MaxEvents 5 | Format-List TimeCreated, Id, Message
```

The query reported:

```text
No events were found that match the specified selection criteria.
```

This is the observed result for the **checked Windows System log**, not proof that Windows never experiences memory pressure. The memory-pressure experiment was performed in **Ubuntu**, not Windows.

Evidence: [Windows Event Viewer](evidence/windows-event-viewer.png), [PowerShell output](evidence/windows-powershell-original.png).

## Result

- Successfully compared the same application type across Windows Task Manager, Windows Process Explorer, and Ubuntu `htop` / `ps`.
- Confirmed the Windows Python server's **parent was `py.exe` (PID 8672)** in a separately documented follow-up run (new Python PID 9444).
- Documented exact **before, during, and after** measurements for the 165% memory-pressure run.
- Matched the Linux **OOM kill at 15:42:59 UTC** with the low-memory reading from **15:42:58 UTC** and explained the selection of the memory-intensive worker.
- Demonstrated actual Linux **swap usage (241 MiB during load)** in a follow-up experiment with a 2 GiB swap file.
- Verified that the checked Windows log had no matching Resource-Exhaustion-Detector entries.

## What did not work the first time

1. **Missing `VBoxService` on Ubuntu.** I found `VBoxService.exe` on Windows but not its equivalent in Ubuntu, so I switched to a Python HTTP server on both guests.
2. **Python not initially installed on Windows.** `python` and `py` commands were unavailable. I installed Python and reran the server.
3. **Incomplete Windows parent-process evidence.** The initial Task Manager and Process Explorer screenshots did not identify the parent. I restarted the same type of server later and confirmed `python.exe` PID 9444 was launched by `py.exe` PID 8672 using `Get-CimInstance`.
4. **No swap during the first Linux tests.** The initial guest had zero swap, so the experiment could not demonstrate swap usage. I added a temporary swap file and recorded measurable usage during a separate run.
5. **OOM did not happen at 70%, 90%, or 120%.** I increased the load to 165%, saw significant slowdowns, and confirmed real process kills in the kernel journal rather than trusting only the stress tool's success message.
6. **SSH / recording interruption.** An SSH session stopped responding during an earlier attempt. I reconnected and resumed logging without overwriting the earlier measurements.

## Evidence

- [task-manager.png](evidence/task-manager.png) — Windows server PID, private working set, working set, commit, handles, and threads.
- [process-explorer.png](evidence/process-explorer.png) — Same original Windows Python PID, working set, private memory, and open handles.
- [htop.png](evidence/htop.png) — Ubuntu Python PID/PPID and resident/virtual memory columns.
- [windows-parent-pid.png](evidence/windows-parent-pid.png) — Follow-up PowerShell evidence identifying the Windows Python server's parent `py.exe`.
- [memory-pressure.txt](evidence/memory-pressure.txt) — Timestamped original memory samples, including 165% before/during/after.
- [kernel-log-extract.txt](evidence/kernel-log-extract.txt) — OOM kills, selected workers, memory figures, and timestamps.
- [windows-event-viewer.png](evidence/windows-event-viewer.png) — Filtered Windows system event log.
- [windows-powershell-original.png](evidence/windows-powershell-original.png) — PowerShell query with no matching events.
- [swap-enabled.png](evidence/swap-enabled.png) — Verified 2 GiB swap file enabled in Ubuntu.
- [swap-during.png](evidence/swap-during.png) — Swap usage increasing to 241 MiB during pressure.
- [swap-experiment.txt](evidence/swap-experiment.txt) — Timestamped before/during/after results for the follow-up swap test.
