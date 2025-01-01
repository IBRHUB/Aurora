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
dism.exe /online /cleanup-image /scanhealth
dism.exe /online /cleanup-image /restorehealth

echo]
echo %ESC%[36m╔════════════════════════════════════════╗
echo ║ Scanning and Repairing System Files... ║
echo ╚════════════════════════════════════════╝%ESC%[0m
sfc.exe /scannow

echo]
echo %ESC%[36m╔════════════════════════════════════════╗
echo ║ Checking CBS Logs for Issues...        ║
echo ╚════════════════════════════════════════╝%ESC%[0m
findstr /c:"[SR]" %windir%\Logs\CBS\CBS.log >nul 2>&1
if %errorlevel% neq 0 (
    echo %ESC%[32mNo integrity violations detected.%ESC%[0m
) else (
    echo %ESC%[33mSome issues were found and repaired.%ESC%[0m
)

echo]
echo %ESC%[36m╔════════════════════════════════════════╗
echo ║ Checking and Repairing Windows Tweaks  ║
echo ╚════════════════════════════════════════╝%ESC%[0m


:: Check SvcHostSplitThresholdInKB
reg query "HKLM\SYSTEM\CurrentControlSet\Control" /v SvcHostSplitThresholdInKB | find "3670016" >nul
if errorlevel 1 (
    echo [Svc Split Threshold] - %ESC%[33mBad%ESC%[0m
    reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v SvcHostSplitThresholdInKB /t REG_DWORD /d 3670016 /f >nul
    reg add "HKLM\SYSTEM\ControlSet001\Control" /v SvcHostSplitThresholdInKB /t REG_DWORD /d 3670016 /f >nul
) else (
    echo [Svc Split Threshold] - %ESC%[32mGood%ESC%[0m
)

:: Check BCDEdit settings
bcdedit | findstr /i "useplatformclock disabledynamictick useplatformtick tscsyncpolicy" >nul
if not errorlevel 1 (
    echo [Bcdedit] - %ESC%[33mBad%ESC%[0m
    bcdedit /deletevalue useplatformclock >nul 2>&1
    bcdedit /deletevalue disabledynamictick >nul 2>&1
    bcdedit /deletevalue useplatformtick >nul 2>&1
    bcdedit /deletevalue tscsyncpolicy >nul 2>&1
) else (
    echo [Bcdedit] - %ESC%[32mGood%ESC%[0m
)

:: Check Timer Resolution
tasklist /fi "imagename eq TimerResolution.exe" | find "TimerResolution.exe" >nul
if not errorlevel 1 (
    echo [Timer Resolution] - %ESC%[33mBad%ESC%[0m
    taskkill /f /im TimerResolution.exe >nul 2>&1
) else (
    echo [Timer Resolution] - %ESC%[32mGood%ESC%[0m
)

:: Check Win32PrioritySeparation
reg query "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation | find "0x26" >nul
if errorlevel 1 (
    echo [Win32PrioritySeparation] - %ESC%[33mBad%ESC%[0m
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 38 /f >nul
    reg add "HKLM\SYSTEM\ControlSet001\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 38 /f >nul
) else (
    echo [Win32PrioritySeparation] - %ESC%[32mGood%ESC%[0m
)

:: Check TCP Auto-Tuning
netsh interface tcp show global | find /i "normal" >nul
if errorlevel 1 (
    echo [Tcp Auto-Tuning] - %ESC%[33mBad%ESC%[0m
    netsh interface tcp set global autotuninglevel=normal >nul
) else (
    echo [Tcp Auto-Tuning] - %ESC%[32mGood%ESC%[0m
)

:: Check Prefetch
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnablePrefetcher | find "0x3" >nul
if errorlevel 1 (
    echo [Prefetch] - %ESC%[33mBad%ESC%[0m
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnablePrefetcher /t REG_DWORD /d 3 /f >nul
) else (
    echo [Prefetch] - %ESC%[32mGood%ESC%[0m
)

:: Check Windows Error Reporting
sc query WerSvc | find "RUNNING" >nul
if errorlevel 1 (
    echo [Windows Error Reporting] - %ESC%[33mBad%ESC%[0m
    sc config WerSvc start= demand >nul
    net start WerSvc >nul 2>&1
) else (
    echo [Windows Error Reporting] - %ESC%[32mGood%ESC%[0m  
)

:: Check SysMain Service
sc query SysMain | find "RUNNING" >nul
if errorlevel 1 (
    echo [Sysmain Service] - %ESC%[33mBad%ESC%[0m
    sc config SysMain start= auto >nul
    net start SysMain >nul 2>&1
) else (
    echo [Sysmain Service] - %ESC%[32mGood%ESC%[0m  
)

:: Check Mouse/Keyboard Queue Size
reg query "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v KeyboardDataQueueSize | find "0x64" >nul
if errorlevel 1 (
    echo [Mouse Keyboard Queue Size] - %ESC%[33mBad%ESC%[0m
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v KeyboardDataQueueSize /t REG_DWORD /d 100 /f >nul
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v MouseDataQueueSize /t REG_DWORD /d 100 /f >nul
) else (
    echo [Mouse Keyboard Queue Size] - %ESC%[32mGood%ESC%[0m
)

:: Check HPET
reg query "HKLM\SYSTEM\CurrentControlSet\Enum\ACPI\PNP0103" /v "Problem" >nul 2>&1
if not errorlevel 1 (
    echo [HPET] - %ESC%[33mBad%ESC%[0m
    devcon enable *PNP0103 >nul 2>&1
) else (
    echo [HPET] - %ESC%[32mGood%ESC%[0m
)

:: Check Windows Search Service
sc query WSearch | find "RUNNING" >nul
if errorlevel 1 (
    echo [Windows Search] - %ESC%[33mBad%ESC%[0m
    sc config WSearch start= auto >nul
    net start WSearch >nul 2>&1
) else (
    echo [Windows Search] - %ESC%[32mGood%ESC%[0m
)

:: Check Windows Audio Service
sc query Audiosrv | find "RUNNING" >nul 
if errorlevel 1 (
    echo [Windows Audio] - %ESC%[33mBad%ESC%[0m
    sc config Audiosrv start= auto >nul
    net start Audiosrv >nul 2>&1
) else (
    echo [Windows Audio] - %ESC%[32mGood%ESC%[0m
)

:: Check Windows Update Service
sc query wuauserv | find "RUNNING" >nul
if errorlevel 1 (
    echo [Windows Update] - %ESC%[33mBad%ESC%[0m
    sc config wuauserv start= auto >nul
    net start wuauserv >nul 2>&1
) else (
    echo [Windows Update] - %ESC%[32mGood%ESC%[0m
)

:: Check Network List Service
sc query netprofm | find "RUNNING" >nul
if errorlevel 1 (
    echo [Network List Service] - %ESC%[33mBad%ESC%[0m
    sc config netprofm start= auto >nul
    net start netprofm >nul 2>&1
) else (
    echo [Network List Service] - %ESC%[32mGood%ESC%[0m
)


:: Check DNS Client
sc query Dnscache | find "RUNNING" >nul
if errorlevel 1 (
    echo [DNS Client] - %ESC%[33mBad%ESC%[0m
    sc config Dnscache start= auto >nul
    net start Dnscache >nul 2>&1
) else (
    echo [DNS Client] - %ESC%[32mGood%ESC%[0m
)


echo]
echo %ESC%[32mRepair process completed! %ESC%[0m& echo. & echo Please reboot your device for changes to take effect.
if "%~1" == "/silent" exit /b
pause
endlocal
exit /b


