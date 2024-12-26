@echo off
:: Enable Delayed Expansion
setlocal enabledelayedexpansion

:: Set PowerShell Execution Policy to Unrestricted
powershell.exe "Set-ExecutionPolicy -ExecutionPolicy Unrestricted" >NUL 2>&1

REM Check if ExecutionPolicy key exists and create it if necessary
REG QUERY "HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v ExecutionPolicy >nul 2>&1
if %errorlevel% neq 0 (
    REG ADD "HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v ExecutionPolicy /t REG_SZ /d Bypass /f >nul 2>&1
)

REG QUERY "HKLM\SOFTWARE\Wow6432Node\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v ExecutionPolicy >nul 2>&1
if %errorlevel% neq 0 (
    REG ADD "HKLM\SOFTWARE\Wow6432Node\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v ExecutionPolicy /t REG_SZ /d Bypass /f >nul 2>&1
)

REM Check if ExecutionPolicy value is set to Bypass and update if necessary
for /f "tokens=2*" %%A in ('REG QUERY "HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v ExecutionPolicy ^| findstr ExecutionPolicy') do (
    if NOT "%%B"=="Bypass" (
        REG ADD "HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v ExecutionPolicy /t REG_SZ /d Bypass /f >nul 2>&1
    )
)

for /f "tokens=2*" %%A in ('REG QUERY "HKLM\SOFTWARE\Wow6432Node\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v ExecutionPolicy ^| findstr ExecutionPolicy') do (
    if NOT "%%B"=="Bypass" (
        REG ADD "HKLM\SOFTWARE\Wow6432Node\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v ExecutionPolicy /t REG_SZ /d Bypass /f >nul 2>&1
    )
)

:: Check Internet Connection
ping -n 1 "google.com" >nul 2>&1
if !ERRORLEVEL! neq 0 (
    echo ERROR: No internet connection found
    echo.
    echo Please make sure you are connected to the internet and try again . . .
    pause >nul && exit
)

:: Check for Administrator Privileges
fltmc > nul 2>&1 || (
    echo Administrator privileges are required.
    powershell -c "Start-Process -Verb RunAs -FilePath 'cmd' -ArgumentList ' /c \"%~f0\"' " 2> nul || (
        echo You must run this script as admin.
        if "%*"=="" pause
        exit /b 1
    )
    exit /b
)

:: Set File Paths
set logFile=%temp%\download_log.txt
set targetDir=%temp%\AuroraModules
set currentDir=%~dp0AuroraModules

:: Ensure Target Directory Exists
if not exist "%targetDir%" mkdir "%targetDir%"

:: Clear Log File
> "%logFile%" echo Download Log - %date% %time%
echo Downloading files for Aurora...
echo.

:: Download Required Files
echo Downloading required PowerShell and CMD files...
curl -g -k -L -# -o "%targetDir%\LockConsoleSize.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/LockConsoleSize.ps1" || echo Failed to download LockConsoleSize.ps1 >> "%logFile%"
curl -g -k -L -# -o "%targetDir%\OneDrive.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/OneDrive.ps1" || echo Failed to download OneDrive.ps1 >> "%logFile%"
curl -g -k -L -# -o "%targetDir%\Power.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/Power.ps1" || echo Failed to download Power.ps1 >> "%logFile%"
curl -g -k -L -# -o "%targetDir%\RestorePoint.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/RestorePoint.ps1" || echo Failed to download RestorePoint.ps1 >> "%logFile%"
curl -g -k -L -# -o "%targetDir%\SetConsoleOpacity.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/SetConsoleOpacity.ps1" || echo Failed to download SetConsoleOpacity.ps1 >> "%logFile%"
curl -g -k -L -# -o "%targetDir%\NvidiaProfileInspector.cmd" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/NvidiaProfileInspector.cmd" || echo Failed to download NvidiaProfileInspector.cmd >> "%logFile%"

:: Create Files Subdirectory
if not exist "%targetDir%\Files" mkdir "%targetDir%\Files"

:: Download Button Files
echo Downloading button files...
curl -g -k -L -# -o "%targetDir%\Files\Box.bat" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/Files/Box.bat" || echo Failed to download Box.bat >> "%logFile%"
curl -g -k -L -# -o "%targetDir%\Files\GetInput.exe" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/Files/GetInput.exe" || echo Failed to download GetInput.exe >> "%logFile%"
curl -g -k -L -# -o "%targetDir%\Files\Getlen.bat" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/Files/Getlen.bat" || echo Failed to download Getlen.bat >> "%logFile%"
curl -g -k -L -# -o "%targetDir%\Files\batbox.exe" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/Files/batbox.exe" || echo Failed to download batbox.exe >> "%logFile%"
curl -g -k -L -# -o "%targetDir%\Files\quickedit.exe" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/Files/quickedit.exe" || echo Failed to download quickedit.exe >> "%logFile%"

curl -g -k -L -# -o "%targetDir%\Button.bat" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/Button.bat" || echo Failed to download Button.bat >> "%logFile%"

:: Ensure Current Directory Exists
if not exist "%currentDir%" mkdir "%currentDir%"

:: Move Files to Current Directory
echo Moving downloaded files to the current directory...
xcopy /e /i /y "%targetDir%\" "%currentDir%\" >nul 2>nul
if errorlevel 1 (
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

:: Enable ANSI Sequences
reg add "HKCU\CONSOLE" /v "VirtualTerminalLevel" /t REG_DWORD /d "1" /F >NUL 2>&1
powershell.exe -Command "$host.ui.RawUI.WindowTitle = 'Aurora | @by IBRHUB'"
mode con: cols=85 lines=29
:: powershell.exe -ExecutionPolicy Bypass -File "%currentDir%\RestorePoint.ps1"
powershell.exe -ExecutionPolicy Bypass -File "%currentDir%\LockConsoleSize.ps1"
powershell.exe -ExecutionPolicy Bypass -File "%currentDir%\SetConsoleOpacity.ps1"
cls

:: Set Colors
:: powershell.exe "ForEach($v in (Get-Command -Name \"Set-ProcessMitigation\").Parameters[\"Disable\"].Attributes.ValidValues){Set-ProcessMitigation -System -Disable $v.ToString() -ErrorAction SilentlyContinue}"  >NUL 2>&1
cls
chcp 65001 >nul
::mode con: cols=85 lines=29


:: Main Section with Colored Buttons
:Main
cls
mode con:cols=90 lines=34

:: Print Project Logo and Text
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
echo		    ║[38;5;177m
echo             ╚╗[38;5;69m
echo             [38;5;213m ╚══════^> [38;5;213mAurora [0m

pushd "%currentDir%"
Set "Path=%cd%;%cd%\Files;%Path%;"
Popd

:: Create Main Buttons in Two Rows: 3 Top, 3 Bottom
pushd "%currentDir%"
call "Button.bat" 10 19 F2 "Windows Tweaks" 35 19 F2 "GPU Tweaks" 60 19 F2 "Network Tweaks" 10 24 F2 "Power-Plan" 35 24 F2 "Discord Website" 65 24 F2 "Exit" X _Var_Box _Var_Hover _Var_Code
batbox %_Var_Code%
popd

:: Get User Choice
pushd "%currentDir%"
call "GetInput.exe" /M %_Var_Box% /H %_Var_Hover%
set "userChoice=%Errorlevel%"
popd

:: Handle User Choice Based on Errorlevel
if /I "%userChoice%"=="1" goto :WinTweaks
if /I "%userChoice%"=="2" goto :GPUTweaks
if /I "%userChoice%"=="3" goto :NetworkTweaks
if /I "%userChoice%"=="4" goto :Power-Plan
if /I "%userChoice%"=="5" goto :website
if /I "%userChoice%"=="6" goto :ExitScript

:: If no valid choice, redisplay the menu
goto :Main

:: Section: Windows Tweaks with Sub-buttons
:WinTweaks
cls
mode con:cols=150 lines=25
echo.	 
echo.	 
echo.	 
echo.	 
echo.	 
echo.[38;5;69m	       ██████╗ ██╗███████╗ █████╗ ██████╗ ██╗     ███████╗     ██████╗ ███╗   ██╗███████╗    ██████╗ ██████╗ ██╗██╗   ██╗███████╗    
echo.[38;5;69m	       ██╔══██╗██║██╔════╝██╔══██╗██╔══██╗██║     ██╔════╝    ██╔═══██╗████╗  ██║██╔════╝    ██╔══██╗██╔══██╗██║██║   ██║██╔════╝     
echo.[38;5;69m	       ██║  ██║██║███████╗███████║██████╔╝██║     █████╗      ██║   ██║██╔██╗ ██║█████╗      ██║  ██║██████╔╝██║██║   ██║█████╗  
echo.[38;5;69m	       ██║  ██║██║╚════██║██╔══██║██╔══██╗██║     ██╔══╝      ██║   ██║██║╚██╗██║██╔══╝      ██║  ██║██╔══██╗██║╚██╗ ██╔╝██╔══╝  
echo.[38;5;69m	       ██████╔╝██║███████║██║  ██║██████╔╝███████╗███████╗    ╚██████╔╝██║ ╚████║███████╗    ██████╔╝██║  ██║██║ ╚████╔╝ ███████╗   
echo.[38;5;69m	       ╚═════╝ ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝     ╚═════╝ ╚═╝  ╚═══╝╚══════╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝  ╚══════╝                          
echo.	 
echo.	 

:: Create Sub-buttons in a Single Row
pushd "%currentDir%"
call "Button.bat" 55 15 F2 "[1] Yes" 70 15 F2 "[2] No (Skip) " 59 20 F2 "[3] Back to Main Menu" X _Var_Box _Var_Hover _Var_Code
batbox %_Var_Code%
popd

:: Get User Choice
pushd "%currentDir%"
call "GetInput.exe" /M %_Var_Box% /H %_Var_Hover%
set "userChoice=%Errorlevel%"
popd

:: Handle User Choice
if /I "%userChoice%"=="1" goto :DisableOneDrive
if /I "%userChoice%"=="2" goto :SkipUpdates
if /I "%userChoice%"=="3" goto :Main

:: If no valid choice, redisplay the current section
goto :WinTweaks

:: Section: Disable OneDrive
:DisableOneDrive
cls

rem - Disabling OneDrive
Reg.exe Add "HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\ShellFolder" /f /v "Attributes" /t REG_DWORD /d "0" >nul 2>&1
Reg.exe Add "HKCR\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\ShellFolder" /f /v "Attributes" /t REG_DWORD /d "0" >nul 2>&1
Reg.exe Add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSync" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe Add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe Add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableMeteredNetworkFileSync" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe Add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableLibrariesDefaultSaveToOneDrive" /t REG_DWORD /d "0" /f >nul 2>&1

start /wait powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "%currentDir%\OneDrive.ps1"

goto :SkipUpdates

:SkipUpdates
cls
echo.	 
echo.	 
echo.	 
echo.	 
echo.	 
echo.	 
echo.	
echo.	
echo.		[38;5;69m	       	       ░█▀█░█░█░█▀▄░█▀█░█▀▄░█▀█░░░▀█▀░█░█░█▀█░█▀▀░░░█▀▀░▀█▀░█▀▄░█▀█░█▀▄░▀█▀
echo.		[38;5;69m	       	       ░█▀█░█░█░█▀▄░█░█░█▀▄░█▀█░░░░█░░█░█░█░█░█▀▀░░░▀▀█░░█░░█▀▄░█▀█░█▀▄░░█░
echo.		[38;5;69m	       	       ░▀░▀░▀▀▀░▀░▀░▀▀▀░▀░▀░▀░▀░░░░▀░░▀▀▀░▀░▀░▀▀▀░░░▀▀▀░░▀░░▀░▀░▀░▀░▀░▀░░▀░

rem - Setting UAC - never notify
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v PromptOnSecureDesktop /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 0 /f >NUL 2>&1
timeout /t 1 /nobreak >NUL
rem - Setting Edge policies
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v StartupBoostEnabled /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v HardwareAccelerationModeEnabled /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v BackgroundModeEnabled /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\MicrosoftEdgeElevationService" /v Start /t REG_DWORD /d 4 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\edgeupdate" /v Start /t REG_DWORD /d 4 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\edgeupdatem" /v Start /t REG_DWORD /d 4 /f >NUL 2>&1

rem - Setting Chrome policies
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v StartupBoostEnabled /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v HardwareAccelerationModeEnabled /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v BackgroundModeEnabled /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v HighEfficiencyModeEnabled /t REG_DWORD /d 1 /f >NUL 2>&1

rem - Enabling old NVIDIA sharpening
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS" /v EnableGR535 /t REG_DWORD /d 0 /f >NUL 2>&1

rem - Disabling NVIDIA Telemetry
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v NvBackend /f >NUL 2>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" /v OptInOrOutPreference /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v EnableRID66610 /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v EnableRID64640 /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v EnableRID44231 /t REG_DWORD /d 0 /f >NUL 2>&1

rem - Graphics settings: Disabling MPO
reg add "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v OverlayTestMode /t REG_DWORD /d 5 /f >NUL 2>&1

rem - Setting game scheduling (performance)
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v Affinity /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Background Only" /t REG_SZ /d False /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Clock Rate" /t REG_DWORD /d 10000 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v Priority /t REG_DWORD /d 6 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d High /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d High /f >NUL 2>&1

reg add "HKLM\SOFTWARE\Microsoft\Windows\File Classification Infrastructure\Property Definition Sync" /v "NoSync" /t REG_DWORD /d 1 /f >NUL 2>&1

rem - Reducing Menu Delay
reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d "0" /f >NUL 2>&1

rem - Increase taskbar transparency
Reg.exe Add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "UseOLEDTaskbarTransparency" /t REG_DWORD /d 1 /f >NUL 2>&1
Reg.exe Add "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v "ForceEffectMode" /t REG_DWORD /d 2 /f >NUL 2>&1

rem - Disable showing recent and mostly used items
Reg.exe Add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "HideRecentlyAddedApps" /t REG_DWORD /d 1 /f >NUL 2>&1
Reg.exe Delete "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "HideRecentlyAddedApps" /f >NUL 2>&1
Reg.exe Add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "HideRecentlyAddedApps" /t REG_DWORD /d 1 /f >NUL 2>&1
Reg.exe Add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowFrequent" /t REG_DWORD /d 0 /f >NUL 2>&1
Reg.exe Add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowRecent" /t REG_DWORD /d 0 /f >NUL 2>&1
Reg.exe Delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoStartMenuMFUprogramsList" /f >NUL 2>&1
Reg.exe Delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoRecentDocsHistory" /f >NUL 2>&1
Reg.exe Add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoRecentDocsHistory" /t REG_DWORD /d 1 /f >NUL 2>&1
Reg.exe Add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarSh" /t REG_DWORD /d 0 /f >NUL 2>&1
Reg.exe Add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "ShowOrHideMostUsedApps" /t REG_DWORD /d 0 /f >NUL 2>&1

rem - Browser background optimizations
Reg.exe Add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "StartupBoostEnabled" /t REG_DWORD /d 0 /f >NUL 2>&1
Reg.exe Add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "BackgroundModeEnabled" /t REG_DWORD /d 0 /f >NUL 2>&1
Reg.exe Add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "BatterySaverModeAvailability" /t REG_DWORD /d 1 /f >NUL 2>&1
Reg.exe Add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "StartupBoostEnabled" /t REG_DWORD /d 0 /f >NUL 2>&1
Reg.exe Add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "BackgroundModeEnabled" /t REG_DWORD /d 0 /f >NUL 2>&1
Reg.exe Add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "HighEfficiencyModeEnabled" /t REG_DWORD /d 1 /f >NUL 2>&1
Reg.exe Add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "BatterySaverModeAvailability" /t REG_DWORD /d 1 /f >NUL 2>&1
Reg.exe Add "HKLM\Software\Policies\BraveSoftware\Brave" /v "BackgroundModeEnabled" /t REG_DWORD /d 0 /f >NUL 2>&1
Reg.exe Add "HKLM\Software\Policies\BraveSoftware\Brave" /v "HighEfficiencyModeEnabled" /t REG_DWORD /d 0 /f >NUL 2>&1
Reg.exe Add "HKLM\Software\Policies\BraveSoftware\Brave" /v "BatterySaverModeAvailability" /t REG_DWORD /d 0 /f >NUL 2>&1
Reg.exe Add "HKLM\Software\Policies\BraveSoftware\Brave\Recommended" /v "BackgroundModeEnabled" /t REG_DWORD /d 0 /f >NUL 2>&1
Reg.exe Add "HKLM\Software\Policies\BraveSoftware\Brave\Recommended" /v "BatterySaverModeAvailability" /t REG_DWORD /d 1 /f >NUL 2>&1

rem - Disables updates for Firefox, Edge and Chrome
Reg.exe Add "HKLM\SYSTEM\CurrentControlSet\Services\MicrosoftEdgeElevationService" /v "Start" /t REG_DWORD /d 4 /f >NUL 2>&1
Reg.exe Add "HKLM\SYSTEM\CurrentControlSet\Services\edgeupdate" /v "Start" /t REG_DWORD /d 4 /f >NUL 2>&1
Reg.exe Add "HKLM\SYSTEM\CurrentControlSet\Services\edgeupdatem" /v "Start" /t REG_DWORD /d 4 /f >NUL 2>&1
Reg.exe Delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree\MicrosoftEdgeUpdateTaskMachineCore" /f >NUL 2>&1
Reg.exe Delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree\MicrosoftEdgeUpdateTaskMachineUA" /f >NUL 2>&1
Reg.exe Add "HKLM\SYSTEM\CurrentControlSet\Services\GoogleChromeElevationService" /v "Start" /t REG_DWORD /d 4 /f >NUL 2>&1
Reg.exe Add "HKLM\SYSTEM\CurrentControlSet\Services\gupdate" /v "Start" /t REG_DWORD /d 4 /f >NUL 2>&1
Reg.exe Add "HKLM\SYSTEM\CurrentControlSet\Services\gupdatem" /v "Start" /t REG_DWORD /d 4 /f >NUL 2>&1
Reg.exe Add "HKLM\SOFTWARE\Policies\Mozilla\Firefox" /v "DisableAppUpdate" /t REG_DWORD /d 1 /f >NUL 2>&1
timeout /t 1 /nobreak > NUL
rem - Explorer Optimizations
Reg.exe Add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoRestartShell" /t REG_DWORD /d 1 /f > NUL 2>&1
Reg.exe Add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "LongPathsEnabled" /t REG_DWORD /d 0 /f > NUL 2>&1
Reg.exe Add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "0" /f > NUL 2>&1
Reg.exe Add "HKCU\Control Panel\Mouse" /v "MouseHoverTime" /t REG_SZ /d "0" /f > NUL 2>&1
Reg.exe Add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ListviewShadow" /t REG_DWORD /d 0 /f > NUL 2>&1
Reg.exe Add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "NoNetCrawling" /t REG_DWORD /d 1 /f > NUL 2>&1
Reg.exe Add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "EnableBalloonTips" /t REG_DWORD /d 0 /f > NUL 2>&1
Reg.exe Add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoStartMenuMFUprogramsList" /t REG_DWORD /d 1 /f > NUL 2>&1
Reg.exe Add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoRecentDocsHistory" /t REG_DWORD /d 1 /f > NUL 2>&1
Reg.exe Add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DisallowShaking" /t REG_DWORD /d 1 /f > NUL 2>&1
Reg.exe Add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d 0 /f > NUL 2>&1
Reg.exe Add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoComplete" /v "Append Completion" /t REG_SZ /d "yes" /f > NUL 2>&1
Reg.exe Add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoComplete" /v "AutoSuggest" /t REG_SZ /d "yes" /f > NUL 2>&1
Reg.exe Add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrDelay" /t REG_DWORD /d 10 /f > NUL 2>&1
Reg.exe Add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "0" /f > NUL 2>&1
Reg.exe Add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AeDebug" /v "Auto" /t REG_SZ /d "0" /f > NUL 2>&1
Reg.exe Add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d 0 /f > NUL 2>&1
Reg.exe Add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" /v "FolderType" /t REG_SZ /d "NotSpecified" /f > NUL 2>&1

rem - Optimizing Windows Scheduled Tasks
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v MaintenanceDisabled /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\ScheduledDiagnostics" /v EnabledExecution /t REG_DWORD /d 0 /f > NUL 2>&1

rem - Disable specific scheduled tasks
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
timeout /t 1 /nobreak > NUL
rem - Disable SleepStudy logging
wevtutil.exe set-log "Microsoft-Windows-SleepStudy/Diagnostic" /e:false > NUL 2>&1
wevtutil.exe set-log "Microsoft-Windows-Kernel-Processor-Power/Diagnostic" /e:false > NUL 2>&1
wevtutil.exe set-log "Microsoft-Windows-UserModePowerService/Diagnostic" /e:false > NUL 2>&1

rem - Visual Effects
reg add "HKCU\Control Panel\Desktop" /v "FontSmoothing" /t REG_SZ /d "2" /f > NUL 2>&1
reg add "HKCU\Control Panel\Desktop" /v "UserPreferencesMask" /t REG_BINARY /d "9012038010000000" /f > NUL 2>&1
reg add "HKCU\Control Panel\Desktop" /v "DragFullWindows" /t REG_SZ /d "1" /f > NUL 2>&1
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "0" /f > NUL 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ListviewAlphaSelect" /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "IconsOnly" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAnimations" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ListviewShadow" /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 3 /f > NUL 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\DWM" /v "EnableAeroPeek" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\DWM" /v "AlwaysHibernateThumbnails" /t REG_DWORD /d 0 /f > NUL 2>&1

cls
goto :Main

:: Section: GPU Tweaks
:GPUTweaks
cls
echo.
echo.
echo.
echo.
echo.[38;5;82m	 ███╗   ██╗██╗   ██╗██╗██████╗ ██╗ █████╗    [38;5;196m  █████╗ ███╗   ███╗██████╗ 
echo.[38;5;82m	 ████╗  ██║██║   ██║██║██╔══██╗██║██╔══██╗   [38;5;196m ██╔══██╗████╗ ████║██╔══██╗  
echo.[38;5;82m	 ██╔██╗ ██║██║   ██║██║██║  ██║██║███████║   [38;5;196m ███████║██╔████╔██║██║  ██║   
echo.[38;5;82m	 ██║╚██╗██║╚██╗ ██╔╝██║██║  ██║██║██╔══██║   [38;5;196m ██╔══██║██║╚██╗██║██║  ██║ 
echo.[38;5;82m	 ██║ ╚████║ ╚████╔╝ ██║██████╔╝██║██║  ██║   [38;5;196m ██║  ██║██║ ╚═╝ ██║██████╔╝  
echo.[38;5;82m	 ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═╝    [38;5;196m╚═╝  ╚═╝╚═╝     ╚═╝╚═════╝    
echo.                                            
    
:: Create Sub-buttons in a Single Row
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
if /I "%userChoice%"=="1" goto :NVIDIATweaks
if /I "%userChoice%"=="2" goto :AMDTweaks
if /I "%userChoice%"=="3" goto :Main

:: If no valid choice, redisplay the current section
goto :GPUTweaks

:: Section: NVIDIA Tweaks
:NVIDIATweaks
cls
echo. Launching NVIDIA Profile Inspector...
CLS
mode con:cols=85 lines=33
start "" /wait "%currentDir%\NvidiaProfileInspector.cmd"

:: Create Sub-buttons in a Single Row
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
if /I "%userChoice%"=="1" goto :AuroraOFF
if /I "%userChoice%"=="2" goto :AuroraON
if /I "%userChoice%"=="3" goto :Main

:: If no valid choice, redisplay the current section
goto :NVIDIATweaks

:: Section: Disable Resizable BAR for NVIDIA
:AuroraOFF
cls
echo. Disabling Resizable BAR...
start "" /wait "C:\NvidiaProfileInspector\nvidiaProfileInspector.exe" "C:\NvidiaProfileInspector\AuroraOFF.nip" 
if errorlevel 1 (
    echo Failed to apply AuroraOFF.nip.
    pause
    goto relaunch
)
echo [38;5;213mResizable BAR has been disabled successfully.[0m
timeout /t 3 /nobreak > NUL

goto :Main

:: Section: Enable Resizable BAR for NVIDIA
:AuroraON
cls
echo. Enabling Resizable BAR...
start "" /wait "C:\NvidiaProfileInspector\nvidiaProfileInspector.exe" "C:\NvidiaProfileInspector\AuroraON.nip" 
if errorlevel 1 (
    echo Failed to apply AuroraON.nip.
    pause
    goto relaunch
)
echo [38;5;213mResizable BAR has been enabled successfully.[0m
timeout /t 3 /nobreak > NUL
goto :Main

:: Section: AMD Tweaks
:AMDTweaks
cls

:: Credits @Imribiy ( https://github.com/imribiy/XOS/blob/main/3-setup-gpu-drivers/amd/AMD%20Dwords.bat )
Reg.exe add "HKCU\Software\AMD\CN" /v "AutoUpdateTriggered" /t REG_DWORD /d "0" /f > nul 2>&1
Reg.exe add "HKCU\Software\AMD\CN" /v "PowerSaverAutoEnable_CUR" /t REG_DWORD /d "0" /f > nul 2>&1
Reg.exe add "HKCU\Software\AMD\CN" /v "BuildType" /t REG_DWORD /d "0" /f > nul 2>&1
Reg.exe add "HKCU\Software\AMD\CN" /v "WizardProfile" /t REG_SZ /d "PROFILE_CUSTOM" /f > nul 2>&1
Reg.exe add "HKCU\Software\AMD\CN" /v "UserTypeWizardShown" /t REG_DWORD /d "1" /f > nul 2>&1
Reg.exe add "HKCU\Software\AMD\CN" /v "AutoUpdate" /t REG_DWORD /d "0" /f > nul 2>&1
Reg.exe add "HKCU\Software\AMD\CN" /v "RSXBrowserUnavailable" /t REG_SZ /d "true" /f > nul 2>&1
Reg.exe add "HKCU\Software\AMD\CN" /v "SystemTray" /t REG_SZ /d "false" /f > nul 2>&1
Reg.exe add "HKCU\Software\AMD\CN" /v "AllowWebContent" /t REG_SZ /d "false" /f > nul 2>&1
Reg.exe add "HKCU\Software\AMD\CN" /v "CN_Hide_Toast_Notification" /t REG_SZ /d "true" /f > nul 2>&1
Reg.exe add "HKCU\Software\AMD\CN" /v "AnimationEffect" /t REG_SZ /d "false" /f > nul 2>&1
Reg.exe add "HKCU\Software\AMD\CN\OverlayNotification" /v "AlreadyNotified" /t REG_DWORD /d "1" /f > nul 2>&1
Reg.exe add "HKCU\Software\AMD\CN\VirtualSuperResolution" /v "AlreadyNotified" /t REG_DWORD /d "1" /f > nul 2>&1
Reg.exe add "HKCU\Software\AMD\DVR" /v "PerformanceMonitorOpacityWA" /t REG_DWORD /d "0" /f > nul 2>&1
Reg.exe add "HKCU\Software\AMD\DVR" /v "DvrEnabled" /t REG_DWORD /d "1" /f > nul 2>&1
Reg.exe add "HKCU\Software\AMD\DVR" /v "ActiveSceneId" /t REG_SZ /d "0" /f > nul 2>&1
Reg.exe add "HKCU\Software\AMD\DVR" /v "PrevInstantReplayEnable" /t REG_DWORD /d "0" /f > nul 2>&1
Reg.exe add "HKCU\Software\AMD\DVR" /v "PrevInGameReplayEnabled" /t REG_DWORD /d "0" /f > nul 2>&1
Reg.exe add "HKCU\Software\AMD\DVR" /v "PrevInstantGifEnabled" /t REG_DWORD /d "0" /f > nul 2>&1
Reg.exe add "HKCU\Software\AMD\DVR" /v "RemoteServerStatus" /t REG_DWORD /d "0" /f > nul 2>&1
Reg.exe add "HKCU\Software\AMD\DVR" /v "ShowRSOverlay" /t REG_SZ /d "false" /f > nul 2>&1
Reg.exe add "HKCU\Software\AMD\DVR" /v "Main3D_DEF" /t REG_SZ /d "1" /f > nul 2>&1
Reg.exe add "HKLM\Software\AMD\Install" /v "AUEP" /t REG_DWORD /d "1" /f > nul 2>&1
Reg.exe add "HKLM\Software\AUEP" /v "RSX_AUEPStatus" /t REG_DWORD /d "2" /f > nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "NotifySubscription" /t REG_BINARY /d "3000" /f > nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "IsComponentControl" /t REG_BINARY /d "00000000" /f > nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "KMD_USUEnable" /t REG_DWORD /d "0" /f > nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "KMD_RadeonBoostEnabled" /t REG_DWORD /d "0" /f > nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "IsAutoDefault" /t REG_BINARY /d "01000000" /f > nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "KMD_ChillEnabled" /t REG_DWORD /d "0" /f > nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "KMD_DeLagEnabled" /t REG_DWORD /d "0" /f > nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "ACE" /t REG_BINARY /d "3000" /f > nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "AnisoDegree_SET" /t REG_BINARY /d "3020322034203820313600" /f > nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "Main3D_SET" /t REG_BINARY /d "302031203220332034203500" /f > nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "Tessellation_OPTION" /t REG_BINARY /d "3200" /f > nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "Tessellation" /t REG_BINARY /d "3100" /f > nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "AAF" /t REG_BINARY /d "30000000" /f > nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "GI" /t REG_BINARY /d "3100" /f > nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "CatalystAI" /t REG_BINARY /d "3100" /f > nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "TemporalAAMultiplier_NA" /t REG_BINARY /d "3100" /f > nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "ForceZBufferDepth_SET" /t REG_BINARY /d "3020313620323400" /f > nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "SwapEffect_OGL_SET" /t REG_BINARY /d "3020312032203320342035203620372038203920313120313220313320313420313520313620313700" /f > nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "Tessellation_SET" /t REG_BINARY /d "31203220342036203820313620333220363400" /f > nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "HighQualityAF" /t REG_BINARY /d "3100" /f > nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "DisplayCrossfireLogo" /t REG_BINARY /d "3000" /f > nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "AppGpuId" /t REG_BINARY /d "300078003000310030003000" /f > nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "SwapEffect" /t REG_BINARY /d "30000000" /f > nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableDMACopy" /t REG_DWORD /d "1" /f > nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableBlockWrite" /t REG_DWORD /d "0" /f > nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PP_ThermalAutoThrottlingEnable" /t REG_DWORD /d "0" /f > nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableDrmdmaPowerGating" /t REG_DWORD /d "1" /f > nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\amdwddmg" /v "ChillEnabled" /t REG_DWORD /d "0" /f > nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\AMD Crash Defender Service" /v "Start" /t REG_DWORD /d "4" /f > nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\AMD External Events Utility" /v "Start" /t REG_DWORD /d "4" /f > nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\amdfendr" /v "Start" /t REG_DWORD /d "4" /f > nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\amdfendrmgr" /v "Start" /t REG_DWORD /d "4" /f > nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\amdlog" /v "Start" /t REG_DWORD /d "4" /f > nul 2>&1

goto :Main

:: Section: Power Plan
:Power-Plan
cls

:: Create Sub-buttons in a Single Row
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
if /I "%userChoice%"=="1" goto :Desktop
if /I "%userChoice%"=="2" goto :Laptop
if /I "%userChoice%"=="3" goto :Main

:Desktop
start /wait powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "%currentDir%\Power.ps1" -Silent
goto :Main

:Laptop
start /wait powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "%currentDir%\Power.ps1" -Silent
goto :Main

:: Section: Discord Website
:website 
cls

:: Create Sub-buttons in a Single Row
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
if /I "%userChoice%"=="1" goto :Discord
if /I "%userChoice%"=="2" goto :Website2
if /I "%userChoice%"=="3" goto :Main

:Discord
start https://discord.gg/T4WemSTX
goto :Main

:Website2
start https://ibrpride.com/
goto :Main

echo. Displaying System Information...
systeminfo
pause
goto :Main

:: Section: Network Tweaks
:NetworkTweaks
cls
echo.

:: Create Sub-buttons in a Single Row
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
if /I "%userChoice%"=="1" goto :Win10Net
if /I "%userChoice%"=="2" goto :Win11Net
if /I "%userChoice%"=="3" goto :Main

:: If no valid choice, redisplay the current section
goto :NetworkTweaks

:: Section: Network Tweaks for Windows 11
:Win11Net
cls
echo. soon ..

:: start /wait powershell.exe -ExecutionPolicy Bypass -File "%currentDir%\NetworkTweaksWin11.ps1"
goto :Main

:: Section: Network Tweaks for Windows 10
:Win10Net
cls
echo. soon ..

:: start /wait powershell.exe -ExecutionPolicy Bypass -File "%currentDir%\NetworkTweaksWin10.ps1"
goto :Main

:: Section: Relaunch Script on Failure
:relaunch
cls
echo. Do you want to restart the script?
echo.
pushd "%currentDir%"
call "Button.bat" 20 10 F2 "[1] Restart" 40 10 F2 "[2] Exit" X _Var_Box _Var_Hover _Var_Code
batbox %_Var_Code%
popd

:: Get User Choice
pushd "%currentDir%"
call "GetInput.exe" /M %_Var_Box% /H %_Var_Hover%
set "userChoice=%Errorlevel%"
popd

:: Handle User Choice
if /I "%userChoice%"=="1" goto :Main
if /I "%userChoice%"=="2" exit

:: If no valid choice, redisplay the current section
goto :relaunch

:: Section: Exit Script
:ExitScript
mode con:cols=99 lines=34
cls
echo.
echo.
echo.
echo.
echo.	 [38;5;105m     ████████╗██╗  ██╗ █████╗ ███╗   ██╗██╗  ██╗    ██╗   ██╗ ██████╗ ██╗   ██╗
echo.	 [38;5;105m     ╚══██╔══╝██║  ██║██╔══██╗████╗  ██║██║ ██╔╝    ╚██╗ ██╔╝██╔═══██╗██║   ██║
echo.	 [38;5;105m        ██║   ███████║███████║██╔██╗ ██║█████╔╝      ╚████╔╝ ██║   ██║██║   ██║
echo.	 [38;5;105m        ██║   ██╔══██║██╔══██║██║╚██╗██║██╔═██╗       ╚██╔╝  ██║   ██║██║   ██║
echo.	 [38;5;105m        ██║   ██║  ██║██║  ██║██║ ╚████║██║  ██╗       ██║   ╚██████╔╝╚██████╔╝
echo.	 [38;5;105m        ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝       ╚═╝    ╚═════╝  ╚═════╝ 
echo.                                                                              
echo. 	 [38;5;105m       ███████╗ ██████╗ ██████╗     ██╗   ██╗███████╗██╗███╗   ██╗ ██████╗       
echo.	 [38;5;105m       ██╔════╝██╔═══██╗██╔══██╗    ██║   ██║██╔════╝██║████╗  ██║██╔════╝       
echo.	 [38;5;105m       █████╗  ██║   ██║██████╔╝    ██║   ██║███████╗██║██╔██╗ ██║██║  ███╗      
echo.	 [38;5;105m       ██╔══╝  ██║   ██║██╔══██╗    ██║   ██║╚════██║██║██║╚██╗██║██║   ██║      
echo.	 [38;5;105m       ██║     ╚██████╔╝██║  ██║    ╚██████╔╝███████║██║██║ ╚████║╚██████╔╝      
echo.	 [38;5;105m       ╚═╝      ╚═════╝ ╚═╝  ╚═╝     ╚═════╝ ╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝       
echo.                                                                               
echo.		 [38;5;105m    █████╗ ██╗   ██╗██████╗  ██████╗ ██████╗  █████╗ ██╗                         
echo.		 [38;5;105m   ██╔══██╗██║   ██║██╔══██╗██╔═══██╗██╔══██╗██╔══██╗██║                         
echo.		 [38;5;105m   ███████║██║   ██║██████╔╝██║   ██║██████╔╝███████║██║                         
echo.		 [38;5;105m   ██╔══██║██║   ██║██╔══██╗██║   ██║██╔══██╗██╔══██║╚═╝                         
echo.		 [38;5;105m   ██║  ██║╚██████╔╝██║  ██║╚██████╔╝██║  ██║██║  ██║██╗                         
echo.		 [38;5;105m   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝                         
echo.                                                                               
echo.                                                                               
echo.                                                                               
echo.                                                                               
echo.                                                                               
echo.                                                                               
echo.                                                                               
echo.                                                                               
echo.                                                                               
pause > NUL 2>&1
exit
