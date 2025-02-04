@echo off
:: ============================================================
::                            Aurora
:: ============================================================
:: AUTHOR:
::   IBRHUB
::   https://github.com/IBRAHUB
::	 https://docs.ibrhub.net/
::
:: VERSION:
::   1.0.0 beta
::
:: LICENSE:
::   MIT License
::   Copyright (c) 2024 IBRAHUB
::
:: ============================================================

:: Check for administrator privileges
net session >nul 2>&1
if errorlevel 1 (
    echo This script requires administrator privileges.
    echo Relaunching as Administrator...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: Check Internet Connection
ping -n 1 google.com >nul 2>&1
if errorlevel 1 (
    echo ERROR: No internet connection detected.
    echo Please connect to the internet and try again.
    pause
    exit /b
)

:: Check if curl is available (Windows 10+ normally includes curl) 
where curl >nul 2>&1
if errorlevel 1 (
    echo Error: curl is required but not found.
    echo Please install curl or run this script on a supported version of Windows.
    pause
    exit /b
)

::  Set directories for Aurora modules 
set "targetDir=%temp%\AuroraModules"
set "currentDir=%~dp0AuroraModules"
if not exist "%targetDir%" mkdir "%targetDir%"
if not exist "%currentDir%" mkdir "%currentDir%"
move "%targetDir%\*" "%currentDir%\" >nul 2>&1
powershell.exe -Command "$host.ui.RawUI.WindowTitle = 'Aurora | @by IBRHUB'"

curl -g -k -L -# -o "%targetDir%\RestorePoint.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/RestorePoint.ps1" >nul 2>&1
curl -g -k -L -# -o "%targetDir%\LockConsoleSize.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/LockConsoleSize.ps1" >nul 2>&1
curl -g -k -L -# -o "%targetDir%\SetConsoleOpacity.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/SetConsoleOpacity.ps1" >nul 2>&1

:: Set console size and appearance
:: powershell.exe -ExecutionPolicy Bypass -File "%currentDir%\RestorePoint.ps1"
powershell.exe -ExecutionPolicy Bypass -File "%currentDir%\LockConsoleSize.ps1"
powershell.exe -ExecutionPolicy Bypass -File "%currentDir%\SetConsoleOpacity.ps1"

:: Enable delayed expansion for the registry operations
setlocal EnableDelayedExpansion


:: Background: Black (0), Text: White (F)
color 0F

:: Define BS (backspace) variable if not defined
if not defined BS set "BS="



:: Check PowerShell version and set execution policy accordingly
powershell -Command "$PSVersionTable.PSVersion.Major" > "%TEMP%\psver.txt"
set /p PS_VER=<"%TEMP%\psver.txt"
del "%TEMP%\psver.txt"

:: For PowerShell 5.1 and below (Windows 10/11)
if %PS_VER% LEQ 5 (
    for %%R in (
        "HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell"
        "HKLM\SOFTWARE\Wow6432Node\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell"
    ) do (
        powershell.exe "Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine -Force" >NUL 2>&1
        REG QUERY "%%R" /v ExecutionPolicy >nul 2>&1
        if !errorlevel! neq 0 (
            REG ADD "%%R" /v ExecutionPolicy /t REG_SZ /d Bypass /f >nul 2>&1
        ) else (
            for /f "tokens=2*" %%A in ('REG QUERY "%%R" /v ExecutionPolicy ^| findstr ExecutionPolicy') do (
                if /I "%%B" neq "Bypass" (
                    REG ADD "%%R" /v ExecutionPolicy /t REG_SZ /d Bypass /f >nul 2>&1
                )
            )
        )
    )
) else (
    :: For PowerShell 7+ (Windows 11 24H2)
    powershell.exe "Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine -Force" >NUL 2>&1
)

:: Verify execution policy was set correctly
powershell.exe "Get-ExecutionPolicy -Scope LocalMachine" | findstr /I "Bypass" >NUL
if errorlevel 1 (
    echo Warning: Failed to set PowerShell execution policy to Bypass
    timeout /t 3 /nobreak >NUL
)


:: start https://docs.ibrhub.net/ar/disclaimer
:: set ANSI escape characters
cd /d "%~dp0"
for /f %%a in ('forfiles /m "%~nx0" /c "cmd /c echo 0x1B"') do set "ESC=%%a"
set "right=%ESC%[<x>C"
set "bullet= %ESC%[34m-%ESC%[0m"
chcp 65001 >NUL

cls
goto :DISCLAIMER


:DISCLAIMER
cls
mode con cols=61 lines=27
color 0f
echo.
echo    %ESC%[1;3;38;5;195m✦  Disclaimer  -  Version 0.1 beta  ✦%ESC%[0m
echo.
echo    %ESC%[38;5;33m╔══════════════════════════════════════════════════════╗%ESC%[0m
echo    %ESC%[38;5;33m║%ESC%[93m  This software makes system modifications that may   %ESC%[38;5;33m║
echo    %ESC%[38;5;33m║%ESC%[93m  affect system stability. By continuing, you agree   %ESC%[38;5;33m║
echo    %ESC%[38;5;33m║%ESC%[93m  to our terms of service and privacy policy.         %ESC%[38;5;33m║
echo    %ESC%[38;5;33m║%ESC%[0m                                                      %ESC%[38;5;33m║
echo    %ESC%[38;5;33m║%ESC%[96m  Full disclaimer:                                    %ESC%[38;5;33m║
echo    %ESC%[38;5;33m║%ESC%[94m  https://docs.ibrhub.net/ar/disclaimer               %ESC%[38;5;33m║
echo    %ESC%[38;5;33m╚══════════════════════════════════════════════════════╝%ESC%[0m
echo.
echo    %ESC%[38;5;33m╭──────────────────────────────────────────────────────╮%ESC%[0m
echo    %ESC%[38;5;33m│%ESC%[92m  ► 1. %ESC%[97mI agree to the terms and conditions            %ESC%[38;5;33m│%ESC%[0m
echo    %ESC%[38;5;33m│%ESC%[91m  ► 2. %ESC%[97mI do not agree (exit program)                  %ESC%[38;5;33m│%ESC%[0m
echo    %ESC%[38;5;33m╰──────────────────────────────────────────────────────╯%ESC%[0m
echo.
echo.

:: Prompt user for input
set /p choice=%ESC%[1;38;5;214m[%ESC%[93mAurora%ESC%[1;38;5;214m]%ESC%[38;5;87m Select option [1-2]: %ESC%[0m

:: Handle user's choice
if /I "%choice%"=="1" (
    echo %ESC%[92m✓%ESC%[0m Agreement confirmed. Initializing Aurora...
    timeout /t 1 /nobreak > NUL
    goto :StartAurora
) else if /I "%choice%"=="2" (
    echo %ESC%[91m✗%ESC%[0m Agreement declined. Exiting program...
    timeout /t 1 /nobreak > NUL
    goto :endAurora
) else (
    echo %ESC%[91mInvalid selection!%ESC%[0m Please choose 1 or 2
    timeout /t 1 /nobreak > NUL
    goto :DISCLAIMER
)

:bypass

goto :MainMenu


:endAurora

exit /b


:StartAurora

cls


:: Check if all required files exist
:CheckFiles
setlocal enabledelayedexpansion
set "allFilesExist=true"

:: List of required files
set "requiredFiles[0]=LockConsoleSize.ps1"
set "requiredFiles[1]=OneDrive.ps1"
set "requiredFiles[2]=Power.ps1"
set "requiredFiles[3]=RestorePoint.ps1"
set "requiredFiles[4]=SetConsoleOpacity.ps1"
set "requiredFiles[5]=NvidiaProfileInspector.cmd"
set "requiredFiles[6]=AuroraAMD.bat"
set "requiredFiles[7]=NetworkBufferBloatFixer.ps1"
set "requiredFiles[8]=Cloud.bat"
set "requiredFiles[9]=Telemetry.bat"
set "requiredFiles[10]=Privacy.bat"
set "requiredFiles[11]=RepairWindows.cmd"
set "requiredFiles[12]=AuroraAvatar.ico"
set "requiredFiles[13]=RemoveEdge.ps1"
set "requiredFiles[14]=Components.ps1"
set "requiredFiles[15]=AuroraTimerResolution.cs"
set "requiredFiles[16]=AuroraTimerResolution.ps1"
set "requiredFiles[17]=AuroraManualServices.cmd"
set "requiredFiles[18]=AuroraSudo.exe"

:: Check each file
for /L %%i in (0,1,18) do (
    if not exist "%currentDir%\!requiredFiles[%%i]!" (
        set "allFilesExist=false"
        goto :checkResult
    )
)

:checkResult
if "!allFilesExist!"=="true" (
    echo   %ESC%[38;5;33m╔══════════════════════════════════════════════════════╗%ESC%[0m
    echo   %ESC%[38;5;33m║%ESC%[92m Required files already exist. Skipping download...   %ESC%[38;5;33m║
    echo   %ESC%[38;5;33m╚══════════════════════════════════════════════════════╝%ESC%[0m
    timeout /t 3 /nobreak > NUL
    goto :skipDownload
) else (
    goto :DownloadModules
)
endlocal

:DownloadModules
cls
mode con cols=98 lines=35
echo    %ESC%[1;3;38;5;195m✦  Downloading Aurora Modules  -  v1.0.0 beta  ✦%ESC%[0m
echo.
echo    %ESC%[38;5;33m╔══════════════════════════════════════════════════════╗%ESC%[0m
echo    %ESC%[38;5;33m║%ESC%[97m           Initializing Download Queue                  %ESC%[38;5;33m║
echo    %ESC%[38;5;33m╚══════════════════════════════════════════════════════╝%ESC%[0m

call :UpdateProgress 0 "LockConsoleSize.ps1"
curl -g -k -L -# -o "%targetDir%\LockConsoleSize.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/LockConsoleSize.ps1" >nul 2>&1

call :UpdateProgress 3.5 "OneDrive.ps1"
curl -g -k -L -# -o "%targetDir%\OneDrive.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/OneDrive.ps1" >nul 2>&1

call :UpdateProgress 7.0 "Power.ps1"
curl -g -k -L -# -o "%targetDir%\Power.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/Power.ps1" >nul 2>&1

call :UpdateProgress 10.5 "RestorePoint.ps1"
curl -g -k -L -# -o "%targetDir%\RestorePoint.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/RestorePoint.ps1" >nul 2>&1

call :UpdateProgress 18.0 "SetConsoleOpacity.ps1"
curl -g -k -L -# -o "%targetDir%\SetConsoleOpacity.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/SetConsoleOpacity.ps1" >nul 2>&1

call :UpdateProgress 21.5 "NetworkBufferBloatFixer.ps1"
curl -g -k -L -# -o "%targetDir%\NetworkBufferBloatFixer.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/NetworkBufferBloatFixer.ps1" >nul 2>&1

call :UpdateProgress 27.0 "RemoveEdge.ps1"
curl -g -k -L -# -o "%targetDir%\RemoveEdge.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/RemoveEdge.ps1" >nul 2>&1

call :UpdateProgress 30.5 "Components.ps1"
curl -g -k -L -# -o "%targetDir%\Components.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/Components.ps1" >nul 2>&1

call :UpdateProgress 34.0 "AuroraTimerResolution.cs"
curl -g -k -L -# -o "%targetDir%\AuroraTimerResolution.cs" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/AuroraTimerResolution.cs" >nul 2>&1

call :UpdateProgress 47.0 "AuroraTimerResolution.ps1"
curl -g -k -L -# -o "%targetDir%\AuroraTimerResolution.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/AuroraTimerResolution.ps1" >nul 2>&1

call :UpdateProgress 59.5 "AuroraSudo.exe"
curl -g -k -L -# -o "%targetDir%\AuroraSudo.exe" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/AuroraSudo.exe" >nul 2>&1

call :UpdateProgress 69.0 "NvidiaProfileInspector.cmd"
curl -g -k -L -# -o "%targetDir%\NvidiaProfileInspector.cmd" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/NvidiaProfileInspector.cmd" >nul 2>&1

call :UpdateProgress 75.0 "AuroraAMD.bat"
curl -g -k -L -# -o "%targetDir%\AuroraAMD.bat" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/AuroraAMD.bat" >nul 2>&1

call :UpdateProgress 79.5 "Cloud.bat"
curl -g -k -L -# -o "%targetDir%\Cloud.bat" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/Cloud.bat" >nul 2>&1

call :UpdateProgress 85.0 "Telemetry.bat"
curl -g -k -L -# -o "%targetDir%\Telemetry.bat" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/Telemetry.bat" >nul 2>&1

call :UpdateProgress 90.5 "Privacy.bat"
curl -g -k -L -# -o "%targetDir%\Privacy.bat" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/Privacy.bat" >nul 2>&1

call :UpdateProgress 93.5 "RepairWindows.cmd"
curl -g -k -L -# -o "%targetDir%\RepairWindows.cmd" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/RepairWindows.cmd" >nul 2>&1

call :UpdateProgress 99.5 "AuroraAvatar.ico"
curl -g -k -L -# -o "%targetDir%\AuroraAvatar.ico" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/Docs/Assets/AuroraAvatar.ico" >nul 2>&1

call :UpdateProgress 100.0 "AuroraManualServices.cmd"
curl -g -k -L -# -o "%targetDir%\AuroraManualServices.cmd" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/AuroraManualServices.cmd" >nul 2>&1

echo    %ESC%[38;5;33m╔══════════════════════════════════════════════════════╗%ESC%[0m
echo    %ESC%[38;5;33m║%ESC%[92m ✓  All modules downloaded successfully! %ESC%[92m(100%%)%ESC%[38;5;33m ║
echo    %ESC%[38;5;33m╚══════════════════════════════════════════════════════╝%ESC%[0m
timeout /t 5 /nobreak > NUL
goto :skipDownload

:UpdateProgress
setlocal enabledelayedexpansion

set "percentage=%~1"
set "filename=%~2"

:: Progress bar calculation
set /a "blocks=percentage / 2"
set "progressBar=%ESC%[92m"
for /l %%i in (1,1,%blocks%) do set "progressBar=!progressBar!█"
set "progressBar=%progressBar%%ESC%[90m"
for /l %%i in (%blocks%,1,49) do set "progressBar=!progressBar!─"
set "progressBar=%progressBar%%ESC%[0m"

:: Clear previous lines (3 lines up)
echo    %ESC%[2K    :: Clear line
echo    %ESC%[2K    :: Clear line
echo    %ESC%[2K    :: Clear line
echo    %ESC%[3A    
CLS
:: Update display
echo    %ESC%[38;5;33m╔══════════════════════════════════════════════════════╗%ESC%[0m
echo    %ESC%[38;5;33m║%ESC%[97m Downloading:%ESC%[96m %filename% %ESC%[0m
echo    %ESC%[38;5;33m║%ESC%[0m [%progressBar%] %ESC%[93m%percentage%%%%ESC%[0m
echo    %ESC%[38;5;33m╚══════════════════════════════════════════════════════╝%ESC%[0m

:: Small delay instead of pause
timeout /t 1 /nobreak >nul
endlocal
goto :eof

:skipDownload
if not exist "%currentDir%" mkdir "%currentDir%"
move "%targetDir%\*" "%currentDir%\" >nul 2>&1
cls


:: Enable ANSI Escape Sequences
reg add "HKCU\CONSOLE" /v "VirtualTerminalLevel" /t REG_DWORD /d "1" /F >NUL 2>&1

:: Disabled modules:
:: powershell.exe -ExecutionPolicy Bypass -File "%currentDir%\resizeConsole.ps1"

:: Disable process mitigations
:: powershell.exe "ForEach($v in (Get-Command -Name \"Set-ProcessMitigation\").Parameters[\"Disable\"].Attributes.ValidValues){Set-ProcessMitigation -System -Disable $v.ToString() -ErrorAction SilentlyContinue}"  >NUL 2>&1
cls
rem ========================================================================================================================================
:: ANSI Escape Code Definition
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "ESC=%%b"
)

:: Enable ANSI Support (Windows 10+)
REG ADD HKCU\CONSOLE /f /v VirtualTerminalLevel /t REG_DWORD /d 1 > nul 2>&1

color 0f

:MainMenu
chcp 65001 >NUL
CLS
mode con cols=98 lines=40
echo.
echo.
echo.
echo.
echo.
echo.
echo                        %ESC%[1;38;5;33m╔══════════════════════════════════════════════════════╗
echo                        %ESC%[1;38;5;33m║%ESC%[1;38;5;87m   █████╗ ██╗   ██╗██████╗  ██████╗ ██████╗   █████╗  %ESC%[1;38;5;33m║
echo                        %ESC%[1;38;5;33m║%ESC%[1;38;5;159m  ██╔══██╗██║   ██║██╔══██╗██╔═══██╗██╔══██╗ ██╔══██╗ %ESC%[1;38;5;33m║
echo                        %ESC%[1;38;5;33m║%ESC%[1;38;5;195m  ███████║██║   ██║██████╔╝██║   ██║██████╔╝ ███████║ %ESC%[1;38;5;33m║
echo                        %ESC%[1;38;5;33m║%ESC%[1;38;5;195m  ██╔══██║██║   ██║██╔══██╗██║   ██║██╔══██╗ ██╔══██║ %ESC%[1;38;5;33m║
echo                        %ESC%[1;38;5;33m║%ESC%[1;38;5;159m  ██║  ██║╚██████╔╝██║  ██║╚██████╔╝██║  ██║ ██║  ██║ %ESC%[1;38;5;33m║
echo                        %ESC%[1;38;5;33m║%ESC%[1;38;5;87m  ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═╝  ╚═╝ %ESC%[1;38;5;33m║
echo                        %ESC%[1;38;5;33m╚══════════════════════════════════════════════════════╝%ESC%[0m
echo.
echo                             %ESC%[1;3;38;5;195m✦ Optimize - Secure - Enhance - Personalize ✦%ESC%[0m
echo.
echo                      %ESC%[38;5;33m╭──────────────────────────────┬──────────────────────────────╮%ESC%[0m
echo                      %ESC%[38;5;33m│%ESC%[0m  %ESC%[38;5;87m1%ESC%[0m ■ %ESC%[1;37mWindows Tweaks          %ESC%[38;5;33m│%ESC%[0m  %ESC%[38;5;87m5%ESC%[0m ■ %ESC%[1;37mDisable Services        %ESC%[38;5;33m│%ESC%[0m
echo                      %ESC%[38;5;33m│%ESC%[0m  %ESC%[38;5;87m2%ESC%[0m ■ %ESC%[1;37mGPU Optimization        %ESC%[38;5;33m│%ESC%[0m  %ESC%[38;5;87m6%ESC%[0m ■ %ESC%[1;37mDark Mode Toggle        %ESC%[38;5;33m│%ESC%[0m
echo                      %ESC%[38;5;33m│%ESC%[0m  %ESC%[38;5;87m3%ESC%[0m ■ %ESC%[1;37mNetwork Configuration   %ESC%[38;5;33m│%ESC%[0m  %ESC%[38;5;87m7%ESC%[0m ■ %ESC%[1;37mSystem Repair           %ESC%[38;5;33m│%ESC%[0m
echo                      %ESC%[38;5;33m│%ESC%[0m  %ESC%[38;5;87m4%ESC%[0m ■ %ESC%[1;37mPower Plans             %ESC%[38;5;33m│%ESC%[0m  %ESC%[38;5;87m8%ESC%[0m ■ %ESC%[1;34mDiscord Community       %ESC%[38;5;33m│%ESC%[0m
echo                      %ESC%[38;5;33m├──────────────────────────────┼──────────────────────────────┤%ESC%[0m
echo                      %ESC%[38;5;33m│%ESC%[0m  %ESC%[38;5;87m9%ESC%[0m ■ %ESC%[1;34mIBRHUB Portal           %ESC%[38;5;33m│%ESC%[0m  %ESC%[38;5;87m10%ESC%[0m ■ %ESC%[1;34mDocumentation          %ESC%[38;5;33m│%ESC%[0m
echo                      %ESC%[38;5;33m╰──────────────────────────────┴──────────────────────────────╯%ESC%[0m
echo.
echo.
echo                                           %ESC%[38;5;196m[ 0 ]%ESC%[0m %ESC%[1;3;38;5;196mExit AURORA %ESC%[0m
echo.
echo.
set /p "input=%ESC%[38;5;33m %ESC%[3;38;5;195mEnter choice [0-10]%ESC%[0m%ESC%[38;5;33m: %ESC%[0m"

if not defined input goto :MainMenu
if "%input%"=="" goto :MainMenu
set "input=%input:"=%"

if "%input%"=="1" goto :WinTweaks
if "%input%"=="2" goto :GPUTweaks
if "%input%"=="3" goto :NetworkTweaks
if "%input%"=="4" goto :Power-Plan
if "%input%"=="5" goto :ManualServices
if "%input%"=="6" goto :DarkMode
if "%input%"=="7" goto :RepairWindows
if "%input%"=="8" goto :Discord
if "%input%"=="9" (start https://ibrpride.com/ & goto :MainMenu)
if "%input%"=="10" (start https://docs.ibrhub.net & goto :MainMenu)
if "%input%"=="0" goto :AuroraExit

echo %ESC%[91mInvalid input. Please select a number between 0 and 10.%ESC%[0m
timeout /t 1 /nobreak > nul
goto :MainMenu

:AuroraExit
CLS
echo %ESC%[1;92mThank you for using AURORA Optimizer!%ESC%[0m
timeout /t 2 /nobreak > nul
exit

:WinTweaks
mode con cols=76 lines=35

:: Standard Header for All Sections
:SectionHeader
mode con cols=98 lines=45

cls
echo.
echo.
echo                           %ESC%[1;38;5;159m╭──────────────────────────╮
echo                           %ESC%[1;38;5;159m│        %ESC%[1;97mA U R O R A%ESC%[1;38;5;159m       │
echo                           %ESC%[1;38;5;159m╰──────────────────────────╯%ESC%[0m
echo.

:: - Setting UAC - never notify
:: reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v PromptOnSecureDesktop /t REG_DWORD /d 0 /f > NUL 2>&1
:: reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 0 /f > NUL 2>&1
:: reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 0 /f > NUL 2>&1

echo.%ESC%[38;5;33m  - Setting Edge policies
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v StartupBoostEnabled /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v HardwareAccelerationModeEnabled /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v BackgroundModeEnabled /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\MicrosoftEdgeElevationService" /v Start /t REG_DWORD /d 4 /f > NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\edgeupdate" /v Start /t REG_DWORD /d 4 /f > NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\edgeupdatem" /v Start /t REG_DWORD /d 4 /f > NUL 2>&1

echo. - Setting Chrome policies
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v StartupBoostEnabled /t REG_DWORD /d 0 /f > NUL 2>&1
:: reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v HardwareAccelerationModeEnabled /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v BackgroundModeEnabled /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v HighEfficiencyModeEnabled /t REG_DWORD /d 1 /f > NUL 2>&1

:: echo. - Enabling old NVIDIA sharpening
:: reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS" /v EnableGR535 /t REG_DWORD /d 0 /f > NUL 2>&1

echo. - Disabling NVIDIA Telemetry
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v NvBackend /f > NUL 2>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" /v OptInOrOutPreference /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v EnableRID66610 /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v EnableRID64640 /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v EnableRID44231 /t REG_DWORD /d 0 /f > NUL 2>&1

echo. - Disable Hardware Accel Steam
reg add "HKCU\SOFTWARE\Valve\Steam" /v "GPUAccelWebViewsV2" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKCU\SOFTWARE\Valve\Steam" /v "H264HWAccel" /t REG_DWORD /d 0 /f > NUL 2>&1

echo. - Graphics settings: Disabling MPO
reg add "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v OverlayTestMode /t REG_DWORD /d 5 /f > NUL 2>&1

echo. - Setting game scheduling (performance)
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v Affinity /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Background Only" /t REG_SZ /d False /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Clock Rate" /t REG_DWORD /d 10000 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v Priority /t REG_DWORD /d 6 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d High /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d High /f > NUL 2>&1

echo. - Disabling Background Apps
Reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d "1" /f >nul 2>&1
Reg add "HKLM\Software\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsRunInBackground" /t REG_DWORD /d "2" /f >nul 2>&1
Reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BackgroundAppGlobalToggle" /t REG_DWORD /d "0" /f >nul 2>&1

echo. - Disabling startup applications
reg.exe export "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" "C:\StartupBackup.reg" /y  >nul 2>&1 
reg.exe export "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" "C:\StartupApprovedBackup.reg" /y  >nul 2>&1 
attrib +h "C:\StartupBackup.reg" >nul 2>&1
attrib +h "C:\StartupApprovedBackup.reg" >nul 2>&1

::  Disable startup for common apps in a loop 
for %%A in (Discord Synapse3 Spotify EpicGamesLauncher RiotClient Steam GoogleDrive OneDrive DropboxUpdate CCleaner iTunesHelper AdobeCreativeCloud AdobeGCClient EADesktop UbisoftConnect UbisoftGameLauncher BattleNet TeamViewer AnyDesk LogitechGHub CorsairService RazerCentralService MSIAfterburner NVIDIAGeForceExperience AMDRyzenMaster Overwolf SteelSeriesEngine ASUSArmouryCrate ROGGameFirst ROGRangeboost iCUE "Wallpaper Engine" "GOG Galaxy" "Microsoft Teams" Slack Zoom Skype WhatsApp Telegram OpenRGB SignalRGB "Java Update Scheduler" "QuickTime Task" SoundBlasterConnect RealPlayer) do (
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "%%A" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
    reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "%%A" /f >nul 2>&1
)

echo. - Enabling Hardware-Accelerated GPU Scheduling
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f > NUL 2>&1

echo. - Enabling Game Mode
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v AllowAutoGameMode /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v AutoGameModeEnabled /t REG_DWORD /d 1 /f > NUL 2>&1

echo. - Adjusting for best performance of programs
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 38 /f > NUL 2>&1

echo. - Reducing Menu Delay
reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d "0" /f > NUL 2>&1

echo. - Increase taskbar transparency
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "UseOLEDTaskbarTransparency" /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v "ForceEffectMode" /t REG_DWORD /d 2 /f > NUL 2>&1

echo. - Disable showing recent and mostly used item
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "HideRecentlyAddedApps" /t REG_DWORD /d 1 /f > NUL 2>&1
reg Delete "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "HideRecentlyAddedApps" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "HideRecentlyAddedApps" /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowFrequent" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowRecent" /t REG_DWORD /d 0 /f > NUL 2>&1
reg Delete "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "ShowOrHideMostUsedApps" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "ShowOrHideMostUsedApps" /t REG_DWORD /d 2 /f > NUL 2>&1
reg Delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoStartMenuMFUprogramsList" /f > NUL 2>&1
reg Delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoRecentDocsHistory" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoRecentDocsHistory" /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarSh" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "ShowOrHideMostUsedApps" /t REG_DWORD /d 0 /f > NUL 2>&1

echo. - Browser background optimizations
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "StartupBoostEnabled" /t REG_DWORD /d 0 /f > NUL 2>&1
rereg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "BatterySaverModeAvailability" /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "StartupBoostEnabled" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "BatterySaverModeAvailability" /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKLM\Software\Policies\BraveSoftware\Brave" /v "HighEfficiencyModeEnabled" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\Software\Policies\BraveSoftware\Brave" /v "BatterySaverModeAvailability" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\Software\Policies\BraveSoftware\Brave\Recommended" /v "BackgroundModeEnabled" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\Software\Policies\BraveSoftware\Brave\Recommended" /v "BatterySaverModeAvailability" /t REG_DWORD /d 1 /f > NUL 2>&1

echo. - Disables updates for Firefox, Edge and Chrome
reg add "HKLM\SYSTEM\CurrentControlSet\Services\MicrosoftEdgeElevationService" /v "Start" /t REG_DWORD /d 4 /f > NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\edgeupdate" /v "Start" /t REG_DWORD /d 4 /f > NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\edgeupdatem" /v "Start" /t REG_DWORD /d 4 /f > NUL 2>&1
reg Delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree\MicrosoftEdgeUpdateTaskMachineCore" /f > NUL 2>&1
reg Delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree\MicrosoftEdgeUpdateTaskMachineUA" /f > NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\GoogleChromeElevationService" /v "Start" /t REG_DWORD /d 4 /f > NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\gupdate" /v "Start" /t REG_DWORD /d 4 /f > NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\gupdatem" /v "Start" /t REG_DWORD /d 4 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Mozilla\Firefox" /v "DisableAppUpdate" /t REG_DWORD /d 1 /f > NUL 2>&1

echo. - Explorer Optimizations
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoRestartShell" /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "LongPathsEnabled" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "0" /f > NUL 2>&1
reg add "HKCU\Control Panel\Mouse" /v "MouseHoverTime" /t REG_SZ /d "0" /f > NUL 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ListviewShadow" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "NoNetCrawling" /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "EnableBalloonTips" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoLowDiskSpaceChecks" /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "LinkResolveIgnoreLinkInfo" /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoResolveSearch" /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoResolveTrack" /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoInternetOpenWith" /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DisallowShaking" /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoComplete" /v "Append Completion" /t REG_SZ /d "yes" /f > NUL 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoComplete" /v "AutoSuggest" /t REG_SZ /d "yes" /f > NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrDelay" /t REG_DWORD /d 10 /f > NUL 2>&1
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "0" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AeDebug" /v "Auto" /t REG_SZ /d "0" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" /v "FolderType" /t REG_SZ /d "NotSpecified" /f > NUL 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "link" /t REG_BINARY /d "0" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\Start" /v "HideRecommendedSection" /t REG_DWORD /d "1" /f > NUL 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\Education" /v "IsEducationEnvironment" /t REG_DWORD /d "1" /f > NUL 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "HideRecommendedSection" /t REG_DWORD /d "1" /f > NUL 2>&1

:: Allow for paths over 260 characters
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "LongPathsEnabled" /t REG_DWORD /d "1" /f >nul 2>&1

echo. - Optimizing Windows Scheduled Tasks
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v MaintenanceDisabled /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\ScheduledDiagnostics" /v EnabledExecution /t REG_DWORD /d 0 /f > NUL 2>&1

echo. - Disable specific scheduled tasks
set "tasksToDisable="
set tasksToDisable=^
 "\Microsoft\Windows\Application Experience\StartupAppTask"^
 "\Microsoft\Windows\Application Experience\AitAgent"^
 "\Microsoft\Windows\Application Experience\MareBackup"^
 "\Microsoft\Windows\Application Experience\PcaPatchDbTask"^
 "\Microsoft\Windows\Application Experience\ProgramDataUpdater"^
 "\Microsoft\Windows\ApplicationData\CleanupTemporaryState"^
 "\Microsoft\Windows\ApplicationData\DsSvcCleanup"^
 "\Microsoft\Windows\AppID\SmartScreenSpecific"^
 "\Microsoft\Windows\Autochk\Proxy"^
 "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"^
 "\Microsoft\Windows\Shell\FamilySafetyUpload"^
 "\Microsoft\Windows\Location\Notifications"^
 "\Microsoft\Windows\Location\WindowsActionDialog"^
 "\Microsoft\Windows\Shell\FamilySafetyMonitorToastTask"^
 "\Microsoft\Windows\SettingSync\BackgroundUploadTask"^
 "\Microsoft\Windows\Customer Experience Improvement Program\Uploader"^
 "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator"^
 "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask"^
 "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"^
 "\Microsoft\Windows\Customer Experience Improvement Program\BthSQM"^
 "\Microsoft\Windows\Customer Experience Improvement Program\HypervisorFlightingTask"^
 "\Microsoft\Windows\DiskFootprint\Diagnostics"^
 "\Microsoft\Windows\Feedback\Siuf\DmClient"^
 "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload"^
 "\Microsoft\Windows\Maintenance\WinSAT"^
 "\Microsoft\Windows\Maps\MapsToastTask"^
 "\Microsoft\Windows\Maps\MapsUpdateTask"^
 "\Microsoft\Windows\Mobile Broadband Accounts\MNO Metadata Parser"^
 "\Microsoft\Windows\NetTrace\GatherNetworkInfo"^
 "\Microsoft\Windows\Offline Files\Background Synchronization"^
 "\Microsoft\Windows\Offline Files\Logon Synchronization"^
 "\Driver Easy Scheduled Scan"^
 "\Microsoft\Windows\Shell\FamilySafetyMonitor"^
 "\Microsoft\Windows\Shell\FamilySafetyRefresh"^
 "\Microsoft\Windows\SpacePort\SpaceAgentTask"^
 "\Microsoft\Windows\SpacePort\SpaceManagerTask"^
 "\Microsoft\Windows\Speech\SpeechModelDownloadTask"^
 "\Microsoft\Windows\User Profile Service\HiveUploadTask"^
 "\Microsoft\Windows\Wininet\CacheTask"^
 "\Microsoft\Windows\Work Folders\Work Folders Logon Synchronization"^
 "\Microsoft\Windows\Work Folders\Work Folders Maintenance Work"^
 "\Microsoft\Windows\Workplace Join\Automatic-Device-Join"^
 "\Microsoft\Windows\Windows Media Sharing\UpdateLibrary"^
 "\Microsoft\Windows\SettingSync\BackupTask"^
 "\Microsoft\Windows\SettingSync\NetworkStateChangeTask"^
 "\Microsoft\Windows\Windows Filtering Platform\BfeOnServiceStartTypeChange"^
 "\Microsoft\Windows\File Classification Infrastructure\Property Definition Sync"^
 "\Microsoft\Windows\Management\Provisioning\Logon"^
 "\Microsoft\Windows\NlaSvc\WiFiTask"^
 "\Microsoft\Windows\WCM\WiFiTask"^
 "\Microsoft\Windows\Ras\MobilityManager"

for %%T in (%tasksToDisable%) do (
    schtasks /change /tn "%%T" /disable > NUL 2>&1
)

echo. - Visual Effects
:: Enable font smoothing
reg add "HKCU\Control Panel\Desktop" /v "FontSmoothing" /t REG_SZ /d "2" /f > NUL 2>&1

:: User Preferences Mask (affects visual effects settings)
reg add "HKCU\Control Panel\Desktop" /v "UserPreferencesMask" /t REG_BINARY /d "9012038010000000" /f > NUL 2>&1

:: Show window contents while dragging
reg add "HKCU\Control Panel\Desktop" /v "DragFullWindows" /t REG_SZ /d "1" /f > NUL 2>&1

:: Disable minimize/maximize animations
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "0" /f > NUL 2>&1

:: Enable translucent selection rectangle
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ListviewAlphaSelect" /t REG_DWORD /d 1 /f > NUL 2>&1

:: Show icons with details in File Explorer
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "IconsOnly" /t REG_DWORD /d 0 /f > NUL 2>&1

:: Disable taskbar animations
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAnimations" /t REG_DWORD /d 0 /f > NUL 2>&1

:: Enable shadows under list view text
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ListviewShadow" /t REG_DWORD /d 1 /f > NUL 2>&1

:: Set visual effects to "Adjust for best appearance"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 3 /f > NUL 2>&1

:: Disable Aero Peek
reg add "HKCU\SOFTWARE\Microsoft\Windows\DWM" /v "EnableAeroPeek" /t REG_DWORD /d 0 /f > NUL 2>&1

:: Disable persistent thumbnails in memory
reg add "HKCU\SOFTWARE\Microsoft\Windows\DWM" /v "AlwaysHibernateThumbnails" /t REG_DWORD /d 0 /f > NUL 2>&1


:: Check if WMIC is available
wmic /? >nul 2>&1
if %errorlevel% equ 0 (
    echo. - WMIC is already available on this system.
    goto :USBPowerSavings
) else (
    echo. - WMIC is not available. Attempting to install...
    goto :skipUSBPowerSavings
)

:USBPowerSavings
echo. - Disable USB Power Savings
for /f "tokens=*" %%a in ('Reg query "HKLM\System\CurrentControlSet\Enum" /s /f "StorPort" 2^>nul ^| findstr "StorPort"') do reg add "%%a" /v "EnableIdlePowerManagement" /t REG_DWORD /d "0" /f > NUL 2>&1
for /f %%a in ('wmic PATH Win32_PnPEntity GET DeviceID ^| find "USB\VID_"') do (
    reg add "HKLM\System\CurrentControlSet\Enum\%%a\Device Parameters" /v "EnhancedPowerManagementEnabled" /t REG_DWORD /d "0" /f > NUL 2>&1
    reg add "HKLM\System\CurrentControlSet\Enum\%%a\Device Parameters" /v "AllowIdleIrpInD3" /t REG_DWORD /d "0" /f > NUL 2>&1
    reg add "HKLM\System\CurrentControlSet\Enum\%%a\Device Parameters" /v "EnableSelectiveSuspend" /t REG_DWORD /d "0" /f > NUL 2>&1
    reg add "HKLM\System\CurrentControlSet\Enum\%%a\Device Parameters" /v "DeviceSelectiveSuspended" /t REG_DWORD /d "0" /f > NUL 2>&1
    reg add "HKLM\System\CurrentControlSet\Enum\%%a\Device Parameters" /v "SelectiveSuspendEnabled" /t REG_DWORD /d "0" /f > NUL 2>&1
    reg add "HKLM\System\CurrentControlSet\Enum\%%a\Device Parameters" /v "SelectiveSuspendOn" /t REG_DWORD /d "0" /f > NUL 2>&1
    reg add "HKLM\System\CurrentControlSet\Enum\%%a\Device Parameters" /v "D3ColdSupported" /t REG_DWORD /d "0" /f > NUL 2>&1
)

echo. - Enable GPU MSI Mode
for /f %%a in ('wmic path Win32_VideoController get PNPDeviceID ^| find "PCI\VEN_"') do ^
reg query "HKLM\System\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" >nul 2>&1 && (
reg add "HKLM\System\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f > NUL 2>&1
)
C:\Windows\System32\TIMEOUT.exe /t 1 /nobreak > nul 2> nul
goto :continue
:skipUSBPowerSavings

:continue
echo. - Quick Boot 
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "DelayedDesktopSwitchTimeout" /t REG_DWORD /d "0" /f > NUL 2>&1
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "StartupDelayInMSec" /t REG_SZ /d "0" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "RunStartupScriptSync" /t REG_DWORD /d "0" /f > NUL 2>&1
bcdedit /set bootuxdisabled on > NUL 2>&1
bcdedit /set bootmenupolicy standard > NUL 2>&1
bcdedit /set quietboot yes > NUL 2>&1

echo. - Quick Shutdown Settings
reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t REG_SZ /d "3000" /f > NUL 2>&1
reg add "HKLM\System\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d "3000" /f > NUL 2>&1
reg add "HKCU\Control Panel\Desktop" /v "AutoEndTasks" /t REG_SZ /d "1" /f > NUL 2>&1

echo. - Additional Performance Optimizations
reg add "HKCU\Control Panel\Desktop" /v "HungAppTimeout" /t REG_SZ /d "2000" /f > NUL 2>&1
reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "20" /f > NUL 2>&1

:: echo. - Usb Overclock with secure boot enabled
:: reg add "HKLM\SYSTEM\CurrentControlSet\Control\CI\Policy" /v "WHQLSettings" /t REG_DWORD /d "1" /f > NUL 2>&1


echo. - Disable Hibernation
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "0" /f > NUL 2>&1

echo. - Disable Sleep Study
schtasks /change /tn "\microsoft\windows\power efficiency diagnostics\analyzesystem" /disable >nul 2>&1
wevtutil set-log "Microsoft-Windows-SleepStudy/Diagnostic" /e:False >nul 2>&1
wevtutil set-log "Microsoft-Windows-Kernel-Processor-Power/Diagnostic" /e:False >nul 2>&1
wevtutil set-log "Microsoft-Windows-UserModePowerService/Diagnostic" /e:False >nul 2>&1


echo. - Adjust processor scheduling for foreground boost
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 42 /f >nul 2>&1
timeout /t 5 /nobreak > NUL

mode con cols=76 lines=28
CLS
echo.
echo.
echo.
echo.
echo.
echo                           %ESC%[1;38;5;159m╭──────────────────────────╮
echo                           %ESC%[1;38;5;159m│        %ESC%[1;97mA U R O R A%ESC%[1;38;5;159m       │
echo                           %ESC%[1;38;5;159m╰──────────────────────────╯%ESC%[0m
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.                 Do you want to Enable Timer Resolution ?
echo.
echo.                             [1] Yes Or [2] No
echo.
set /p input=%BS%══════════^> 
if /I "%input%"=="1" goto :TimerR
if /I "%input%"=="2" goto :CloudSync
if /I "%input%"=="3" goto :MainMenu
echo.
echo.    Invalid input. Please enter [1] or [2].
echo:       ______________________________________________________________
echo.
timeout /t 2 /nobreak > NUL

:TimerR
start /wait powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%currentDir%\AuroraTimerResolution.ps1"


goto :CloudSync
rem ========================================================================================================================================

:CloudSync
mode con cols=76 lines=28
CLS
echo.
echo.
echo.
echo.
echo.
echo                           %ESC%[1;38;5;159m╭──────────────────────────╮
echo                           %ESC%[1;38;5;159m│        %ESC%[1;97mA U R O R A%ESC%[1;38;5;159m       │
echo                           %ESC%[1;38;5;159m╰──────────────────────────╯%ESC%[0m
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.                      Do you want to Disable Cloud Sync ?
echo.
echo.                             [1] Yes Or [2] No
echo.
set /p input=%BS%══════════^> 
if /I "%input%"=="1" goto :DisableCloudSync
if /I "%input%"=="2" goto :Telemetry
if /I "%input%"=="3" goto :MainMenu
echo.
echo.    Invalid input. Please enter [1] or [2].
echo:       ______________________________________________________________
echo.
timeout /t 2 /nobreak > NUL
goto :CloudSync

:DisableCloudSync
rem - Disable Cloud Sync via Registry
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /t REG_DWORD /d "1" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableSoftLanding" /t REG_DWORD /d "1" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableCloudOptimizedContent" /t REG_DWORD /d "1" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableConsumerAccountStateContent" /t REG_DWORD /d "1" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /t REG_DWORD /d "1" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d "1" /f > NUL 2>&1

rem - Run additional Cloud sync disabling script
CALL "%currentDir%\Cloud.BAT"
goto :Telemetry


rem ========================================================================================================================================

:Telemetry
mode con cols=76 lines=28
CLS
echo.
echo.
echo.
echo.
echo.
echo                           %ESC%[1;38;5;159m╭──────────────────────────╮
echo                           %ESC%[1;38;5;159m│        %ESC%[1;97mA U R O R A%ESC%[1;38;5;159m       │
echo                           %ESC%[1;38;5;159m╰──────────────────────────╯%ESC%[0m
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.                      Do you want to Disable Telemetry ?
echo.
echo.                             [1] Yes Or [2] No
echo.
set /p input=%BS%══════════^> 
if /I "%input%"=="1" goto :DisableTelemetry
if /I "%input%"=="2" goto :Privacy
if /I "%input%"=="3" goto :MainMenu
echo.
echo.    Invalid input. Please enter [1] or [2].
echo.
echo.
timeout /t 2 /nobreak > NUL
goto :Telemetry

:DisableTelemetry
CALL "%currentDir%\Telemetry.bat"
goto :Privacy


rem ========================================================================================================================================

:Privacy
mode con cols=76 lines=28
CLS
echo.
echo.
echo.
echo.
echo                           %ESC%[1;38;5;159m╭──────────────────────────╮
echo                           %ESC%[1;38;5;159m│        %ESC%[1;97mA U R O R A%ESC%[1;38;5;159m       │
echo                           %ESC%[1;38;5;159m╰──────────────────────────╯%ESC%[0m
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.                      Do you want to Disable Privacy ?
echo.
echo.                             [1] Yes Or [2] No
echo.
set /p input=%BS% ══════════^> 
if /I "%input%"=="1" goto :DisablePrivacy
if /I "%input%"=="2" goto :RemoveEdge
if /I "%input%"=="3" goto :MainMenu
echo.
echo.    Invalid input. Please enter [1] or [2].
echo:       ______________________________________________________________
echo.
timeout /t 2 /nobreak > NUL
goto :Privacy

:DisablePrivacy
CALL "%currentDir%\Privacy.bat

goto :RemoveEdge
cls

rem ========================================================================================================================================

:RemoveEdge
mode con cols=76 lines=28
CLS
echo.
echo.
echo                           %ESC%[1;38;5;159m╭──────────────────────────╮
echo                           %ESC%[1;38;5;159m│       %ESC%[1;97mA U R O R A%ESC%[1;38;5;159m        │
echo                           %ESC%[1;38;5;159m╰──────────────────────────╯%ESC%[0m
echo.
echo                    %ESC%[38;5;147m╔══════════════════════════════════════╗
echo                    %ESC%[38;5;147m║                                      ║
echo                    %ESC%[38;5;147m║      %ESC%[97mDo you want to Remove Edge?%ESC%[38;5;147m     ║
echo                    %ESC%[38;5;147m║                                      ║
echo                    %ESC%[38;5;147m╚══════════════════════════════════════╝%ESC%[0m
echo.
echo.
echo                    %ESC%[38;5;153m╭─────────────╮    ╭────────────╮
echo                    %ESC%[38;5;153m│    %ESC%[97m1. Yes%ESC%[38;5;153m   │    │   %ESC%[97m2. No%ESC%[38;5;153m    │
echo                    %ESC%[38;5;153m╰─────────────╯    ╰────────────╯%ESC%[0m
echo.
echo.
echo                    %ESC%[38;5;147m[ Please type your choice and press Enter ]%ESC%[0m
echo.
set /p input=%BS% ══════════^> 
if /I "%input%"=="1" goto :runRemoveEdge
if /I "%input%"=="2" goto :OneDrive
if /I "%input%"=="3" goto :MainMenu
echo.
echo.- Invalid input. Please enter [1] or [2].
echo:       ______________________________________________________________
echo.
timeout /t 2 /nobreak > NUL
goto :RemoveEdge

:runRemoveEdge
if exist "%currentDir%\RemoveEdge.ps1" (
    start /wait powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%currentDir%\RemoveEdge.ps1" -UninstallEdge -NonInteractive
    if %ERRORLEVEL% NEQ 0 (
        echo Error: Failed to execute Edge removal script.
        timeout /t 2 /nobreak > NUL
    )
) else (
    echo Error: RemoveEdge.ps1 not found in AuroraModules.
    timeout /t 2 /nobreak > NUL
)

goto :OneDrive
cls



rem ========================================================================================================================================

:OneDrive
mode con cols=76 lines=28
CLS
echo.
echo.
echo.
echo.
echo                           %ESC%[1;38;5;159m╭──────────────────────────╮
echo                           %ESC%[1;38;5;159m│       %ESC%[1;97mA U R O R A%ESC%[1;38;5;159m        │
echo                           %ESC%[1;38;5;159m╰──────────────────────────╯%ESC%[0m
echo.
echo.
echo                    %ESC%[38;5;147m╔══════════════════════════════════════╗
echo                    %ESC%[38;5;147m║                                      ║
echo                    %ESC%[38;5;147m║     %ESC%[97mDo you want to Remove OneDrive? %ESC%[38;5;147m     ║
echo                    %ESC%[38;5;147m║                                      ║
echo                    %ESC%[38;5;147m╚══════════════════════════════════════╝%ESC%[0m
echo.
echo                    %ESC%[38;5;153m╭─────────────╮    ╭────────────╮
echo                    %ESC%[38;5;153m│    %ESC%[97m1. Yes%ESC%[38;5;153m   │    │   %ESC%[97m2. No%ESC%[38;5;153m    │
echo                    %ESC%[38;5;153m╰─────────────╯    ╰────────────╯%ESC%[0m
echo.
echo.
echo                    %ESC%[38;5;147m[ Please type your choice and press Enter ]%ESC%[0m
set /p input=%BS%              ══════════^> 
if /I "%input%"=="1" goto :DisableOneDrive
if /I "%input%"=="2" goto :DeblootWindows
if /I "%input%"=="3" goto :MainMenu
echo.
echo.    Invalid input. Please enter [1] or [2].
echo.
timeout /t 2 /nobreak > NUL
goto :OneDrive

:DisableOneDrive
echo.
echo Please wait while OneDrive is being removed...
echo This may take a few minutes...
echo.

taskkill /F /IM "OneDrive.exe" > NUL 2>&1

rem -  Disabling OneDrive
reg add "HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\ShellFolder" /f /v "Attributes" /t REG_DWORD /d "0" > NUL 2>&1
reg add "HKCR\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\ShellFolder" /f /v "Attributes" /t REG_DWORD /d "0" >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSync" /t REG_DWORD /d "1" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d "1" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableMeteredNetworkFileSync" /t REG_DWORD /d "0" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableLibrariesDefaultSaveToOneDrive" /t REG_DWORD /d "0" /f > NUL 2>&1

timeout /t 1 /nobreak > NUL
if exist "%currentDir%\OneDrive.ps1" (
    :: The OneDrive removal operation is commented out to prevent potential data loss.
    rem start /wait powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%currentDir%\OneDrive.ps1"
    if %ERRORLEVEL% NEQ 0 (
        echo - Error: Failed to execute OneDrive removal script.
        timeout /t 2 /nobreak > NUL
    )
) else (
    echo - Error: OneDrive.ps1 script not found in AuroraModules folder.
    timeout /t 2 /nobreak > NUL
)

goto :DeblootWindows

:DeblootWindows
mode con cols=76 lines=28
CLS
echo.
echo.
echo.
echo.
echo                           %ESC%[1;38;5;159m╭──────────────────────────╮
echo                           %ESC%[1;38;5;159m│       %ESC%[1;97mA U R O R A%ESC%[1;38;5;159m        │
echo                           %ESC%[1;38;5;159m╰──────────────────────────╯%ESC%[0m
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.                     Do you want to Debloat Windows? 
echo.
echo                    %ESC%[38;5;153m╭─────────────╮    ╭────────────╮
echo                    %ESC%[38;5;153m│  %ESC%[97m1. Yes%ESC%[38;5;153m    │    │  %ESC%[97m2. No%ESC%[38;5;153m    │
echo                    %ESC%[38;5;153m╰─────────────╯    ╰────────────╯%ESC%[0m
echo.
echo.
echo                    %ESC%[38;5;147m[ Please type your choice and press Enter ]%ESC%[0m
set /p input=%BS%              ══════════^> 
if /I "%input%"=="1" goto :RunDebloot
if /I "%input%"=="2" goto :MainMenu
echo.
echo.    Invalid input. Please enter [1] or [2].
echo.
timeout /t 2 /nobreak > NUL
goto :DeblootWindows

:RunDebloot
if exist "%currentDir%\Components.ps1" (
    start /wait powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0AuroraModules\Components.ps1" 
    if %ERRORLEVEL% NEQ 0 (
        echo - Error: Failed to execute Windows debloating script.
        timeout /t 2 /nobreak > NUL
    )
) else (
    echo - Error: Components.ps1 script not found in AuroraModules folder.
    timeout /t 2 /nobreak > NUL
)

goto :MainMenu

rem ========================================================================================================================================

:GPUTweaks
mode con cols=76 lines=33
CLS
echo.
echo.
echo.
echo.
echo                           %ESC%[1;38;5;159m╭──────────────────────────╮
echo                           %ESC%[1;38;5;159m│       %ESC%[1;97mA U R O R A%ESC%[1;38;5;159m        │
echo                           %ESC%[1;38;5;159m╰──────────────────────────╯%ESC%[0m
echo.
echo                    %ESC%[38;5;147m╔══════════════════════════════════════╗
echo                    %ESC%[38;5;147m║                                      ║
echo                    %ESC%[38;5;147m║ %ESC%[97mDo You Have NVIDIA (1) or AMD (2) ?%ESC%[1;38;5;147m  ║
echo                    %ESC%[38;5;147m║                                      ║
echo                    %ESC%[38;5;147m╚══════════════════════════════════════╝%ESC%[0m
echo.
echo                     %ESC%[38;5;153m╭─────────────╮    ╭────────────╮
echo                     %ESC%[38;5;153m│  %ESC%[97m1. NVIDIA%ESC%[38;5;153m  │    │  %ESC%[97m2. AMD%ESC%[38;5;153m    │
echo                     %ESC%[38;5;153m╰─────────────╯    ╰────────────╯%ESC%[0m
echo.
echo.
echo                     %ESC%[38;5;147m[ Please type your choice and press Enter ]%ESC%[0m
set /p input=%BS%      ══════════^> 
if /I "%input%"=="1" goto :NVIDIATweaks
if /I "%input%"=="2" goto :AMDTweaks
if /I "%input%"=="3" goto :MainMenu

echo.
echo.    Invalid input. Please enter [1] or [2].
echo:       ______________________________________________________________
echo.
timeout /t 2 /nobreak > NUL
goto :GPUTweaks



rem ========================================================================================================================================

:NVIDIATweaks
CLS
mode con cols=76 lines=33
start /wait cmd /c "%currentDir%\NvidiaProfileInspector.cmd"
timeout /t 3 /nobreak > NUL
:NVIDIATweaks1
cls
echo.
echo.
echo                           %ESC%[1;38;5;159m╭──────────────────────────╮
echo                           %ESC%[1;38;5;159m│        %ESC%[1;97mA U R O R A%ESC%[1;38;5;159m       │
echo                           %ESC%[1;38;5;159m╰──────────────────────────╯%ESC%[0m
echo.
echo                    %ESC%[38;5;147m╔══════════════════════════════════════╗
echo                    %ESC%[38;5;147m║                                      ║
echo                    %ESC%[38;5;147m║   %ESC%[97mNVIDIA Control Panel Settings%ESC%[38;5;147m      ║
echo                    %ESC%[38;5;147m║                                      ║
echo                    %ESC%[38;5;147m╚══════════════════════════════════════╝%ESC%[0m
echo.
echo.
echo                      %ESC%[38;5;153m╭─────────────────────────────────╮
echo                      %ESC%[38;5;153m│  %ESC%[97m1. NVIDIA Settings (Aurora)%ESC%[38;5;153m    │
echo                      %ESC%[38;5;153m╰─────────────────────────────────╯
echo.
echo                      %ESC%[38;5;153m╭─────────────────────────────────╮
echo                      %ESC%[38;5;153m│  %ESC%[97m2. NVIDIA Settings (Default)%ESC%[38;5;153m   │
echo                      %ESC%[38;5;153m╰─────────────────────────────────╯
echo.
echo                      %ESC%[38;5;153m╭─────────────────────────────────╮
echo                      %ESC%[38;5;153m│  %ESC%[97m3. Back to Main Menu%ESC%[38;5;153m           │
echo                      %ESC%[38;5;153m╰─────────────────────────────────╯%ESC%[0m
echo.
echo                        %ESC%[38;5;147m[ Please enter your choice ]%ESC%[0m
echo.
set /p input=%ESC%[38;5;147m    ══════════^>%ESC%[0m 
if /I "%input%"=="1" goto :AuroraON
if /I "%input%"=="2" goto :AuroraOFF
if /I "%input%"=="3" goto :MainMenu
echo.
echo    %ESC%[91mInvalid input. Please enter [1], [2], or [3].%ESC%[0m
timeout /t 2 /nobreak > NUL
goto :NVIDIATweaks1

:AuroraOFF
timeout /t 3 /nobreak > NUL
set AuroraAsAdmin=%currentDir%\AuroraSudo.exe
%AuroraAsAdmin% --NoLogo -S -P --WorkDir="%~dp0AuroraModules\AuroraNvidia\NvidiaProfileInspector" "%~dp0AuroraModules\AuroraNvidia\NvidiaProfileInspector\nvidiaProfileInspector.exe" "%~dp0AuroraModules\AuroraNvidia\NvidiaProfileInspector\AuroraOFF.nip"

if errorlevel 1 (
    echo - Failed to apply AuroraOFF.nip.
    pause
    goto :relaunch
)

echo.
echo - Resizable BAR has been disabled successfully.
timeout /t 3 /nobreak > NUL

goto :MainMenu

:AuroraON
timeout /t 3 /nobreak > NUL
set AuroraAsAdmin=%currentDir%\AuroraSudo.exe
%AuroraAsAdmin% --NoLogo -S -P --WorkDir="%~dp0AuroraModules\AuroraNvidia\NvidiaProfileInspector" "%~dp0AuroraModules\AuroraNvidia\NvidiaProfileInspector\nvidiaProfileInspector.exe" "%~dp0AuroraModules\AuroraNvidia\NvidiaProfileInspector\AuroraON.nip"
if errorlevel 1 (
    echo - Failed to apply AuroraON.nip.
    pause
    goto :relaunch
)

echo.
echo - Resizable BAR has been enabled successfully.
timeout /t 3 /nobreak > NUL

goto :MainMenu
cls


rem ======================================================================================================================================== 

:AMDTweaks
timeout /t 3 /nobreak > NUL
call %currentDir%\AuroraAMD.bat

echo.
echo AMD GPU optimizations have been successfully applied!
echo A system restart is recommended for all changes to take effect.
echo.
timeout /t 3 /nobreak > NUL

goto :MainMenu
cls

rem ========================================================================================================================================

:Power-Plan
cls
if exist "%currentDir%\Power.ps1" (
    start /wait powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "%currentDir%\Power.ps1" -Silent
    if %ERRORLEVEL% NEQ 0 (
        echo - Error: Failed to apply power plan optimizations.
        timeout /t 2 /nobreak > NUL
    ) else (
        echo - Power plan optimizations applied successfully.
        timeout /t 2 /nobreak > NUL
    )
) else (
    echo - Error: Power.ps1 script not found in AuroraModules folder.
    timeout /t 2 /nobreak > NUL
)

cls
goto :MainMenu


rem ========================================================================================================================================


:NetworkTweaks
mode con cols=76 lines=33
cls
echo.
echo.
echo                           %ESC%[1;38;5;159m╭──────────────────────────╮
echo                           %ESC%[1;38;5;159m│       %ESC%[1;97mA U R O R A%ESC%[1;38;5;159m        │
echo                           %ESC%[1;38;5;159m╰──────────────────────────╯%ESC%[0m
echo.
echo    %ESC%[1;38;5;45m╔══════════════════════════════════════════════════════╗
echo    %ESC%[1;38;5;45m║%ESC%[97m               NETWORK OPTIMIZATION SETTINGS          %ESC%[1;38;5;45m║
echo    %ESC%[1;38;5;45m╚══════════════════════════════════════════════════════╝%ESC%[0m
echo.
echo    %ESC%[93m1.%ESC%[0m Apply Gaming Network Profile
echo    %ESC%[93m2.%ESC%[0m Return to Main Menu
echo.
set /p "input=%ESC%[38;5;33m %ESC%[3;38;5;195mEnter choice [0-2]:%ESC%[0m "

if /I "%input%"=="1" goto  :NetworkTweaks1
if /I "%input%"=="2" goto  :MainMenu

:NetworkTweaks1
timeout /t 3 /nobreak > NUL
if exist "%currentDir%\NetworkBufferBloatFixer.ps1" (
    start /wait powershell.exe -ExecutionPolicy Bypass -File "%currentDir%\NetworkBufferBloatFixer.ps1"
    if %ERRORLEVEL% NEQ 0 (
        echo - Error: Failed to apply network optimizations.
        timeout /t 2 /nobreak > NUL
    ) else (
        echo - Network optimizations applied successfully.
        timeout /t 2 /nobreak > NUL
    )
) else (
    echo - Error: NetworkBufferBloatFixer.ps1 script not found in AuroraModules folder.
    timeout /t 2 /nobreak > NUL
)
goto :MainMenu




rem ========================================================================================================================================
:ManualServices
mode con cols=76 lines=33
cls
echo.
echo.
echo.
echo                           %ESC%[1;38;5;159m╭──────────────────────────╮
echo                           %ESC%[1;38;5;159m│       %ESC%[1;97mA U R O R A%ESC%[1;38;5;159m        │
echo                           %ESC%[1;38;5;159m╰──────────────────────────╯%ESC%[0m
echo.
echo.
echo.
echo.
echo            %ESC%[1;38;5;196m╔══════════════════════════════════════════════════════╗
echo            %ESC%[1;38;5;196m║%ESC%[93m                    W A R N I N G !                    %ESC%[1;38;5;196m║
echo            %ESC%[1;38;5;196m║                                                      ║%ESC%[0m 
echo            %ESC%[1;38;5;196m║%ESC%[91m  These changes may cause system instability          %ESC%[1;38;5;196m║
echo            %ESC%[1;38;5;196m║%ESC%[91m  Only proceed if you understand the consequences     %ESC%[1;38;5;196m║
echo            %ESC%[1;38;5;196m╚══════════════════════════════════════════════════════╝%ESC%[0m
echo.
echo.
echo.
echo                         %ESC%[93m[1]%ESC%[0m Continue    %ESC%[93m[2]%ESC%[0m Main Menu    
echo.
set /p "input=%ESC%[38;5;33m %ESC%[3;38;5;195mEnter choice [0-2]:%ESC%[0m "
if /I "%input%"=="1" goto :StartServiceChanges
if /I "%input%"=="2" goto :MainMenu
echo Invalid input
timeout /t 2 /nobreak > NUL

:StartServiceChanges
start /wait cmd.exe /c "%~dp0AuroraModules\AuroraManualServices.cmd"
echo.
echo    %ESC%[92m✓%ESC%[0m %ESC%[97mOperation completed successfully!%ESC%[0m
echo.
timeout /t 2 /nobreak > NUL
goto :MainMenu


rem ========================================================================================================================================
:DarkMode
mode con cols=76 lines=33
cls

:: Enable dark mode for system
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "SystemUsesLightTheme" /t REG_DWORD /d "0" /f >nul 2>&1

:: Enable dark mode for current user
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d "0" /f >nul 2>&1 
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "SystemUsesLightTheme" /t REG_DWORD /d "0" /f >nul 2>&1
echo.
echo.
echo.
echo.
echo %ESC%[92m✓%ESC%[0m %ESC%[97mOperation completed successfully!%ESC%[0m

C:\windows\system32\cmd.exe /c taskkill /f /im explorer.exe >nul 2>&1
 
timeout /t 3 /nobreak > NUL

start %windir%\explorer.exe >nul 2>&1

goto :MainMenu

rem ========================================================================================================================================

:RepairWindows
mode con cols=76 lines=33
cls
echo - Repairing Windows components...
echo.

if exist "%currentDir%\RepairWindows.cmd" (
    start "" /wait "%currentDir%\RepairWindows.cmd"
    echo    %ESC%[93m⌛%ESC%[0m %ESC%[97mProcessing... Please wait%ESC%[0m
) else (
    echo    %ESC%[91m✗%ESC%[0m %ESC%[97mFailed to execute operation!%ESC%[0m
)

timeout /t 2 /nobreak > NUL
goto :MainMenu

rem ========================================================================================================================================

:Discord
cls
echo.
echo.
echo.
echo - Join Our Discord Community

start "" "https://discord.gg/fVYtpuYuZ6"
timeout /t 7 /nobreak > NUL
goto :MainMenu


:relaunch
cls
mode con cols=76 lines=33
echo.
echo.
echo:       ______________________________________________________________
echo.
echo.
echo                    Do you want to restart Aurora or exit?
echo.
echo                           [1] Restart Aurora
echo                           [2] Exit
echo.
echo:       ______________________________________________________________
echo.
echo.
set /p input=%BS%══════════^> 

if /I "%input%"=="2" (
    echo.
    echo - Exiting Aurora...
    timeout /t 2 /nobreak > NUL
    exit /b
) else if /I "%input%"=="1" (
    echo.
    echo - Restarting Aurora...
    timeout /t 2 /nobreak > NUL
    goto :MainMenu
) else (
    echo.
    echo - Invalid input. Please enter [1] or [2].
    timeout /t 2 /nobreak > NUL
    goto :relaunch
)



:Seticon
:: Set custom icon for the current CMD window and handle OneDrive
if exist "%currentDir%\AuroraAvatar.ico" (
    :: Check if PowerShell is available 
    where powershell >nul 2>&1
    if %ERRORLEVEL% NEQ 0 (
        goto :StartupAuroraMain
    )

    :: Check if OneDrive is installed
    if exist "%LOCALAPPDATA%\Microsoft\OneDrive\OneDrive.exe" (
        :: Create OneDrive backup folder
        if not exist "%USERPROFILE%\OneDrive\Aurora_Backup" (
            mkdir "%USERPROFILE%\OneDrive\Aurora_Backup" >nul 2>&1
        )
        
        :: Copy icon to OneDrive backup
        copy /y "%currentDir%\AuroraAvatar.ico" "%USERPROFILE%\OneDrive\Aurora_Backup\" >nul 2>&1
    )

    :: Create temporary VBS script to change console icon silently
    (
        echo Set objShell = CreateObject^("Shell.Application"^)
        echo Set objWin = objShell.Windows^(^)
        echo On Error Resume Next
        echo For Each win In objWin
        echo     If InStr^(win.LocationName, "cmd.exe"^) Then
        echo         win.Document.DefaultIcon = "%currentDir%\AuroraAvatar.ico"
        echo     End If
        echo Next
    ) > "%TEMP%\seticon.vbs"

    :: Run the VBS script silently
    cscript //nologo "%TEMP%\seticon.vbs" >nul 2>&1
    
    :: Clean up silently
    del "%TEMP%\seticon.vbs" >nul 2>&1

    :: Create shortcuts with custom icon
    (
        echo Set WshShell = CreateObject^("WScript.Shell"^)
        echo On Error Resume Next
        echo Set shortcut = WshShell.CreateShortcut^("%USERPROFILE%\Desktop\Aurora.lnk"^)
        echo shortcut.TargetPath = "%~dp0Aurora.cmd"
        echo shortcut.IconLocation = "%currentDir%\AuroraAvatar.ico"
        echo shortcut.Save
        
        echo If FSO.FolderExists^("%USERPROFILE%\OneDrive"^) Then
        echo     Set oneDriveShortcut = WshShell.CreateShortcut^("%USERPROFILE%\OneDrive\Aurora.lnk"^)
        echo     oneDriveShortcut.TargetPath = "%~dp0Aurora.cmd"
        echo     oneDriveShortcut.IconLocation = "%currentDir%\AuroraAvatar.ico"
        echo     oneDriveShortcut.Save
        echo End If
    ) > "%TEMP%\createshortcut.vbs"

    :: Run the shortcut creation script
    cscript //nologo "%TEMP%\createshortcut.vbs" >nul 2>&1
    
    :: Clean up
    del "%TEMP%\createshortcut.vbs" >nul 2>&1

    :: Verify at least one shortcut creation
    if not exist "%USERPROFILE%\Desktop\Aurora.lnk" (
        if not exist "%USERPROFILE%\OneDrive\Aurora.lnk" (
            goto :StartupAuroraMain
        )
    )
) else (
    goto :StartupAuroraMain
)

:AuroraExit
goto :end
cls
mode con: cols=75 lines=28
echo:
echo:
echo:
echo:
echo:
echo:
echo:                                Auto Cleaner     
echo:            ___________________________________________________ 
echo:                                                               
echo:                   	[1]  Temp and Prefetch  
echo:                  	[2]  Event Viewer 
echo:
echo:                                                               
echo:                            	 [0] Exit
echo:            ___________________________________________________
echo:
set /p choice=                            "Enter your choice: "
if "%choice%"=="1" (
    goto TempPrefetch
) else if "%choice%"=="2" (
    goto EventViewer
) else if "%choice%"=="0" (
    goto end
) else (
    echo                     Invalid choice. Please enter 1, 2, or 0.
    pause
    cls
    goto Auto-Cleaner
)


:TempPrefetch
echo.
echo - Clean up temp folders

rd /s /q !TEMP! >nul 2>&1
rd /s /q !windir!\temp >nul 2>&1
md !TEMP! >nul 2>&1
md !windir!\temp >nul 2>&1

echo  %ESC%[92mTemp folders have been cleaned
echo.
echo.
echo - Clean up the Prefetch folder
rd /s /q !windir!\Prefetch >nul 2>&1

echo  %ESC%[92mPrefetch folder has been cleaned
echo.


goto EventViewer

:EventViewer
echo.
echo - Clear all Event Viewer logs
echo.
echo.
for /f "tokens=*" %%a in ('wevtutil el') do (
    wevtutil cl "%%a"
) >nul 2>&1

echo - Event Viewer logs has been cleaned
echo.

goto :end

:end
C:\Windows\System32\TASKKILL.exe /f /im powershell.exe > nul 2> nul
C:\Windows\System32\TASKKILL.exe /f /im cmd.exe > nul 2> nul
exit /b

