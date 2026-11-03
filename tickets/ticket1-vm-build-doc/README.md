# Ticket 1 — VM Build Document

## 1. What was asked
> "Hi, we have someone starting on Monday and he needs a test computer set up. Nothing special, just so he can try things without breaking anything. Can you write down how to do it so I can do the next one myself? Thanks"  
> — Aigerim T. (Office Manager)

## 2. What was actually needed
* **What the request left out:**
  * Target OS distribution and architecture (e.g., Linux Ubuntu LTS vs. Windows).
  * Host resource sizing (total host RAM, CPU thread count, and available disk capacity).
  * Hypervisor tooling (VirtualBox, VMware, or Hyper-V).
  * Network mode and routing policy (outbound internet access vs. local network isolation).
  * State recovery mechanism ("try things without breaking anything" requires point-in-time snapshots, which the requester did not specify).
* **Where the request is wrong:**
  * The requester asks for a generic "test computer", implying physical provisioning or an unmanaged system. A physical setup cannot be rolled back instantly after catastrophic test failures; a virtual machine with snapshots is required.
  * The requester expects to replicate the installation without technical guidance. Without explicit reasoning, a non-technical manager will choose defaults that lead to network isolation or excessive disk consumption.
* **What I would have asked the requester:**
  1. What software stack will the developer test (CLI tools, GUI desktop, container engines)?
  2. What are the host workstation's hardware specifications?
  3. Does the developer require incoming SSH access from the host?
* **What I assumed instead:**
  1. **Hypervisor:** Oracle VM VirtualBox (free, cross-platform, GUI-friendly).
  2. **Guest OS:** Ubuntu 26.04.1 LTS (stable server/development baseline).
  3. **Resource Sizing:** 4,096 MB RAM, 2 vCP