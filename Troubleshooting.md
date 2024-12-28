
<p align="center">

<h1 align="center">Troubleshooting</h1>

<br>




This document provides common issues and their solutions when using the Aurora script. The script includes optimizations and tweaks for Windows, OneDrive, NVIDIA, AMD, and more. If you have any issues running or using this script, check the sections below for possible remedies.

# OneDrive Not Launching
Some users want to continue using OneDrive after the script’s tweaks. If OneDrive is not starting or syncing, it’s often because it was disabled or blocked by the registry changes.
<details>
<summary>Click to Show Fix</summary>
You need to Enable OneDrive and User Sync
Right-click on Start and open Windows PowerShell (or Terminal) as Admin.

Run:

```cmd
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\OneDrive" /v KFMBlockOptIn /t REG_DWORD /d 0 /f
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v DisableFileSyncNGSC /t REG_DWORD /d 0 /f
reg.exe add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" /v SettingSyncEnabled /t REG_DWORD /d 1 /f
```
Close PowerShell and restart your PC
</details>

#  Issues with PowerShell Execution Policy
Symptom
The script fails with a message about scripts being disabled on your system.
For example: File cannot be loaded because running scripts is disabled on this system.

### Cause
The script attempts to bypass the Execution Policy, but sometimes this may not apply globally.
<details>
<summary>Click to Show Fix</summary>
Fix
Open Windows PowerShell as Administrator.

Run:
```PowerShell
Set-ExecutionPolicy Bypass -Scope LocalMachine -Force
```
Close PowerShell and re-run the Aurora script as administrator.
</details>
<p align="center">
<a href="https://github.com/IBRHUB/Aurora/blob/main/Troubleshooting.ar.md">
<img src="https://upload.wikimedia.org/wikipedia/commons/0/0d/Flag_of_Saudi_Arabia.svg" alt="Saudi Flag" width="20" height="20"> &nbsp; Troubleshooting in Arabic
</a>
⠂ 
<a href="https://github.com/IBRHUB/Aurora">Aurora</a>
</p>
</p>

<br>
