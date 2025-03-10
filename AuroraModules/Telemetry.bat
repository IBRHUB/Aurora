@echo off
:: ============================================================
:: Windows Telemetry Configuration Script
:: ============================================================
::
:: DESCRIPTION:
::   This script disables various Windows telemetry and data 
::   collection features to enhance privacy. It:
::   - Disables .NET Core CLI telemetry
::   - Turns off diagnostic data collection
::   - Disables handwriting data sharing
::   - Prevents personalization data collection
::   - Stops the DiagTrack service
::   - Cleans up diagnostic logs
::
:: DOCUMENTATION:
::   .NET Telemetry: https://learn.microsoft.com/en-us/dotnet/core/tools/telemetry
::
:: NOTES:
::   - Requires TrustedInstaller privileges
::   - Changes take effect after reboot
::   - Can be reverted via Windows Settings
:: ============================================================
::                            Aurora
:: ============================================================
:: AUTHOR:
::   IBRHUB - IBRAHIM
::   https://github.com/IBRAHUB
::	 https://docs.ibrhub.net/
:: ============================================================

set AuroraAsTrustedInstaller=%~dp0\AuroraSudo.exe

:: These operations don't require TrustedInstaller
setx DOTNET_CLI_TELEMETRY_OPTOUT 1 > NUL 2>&1
reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Input\Settings" /v "InsightsEnabled" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /v "ShowedToastAtLevel" /t REG_DWORD /d 1 /f > NUL 2>&1

:: These operations require TrustedInstaller due to HKLM and system paths
%AuroraAsTrustedInstaller% --TrustedInstaller --Privileged --NoLogo reg add "HKLM\SOFTWARE\Policies\Microsoft\AppV\CEIP" /v "CEIPEnable" /t REG_DWORD /d 0 /f >nul 2>nul
%AuroraAsTrustedInstaller% --TrustedInstaller --Privileged --NoLogo reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d 0 /f >nul 2>nul
%AuroraAsTrustedInstaller% --TrustedInstaller --Privileged --NoLogo reg add "HKLM\SYSTEM\CurrentControlSet\Control\Diagnostics\Performance" /v "DisableDiagnosticTracing" /t REG_DWORD /d 1 /f >nul 2>nul
%AuroraAsTrustedInstaller% --TrustedInstaller --Privileged --NoLogo reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\TabletPC" /v "PreventHandwritingDataSharing" /t REG_DWORD /d 1 /f >nul 2>nul
%AuroraAsTrustedInstaller% --TrustedInstaller --Privileged --NoLogo reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" /v "PreventHandwritingErrorReports" /t REG_DWORD /d 1 /f >nul 2>nul
%AuroraAsTrustedInstaller% --TrustedInstaller --Privileged --NoLogo reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform" /v "NoGenTicket" /t REG_DWORD /d 1 /f >nul 2>nul
%AuroraAsTrustedInstaller% --TrustedInstaller --Privileged --NoLogo reg add "HKLM\SYSTEM\CurrentControlSet\Services\DiagTrack" /v "Start" /t REG_DWORD /d "4" /f >nul 2>nul
%AuroraAsTrustedInstaller% --TrustedInstaller --Privileged --NoLogo reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>nul
%AuroraAsTrustedInstaller% --TrustedInstaller --Privileged --NoLogo reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "MaxTelemetryAllowed" /t REG_DWORD /d 0 /f >nul 2>nul
%AuroraAsTrustedInstaller% --TrustedInstaller --Privileged --NoLogo reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>nul
%AuroraAsTrustedInstaller% --TrustedInstaller --Privileged --NoLogo reg delete "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\Diagtrack-Listener" /f >nul 2>nul
%AuroraAsTrustedInstaller% --TrustedInstaller --Privileged --NoLogo reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\Diagtrack-Listener" /v "Start" /t REG_DWORD /d 0 /f >nul 2>nul
%AuroraAsTrustedInstaller% --TrustedInstaller --Privileged --NoLogo del /F /Q "%ProgramData%\Microsoft\Diagnosis\ETLLogs\AutoLogger\DiagTrack*" >nul 2>nul
%AuroraAsTrustedInstaller% --TrustedInstaller --Privileged --NoLogo del /F /Q "%ProgramData%\Microsoft\Diagnosis\ETLLogs\ShutdownLogger\DiagTrack*" >nul 2>nul
exit /b
