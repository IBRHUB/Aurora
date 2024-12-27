@echo off
:: =============================================================================
:: Script: Aurora Setup and Tweaks
:: Description: Downloads necessary modules, sets up environment, and provides
::              a menu for various system tweaks.
:: Author: IBRHUB
:: =============================================================================

:: Enable Delayed Expansion
setlocal enabledelayedexpansion

:: Set PowerShell Execution Policy to Bypass for both 64-bit and 32-bit
for %%R in (
    "HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell"
    "HKLM\SOFTWARE\Wow6432Node\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell"
) do (
    powershell.exe "Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine" >NUL 2>&1
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

:: Check Internet Connection
ping -n 1 "google.com" >nul 2>&1
if !ERRORLEVEL! neq 0 (
    echo ERROR: No internet connection found
    echo.
    echo Please make sure you are connected to the internet and try again . . .
    pause >nul
    exit /b
)

:: Check for Administrator Privileges
fltmc >nul 2>&1
if !errorlevel! neq 0 (
    echo Administrator privileges are required.
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs" >nul 2>&1
    if !errorlevel! neq 0 (
        echo You must run this script as admin.
        pause
        exit /b 1
    )
    exit /b
)

:: Set File Paths
set "logFile=%temp%\download_log.txt"
set "targetDir=%temp%\AuroraModules"
set "currentDir=%~dp0AuroraModules"

:: Ensure Target and Files Directories Exist
mkdir "%targetDir%\Files" 2>nul

:: Initialize Log File
> "%logFile%" echo Download Log - %date% %time%
echo Downloading files for Aurora...
echo.

:: Define Files to Download
set "files=LockConsoleSize.ps1 OneDrive.ps1 Power.ps1 RestorePoint.ps1 SetConsoleOpacity.ps1 NvidiaProfileInspector.cmd"
set "fileURLs=https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/"

:: Download Required Files
echo Downloading required PowerShell and CMD files...
for %%F in (%files%) do (
    curl -g -k -L -# -o "%targetDir%\%%F" "%fileURLs%%%F" || echo Failed to download %%F >> "%logFile%"
)

:: Define Button Files to Download
set "buttonFiles=Box.bat GetInput.exe Getlen.bat batbox.exe quickedit.exe Button.bat"
set "buttonURLs=https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/Files/"

:: Download Button Files
echo Downloading button files...
for %%F in (Box.bat GetInput.exe Getlen.bat batbox.exe quickedit.exe) do (
    curl -g -k -L -# -o "%targetDir%\Files\%%F" "%buttonURLs%%%F" || echo Failed to download %%F >> "%logFile%"
)

:: Download Button.bat
curl -g -k -L -# -o "%targetDir%\Button.bat" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/Button.bat" || echo Failed to download Button.bat >> "%logFile%"

:: Ensure Current Directory Exists and Move Files
mkdir "%currentDir%" 2>nul
echo Moving downloaded files to the current directory...
xcopy /e /i /y "%targetDir%\" "%currentDir%\" >nul 2>>"%logFile%"
if !errorlevel! neq 0 (
    echo Failed to move files. Check permissions or existing files in the target directory. >> "%logFile%"
) else (
    echo Files moved successfully.
)

:: Log Summary
echo.
echo Download Summary:
type "%logFile%"

:: Cleanup
echo.
echo Cleanup completed. Check the log file for details: %logFile%
pause

:: Enable ANSI Sequences and Set Console Properties
reg add "HKCU\CONSOLE" /v "VirtualTerminalLevel" /t REG_DWORD /d "1" /f >nul 2>&1
powershell.exe -Command "$host.ui.RawUI.WindowTitle = 'Aurora | @by IBRHUB'"
mode con: cols=85 lines=29
powershell.exe -ExecutionPolicy Bypass -File "%currentDir%\LockConsoleSize.ps1"
cls

:: Additional PowerShell Commands
powershell.exe "ForEach($v in (Get-Command -Name 'Set-ProcessMitigation').Parameters['Disable'].Attributes.ValidValues){Set-ProcessMitigation -System -Disable $v.ToString() -ErrorAction SilentlyContinue}" >nul 2>&1
cls
chcp 65001 >nul
color f

:: Main Menu
:Main
cls
mode con:cols=90 lines=34

:: Display Project Logo
echo.
echo.
echo.
echo.
echo.
echo	        [38;5;105m ▄█  ▀█████████▄     ▄████████    ▄█    █▄    ███    █▄  ▀█████████▄  
echo	        [38;5;105m ███    ███    ███   ███    ███   ███    ███   ███    ███   ███    ███ 
echo	        [38;5;69m ███▌   ███    ███   ███    ███   ███    ███   ███    ███   ███    ███ 
echo	        [38;5;69m ███▌  ▄███▄▄▄██▀   ▄███▄▄▄▄██▀  ▄███▄▄▄▄███▄▄ ███    ███  ▄███▄▄▄██▀  
echo	        [38;5;133m ███▌ ▀▀███▀▀▀██▄  ▀▀███▀▀▀▀▀   ▀▀███▀▀▀▀███▀  ███    ███ ▀▀███▀▀▀██▄  
echo	        [38;5;133m ███    ███    ██▄ ▀███████████   ███    ███   ███    ███   ███    ██▄ 
echo	        [38;5;105m ███    ███    ███   ███    ███   ███    ███   ███    ███   ███    ███ 
echo	        [38;5;105m █▀   ▄█████████▀    ███    ███   ███    █▀    ████████▀  ▄█████████▀  
echo	        [38;5;69m                     ███    ███                                       
echo.

:: Update PATH
pushd "%currentDir%"
set "Path=%cd%;%cd%\Files;%Path%;"
popd

:: Create Main Buttons
pushd "%currentDir%"
call "Button.bat" 10 19 F2 "Windows Tweaks" 35 19 F2 "GPU Tweaks" 60 19 F2 "Network Tweaks" 10 24 F2 "Power-Plan" 35 24 F2 "Discord Website" 65 24 F2 "Exit" X _Var_Box _Var_Hover _Var_Code
batbox %_Var_Code%
popd

:: Get User Choice
pushd "%currentDir%"
call "GetInput.exe" /M %_Var_Box% /H %_Var_Hover%
set "userChoice=%Errorlevel%"
popd

:: Handle User Choice
if "%userChoice%"=="1" goto WinTweaks
if "%userChoice%"=="2" goto GPUTweaks
if "%userChoice%"=="3" goto NetworkTweaks
if "%userChoice%"=="4" goto PowerPlan
if "%userChoice%"=="5" goto Website
if "%userChoice%"=="6" goto ExitScript
goto Main

:: =============================================================================
:: Section: Windows Tweaks
:: =============================================================================
:WinTweaks
cls
mode con:cols=150 lines=25
echo.

:: Create Sub-buttons
pushd "%currentDir%"
call "Button.bat" 55 15 F2 "[1] Yes" 70 15 F2 "[2] No (Skip)" 59 20 F2 "[3] Back to Main Menu" X _Var_Box _Var_Hover _Var_Code
batbox %_Var_Code%
popd

:: Get User Choice
pushd "%currentDir%"
call "GetInput.exe" /M %_Var_Box% /H %_Var_Hover%
set "userChoice=%Errorlevel%"
popd

:: Handle User Choice
if "%userChoice%"=="1" goto DisableOneDrive
if "%userChoice%"=="2" goto SkipUpdates
if "%userChoice%"=="3" goto Main
goto WinTweaks

:DisableOneDrive
cls
echo Disabling OneDrive...
:: Add your OneDrive disabling commands here
pause
goto SkipUpdates

:SkipUpdates
cls
echo Skipping updates...
pause
goto Main

:: =============================================================================
:: Section: GPU Tweaks
:: =============================================================================
:GPUTweaks
cls
echo.

:: Create Sub-buttons
pushd "%currentDir%"
call "Button.bat" 15 15 F2 "[1] NVIDIA" 35 15 F4 "[2] AMD" 50 15 F2 "[3] Back to Main Menu" X _Var_Box _Var_Hover _Var_Code
batbox %_Var_Code%
popd

:: Get User Choice
pushd "%currentDir%"
call "GetInput.exe" /M %_Var_Box% /H %_Var_Hover%
set "userChoice=%Errorlevel%"
popd

:: Handle User Choice
if "%userChoice%"=="1" goto NVIDIATweaks
if "%userChoice%"=="2" goto AMDTweaks
if "%userChoice%"=="3" goto Main
goto GPUTweaks

:NVIDIATweaks
cls
echo Launching NVIDIA Profile Inspector...
mode con:cols=85 lines=33
start "" /wait "%currentDir%\NvidiaProfileInspector.cmd"

:: Create Sub-buttons
pushd "%currentDir%"
call "Button.bat" 19 11 F2 "[1] ResizableBarOFF" 44 11 F2 "[2] ResizableBarON" 30 16 F2 "[3] Back to Main Menu" X _Var_Box _Var_Hover _Var_Code
batbox %_Var_Code%
popd

:: Get User Choice
pushd "%currentDir%"
call "GetInput.exe" /M %_Var_Box% /H %_Var_Hover%
set "userChoice=%Errorlevel%"
popd

:: Handle User Choice
if "%userChoice%"=="1" goto AuroraOFF
if "%userChoice%"=="2" goto AuroraON
if "%userChoice%"=="3" goto Main
goto NVIDIATweaks

:AuroraOFF
cls
echo Disabling Resizable BAR...
start "" /wait "C:\NvidiaProfileInspector\nvidiaProfileInspector.exe" "C:\NvidiaProfileInspector\AuroraOFF.nip"
if !errorlevel! neq 0 (
    echo Failed to apply AuroraOFF.nip.
    pause
    goto Main
)
echo [38;5;213mResizable BAR has been disabled successfully.[0m
timeout /t 3 /nobreak >nul
goto Main

:AuroraON
cls
echo Enabling Resizable BAR...
start "" /wait "C:\NvidiaProfileInspector\nvidiaProfileInspector.exe" "C:\NvidiaProfileInspector\AuroraON.nip"
if !errorlevel! neq 0 (
    echo Failed to apply AuroraON.nip.
    pause
    goto Main
)
echo [38;5;213mResizable BAR has been enabled successfully.[0m
timeout /t 3 /nobreak >nul
goto Main

:AMDTweaks
cls
echo Launching AMD Tweaks...
start "" /wait "%currentDir%\AMDDwords.bat"
goto Main

:: =============================================================================
:: Section: Power Plan
:: =============================================================================
:PowerPlan
cls

:: Create Sub-buttons
pushd "%currentDir%"
call "Button.bat" 22 10 F2 "[1] Desktop" 50 10 F2 "[2] Laptop" 32 16 F2 "[3] Back to Main Menu" X _Var_Box _Var_Hover _Var_Code
batbox %_Var_Code%
popd

:: Get User Choice
pushd "%currentDir%"
call "GetInput.exe" /M %_Var_Box% /H %_Var_Hover%
set "userChoice=%Errorlevel%"
popd

:: Handle User Choice
if "%userChoice%"=="1" goto Desktop
if "%userChoice%"=="2" goto Laptop
if "%userChoice%"=="3" goto Main
goto PowerPlan

:Desktop
cls
echo Applying Desktop Power Plan...
start /wait powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "%currentDir%\Power.ps1" -Silent
goto Main

:Laptop
cls
echo Applying Laptop Power Plan...
start /wait powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "%currentDir%\Power.ps1" -Silent
goto Main

:: =============================================================================
:: Section: Website
:: =============================================================================
:Website
cls

:: Create Sub-buttons
pushd "%currentDir%"
call "Button.bat" 22 10 F2 "[1] Discord" 50 10 F2 "[2] IBRPRIDE.COM" 32 16 F2 "[3] Back to Main Menu" X _Var_Box _Var_Hover _Var_Code
batbox %_Var_Code%
popd

:: Get User Choice
pushd "%currentDir%"
call "GetInput.exe" /M %_Var_Box% /H %_Var_Hover%
set "userChoice=%Errorlevel%"
popd

:: Handle User Choice
if "%userChoice%"=="1" goto Discord
if "%userChoice%"=="2" goto Website2
if "%userChoice%"=="3" goto Main
goto Website

:Discord
start https://discord.gg/T4WemSTX
goto Main

:Website2
start https://ibrpride.com/
goto Main

:: =============================================================================
:: Section: Network Tweaks
:: =============================================================================
:NetworkTweaks
cls
echo.

:: Create Sub-buttons
pushd "%currentDir%"
call "Button.bat" 20 11 F2 "[1] Windows 10" 50 11 F2 "[2] Windows 11" 32 16 F2 "[3] Back to Main Menu" X _Var_Box _Var_Hover _Var_Code
batbox %_Var_Code%
popd

:: Get User Choice
pushd "%currentDir%"
call "GetInput.exe" /M %_Var_Box% /H %_Var_Hover%
set "userChoice=%Errorlevel%"
popd

:: Handle User Choice
if "%userChoice%"=="1" goto Win10Net
if "%userChoice%"=="2" goto Win11Net
if "%userChoice%"=="3" goto Main
goto NetworkTweaks

:Win10Net
cls
echo Configuring Network Tweaks for Windows 10...
:: Add your Windows 10 network tweak commands here
pause
goto Main

:Win11Net
cls
echo Configuring Network Tweaks for Windows 11...
:: Add your Windows 11 network tweak commands here
pause
goto Main

:: =============================================================================
:: Section: Exit Script
:: =============================================================================
:ExitScript
cls
echo Exiting Aurora Setup...
pause >nul
exit

:: =============================================================================
:: End of Script
:: =============================================================================
