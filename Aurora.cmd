@echo off
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

:: Check for administrator privileges
fltmc > nul 2>&1 || (
	echo Administrator privileges are required.
	powershell -c "Start-Process -Verb RunAs -FilePath 'cmd' -ArgumentList " 2> nul || (
		echo You must run this script as admin.
		if "%*"=="" pause
		exit /b 1
	)
	exit /b
)
set logFile=%temp%\Aurora_log.txt
set targetDir=%temp%\AuroraModules
set currentDir=%~dp0AuroraModules

:: Ensure the target directory exists
if not exist "%targetDir%" mkdir "%targetDir%"

:: Clear the log file
> "%logFile%" echo Download Log - %date% %time%

echo Download files for Aurora

curl -g -k -L -# -o "%targetDir%\LockConsoleSize.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/LockConsoleSize.ps1" >> "%logFile%" 2>&1
if %errorlevel% neq 0 echo Error downloading LockConsoleSize.ps1 >> "%logFile%"

curl -g -k -L -# -o "%targetDir%\OneDrive.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/OneDrive.ps1" >> "%logFile%" 2>&1
if %errorlevel% neq 0 echo Error downloading OneDrive.ps1 >> "%logFile%"

curl -g -k -L -# -o "%targetDir%\Power.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/Power.ps1" >> "%logFile%" 2>&1
if %errorlevel% neq 0 echo Error downloading Power.ps1 >> "%logFile%"

curl -g -k -L -# -o "%targetDir%\RestorePoint.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/RestorePoint.ps1" >> "%logFile%" 2>&1
if %errorlevel% neq 0 echo Error downloading RestorePoint.ps1 >> "%logFile%"

curl -g -k -L -# -o "%targetDir%\SetConsoleOpacity.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/SetConsoleOpacity.ps1" >> "%logFile%" 2>&1
if %errorlevel% neq 0 echo Error downloading SetConsoleOpacity.ps1 >> "%logFile%"

curl -g -k -L -# -o "%targetDir%\NvidiaProfileInspector.cmd" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/NvidiaProfileInspector.cmd" >> "%logFile%" 2>&1
if %errorlevel% neq 0 echo Error downloading NvidiaProfileInspector.cmd >> "%logFile%"

curl -g -k -L -# -o "%targetDir%\AMDDwords.bat" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/AMDDwords.bat" >> "%logFile%" 2>&1
if %errorlevel% neq 0 echo Error downloading AMDDwords.bat >> "%logFile%"

curl -g -k -L -# -o "%targetDir%\NetworkBufferBloatFixer.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/NetworkBufferBloatFixer.ps1" >> "%logFile%" 2>&1
if %errorlevel% neq 0 echo Error downloading NetworkBufferBloatFixer.ps1 >> "%logFile%"

:: Ensure the destination directory exists in the current script location
if not exist "%currentDir%" mkdir "%currentDir%"

:: Move downloaded files to the script's current directory
move "%targetDir%\*" "%currentDir%\" >> "%logFile%" 2>&1
if %errorlevel% neq 0 echo Error moving files to current directory >> "%logFile%"

:: Enable ANSI Escape Sequences
reg add "HKCU\CONSOLE" /v "VirtualTerminalLevel" /t REG_DWORD /d "1" /F >NUL 2>&1
powershell.exe -Command "$host.ui.RawUI.WindowTitle = 'Aurora | @by IBRHUB'"
mode con: cols=75 lines=28
powershell.exe -ExecutionPolicy Bypass -File "%~dp0\AuroraModules\RestorePoint.ps1"  
powershell.exe -ExecutionPolicy Bypass -File "%~dp0\AuroraModules\LockConsoleSize.ps1"
powershell.exe -ExecutionPolicy Bypass -File "%~dp0\AuroraModules\SetConsoleOpacity.ps1"
powershell.exe -ExecutionPolicy Bypass -File "%~dp0\AuroraModules\resizeConsole.ps1"
cls

powershell.exe "ForEach($v in (Get-Command -Name \"Set-ProcessMitigation\").Parameters[\"Disable\"].Attributes.ValidValues){Set-ProcessMitigation -System -Disable $v.ToString() -ErrorAction SilentlyContinue}"  >NUL 2>&1
cls
chcp 65001 >nul

color f
:Main
CLS
echo.
echo.
echo	      [38;5;105m ▄█  ▀█████████▄     ▄████████    ▄█    █▄    ███    █▄  ▀█████████▄  
echo	      [38;5;105m ███    ███    ███   ███    ███   ███    ███   ███    ███   ███    ███ 
echo	      [38;5;69m ███▌   ███    ███   ███    ███   ███    ███   ███    ███   ███    ███ 
echo	      [38;5;69m ███▌  ▄███▄▄▄██▀   ▄███▄▄▄▄██▀  ▄███▄▄▄▄███▄▄ ███    ███  ▄███▄▄▄██▀  
echo	      [38;5;133m ███▌ ▀▀███▀▀▀██▄  ▀▀███▀▀▀▀▀   ▀▀███▀▀▀▀███▀  ███    ███ ▀▀███▀▀▀██▄  
echo	      [38;5;133m ███    ███    ██▄ ▀███████████   ███    ███   ███    ███   ███    ██▄ 
echo	      [38;5;105m ███    ███    ███   ███    ███   ███    ███   ███    ███   ███    ███ 
echo	      [38;5;105m █▀   ▄█████████▀    ███    ███   ███    █▀    ████████▀  ▄█████████▀  
echo	      [38;5;69m                     ███    ███                                       
echo.
echo.
echo			╔═══════════════════════════════════════════════╗
echo			║ Made by [0m[95mIbrahim[90m \ [37mhttps://ibrpride.com/       ║[38;5;105m 
echo			╚═══════════════════════════════════════════════╝
echo.
echo		        ╔═══════════════════════════════════════════════╗[38;5;105m
echo		      ╔═╣ [38;5;213m[1] - [37mWindows Tweaks[37m     [38;5;213m[3] - [37mNetwork Tweaks[37m ║[38;5;105m
echo		    ╔═╝ ║ [38;5;213m[2] - [37mGPU Tweaks[37m         [38;5;213m[4] - [37mPower-Plan[37m     ║[38;5;213m
echo		    ║   ╚═══════════════════════════════════════════════╝[38;5;105m
echo		    ║[38;5;177m
echo             ╚╗[38;5;69m
set /p input=%BS% [38;5;213m             ╚══════^> [38;5;213m
if /I %input% EQU 1 goto :WinTweaks
if /I %input% EQU 2 goto :GPUTweaks
if /I %input% EQU 3 goto :NetworkTweaks
if /I %input% EQU 4 goto :Power-Plan



:WinTweaks
ECHO.
ECHO. 		     [38;5;213m  Disable OneDrive?
ECHO.
ECHO. 		             [38;5;105m[1] Yes Or [38;5;105m[2] No
ECHO. 
set /p input=%BS% [38;5;213m             ╚══════^> [38;5;213m
if /I %input% EQU 1 goto :DisableOneDrive
if /I %input% EQU 2 goto :SkipUpdates

:DisableOneDrive

rem -  Disabling OneDrive
reg add "HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\ShellFolder" /f /v "Attributes" /t REG_DWORD /d "0" > $null 2>&1
reg add "HKCR\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\ShellFolder" /f /v "Attributes" /t REG_DWORD /d "0" > $null 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSync" /t REG_DWORD /d "1" /f > $null 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d "1" /f > $null 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableMeteredNetworkFileSync" /t REG_DWORD /d "0" /f > $null 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableLibrariesDefaultSaveToOneDrive" /t REG_DWORD /d "0" /f > $null 2>&1

start /wait powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0\AuroraModules\OneDrive.ps1"


goto :SkipUpdates

:SkipUpdates

rem - Setting UAC - never notify
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v PromptOnSecureDesktop /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 0 /f > NUL 2>&1

rem - Setting Edge policies
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v StartupBoostEnabled /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v HardwareAccelerationModeEnabled /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v BackgroundModeEnabled /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\MicrosoftEdgeElevationService" /v Start /t REG_DWORD /d 4 /f > NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\edgeupdate" /v Start /t REG_DWORD /d 4 /f > NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\edgeupdatem" /v Start /t REG_DWORD /d 4 /f > NUL 2>&1

rem - Setting Chrome policies
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v StartupBoostEnabled /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v HardwareAccelerationModeEnabled /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v BackgroundModeEnabled /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v HighEfficiencyModeEnabled /t REG_DWORD /d 1 /f > NUL 2>&1

rem - Enabling old NVIDIA sharpening
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS" /v EnableGR535 /t REG_DWORD /d 0 /f > NUL 2>&1

rem - Disabling NVIDIA Telemetry
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v NvBackend /f > NUL 2>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" /v OptInOrOutPreference /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v EnableRID66610 /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v EnableRID64640 /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v EnableRID44231 /t REG_DWORD /d 0 /f > NUL 2>&1

rem - Disable Hardware Accel Steam
reg add "HKCU\SOFTWARE\Valve\Steam" /v "GPUAccelWebViewsV2" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKCU\SOFTWARE\Valve\Steam" /v "H264HWAccel" /t REG_DWORD /d 0 /f > NUL 2>&1

rem - Graphics settings: Disabling MPO
reg add "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v OverlayTestMode /t REG_DWORD /d 5 /f > NUL 2>&1

rem - Setting game scheduling (performance)
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v Affinity /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Background Only" /t REG_SZ /d False /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Clock Rate" /t REG_DWORD /d 10000 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v Priority /t REG_DWORD /d 6 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d High /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d High /f > NUL 2>&1

rem - Disabling Background Apps
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v BackgroundAppGlobalToggle /t REG_DWORD /d 0 /f > NUL 2>&1

rem - Enabling Hardware-Accelerated GPU Scheduling
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f > NUL 2>&1

rem - Enabling Game Mode
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v AllowAutoGameMode /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v AutoGameModeEnabled /t REG_DWORD /d 1 /f > NUL 2>&1

rem - Adjusting for best performance of programs
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 38 /f > NUL 2>&1

rem - Reducing Menu Delay
reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d "0" /f > NUL 2>&1

rem - Increase taskbar transparency
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "UseOLEDTaskbarTransparency" /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v "ForceEffectMode" /t REG_DWORD /d 2 /f > NUL 2>&1

rem - Disable showing recent and mostly used item
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

rem - Browser background optimizations
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "StartupBoostEnabled" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "BackgroundModeEnabled" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "BatterySaverModeAvailability" /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "StartupBoostEnabled" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "BackgroundModeEnabled" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "HighEfficiencyModeEnabled" /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "BatterySaverModeAvailability" /t REG_DWORD /d 1 /f > NUL 2>&1
reg add "HKLM\Software\Policies\BraveSoftware\Brave" /v "BackgroundModeEnabled" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\Software\Policies\BraveSoftware\Brave" /v "HighEfficiencyModeEnabled" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\Software\Policies\BraveSoftware\Brave" /v "BatterySaverModeAvailability" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\Software\Policies\BraveSoftware\Brave\Recommended" /v "BackgroundModeEnabled" /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\Software\Policies\BraveSoftware\Brave\Recommended" /v "BatterySaverModeAvailability" /t REG_DWORD /d 1 /f > NUL 2>&1

rem - Disables updates for Firefox, Edge and Chrome
reg add "HKLM\SYSTEM\CurrentControlSet\Services\MicrosoftEdgeElevationService" /v "Start" /t REG_DWORD /d 4 /f > NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\edgeupdate" /v "Start" /t REG_DWORD /d 4 /f > NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\edgeupdatem" /v "Start" /t REG_DWORD /d 4 /f > NUL 2>&1
reg Delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree\MicrosoftEdgeUpdateTaskMachineCore" /f > NUL 2>&1
reg Delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree\MicrosoftEdgeUpdateTaskMachineUA" /f > NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\GoogleChromeElevationService" /v "Start" /t REG_DWORD /d 4 /f > NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\gupdate" /v "Start" /t REG_DWORD /d 4 /f > NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\gupdatem" /v "Start" /t REG_DWORD /d 4 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Mozilla\Firefox" /v "DisableAppUpdate" /t REG_DWORD /d 1 /f > NUL 2>&1

rem - Explorer Optimizations
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

:gputweaks
ECHO.
ECHO. 		     [38;5;213m  Do You Have NVIDIA (1) or AMD (2)?
ECHO.
ECHO. 		           [38;5;105m[1] NVIDIA Or [38;5;105m[2] AMD
ECHO. 
set /p input=%BS% [38;5;213m             ╚══════^> [38;5;213m
if /I %input% EQU 1 goto :NVIDIATweaks
if /I %input% EQU 2 goto :AMDTweakss

:NVIDIATweaks

mode con cols=85 lines=33
start %~dp0\AuroraModules\NvidiaProfileInspector.cmd

echo.
echo.           [38;5;213m  Resizable Bar OFF (1) or Resizable Bar ON (2)?
echo.
echo.                 [38;5;105m[1] ResizableBarOFF   [38;5;105m[2] ResizableBarON
echo.
set /p input=%BS% [38;5;213m             ╚══════^> [38;5;213m

if /I "%input%" EQU "1" goto :AuroraOFF
if /I "%input%" EQU "2" goto :AuroraON

:AuroraOFF
start "" /wait "%~dp0AuroraModules\NvidiaProfileInspector\nvidiaProfileInspector.exe" "%~dp0AuroraModules\NvidiaProfileInspector\AuroraOFF.nip" 
if errorlevel 1 (
    echo Failed to apply AuroraOFF.nip.
    pause
    goto relaunch
)
echo.
echo [38;5;213mResizable BAR has been disabled successfully.%[0m
timeout /t 3 /nobreak > NUL

goto :Main

:AuroraON
start "" /wait "%~dp0AuroraModules\NvidiaProfileInspector\nvidiaProfileInspector.exe" "%~dp0AuroraModules\NvidiaProfileInspector\AuroraON.nip" 
if errorlevel 1 (
    echo Failed to apply AuroraON.nip.
    pause
    goto relaunch
)
echo.
echo [38;5;213mResizable BAR has been enabled successfully.%[0m
timeout /t 3 /nobreak > NUL

goto :Main


cls
goto :Main

:AMDTweaks

start %~dp0\AuroraModules\AMDDwords.bat

cls
goto :Main

:Power-Plan

start /wait powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0\AuroraModules\Power.ps1" -Silent

cls
goto :Main


:NetworkTweaks
ECHO.
ECHO. 		     [38;5;213m  Are You On Windows 10 (1) or Windows 11 (2)?
ECHO.
ECHO. 		        [38;5;105m[1] 10 Or [38;5;105m[2] 11
ECHO. 
choice /c:12 /n > NUL 2>&1
if errorlevel 2 goto Win11Net
if errorlevel 1 goto Win10Net


:Win11Net

cls 
powershell.exe -ExecutionPolicy Bypass -File "%~dp0\AuroraModules\NetworkBufferBloatFixer.ps1"
goto :Main



:Win10Net 
cls
powershell.exe -ExecutionPolicy Bypass -File "%~dp0\AuroraModules\NetworkBufferBloatFixer.ps1"
goto :Main


:relaunch
set /p userInput=Enter your choice: 

if /i "%userInput%"=="restart" (
    :: Relaunch the script from the :Main function
    start "" "%~f0" Main
    exit
)

if /i "%userInput%"=="exit" exit

echo Invalid choice. Restarting the script...
:: Relaunch the script from the :Main function
start "" "%~f0" Main
exit
