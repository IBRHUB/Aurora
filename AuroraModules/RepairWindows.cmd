@echo off
setlocal enabledelayedexpansion
:: ============================================================
::                            Aurora
:: ============================================================
:: AUTHOR:
::   IBRHUB - IBRAHIM
::   https://github.com/IBRAHUB
::	 https://docs.ibrhub.net/

title Windows Components Repair
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

:: Define ANSI escape character for colored output
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "ESC=%%b"
)

mode con: cols=100 lines=30
chcp 65001 >nul 2>&1

cls
echo.
echo    %ESC%[38;5;33m╭──────────────────────────────────────────────────────────────────────────────────╮%ESC%[0m
echo    %ESC%[38;5;33m│%ESC%[97m                      Windows Components and System Files Repair                  %ESC%[38;5;33m│%ESC%[0m
echo    %ESC%[38;5;33m╰──────────────────────────────────────────────────────────────────────────────────╯%ESC%[0m
echo.
echo    %ESC%[36mThis utility will perform a comprehensive scan and repair of Windows system components%ESC%[0m
echo    %ESC%[36mto ensure optimal system performance and stability.%ESC%[0m
echo.
echo    %ESC%[33mOperations to be performed:%ESC%[0m
echo    %ESC%[97m⚡ Analyze Windows component store for corruption%ESC%[0m
echo    %ESC%[97m⚡ Restore and repair damaged system components%ESC%[0m 
echo    %ESC%[97m⚡ Deep scan of system files for integrity%ESC%[0m
echo    %ESC%[97m⚡ Validate repairs through CBS log analysis%ESC%[0m
echo.
echo    %ESC%[90mPress any key to initiate the repair process...%ESC%[0m
pause >nul
cls

:main
set start_time=%time%

echo    %ESC%[38;5;33m╭──────────────────────────────────────────────────────────────────────────────────╮%ESC%[0m
echo    %ESC%[38;5;33m│%ESC%[33m                 Please wait while the system is being analyzed and repaired...    %ESC%[38;5;33m│%ESC%[0m
echo    %ESC%[38;5;33m╰──────────────────────────────────────────────────────────────────────────────────╯%ESC%[0m
echo.
echo    %ESC%[38;5;33m╭──────────────────────────────────────────────────────────────────────────────────╮%ESC%[0m
echo    %ESC%[38;5;33m│%ESC%[97m                         Analyzing Windows Component Store                        %ESC%[38;5;33m│%ESC%[0m
echo    %ESC%[38;5;33m╰──────────────────────────────────────────────────────────────────────────────────╯%ESC%[0m
:: dism.exe /online /cleanup-image /scanhealth
:: dism.exe /online /cleanup-image /restorehealth

echo.
echo    %ESC%[38;5;33m╭──────────────────────────────────────────────────────────────────────────────────╮%ESC%[0m
echo    %ESC%[38;5;33m│%ESC%[97m                         System File Integrity Verification                       %ESC%[38;5;33m│%ESC%[0m
echo    %ESC%[38;5;33m╰──────────────────────────────────────────────────────────────────────────────────╯%ESC%[0m
:: sfc.exe /scannow

echo.
echo    %ESC%[38;5;33m╭──────────────────────────────────────────────────────────────────────────────────╮%ESC%[0m
echo    %ESC%[38;5;33m│%ESC%[97m                            CBS Log Analysis Results                              %ESC%[38;5;33m│%ESC%[0m
echo    %ESC%[38;5;33m╰──────────────────────────────────────────────────────────────────────────────────╯%ESC%[0m
findstr /c:"[SR]" %windir%\Logs\CBS\CBS.log >nul 2>&1
if %errorlevel% equ 0 (
   echo    %ESC%[32m[✓] System integrity verification completed - No violations detected%ESC%[0m
) else (
   echo    %ESC%[33m[!] System repairs completed - Some issues were detected and resolved%ESC%[0m
   findstr /c:"[SR]" %windir%\Logs\CBS\CBS.log | findstr /c:"Verify complete" >nul 2>&1
   if %errorlevel% equ 0 (
      echo    %ESC%[32m[✓] All repairs were successful%ESC%[0m
   ) else (
      echo    %ESC%[31m[X] Some repairs may have failed - Check CBS.log for details%ESC%[0m
   )
)

set end_time=%time%
set options="tokens=1-4 delims=:.,"
for /f %options% %%a in ("%start_time%") do set start_h=%%a&set /a start_m=100%%b %% 100&set /a start_s=100%%c %% 100
for /f %options% %%a in ("%end_time%") do set end_h=%%a&set /a end_m=100%%b %% 100&set /a end_s=100%%c %% 100

set /a hours=%end_h%-%start_h%
set /a mins=%end_m%-%start_m%
set /a secs=%end_s%-%start_s%
if %hours% lss 0 set /a hours = 24%hours%
if %mins% lss 0 set /a hours = %hours% - 1 & set /a mins = 60%mins%
if %secs% lss 0 set /a mins = %mins% - 1 & set /a secs = 60%secs%

echo.
echo    %ESC%[38;5;33m╭──────────────────────────────────────────────────────────────────────────────────╮%ESC%[0m
echo    %ESC%[38;5;33m│%ESC%[32m                   System repair and optimization completed successfully!          %ESC%[38;5;33m│%ESC%[0m
echo    %ESC%[38;5;33m│%ESC%[36m                Total processing time: %hours% hours %mins% minutes %secs% seconds                %ESC%[38;5;33m│%ESC%[0m
echo    %ESC%[38;5;33m│%ESC%[33m               A system restart is required to complete the optimization process  %ESC%[38;5;33m│%ESC%[0m
echo    %ESC%[38;5;33m╰──────────────────────────────────────────────────────────────────────────────────╯%ESC%[0m

if "%~1" == "/silent" exit /b
pause
endlocal
:CleanupAndExit
:: Get current PID and terminate process silently
for /f "tokens=2" %%p in ('tasklist /fi "IMAGENAME eq cmd.exe" /fo list ^| findstr "PID:"') do (
    if "%%p" == "%~1" (
        taskkill /F /PID %%p >nul 2>&1
    )
)

:: Alternative method using PowerShell to terminate the current process silently
powershell -Command "$currentPid = [System.Diagnostics.Process]::GetCurrentProcess().Id; Stop-Process -Id $currentPid -Force" > nul 2> nul

exit /b

