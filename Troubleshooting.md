
<p align="center">

<h1 align="center">Troubleshooting</h1>

<br>




This document provides common issues and their solutions when using the Aurora script. The script includes optimizations and tweaks for Windows, OneDrive, NVIDIA, AMD, and more. If you have any issues running or using this script, check the sections below for possible remedies.

## OneDrive not Launching

<details>
<summary>Click to Show Fix</summary>

### You need to Enable OneDrive and User Sync

1. Right-Click on Start and open Windows Powershell or Terminal as Admin.
2. Run the following commands:
    ```powershell
    reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\OneDrive" /v KFMBlockOptIn /t REG_DWORD /d 0 /f
    reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v DisableFileSyncNGSC /t REG_DWORD /d 0 /f
    reg.exe add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" /v SettingSyncEnabled /t REG_DWORD /d 1 /f
    ```
3. Restart Your PC and try launching OneDrive again.

</details>

##  Issues with PowerShell Execution Policy

<details>
<summary>Click to Show Fix</summary>
Symptom
The script fails with a message about scripts being disabled on your system.
For example: File cannot be loaded because running scripts is disabled on this system.

### Cause
The script attempts to bypass the Execution Policy, but sometimes this may not apply globally.

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

### Install the Xbox App for Windows and Enable the Xbox Game Bar

1. Download, Install and Launch the [Xbox App for Windows](https://www.xbox.com/en-US/apps/xbox-app-for-pc)
2. It will prompt you to install missing dependencies, install all of them.
3. Right-Click on Start and open Windows Powershell or Terminal as Admin.
4. Run the following commands:
    ```powershell
    reg.exe add "HKEY_CURRENT_USER\System\GameConfigStore" /v GameDVR_FSEBehavior /t REG_DWORD /d 0 /f
    reg.exe add "HKEY_CURRENT_USER\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 1 /f
    reg.exe add "HKEY_CURRENT_USER\System\GameConfigStore" /v GameDVR_DXGIHonorFSEWindowsCompatible /t REG_DWORD /d 0 /f
    reg.exe add "HKEY_CURRENT_USER\System\GameConfigStore" /v GameDVR_HonorUserFSEBehaviorMode /t REG_DWORD /d 0 /f
    reg.exe add "HKEY_CURRENT_USER\System\GameConfigStore" /v GameDVR_EFSEFeatureFlags /t REG_DWORD /d 1 /f
    reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 1 /f
    ```
5. Restart Your PC to apply the changes.

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
