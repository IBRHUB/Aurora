
<p align="center">

<h1 align="center">Troubleshooting</h1>

<br>


## Quick Navigation
- [PowerShell Execution](#issues-with-powershell-execution-policy)
- [System Performance](#power-plan-not-applying)  
- [Network Issues](#network-settings-not-optimized)
- [Gaming Performance](#game-performance-issues)
- [Hardware Optimization](#resizable-bar-not-working)
- [Performance Issues](#high-cpu-usage-after-installation)
- [System Maintenance](#windows-updates-not-working)
- [Gaming Features](#xbox-game-bar-not-working-or-recording)
- [Calendar & Notifications](#calendar-and-notifications-whatsapp-not-working)
- [Windows Features](#windows-spotlight-not-working)
- [Browser Management](#edge-browser-not-removed-completely)
- [OneDrive Issues](#onedrive-not-launching)

This document provides common issues and their solutions when using the Aurora script. The script includes optimizations and tweaks for Windows, OneDrive, NVIDIA, AMD, and more. If you have any issues running or using this script, check the sections below for possible remedies.

## OneDrive Not Launching
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

##  Issues with PowerShell Execution Policy
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


## Calendar and Notifications (WhatsApp) not Working

<details>
<summary>Click to Show Fix</summary>

### You need to Enable the Calendar, Notifications and Background Apps 

1. Right-Click on Start and open Windows Powershell or Terminal as Admin.
2. Run the following commands:
    ```powershell
    reg.exe add "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Explorer" /v DisableNotificationCenter /t REG_DWORD /d 0 /f
    reg.exe add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v ToastEnabled /t REG_DWORD /d 1 /f
    reg.exe add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 0 /f
    ```
3. Restart Your PC to apply the changes.

</details>


## Windows Spotlight not Working

<details>
<summary>Click to Show Fix</summary>

### You need to Enable Windows Spotlight

1. Right-Click on Start and open Windows Powershell or Terminal as Admin.
2. Run the following commands:
    ```powershell
    reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsSpotlightOnLockScreen /t REG_DWORD /d 0 /f
    reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 0 /f
    reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsSpotlightActiveUser /t REG_DWORD /d 0 /f
    ```
3. Restart Your PC to apply the changes.

</details>


## Xbox Game Bar not Working or Recording

<details>
<summary>Click to Show Fix</summary>

### Xbox Game Bar Not Working After Aurora Installation

1. Download, Install and Launch the [Xbox App for Windows](https://www.xbox.com/en-US/apps/xbox-app-for-pc)
2. Install any missing dependencies when prompted
3. Right-Click on Start and open Windows PowerShell or Terminal as Admin
4. Run these commands to re-enable Xbox Game Bar functionality:
    ```powershell
    reg.exe add "HKEY_CURRENT_USER\System\GameConfigStore" /v GameDVR_FSEBehavior /t REG_DWORD /d 0 /f
    reg.exe add "HKEY_CURRENT_USER\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 1 /f
    reg.exe add "HKEY_CURRENT_USER\System\GameConfigStore" /v GameDVR_DXGIHonorFSEWindowsCompatible /t REG_DWORD /d 0 /f
    reg.exe add "HKEY_CURRENT_USER\System\GameConfigStore" /v GameDVR_HonorUserFSEBehaviorMode /t REG_DWORD /d 0 /f
    reg.exe add "HKEY_CURRENT_USER\System\GameConfigStore" /v GameDVR_EFSEFeatureFlags /t REG_DWORD /d 1 /f
    reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 1 /f
    ```
5. Restart your PC to apply all changes

</details>


## Resizable BAR Not Working

<details>
<summary>Click to Show Fix</summary>

### Resizable BAR Issues After Aurora Installation

1. Right-Click on Start and open Windows PowerShell or Terminal as Admin
2. Run Aurora again using the command:
    ```powershell
    irm "https://ibrpride.com/Aurora" | iex
    ```
3. Navigate to GPU Tweaks section and select your GPU type (NVIDIA/AMD)
4. For NVIDIA users, select "Resizable Bar ON" option
5. Restart your PC to apply the changes
6. Verify Resizable BAR is enabled in NVIDIA Control Panel under "System Information"

Note: Make sure your system meets the hardware requirements for Resizable BAR (supported CPU, motherboard and GPU)

</details>


## Power Plan Not Applying

<details>
<summary>Click to Show Fix</summary>

### Power Plan Issues After Aurora Installation

1. Right-Click on Start and open Windows PowerShell or Terminal as Admin
2. Run these commands to reset and reapply power settings:
    ```powershell
    powercfg -restoredefaultschemes
    powercfg /setactive SCHEME_BALANCED
    ```
3. Run Aurora again using:
    ```powershell
    irm "https://ibrpride.com/Aurora" | iex
    ```
4. Navigate to Power Plan section and apply the optimizations
5. Restart your PC to ensure changes take effect

</details>


## Network Settings Not Optimized

<details>
<summary>Click to Show Fix</summary>

### Network Optimization Issues After Aurora Installation

1. Right-Click on Start and open Windows PowerShell or Terminal as Admin
2. Run Aurora again using:
    ```powershell
    irm "https://ibrpride.com/Aurora" | iex
    ```
3. The script will automatically run NetworkBufferBloatFixer.ps1 to optimize:
   - Network adapter settings
   - TCP/IP parameters
   - Network buffer sizes
   - QoS policies
4. Restart your PC to apply all changes

</details>


## Windows Updates Not Working

<details>
<summary>Click to Show Fix</summary>

### Windows Update Issues After Aurora Installation

1. Right-Click on Start and open Windows PowerShell or Terminal as Admin
2. Run Aurora again and select "Repair Windows" option
3. The RepairWindows.cmd script will:
   - Reset Windows Update components
   - Fix corrupted system files
   - Restore critical services
4. Restart your PC to apply changes

</details>


## Edge Browser Not Removed Completely

<details>
<summary>Click to Show Fix</summary>

### Edge Removal Issues After Aurora Installation

1. Right-Click on Start and open Windows PowerShell or Terminal as Admin
2. Run Aurora again and select Edge removal option
3. The RemoveEdge.ps1 script will:
   - Force stop Edge processes
   - Remove Edge installation
   - Clean up registry entries
   - Delete remaining files
4. Restart your PC to complete removal

</details>

## OneDrive Still Present

<details>
<summary>Click to Show Fix</summary>

### OneDrive Removal Issues After Aurora Installation

1. Right-Click on Start and open Windows PowerShell or Terminal as Admin
2. Run Aurora again and select OneDrive removal option
3. The OneDrive.ps1 script will:
   - Stop OneDrive processes
   - Uninstall OneDrive
   - Remove registry entries
   - Delete OneDrive folders
4. The script also disables OneDrive via registry:
   ```powershell
   reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSync" /t REG_DWORD /d "1" /f
   reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d "1" /f
   ```
5. Restart your PC to complete removal

</details>

## High CPU Usage After Installation

<details>
<summary>Click to Show Fix</summary>

### CPU Performance Issues After Aurora Installation

1. Right-Click on Start and open Windows PowerShell or Terminal as Admin
2. Run Aurora again and select:
   - Power Plan optimization (applies balanced power scheme)
   - Privacy settings (disables telemetry and background processes)
   - Components removal (removes unnecessary Windows components)
3. The scripts will optimize:
   - System services
   - Background processes
   - Power settings
4. Restart your PC to apply changes

</details>

## Game Performance Issues

<details>
<summary>Click to Show Fix</summary>

### Gaming Performance Issues After Aurora Installation

1. Right-Click on Start and open Windows PowerShell or Terminal as Admin
2. Run Aurora again and select GPU Tweaks
3. For NVIDIA users:
   - Select appropriate Resizable BAR option
   - The script will apply optimized NVIDIA profiles
4. For AMD users:
   - AuroraAMD.bat will apply optimized AMD settings
   - Registry tweaks for better performance
5. Restart your PC to apply changes

</details>


## Still Having Issues?

<details>
<summary>Click to Show Support Options</summary>

### Get Help on Discord

If you're still experiencing issues after trying the fixes above:

1. Join our Discord server: [https://discord.gg/vUGMBuVFrt](https://discord.gg/vUGMBuVFrt)
2. Open a support ticket
3. Describe your issue in detail:
   - What problem you're experiencing
   - Steps you've already tried
   - Your system specifications
4. Our support team will assist you further

</details>


## Cannot Run Aurora from PowerShell

<details>
<summary>Click to Show Fix</summary>

### PowerShell Execution Issues Due to Regional Restrictions

If you cannot run Aurora from PowerShell, this may be due to your geographical location. You can:

1. Use a VPN service to bypass regional restrictions, or
2. Run this alternative command directly in CMD or PowerShell:

```powershell
powershell Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-WebRequest "https://github.com/IBRHUB/Aurora/releases/download/0.5/Aurora.cmd" -OutFile "$env:temp\Aurora.cmd"; Start-process $env:temp\Aurora.cmd
```

### Note: This is a Beta Version

This is an initial version of the troubleshooting guide based on reported issues. We will continue to update and improve it as we receive more feedback from users. Issues will be addressed and solutions will be added regularly.

If you encounter any problems not listed here, please report them through our Discord support channel so we can help resolve them and add solutions to this guide.


<p align="center">
<a href="https://github.com/IBRHUB/Aurora/blob/main/Troubleshooting.ar.md">
<img src="https://upload.wikimedia.org/wikipedia/commons/0/0d/Flag_of_Saudi_Arabia.svg" alt="Saudi Flag" width="20" height="20"> &nbsp; Troubleshooting in Arabic
</a>
⠂ 
<a href="https://github.com/IBRHUB/Aurora">Aurora</a>
</p>
</p>

<br>
