@echo off
:: ============================================================================
:: Cloud Settings Configuration Script
:: ============================================================================
::
:: DESCRIPTION:
::   This script disables various cloud synchronization and user profile 
::   engagement features in Windows to enhance privacy and reduce network usage.
::   It modifies registry settings related to:
::   - User Profile Engagement
::   - Windows Settings Sync
::   - Browser Settings Sync
::   - Credentials Sync
::   - Accessibility Settings Sync
::   - Messaging Sync
::
:: NOTES:
::   - Requires administrative privileges to modify registry settings
::   - Changes take effect immediately but may require restart
::   - All operations are performed silently (> NUL 2>&1)
::
:: ============================================================================

:: Ensure admin privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Administrator privileges are required.
    PowerShell Start-Process -Verb RunAs -FilePath '%0' 2>nul || (
        echo Right-click on the script and select "Run as administrator".
        pause & exit 1
    )
    exit 0
)

reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement" /v "ScoobeSystemSettingEnabled" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "DisableSettingSync" /t REG_DWORD /d 2 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "DisableSettingSyncUserOverride" /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "DisableSyncOnPaidNetwork" /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "DisableWindowsSettingSync" /t REG_DWORD /d 2 /f > NUL 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization" /v "Enabled" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\BrowserSettings" /v "Enabled" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Credentials" /v "Enabled" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility" /v "Enabled" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Windows" /v "Enabled" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync" /v "SyncPolicy" /t REG_DWORD /d 5 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Messaging" /v "AllowMessageSync" /t REG_DWORD /d 0 /f > NUL 2>&1
exit /b 0
