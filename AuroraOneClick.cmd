@echo off
:: ============================================================
::                            Aurora
:: ============================================================
:: AUTHOR:
::   IBRHUB - IBRAHIM
::   https://github.com/IBRAHUB
::	 https://docs.ibrhub.net/
::
:: VERSION:
::   1.0 beta
::
:: LICENSE:
::   MIT License
::   Copyright (c) 2024 2025 IBRAHUB
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
if not exist "%targetDir%" mkdir "%targetDir%" >nul 2>&1
if not exist "%currentDir%" mkdir "%currentDir%" >nul 2>&1

:: Clear any existing files in target directory
del /Q "%targetDir%\*" >nul 2>&1

:: Download required files

:: First check if files exist in target directory
set "fileRestorePoint=%targetDir%\RestorePoint.ps1"
set "fileLockConsoleSize=%targetDir%\LockConsoleSize.ps1"
set "fileSetConsoleOpacity=%targetDir%\SetConsoleOpacity.ps1"
set "fileBackupRegistry=%targetDir%\Backup-Registry.ps1"

:: Also check if files exist in current directory
set "currentRestorePoint=%currentDir%\RestorePoint.ps1"
set "currentLockConsoleSize=%currentDir%\LockConsoleSize.ps1"
set "currentSetConsoleOpacity=%currentDir%\SetConsoleOpacity.ps1"
set "currentBackupRegistry=%currentDir%\Backup-Registry.ps1"

:: Download only if files don't exist in either location
if not exist "%fileRestorePoint%" if not exist "%currentRestorePoint%" curl -g -k -L -# -o "%targetDir%\RestorePoint.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/RestorePoint.ps1" >nul 2>&1
if not exist "%fileLockConsoleSize%" if not exist "%currentLockConsoleSize%" curl -g -k -L -# -o "%targetDir%\LockConsoleSize.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/LockConsoleSize.ps1" >nul 2>&1
if not exist "%fileSetConsoleOpacity%" if not exist "%currentSetConsoleOpacity%" curl -g -k -L -# -o "%targetDir%\SetConsoleOpacity.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/SetConsoleOpacity.ps1" >nul 2>&1
if not exist "%fileBackupRegistry%" if not exist "%currentBackupRegistry%" curl -g -k -L -# -o "%targetDir%\Backup-Registry.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/Backup-Registry.ps1" >nul 2>&1

:: Verify all files were downloaded successfully
set "allFilesExist=true"
if not exist "%fileRestorePoint%" if not exist "%currentRestorePoint%" set "allFilesExist=false"
if not exist "%fileLockConsoleSize%" if not exist "%currentLockConsoleSize%" set "allFilesExist=false"
if not exist "%fileSetConsoleOpacity%" if not exist "%currentSetConsoleOpacity%" set "allFilesExist=false"
if not exist "%fileBackupRegistry%" if not exist "%currentBackupRegistry%" set "allFilesExist=false"

if "%allFilesExist%"=="false" (
    echo Some files failed to download. Please check your internet connection and try again.

    exit /b 1
)

:: Move files to current directory and set window title
move "%targetDir%\*" "%currentDir%\" >nul 2>&1
powershell.exe -Command "$host.ui.RawUI.WindowTitle = 'Aurora | @by IBRHUB'" >nul 2>&1


start cmd /c "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass "%currentDir%\Backup-Registry.ps1" >nul 2>&1"
if %errorlevel% neq 0 (
    echo Retrying Backup-Registry.ps1...
    start cmd /c "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass "%currentDir%\Backup-Registry.ps1" >nul 2>&1"
)

:: Execute PowerShell scripts
:: powershell.exe -ExecutionPolicy Bypass -File "%currentDir%\RestorePoint.ps1" >nul 2>&1
:: if %errorlevel% neq 0 (
::     echo Retrying RestorePoint.ps1...
::     powershell.exe -ExecutionPolicy Bypass -File "%currentDir%\RestorePoint.ps1" >nul 2>&1
:: )

powershell.exe -ExecutionPolicy Bypass -File "%currentDir%\LockConsoleSize.ps1" >nul 2>&1
if %errorlevel% neq 0 (
    echo Retrying LockConsoleSize.ps1...
    powershell.exe -ExecutionPolicy Bypass -File "%currentDir%\LockConsoleSize.ps1" >nul 2>&1
)

powershell.exe -ExecutionPolicy Bypass -File "%currentDir%\SetConsoleOpacity.ps1" >nul 2>&1
if %errorlevel% neq 0 (
    echo Retrying SetConsoleOpacity.ps1...
    powershell.exe -ExecutionPolicy Bypass -File "%currentDir%\SetConsoleOpacity.ps1" >nul 2>&1
)



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
chcp 65001 >NUL 2>&1
if errorlevel 1 (
    chcp 65001 >NUL 2>&1
    if errorlevel 1 (
        chcp 65001 >NUL 2>&1
        if errorlevel 1 (
            powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs" >NUL 2>&1
            exit /b
        )
    )
)

rem Remove the custom values
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Nls\CodePage" /v "OEMCP" /f >NUL 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Nls\CodePage" /v "ACP" /f >NUL 2>&1

rem Restore default values (OEMCP: 437, ACP: 1252)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Nls\CodePage" /v "OEMCP" /t REG_SZ /d "437" /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Nls\CodePage" /v "ACP" /t REG_SZ /d "1252" /f >NUL 2>&1

reg add "HKCU\CONSOLE" /v "VirtualTerminalLevel" /t REG_DWORD /d "1" /F >NUL 2>&1
cls
goto :DISCLAIMER


:DISCLAIMER
cls
mode con cols=61 lines=27
color 0f
echo.
echo                  %ESC%[1;38;5;159m╭──────────────────────────╮
echo                  %ESC%[1;38;5;159m│       %ESC%[1;97mA U R O R A%ESC%[1;38;5;159m        │
echo                  %ESC%[1;38;5;159m╰──────────────────────────╯%ESC%[0m
echo.
echo     %ESC%[1;3;38;5;195m- Disclaimer %ESC%[0m     
echo.
echo    %ESC%[38;5;33m╔══════════════════════════════════════════════════════╗%ESC%[0m
echo    %ESC%[38;5;33m║%ESC%[93m  This script makes system modifications that may     %ESC%[38;5;33m║
echo    %ESC%[38;5;33m║%ESC%[93m  affect system stability. By continuing, you agree   %ESC%[38;5;33m║
echo    %ESC%[38;5;33m║%ESC%[93m  to our terms of service and privacy policy.         %ESC%[38;5;33m║
echo    %ESC%[38;5;33m║%ESC%[0m                                                      %ESC%[38;5;33m║
echo    %ESC%[38;5;33m║%ESC%[96m  Full disclaimer:                                    %ESC%[38;5;33m║
echo    %ESC%[38;5;33m║%ESC%[94m  https://docs.ibrhub.net/ar/disclaimer               %ESC%[38;5;33m║
echo    %ESC%[38;5;33m╚══════════════════════════════════════════════════════╝%ESC%[0m
echo.
echo    %ESC%[38;5;33m╭──────────────────────────────────────────────────────╮%ESC%[0m
echo    %ESC%[38;5;33m│%ESC%[92m  ► 1. %ESC%[97mI agree to the terms and conditions            %ESC%[38;5;33m│%ESC%[0m
echo    %ESC%[38;5;33m╰──────────────────────────────────────────────────────╯%ESC%[0m
echo.
echo    %ESC%[38;5;33m╭──────────────────────────────────────────────────────╮%ESC%[0m
echo    %ESC%[38;5;33m│%ESC%[91m  ► 2. %ESC%[97mI do not agree %ESC%[1;38;5;214m[%ESC%[93mExit Aurora%ESC%[1;38;5;214m]                   %ESC%[38;5;33m│%ESC%[0m
echo    %ESC%[38;5;33m╰──────────────────────────────────────────────────────╯%ESC%[0m
echo.
echo.

:: Prompt user for input
set /p choice=%ESC%[1;38;5;214m[%ESC%[93mAurora%ESC%[1;38;5;214m]%ESC%[38;5;87m Select option [1-2]: %ESC%[0m

:: Handle user's choice
if /I "%choice%"=="1" (
    echo.
    echo    %ESC%[38;5;33m╭──────────────────────────────────────────────────────╮%ESC%[0m
    echo    %ESC%[38;5;33m│%ESC%[92m  ✓ Agreement confirmed. Initializing Aurora...       %ESC%[38;5;33m│%ESC%[0m
    echo    %ESC%[38;5;33m╰──────────────────────────────────────────────────────╯%ESC%[0m
    timeout /t 1 /nobreak > NUL
    goto :StartAurora
) else if /I "%choice%"=="2" (
    echo.
    echo    %ESC%[38;5;33m╭──────────────────────────────────────────────────────╮%ESC%[0m
    echo    %ESC%[38;5;33m│%ESC%[91m  ✗ Agreement declined. Exiting program...            %ESC%[38;5;33m│%ESC%[0m
    echo    %ESC%[38;5;33m╰──────────────────────────────────────────────────────╯%ESC%[0m
    timeout /t 1 /nobreak > NUL
    goto :endAurora
) else if /I "%choice%"=="X" (
    goto :MainMenu
) else (
    echo.
	cls
    echo    %ESC%[38;5;33m╭──────────────────────────────────────────────────────╮%ESC%[0m
    echo    %ESC%[38;5;33m│%ESC%[91m  Invalid selection! Please choose 1 or 2             %ESC%[38;5;33m│%ESC%[0m
    echo    %ESC%[38;5;33m╰──────────────────────────────────────────────────────╯%ESC%[0m
    timeout /t 3 /nobreak > NUL
    goto :DISCLAIMER
)


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
set "requiredFiles[19]=UltimateCleanup.bat"
set "requiredFiles[20]=ONED.bat"
set "requiredFiles[21]=winfetch.psm1"
set "requiredFiles[22]=TempCleaner.bat"


:: Check each file
for /L %%i in (0,1,18) do (
    if not exist "%currentDir%\!requiredFiles[%%i]!" (
        set "allFilesExist=false"
        goto :checkResult
    )
)

:checkResult
if "!allFilesExist!"=="true" (
    echo    %ESC%[38;5;33m╭──────────────────────────────────────────────────────╮%ESC%[0m
    echo    %ESC%[38;5;33m│%ESC%[92m Required files already exist. Skipping download...   %ESC%[38;5;33m│
    echo    %ESC%[38;5;33m╰──────────────────────────────────────────────────────╯%ESC%[0m
    timeout /t 3 /nobreak > NUL
    goto :skipDownload
) else (
    goto :DownloadModules
)
endlocal

:DownloadModules
cls
mode con cols=98 lines=35
echo    %ESC%[1;3;38;5;195m- Downloading Aurora Modules%ESC%[0m
echo.
echo    %ESC%[38;5;33m╭──────────────────────────────────────────────────────╮%ESC%[0m
echo    %ESC%[38;5;33m│%ESC%[97m           Starting the Module Download Process            %ESC%[38;5;33m│
echo    %ESC%[38;5;33m╰──────────────────────────────────────────────────────╯%ESC%[0m

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

call :UpdateProgress 95.5 "AuroraAvatar.ico"
curl -g -k -L -# -o "%targetDir%\AuroraAvatar.ico" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/Docs/Assets/AuroraAvatar.ico" >nul 2>&1

call :UpdateProgress 96.0 "AuroraManualServices.cmd"
curl -g -k -L -# -o "%targetDir%\AuroraManualServices.cmd" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/AuroraManualServices.cmd" >nul 2>&1

call :UpdateProgress 97.0 "UltimateCleanup.bat"
curl -g -k -L -# -o "%targetDir%\UltimateCleanup.bat" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/UltimateCleanup.bat" >nul 2>&1

call :UpdateProgress 98.0 "ONED.bat"
curl -g -k -L -# -o "%targetDir%\ONED.bat" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/ONED.bat" >nul 2>&1

call :UpdateProgress 98.5 "winfetch.psm1"
curl -g -k -L -# -o "%targetDir%\winfetch.psm1" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/winfetch.psm1" >nul 2>&1

call :UpdateProgress 100.0 "TempCleaner.bat"
curl -g -k -L -# -o "%targetDir%\TempCleaner.bat" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/TempCleaner.bat" >nul 2>&1

echo    %ESC%[38;5;33m╭──────────────────────────────────────────────────────╮%ESC%[0m
echo    %ESC%[38;5;33m│%ESC%[92m ✓  All modules downloaded successfully!        %ESC%[93m(100%%)%ESC%[38;5;33m │
echo    %ESC%[38;5;33m╰──────────────────────────────────────────────────────╯%ESC%[0m
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
echo    %ESC%[38;5;33m╭─────────────────────────────────────────────────────────╮%ESC%[0m
echo    %ESC%[38;5;33m│%ESC%[97m Downloading:%ESC%[96m %filename% %ESC%[0m
echo    %ESC%[38;5;33m│%ESC%[0m [%progressBar%] %ESC%[93m%percentage%%%%ESC%[0m
echo    %ESC%[38;5;33m╰─────────────────────────────────────────────────────────╯%ESC%[0m

:: Small delay instead of pause
endlocal
goto :eof

:skipDownload
if not exist "%currentDir%" mkdir "%currentDir%"
move "%targetDir%\*" "%currentDir%\" >nul 2>&1
cls

cls
rem ========================================================================================================================================

:: ANSI Escape Code Definition
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "ESC=%%b"
)
set AuroraAsAdmin=%currentDir%\AuroraSudo.exe
:: Enable ANSI Support (Windows 10+)
REG ADD HKCU\CONSOLE /f /v VirtualTerminalLevel /t REG_DWORD /d 1 >nul 2>&1
REG ADD HKCU\CONSOLE /f /v InsertMode /t REG_DWORD /d 1 >nul 2>&1
REG ADD HKCU\CONSOLE /f /v QuickEdit /t REG_DWORD /d 0 >nul 2>&1
REG ADD HKCU\CONSOLE /f /v LineSelection /t REG_DWORD /d 1 >nul 2>&1

color 0f

:WinTweaks
mode con cols=76 lines=28

:: - Setting UAC - never notify
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v PromptOnSecureDesktop /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 0 /f > NUL 2>&1

echo.%ESC%[38;5;33m - Optimizing Edge and Chrome Settings...%ESC%[0m
:: Disable startup boost for Edge
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v StartupBoostEnabled /t REG_DWORD /d 0 /f > NUL 2>&1
:: Disable hardware acceleration for Edge
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v HardwareAccelerationModeEnabled /t REG_DWORD /d 0 /f > NUL 2>&1
:: Disable background mode for Edge
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v BackgroundModeEnabled /t REG_DWORD /d 0 /f > NUL 2>&1
:: Disable Edge elevation service
reg add "HKLM\SYSTEM\CurrentControlSet\Services\MicrosoftEdgeElevationService" /v Start /t REG_DWORD /d 4 /f > NUL 2>&1
:: Disable Edge update service
reg add "HKLM\SYSTEM\CurrentControlSet\Services\edgeupdate" /v Start /t REG_DWORD /d 4 /f > NUL 2>&1
:: Disable Edge update service (machine)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\edgeupdatem" /v Start /t REG_DWORD /d 4 /f > NUL 2>&1

:: Disable startup boost for Chrome
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v StartupBoostEnabled /t REG_DWORD /d 0 /f > NUL 2>&1
:: Disable background mode for Chrome
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v BackgroundModeEnabled /t REG_DWORD /d 0 /f > NUL 2>&1
:: Enable high efficiency mode for Chrome
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v HighEfficiencyModeEnabled /t REG_DWORD /d 1 /f > NUL 2>&1

echo.%ESC%[38;5;33m - Configuring Game Settings...%ESC%[0m
:: Remove NVIDIA backend from startup
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v NvBackend /f > NUL 2>&1
:: Disable NVIDIA telemetry opt-in
reg add "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" /v OptInOrOutPreference /t REG_DWORD /d 0 /f > NUL 2>&1
:: Disable various NVIDIA telemetry features
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v EnableRID66610 /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v EnableRID64640 /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v EnableRID44231 /t REG_DWORD /d 0 /f > NUL 2>&1

:: Disable GPU acceleration for Steam web views
reg add "HKCU\SOFTWARE\Valve\Steam" /v "GPUAccelWebViewsV2" /t REG_DWORD /d 0 /f > NUL 2>&1
:: Disable H264 hardware acceleration for Steam
reg add "HKCU\SOFTWARE\Valve\Steam" /v "H264HWAccel" /t REG_DWORD /d 0 /f > NUL 2>&1

:: Disable Multiple Plane Overlay
reg add "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v OverlayTestMode /t REG_DWORD /d 5 /f > NUL 2>&1

:: Configure game scheduling for optimal performance
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v Affinity /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Background Only" /t REG_SZ /d False /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Clock Rate" /t REG_DWORD /d 10000 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v Priority /t REG_DWORD /d 6 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d High /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d High /f > NUL 2>&1

echo.%ESC%[38;5;33m - Disabling Background Apps...%ESC%[0m
:: Disable background apps globally
Reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d "1" /f >nul 2>&1
:: Prevent apps from running in background via policy
Reg add "HKLM\Software\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsRunInBackground" /t REG_DWORD /d "2" /f >nul 2>&1
:: Disable background app global toggle
Reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BackgroundAppGlobalToggle" /t REG_DWORD /d "0" /f >nul 2>&1
:: Backup current startup configuration

if not exist "C:\StartupBackup.reg" (
    reg.exe export "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" "C:\StartupBackup.reg" /y >nul 2>&1
    attrib +h "C:\StartupBackup.reg" >nul 2>&1
)
if not exist "C:\StartupApprovedBackup.reg" (
    reg.exe export "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" "C:\StartupApprovedBackup.reg" /y >nul 2>&1
    attrib +h "C:\StartupApprovedBackup.reg" >nul 2>&1
)

::  Disable startup for common apps in a loop 
for %%A in (Discord Synapse3 Spotify EpicGamesLauncher RiotClient Steam GoogleDrive OneDrive DropboxUpdate CCleaner iTunesHelper AdobeCreativeCloud AdobeGCClient EADesktop UbisoftConnect UbisoftGameLauncher BattleNet TeamViewer AnyDesk LogitechGHub CorsairService RazerCentralService MSIAfterburner NVIDIAGeForceExperience AMDRyzenMaster Overwolf SteelSeriesEngine ASUSArmouryCrate ROGGameFirst ROGRangeboost iCUE "Wallpaper Engine" "GOG Galaxy" "Microsoft Teams" Slack Zoom Skype WhatsApp Telegram OpenRGB SignalRGB "Java Update Scheduler" "QuickTime Task" SoundBlasterConnect RealPlayer) do (
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "%%A" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
    reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "%%A" /f >nul 2>&1
)
:: Enable Hardware-Accelerated GPU Scheduling
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f > NUL 2>&1

:: Enable Windows Game Mode
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v AllowAutoGameMode /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v AutoGameModeEnabled /t REG_DWORD /d 1 /f > NUL 2>&1

:: Set system to prioritize programs over background services
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 38 /f > NUL 2>&1

echo.%ESC%[38;5;33m - Optimizing Explorer ...%ESC%[0m
:: Set menu show delay to 0
reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d "0" /f > NUL 2>&1

:: Enable OLED taskbar transparency
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "UseOLEDTaskbarTransparency" /t REG_DWORD /d 1 /f > NUL 2>&1
:: Force transparency effect mode
reg add "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v "ForceEffectMode" /t REG_DWORD /d 2 /f > NUL 2>&1

:: Hide recently added apps
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "HideRecentlyAddedApps" /t REG_DWORD /d 1 /f > NUL 2>&1
reg Delete "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "HideRecentlyAddedApps" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "HideRecentlyAddedApps" /t REG_DWORD /d 1 /f > NUL 2>&1
:: Disable showing frequent items
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowFrequent" /t REG_DWORD /d 0 /f > NUL 2>&1
:: Disable showing recent items
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowRecent" /t REG_DWORD /d 0 /f > NUL 2>&1
:: Hide most used apps
reg Delete "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "ShowOrHideMostUsedApps" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "ShowOrHideMostUsedApps" /t REG_DWORD /d 2 /f > NUL 2>&1
:: Disable recent docs history
reg Delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoStartMenuMFUprogramsList" /f > NUL 2>&1
reg Delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoRecentDocsHistory" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoRecentDocsHistory" /t REG_DWORD /d 1 /f > NUL 2>&1
:: Disable taskbar search
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarSh" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "ShowOrHideMostUsedApps" /t REG_DWORD /d 0 /f > NUL 2>&1

:: Disable Edge startup boost and enable battery saver
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "StartupBoostEnabled" /t REG_DWORD /d 0 /f > NUL 2>&1
rereg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "BatterySaverModeAvailability" /t REG_DWORD /d 1 /f > NUL 2>&1
:: Disable Chrome startup boost and enable battery saver
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "StartupBoostEnabled" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "BatterySaverModeAvailability" /t REG_DWORD /d 1 /f > NUL 2>&1
:: Configure Brave browser settings
reg add "HKLM\Software\Policies\BraveSoftware\Brave" /v "HighEfficiencyModeEnabled" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\Software\Policies\BraveSoftware\Brave" /v "BatterySaverModeAvailability" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\Software\Policies\BraveSoftware\Brave\Recommended" /v "BackgroundModeEnabled" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\Software\Policies\BraveSoftware\Brave\Recommended" /v "BatterySaverModeAvailability" /t REG_DWORD /d 1 /f > NUL 2>&1

:: Disable Edge update services
reg add "HKLM\SYSTEM\CurrentControlSet\Services\MicrosoftEdgeElevationService" /v "Start" /t REG_DWORD /d 4 /f > NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\edgeupdate" /v "Start" /t REG_DWORD /d 4 /f > NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\edgeupdatem" /v "Start" /t REG_DWORD /d 4 /f > NUL 2>&1
:: Remove Edge update tasks
reg Delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree\MicrosoftEdgeUpdateTaskMachineCore" /f > NUL 2>&1
reg Delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree\MicrosoftEdgeUpdateTaskMachineUA" /f > NUL 2>&1
:: Disable Chrome update services
reg add "HKLM\SYSTEM\CurrentControlSet\Services\GoogleChromeElevationService" /v "Start" /t REG_DWORD /d 4 /f > NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\gupdate" /v "Start" /t REG_DWORD /d 4 /f > NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\gupdatem" /v "Start" /t REG_DWORD /d 4 /f > NUL 2>&1
:: Disable Firefox updates
reg add "HKLM\SOFTWARE\Policies\Mozilla\Firefox" /v "DisableAppUpdate" /t REG_DWORD /d 1 /f > NUL 2>&1

:: Enable auto restart of Explorer
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoRestartShell" /t REG_DWORD /d 1 /f > NUL 2>&1
:: Enable long paths
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "LongPathsEnabled" /t REG_DWORD /d 0 /f > NUL 2>&1
:: Reduce menu show delay
reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "0" /f > NUL 2>&1
:: Reduce mouse hover time
reg add "HKCU\Control Panel\Mouse" /v "MouseHoverTime" /t REG_SZ /d "0" /f > NUL 2>&1
:: Disable listview shadow
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ListviewShadow" /t REG_DWORD /d 0 /f > NUL 2>&1
:: Disable network crawling
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "NoNetCrawling" /t REG_DWORD /d 1 /f > NUL 2>&1
:: Disable balloon tips
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "EnableBalloonTips" /t REG_DWORD /d 0 /f > NUL 2>&1
:: Disable low disk space checks
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoLowDiskSpaceChecks" /t REG_DWORD /d 1 /f > NUL 2>&1
:: Configure link resolution settings
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "LinkResolveIgnoreLinkInfo" /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoResolveSearch" /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoResolveTrack" /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoInternetOpenWith" /t REG_DWORD /d 1 /f > NUL 2>&1
:: Disable window shaking
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DisallowShaking" /t REG_DWORD /d 1 /f > NUL 2>&1
:: Show file extensions
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d 0 /f > NUL 2>&1
:: Enable auto complete
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoComplete" /v "Append Completion" /t REG_SZ /d "yes" /f > NUL 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoComplete" /v "AutoSuggest" /t REG_SZ /d "yes" /f > NUL 2>&1
:: Set TDR delay
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrDelay" /t REG_DWORD /d 10 /f > NUL 2>&1
:: Disable window animation
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "0" /f > NUL 2>&1
:: Disable auto debug
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AeDebug" /v "Auto" /t REG_SZ /d "0" /f > NUL 2>&1
:: Disable secure desktop prompt
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d 0 /f > NUL 2>&1
:: Set folder type to not specified
reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" /v "FolderType" /t REG_SZ /d "NotSpecified" /f > NUL 2>&1
:: Disable link tracking
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "link" /t REG_BINARY /d "0" /f >nul 2>&1
:: Hide recommended section
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\Start" /v "HideRecommendedSection" /t REG_DWORD /d "1" /f > NUL 2>&1
:: Set as education environment
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\Education" /v "IsEducationEnvironment" /t REG_DWORD /d "1" /f > NUL 2>&1
:: Hide recommended section (policy)
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "HideRecommendedSection" /t REG_DWORD /d "1" /f > NUL 2>&1

:: Allow for paths over 260 characters
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "LongPathsEnabled" /t REG_DWORD /d "1" /f >nul 2>&1

:: Disable maintenance
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v MaintenanceDisabled /t REG_DWORD /d 1 /f > NUL 2>&1
:: Disable diagnostics
reg add "HKLM\SOFTWARE\Microsoft\Windows\ScheduledDiagnostics" /v EnabledExecution /t REG_DWORD /d 0 /f > NUL 2>&1

echo.%ESC%[38;5;33m - Disabling Non-Essential Scheduled Tasks...%ESC%[0m
set "tasksToDisable="
set tasksToDisable=^
 "\Microsoft\Windows\Application Experience\ProgramDataUpdater"^
 "\Microsoft\Windows\ApplicationData\DsSvcCleanup"^
 "\Microsoft\Windows\Customer Experience Improvement Program\Uploader"^
 "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator"^
 "\Microsoft\Windows\DiskFootprint\Diagnostics"^
 "\Microsoft\Windows\Feedback\Siuf\DmClient"^
 "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload"^
 "\Microsoft\Windows\Maps\MapsUpdateTask"^
 "\Microsoft\Windows\NetTrace\GatherNetworkInfo"^
 "\Microsoft\Windows\Shell\FamilySafetyUpload"^
 "\Microsoft\Windows\Windows Media Sharing\UpdateLibrary"^
 "\Microsoft\Windows\SettingSync\BackupTask"^
 "\Microsoft\Windows\SettingSync\NetworkStateChangeTask"^
 "\Microsoft\Windows\SettingSync\BackgroundUploadTask"

for %%T in (%tasksToDisable%) do (
    schtasks /change /tn "%%T" /disable > NUL 2>&1
)

echo.%ESC%[38;5;33m - Optimizing Visual Effects...%ESC%[0m
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
    goto :USBPowerSavings
) else (
    goto :skipUSBPowerSavings
)

:USBPowerSavings
echo.%ESC%[38;5;33m - Configuring USB Settings...%ESC%[0m
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


for /f %%a in ('wmic path Win32_VideoController get PNPDeviceID ^| find "PCI\VEN_"') do ^
reg query "HKLM\System\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" >nul 2>&1 && (
reg add "HKLM\System\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f > NUL 2>&1
)

goto :continue
:skipUSBPowerSavings

:continue
echo.%ESC%[38;5;33m - Finalizing Performance Settings...%ESC%[0m
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "DelayedDesktopSwitchTimeout" /t REG_DWORD /d "0" /f > NUL 2>&1
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "StartupDelayInMSec" /t REG_SZ /d "0" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "RunStartupScriptSync" /t REG_DWORD /d "0" /f > NUL 2>&1
bcdedit /set bootuxdisabled on > NUL 2>&1
bcdedit /set bootmenupolicy standard > NUL 2>&1
bcdedit /set quietboot yes > NUL 2>&1

reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t REG_SZ /d "3000" /f > NUL 2>&1
reg add "HKLM\System\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d "3000" /f > NUL 2>&1
reg add "HKCU\Control Panel\Desktop" /v "AutoEndTasks" /t REG_SZ /d "1" /f > NUL 2>&1

reg add "HKCU\Control Panel\Desktop" /v "HungAppTimeout" /t REG_SZ /d "2000" /f > NUL 2>&1
reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "20" /f > NUL 2>&1


reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "0" /f > NUL 2>&1

schtasks /change /tn "\microsoft\windows\power efficiency diagnostics\analyzesystem" /disable >nul 2>&1
wevtutil set-log "Microsoft-Windows-SleepStudy/Diagnostic" /e:False >nul 2>&1
wevtutil set-log "Microsoft-Windows-Kernel-Processor-Power/Diagnostic" /e:False >nul 2>&1
wevtutil set-log "Microsoft-Windows-UserModePowerService/Diagnostic" /e:False >nul 2>&1



start /wait powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%currentDir%\AuroraTimerResolution.ps1"
timeout /t 4 /nobreak > NUL
taskkill /f /im taskmgr.exe >nul 2>&1
rem - Disable Cloud Sync via Registry
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /t REG_DWORD /d "1" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableSoftLanding" /t REG_DWORD /d "1" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableCloudOptimizedContent" /t REG_DWORD /d "1" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableConsumerAccountStateContent" /t REG_DWORD /d "1" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /t REG_DWORD /d "1" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d "1" /f > NUL 2>&1
cls

CALL "%currentDir%\Cloud.BAT"

CALL "%currentDir%\Telemetry.bat"

CALL "%currentDir%\Privacy.bat
cls
start /wait powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%currentDir%\RemoveEdge.ps1" -UninstallEdge -NonInteractive

start /wait powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0AuroraModules\Components.ps1" 


:: Check GPU type using PowerShell as alternative to wmic
powershell -NoProfile -WindowStyle Hidden -Command "Get-WmiObject Win32_VideoController | Select-Object -ExpandProperty Name" | findstr /i "NVIDIA" >nul 2>&1
if %errorlevel% equ 0 (
    goto :NVIDIATweaks
) >nul 2>&1

powershell -NoProfile -WindowStyle Hidden -Command "Get-WmiObject Win32_VideoController | Select-Object -ExpandProperty Name" | findstr /i "AMD" >nul 2>&1
if %errorlevel% equ 0 (
    goto :AMDTweaks
) >nul 2>&1


:NVIDIATweaks
start /wait cmd /c "%currentDir%\NvidiaProfileInspector.cmd"

timeout /t 1 /nobreak > NUL
%AuroraAsAdmin% --NoLogo -S -P --WorkDir="%~dp0AuroraModules\AuroraNvidia\NvidiaProfileInspector" "%~dp0AuroraModules\AuroraNvidia\NvidiaProfileInspector\nvidiaProfileInspector.exe" "%~dp0AuroraModules\AuroraNvidia\NvidiaProfileInspector\AuroraON.nip"

goto :Power-Plan


:AMDTweaks
timeout /t 3 /nobreak > NUL
start /wait cmd /c "%currentDir%\AuroraAMD.bat"

goto :Power-Plan

:Power-Plan
start /wait powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "%currentDir%\Power.ps1" -Silent

:NetworkTweaks
start /wait powershell.exe -ExecutionPolicy Bypass -File "%currentDir%\NetworkBufferBloatFixer.ps1"


start /wait cmd.exe /c "%~dp0AuroraModules\AuroraManualServices.cmd"

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "SystemUsesLightTheme" /t REG_DWORD /d "0" /f >nul 2>&1

:: Enable dark mode for current user
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d "0" /f >nul 2>&1 
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "SystemUsesLightTheme" /t REG_DWORD /d "0" /f >nul 2>&1

C:\windows\system32\cmd.exe /c taskkill /f /im explorer.exe >nul 2>&1
timeout /t 1 /nobreak > NUL
start %windir%\explorer.exe >nul 2>&1


start /wait cmd.exe /c "%currentDir%\RepairWindows.cmd"
pause

:: Run TempCleaner with error handling
start /wait cmd.exe /c "%currentDir%\TempCleaner.bat" >nul 2>&1
if %errorlevel% neq 0 (
    echo Error running TempCleaner.bat
    timeout /t 2 /nobreak >nul
)

:: Run UltimateCleanup with error handling 
start /wait cmd.exe /c "%currentDir%\UltimateCleanup.bat" >nul 2>&1
if %errorlevel% neq 0 (
    echo Error running UltimateCleanup.bat
    timeout /t 2 /nobreak >nul
)

:end
C:\Windows\System32\TASKKILL.exe /f /im powershell.exe > nul 2> nul
C:\Windows\System32\TASKKILL.exe /f /im cmd.exe > nul 2> nul
exit /b



call ONED.bat
reg add "HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\ShellFolder" /f /v "Attributes" /t REG_DWORD /d "0" > NUL 2>&1
reg add "HKCR\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\ShellFolder" /f /v "Attributes" /t REG_DWORD /d "0" >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSync" /t REG_DWORD /d "1" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d "1" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableMeteredNetworkFileSync" /t REG_DWORD /d "0" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableLibrariesDefaultSaveToOneDrive" /t REG_DWORD /d "0" /f > NUL 2>&1

start /wait powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%currentDir%\OneDrive.ps1"
