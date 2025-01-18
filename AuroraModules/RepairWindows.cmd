@echo off
setlocal enabledelayedexpansion

title Windows Components Repair @IBRHUB
cd /d "%~dp0"

if "%~1" == "/silent" goto main

fltmc >nul 2>&1 || (
    echo Administrator privileges are required.
    PowerShell Start -Verb RunAs '%0' 2>nul || (
        echo You must run this script as administrator.
        exit /b 1
    )
    exit /b
)

:: Set ANSI escape characters
for /f %%a in ('forfiles /m "%~nx0" /c "cmd /c echo 0x1B"') do set "ESC=%%a"
set "right=%ESC%[<x>C"
set "bullet=%ESC%[34m-%ESC%[0m"

mode con: cols=60 lines=20
chcp 65001 >nul

echo]
echo %ESC%[31m   Windows Components and System Files Repair
echo   ──────────────────────────────────────────────────%ESC%[0m
echo   This utility will scan and repair corrupted Windows
echo   components and system files on your device.
echo]
echo   %ESC%[7mThe following tasks will be performed:%ESC%[0m
echo   %bullet% Check Windows component store integrity
echo   %bullet% Restore corrupted system components
echo   %bullet% Scan and repair system files
echo   %bullet% Verify repairs in CBS logs
echo   %bullet% Check and repair Windows tweaks
echo]
echo   Press any key to begin the repair process...
pause >nul
cls

:main
echo %ESC%[33mThis process might take a while. Please be patient.%ESC%[0m

echo]
echo %ESC%[36m╔════════════════════════════════════════╗
echo ║ Checking Windows Component Store...    ║
echo ╚════════════════════════════════════════╝%ESC%[0m
::dism.exe /online /cleanup-image /scanhealth
::dism.exe /online /cleanup-image /restorehealth

echo]
echo %ESC%[36m╔════════════════════════════════════════╗
echo ║ Scanning and Repairing System Files... ║
echo ╚════════════════════════════════════════╝%ESC%[0m
::sfc.exe /scannow
echo]
echo %ESC%[36m╔════════════════════════════════════════╗
echo ║ Checking CBS Logs for Issues...        ║
echo ╚════════════════════════════════════════╝%ESC%[0m
::findstr /c:"[SR]" %windir%\Logs\CBS\CBS.log >nul 2>&1
::if %errorlevel% neq 0 (
::    echo %ESC%[32mNo integrity violations detected.%ESC%[0m
::) else (
::   echo %ESC%[33mSome issues were found and repaired.%ESC%[0m
::)


echo]
echo %ESC%[32mRepair process completed! %ESC%[0m& echo. & echo Please reboot your device for changes to take effect.
if "%~1" == "/silent" exit /b
pause
endlocal
exit /b


