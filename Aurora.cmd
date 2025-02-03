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
fltmc > nul 2>&1 || (
	echo Administrator privileges are required.
	powershell -c "Start-Process -Verb RunAs -FilePath 'cmd' -ArgumentList " 2> nul || (
		echo You must run this script as admin.
		if "%*"=="" pause
		exit /b 1
	)
	exit /b
)

reg add "HKCU\Console" /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1

:: Enable delayed expansion for the registry operations
setlocal EnableDelayedExpansion


:: Background: Black (0), Text: White (F)
set BackgroundColor=0
set TextColor=F
color %BackgroundColor%%TextColor%




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


start https://docs.ibrhub.net/ar/disclaimer
:: set ANSI escape characters
cd /d "%~dp0"
for /f %%a in ('forfiles /m "%~nx0" /c "cmd /c echo 0x1B"') do set "ESC=%%a"
set "right=%ESC%[<x>C"
set "bullet= %ESC%[34m-%ESC%[0m"


cls
goto :DISCLAIMER


:DISCLAIMER
cls
mode con cols=78 lines=30
color 0f

echo.
echo.%ESC%[31m                                DISCLAIMER%ESC%[0m
echo.
echo.
echo.
echo. Please carefully read the disclaimer that has opened in Notepad.
echo.
echo. This tool makes changes to your system settings. While these changes are
echo. intended to optimize performance, they may affect your system's behavior
echo. and stability.
echo.
echo. By proceeding, you acknowledge that you understand and accept the risks
echo. involved with making these system modifications.
echo.
echo. %ESC%[7mPlease take time to review the full disclaimer in the Notepad window.%ESC%[0m
echo.
echo.

timeout /t 1 /nobreak > NUL

echo.
echo.               1%bullet% I have read and agree to the terms
echo.
echo.               2%bullet% I do not agree
echo.
echo. 
:: Prompt user for input
set /p choice=%right:<x>=2%%ESC%[1m%ESC%[33m                      Choose your option (1/2): %ESC%[0m

:: Handle user's choice
if /I "%choice%"=="1" (
    echo Thank you for agreeing to the terms. The process will continue.
    timeout /t 2 /nobreak > NUL
    goto :StartAurora
) else (
    if /I "%choice%"=="2" (
        echo The process has been canceled because you did not agree to the terms.
        timeout /t 2 /nobreak > NUL
        goto :endAurora
    ) else (
        if /I "%choice%"=="x" (
            goto :bypass
        ) else (
            echo Invalid input. Please enter either 1, 2
            timeout /t 2 /nobreak > NUL
            goto :DISCLAIMER
        )
    )
)

:bypass

goto :MainMenu


:endAurora

exit /b


:StartAurora

cls



rem ========================================================================================================================================
:: Check Internet Connection
ping -n 1 "google.com" >nul 2>&1
if !ERRORLEVEL! neq 0 (
    echo ERROR: No internet connection found
    echo.
    echo Please make sure you are connected to the internet and try again . . .
    pause >nul
    exit /b
)


set targetDir=%temp%\AuroraModules
set currentDir=%~dp0AuroraModules

:: Ensure the target directory exists
if not exist "%targetDir%" mkdir "%targetDir%"

:: Check if all required files exist in the current directory
if exist "%currentDir%\LockConsoleSize.ps1" (
    if exist "%currentDir%\OneDrive.ps1" (
        if exist "%currentDir%\Power.ps1" (
            if exist "%currentDir%\RestorePoint.ps1" (
                if exist "%currentDir%\SetConsoleOpacity.ps1" (
                    if exist "%currentDir%\NvidiaProfileInspector.cmd" (
                        if exist "%currentDir%\AuroraAMD.bat" (
                            if exist "%currentDir%\NetworkBufferBloatFixer.ps1" (
                                if exist "%currentDir%\Cloud.bat" (
                                    if exist "%currentDir%\Telemetry.bat" (
                                        if exist "%currentDir%\Privacy.bat" (
                                             if exist "%currentDir%\RepairWindows.cmd" (
                                                if exist "%currentDir%\AuroraAvatar.ico" (
                                                    if exist "%currentDir%\RemoveEdge.ps1" (
                                                        if exist "%currentDir%\Components.ps1" (
                                                            if exist "%currentDir%\AuroraTimerResolution.cs" (
                                                                if exist "%currentDir%\AuroraTimerResolution.ps1" (
                                                                    if exist "%currentDir%\AuroraManualServices.cmd" (
                                                                        if exist "%currentDir%\AuroraSudo.exe" (
                                                                            echo Files already exist in AuroraModules directory. Skipping download...
                                                                            goto :skipDownload
                                                                        )
                                                                    )
                                                                )
                                                            )
                                                        )
                                                    )
                                                )
                                             )
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
    )
)
cls
echo Download files for Aurora

curl -g -k -L -# -o "%targetDir%\LockConsoleSize.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/LockConsoleSize.ps1" > NUL 2>&1
curl -g -k -L -# -o "%targetDir%\OneDrive.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/OneDrive.ps1" > NUL 2>&1
curl -g -k -L -# -o "%targetDir%\Power.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/Power.ps1" > NUL 2>&1
curl -g -k -L -# -o "%targetDir%\RestorePoint.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/RestorePoint.ps1" > NUL 2>&1
curl -g -k -L -# -o "%targetDir%\SetConsoleOpacity.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/SetConsoleOpacity.ps1" > NUL 2>&1
curl -g -k -L -# -o "%targetDir%\NetworkBufferBloatFixer.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/NetworkBufferBloatFixer.ps1" > NUL 2>&1
curl -g -k -L -# -o "%targetDir%\RemoveEdge.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/RemoveEdge.ps1" > NUL 2>&1
curl -g -k -L -# -o "%targetDir%\Components.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/Components.ps1" > NUL 2>&1
curl -g -k -L -# -o "%targetDir%\AuroraTimerResolution.cs" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/AuroraTimerResolution.cs" > NUL 2>&1
curl -g -k -L -# -o "%targetDir%\AuroraTimerResolution.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/AuroraTimerResolution.ps1" > NUL 2>&1
curl -g -k -L -# -o "%targetDir%\AuroraSudo.exe" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/AuroraSudo.exe" > NUL 2>&1

curl -g -k -L -# -o "%targetDir%\NvidiaProfileInspector.cmd" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/NvidiaProfileInspector.cmd" > NUL 2>&1
curl -g -k -L -# -o "%targetDir%\AuroraAMD.bat" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/AuroraAMD.bat" > NUL 2>&1
curl -g -k -L -# -o "%targetDir%\Cloud.bat" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/Cloud.bat" > NUL 2>&1
curl -g -k -L -# -o "%targetDir%\Telemetry.bat" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/Telemetry.bat" > NUL 2>&1
curl -g -k -L -# -o "%targetDir%\Privacy.bat" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/Privacy.bat" > NUL 2>&1
curl -g -k -L -# -o "%targetDir%\RepairWindows.cmd" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/RepairWindows.cmd" > NUL 2>&1
curl -g -k -L -# -o "%targetDir%\AuroraAvatar.ico" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/Docs/Assets/AuroraAvatar.ico" > NUL 2>&1
curl -g -k -L -# -o "%targetDir%\AuroraManualServices.cmd" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/AuroraManualServices.cmd" > NUL 2>&1


:: Ensure the destination directory exists in the current script location
if not exist "%currentDir%" mkdir "%currentDir%"

:: Move downloaded files to the script's current directory
move "%targetDir%\*" "%currentDir%\" > NUL 2>&1
cls

:skipDownload
:: Enable ANSI Escape Sequences
powershell.exe -Command "$host.ui.RawUI.WindowTitle = 'Aurora | @by IBRHUB'"


:: Set console size and appearance
powershell.exe -ExecutionPolicy Bypass -File "%~dp0\AuroraModules\RestorePoint.ps1"
powershell.exe -ExecutionPolicy Bypass -File "%~dp0\AuroraModules\LockConsoleSize.ps1"
powershell.exe -ExecutionPolicy Bypass -File "%~dp0\AuroraModules\SetConsoleOpacity.ps1"

:: Disabled modules:
:: powershell.exe -ExecutionPolicy Bypass -File "%~dp0\AuroraModules\resizeConsole.ps1"

:: Disable process mitigations
:: powershell.exe "ForEach($v in (Get-Command -Name \"Set-ProcessMitigation\").Parameters[\"Disable\"].Attributes.ValidValues){Set-ProcessMitigation -System -Disable $v.ToString() -ErrorAction SilentlyContinue}"  >NUL 2>&1
cls
rem ========================================================================================================================================


color f
:MainMenu
chcp 65001 >NUL
CLS
mode con cols=95 lines=40
echo.
echo.
echo.
echo.
echo.
echo.
echo                             [1;4;94mA[1;96mU[1;92mR[1;93mO[1;92mR[1;90mA[1;37m[0m ✓[1;3;37m%bullet% Lighting Up Your PC's Performance[0m   
echo.
echo.
echo.
echo.
echo                       ═══════════════════════════════════════════════════════
echo.                                                                            
echo                         [38;5;36m[1]%bullet% [1;37mWindows Tweaks[37m       [38;5;36m[3]%bullet% [1;37mNetwork Tweaks[37m     [38;5;105m
echo.                                                                            
echo                         [38;5;36m[2]%bullet% [1;37mGPU Tweaks[37m           [38;5;36m[4]%bullet% [1;37mPower Plan[37m         [38;5;36m
echo.                                                                            
echo                       ═══════════════════════════════════════════════════════                                                                                                                                                    
echo                         [38;5;36m[5]%bullet% [1;37mDisable Services[37m     [38;5;36m[7]%bullet% [1;37mRepair Windows[37m     [38;5;105m
echo.                                                                            
echo                         [38;5;36m[6]%bullet% [1;37mDark Mode[37m            [38;5;36m[8]%bullet% [1;4;3;34mDiscord[0m            [38;5;36m
echo.                                                                                   
echo                       ═══════════════════════════════════════════════════════
echo.
echo                         [38;5;36m[9]%bullet% [1;4;3;34mIBRHUB.COM[0m          [38;5;36m[10]%bullet% [1;4;3;34mDocumentation![0m             
echo.
echo                       ═══════════════════════════════════════════════════════
echo.
echo.                                                                             
echo                                               [91m[0][0m%bullet% [1;4;3;91mExit[0m  [37m                       
echo.                                                                                                            
set /p input= [38;5;36m                      ══════════^> [38;5;36 m[0m

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
echo [91mInvalid input. Please select a number between 1 and 8.[0m
C:\Windows\System32\TIMEOUT.exe /t 1 /nobreak > nul 2> nul
goto :MainMenu

:WinTweaks
mode con cols=76 lines=35
cls
:: - Setting UAC - never notify
:: reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v PromptOnSecureDesktop /t REG_DWORD /d 0 /f > NUL 2>&1
:: reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 0 /f > NUL 2>&1
:: reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 0 /f > NUL 2>&1

echo. - Setting Edge policies
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

:: Discord
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "Discord" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "Discord" /f >nul 2>&1

:: Synapse3
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "Synapse3" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "Synapse3" /f >nul 2>&1

:: Spotify
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "Spotify" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "Spotify" /f >nul 2>&1

:: EpicGamesLauncher
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "EpicGamesLauncher" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "EpicGamesLauncher" /f >nul 2>&1

:: RiotClient
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "RiotClient" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "RiotClient" /f >nul 2>&1

:: Steam
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "Steam" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "Steam" /f >nul 2>&1

:: GoogleDrive
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "GoogleDrive" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "GoogleDrive" /f >nul 2>&1

:: OneDrive
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "OneDrive" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDrive" /f >nul 2>&1

:: DropboxUpdate
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "DropboxUpdate" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "DropboxUpdate" /f >nul 2>&1

:: CCleaner
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "CCleaner" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "CCleaner" /f >nul 2>&1

:: iTunesHelper
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "iTunesHelper" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "iTunesHelper" /f >nul 2>&1

:: AdobeCreativeCloud
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "AdobeCreativeCloud" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "AdobeCreativeCloud" /f >nul 2>&1

:: AdobeGCClient
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "AdobeGCClient" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "AdobeGCClient" /f >nul 2>&1

:: EADesktop
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "EADesktop" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "EADesktop" /f >nul 2>&1

:: UbisoftConnect
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "UbisoftConnect" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "UbisoftConnect" /f >nul 2>&1

:: UbisoftGameLauncher
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "UbisoftGameLauncher" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "UbisoftGameLauncher" /f >nul 2>&1

:: BattleNet
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "BattleNet" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "BattleNet" /f >nul 2>&1

:: TeamViewer
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "TeamViewer" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "TeamViewer" /f >nul 2>&1

:: AnyDesk
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "AnyDesk" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "AnyDesk" /f >nul 2>&1

:: LogitechGHub
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "LogitechGHub" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "LogitechGHub" /f >nul 2>&1

:: CorsairService
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "CorsairService" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "CorsairService" /f >nul 2>&1

:: RazerCentralService
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "RazerCentralService" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "RazerCentralService" /f >nul 2>&1

:: MSIAfterburner
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "MSIAfterburner" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "MSIAfterburner" /f >nul 2>&1

:: NVIDIAGeForceExperience
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "NVIDIAGeForceExperience" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "NVIDIAGeForceExperience" /f >nul 2>&1

:: AMDRyzenMaster
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "AMDRyzenMaster" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "AMDRyzenMaster" /f >nul 2>&1

:: Overwolf
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "Overwolf" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "Overwolf" /f >nul 2>&1

:: SteelSeriesEngine
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "SteelSeriesEngine" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SteelSeriesEngine" /f >nul 2>&1

:: ASUSArmouryCrate
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "ASUSArmouryCrate" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "ASUSArmouryCrate" /f >nul 2>&1

:: ROGGameFirst
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "ROGGameFirst" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "ROGGameFirst" /f >nul 2>&1

:: ROGRangeboost
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "ROGRangeboost" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "ROGRangeboost" /f >nul 2>&1

:: iCUE
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "iCUE" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "iCUE" /f >nul 2>&1

:: Wallpaper Engine
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "Wallpaper Engine" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "Wallpaper Engine" /f >nul 2>&1

:: GOG Galaxy
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "GOG Galaxy" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "GOG Galaxy" /f >nul 2>&1

:: Microsoft Teams
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "Microsoft Teams" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "Microsoft Teams" /f >nul 2>&1

:: Slack
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "Slack" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "Slack" /f >nul 2>&1

:: Zoom
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "Zoom" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "Zoom" /f >nul 2>&1

:: Skype
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "Skype" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "Skype" /f >nul 2>&1

:: WhatsApp
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "WhatsApp" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "WhatsApp" /f >nul 2>&1

:: Telegram
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "Telegram" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "Telegram" /f >nul 2>&1

:: OpenRGB
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "OpenRGB" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OpenRGB" /f >nul 2>&1

:: SignalRGB
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "SignalRGB" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SignalRGB" /f >nul 2>&1

:: Java Update Scheduler
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "Java Update Scheduler" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "Java Update Scheduler" /f >nul 2>&1

:: QuickTime Task
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "QuickTime Task" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "QuickTime Task" /f >nul 2>&1

:: SoundBlasterConnect
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "SoundBlasterConnect" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SoundBlasterConnect" /f >nul 2>&1

:: RealPlayer
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "RealPlayer" /t REG_BINARY /d "030000000000000000000000" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "RealPlayer" /f >nul 2>&1


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
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "BatterySaverModeAvailability" /t REG_DWORD /d 1 /f > NUL 2>&1
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


echo. - Adjust processor scheduling to allocate processor resources to programs
echo. - 2A Hex/42 Dec = Short, Fixed, High foreground boost.
Reg query "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" 2>nul | find "0x18" >nul 
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d "42" /f > NUL 2>&1
Reg query "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" 2>nul | find "0x26" >nul 
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d "42" /f > NUL 2>&1
timeout /t 5 /nobreak > NUL

mode con cols=76 lines=28
CLS
echo.
echo.
echo.
echo:       ______________________________________________________________
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.                 [96mDo you want to Enable Timer Resolution ?%ESC%[0m
echo.
echo.                             [1] Yes Or [2] No
echo.
set /p input=══════════^> 
if /I "%input%"=="1" goto :TimerR
if /I "%input%"=="2" goto :CloudSync
if /I "%input%"=="3" goto :MainMenu
echo.
echo.    Invalid input. Please enter [1] or [2].
echo:       ______________________________________________________________
echo.
timeout /t 2 /nobreak > NUL

:TimerR
start /wait powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0AuroraModules\AuroraTimerResolution.ps1"


goto :CloudSync
rem ========================================================================================================================================

:CloudSync
mode con cols=76 lines=28
CLS
echo.
echo.
echo.
echo:       ______________________________________________________________
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.                      [96mDo you want to Disable Cloud Sync ?%ESC%[0m
echo.
echo.                             [1] Yes Or [2] No
echo.
set /p input=══════════^> 
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
CALL "%~dp0\AuroraModules\Cloud.BAT"
goto :Telemetry


rem ========================================================================================================================================

:Telemetry
mode con cols=76 lines=28
CLS
echo.
echo.
echo.
echo:       ______________________________________________________________
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.                      [96mDo you want to Disable Telemetry ?%ESC%[0m
echo.
echo.                             [1] Yes Or [2] No
echo.
set /p input=══════════^> 
if /I "%input%"=="1" goto :DisableTelemetry
if /I "%input%"=="2" goto :Privacy
if /I "%input%"=="3" goto :MainMenu
echo.
echo.    Invalid input. Please enter [1] or [2].
echo:       ______________________________________________________________
echo.
timeout /t 2 /nobreak > NUL
goto :Telemetry

:DisableTelemetry
CALL %~dp0\AuroraModules\Telemetry.bat
goto :Privacy


rem ========================================================================================================================================

:Privacy
mode con cols=76 lines=28
CLS
echo.
echo.
echo.
echo:       ______________________________________________________________
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.                      [96mDo you want to Disable Privacy ?%ESC%[0m
echo.
echo.                             [1] Yes Or [2] No
echo.
set /p input= ══════════^> 
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
CALL %~dp0\AuroraModules\Privacy.bat

goto :RemoveEdge
cls

rem ========================================================================================================================================

:RemoveEdge
mode con cols=76 lines=28
CLS
echo.
echo.
echo.
echo:       ______________________________________________________________
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.                        [96mDo you want to Remove Edge ?%ESC%[0m
echo.
echo.                             [1] Yes Or [2] No
echo.
echo.
set /p input= ══════════^> 
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
if exist "%~dp0\AuroraModules\RemoveEdge.ps1" (
    start /wait powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0AuroraModules\RemoveEdge.ps1" -UninstallEdge -NonInteractive
    if %ERRORLEVEL% NEQ 0 (
        echo [91mError: Failed to execute Edge removal script.[0m
        timeout /t 2 /nobreak > NUL
    )
) else (
    echo [91mError: RemoveEdge.ps1 script not found in AuroraModules folder.[0m
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
echo:       ______________________________________________________________
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.                       [96mDo you want to Remove OneDrive? %ESC%[0m
echo.
echo.                                 [1] Yes [2] No
echo.
set /p input=              ══════════^> 
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
if exist "%~dp0\AuroraModules\OneDrive.ps1" (
    :: start /wait powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0\AuroraModules\OneDrive.ps1"
	:: This operation has been disabled due to the large number of users relying on OneDrive and to prevent potential data loss.
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
echo:       ______________________________________________________________
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.                     [96mDo you want to Debloat Windows? %ESC%[0m
echo.
echo.                                 [1] Yes [2] No
echo.
set /p input=              ══════════^> 
if /I "%input%"=="1" goto :RunDebloot
if /I "%input%"=="2" goto :MainMenu
echo.
echo.    Invalid input. Please enter [1] or [2].
echo.
timeout /t 2 /nobreak > NUL
goto :DeblootWindows

:RunDebloot
if exist "%~dp0\AuroraModules\Components.ps1" (
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
echo:       ______________________________________________________________
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.                    [96mDo You Have NVIDIA (1) or AMD (2) ?%ESC%[0m
echo.
echo.                           [1] NVIDIA Or [2] AMD
echo.
set /p input=      ══════════^> 
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
start /wait cmd /c "%~dp0\AuroraModules\NvidiaProfileInspector.cmd"
timeout /t 3 /nobreak > NUL
echo:
echo:
echo:
echo:
echo:
echo:
echo:
echo:
echo:
echo:             [96m Do you want to Modify your NVIDIA Control Panel[0m     
echo:            ___________________________________________________ 
echo:                                                               
echo:                       [1] [93mNVIDIA Settings ( Aurora )[0m
echo:                       [2] [93mNVIDIA Settings ( Default ) [0m
echo:               _____________________________________________   
echo:                                                               
echo:                       [3] [91mBack to Main Menu[0m
echo:            ___________________________________________________
echo:
set /p input= ══════════^> 

if /I "%input%"=="1" goto :AuroraON
if /I "%input%"=="2" goto :AuroraOFF
if /I "%input%"=="3" goto :MainMenu
echo.
echo. Invalid input. Please enter [1] or [2].

echo.
timeout /t 2 /nobreak > NUL
goto :NVIDIATweaks

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
call %~dp0\AuroraModules\AuroraAMD.bat

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
if exist "%~dp0\AuroraModules\Power.ps1" (
    start /wait powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0\AuroraModules\Power.ps1" -Silent
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
echo.
echo:           ______________________________________________________
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.                                  %ESC%[4mWarning:%ESC%[0m
echo.
echo.                      %ESC%[31mThese network tweaks may improve 
echo.                     or worsen your internet performance%ESC%[0m
echo.
echo.                        [1] Network Tweaks [2] menu
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo:           ______________________________________________________
echo.
echo.
echo.
choice /c:12 /n > NUL 2>&1
if "%errorlevel%"=="1" goto :NetworkTweaks1
if "%errorlevel%"=="2" goto :MainMenu

:NetworkTweaks1
timeout /t 3 /nobreak > NUL
if exist "%~dp0\AuroraModules\NetworkBufferBloatFixer.ps1" (
    start /wait powershell.exe -ExecutionPolicy Bypass -File "%~dp0\AuroraModules\NetworkBufferBloatFixer.ps1"
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
echo:       ______________________________________________________________
echo.
echo.
echo.                                %ESC%[4mWarning:%ESC%[0m
echo.
echo.          %ESC%[31mThese changes may cause issues with Windows functionality%ESC%[0m
echo.          %ESC%[31mOnly proceed if you understand the potential risks%ESC%[0m
echo.
echo.                    Press [1] if you want to continue
echo.                    Press [2] to return to main menu
echo.
set /p input= ══════════^> 
if /I "%input%"=="1" goto :ConfirmServices
if /I "%input%"=="2" goto :MainMenu
echo Invalid input
timeout /t 2 /nobreak > NUL
goto :ManualServices

:ConfirmServices
cls
echo.
echo.
echo:       ______________________________________________________________
echo.
echo.                        Are you absolutely sure?
echo.                     This cannot be easily undone
echo.
echo.                    Press [1] to confirm and proceed
echo.                    Press [2] to return to main menu
echo.
set /p input= ══════════^> 
if /I "%input%"=="1" goto :StartServiceChanges
if /I "%input%"=="2" goto :MainMenu
echo Invalid input
timeout /t 2 /nobreak > NUL

:StartServiceChanges
start /wait cmd.exe /c "%~dp0AuroraModules\AuroraManualServices.cmd"
echo.
echo.                     Services modified successfully.
echo.
timeout /t 2 /nobreak > NUL
goto :MainMenu


rem ========================================================================================================================================
:DarkMode
mode con cols=76 lines=33
cls
echo - Enabling Dark Mode...

:: Enable dark mode for system
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "SystemUsesLightTheme" /t REG_DWORD /d "0" /f >nul 2>&1

:: Enable dark mode for current user
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d "0" /f >nul 2>&1 
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "SystemUsesLightTheme" /t REG_DWORD /d "0" /f >nul 2>&1

echo - Dark Mode enabled successfully.

C:\windows\system32\cmd.exe /c taskkill /f /im explorer.exe
 
timeout /t 3 /nobreak > NUL

start %windir%\explorer.exe >nul 2>&1

goto :MainMenu

rem ========================================================================================================================================

:RepairWindows
mode con cols=76 lines=33
cls
echo - Repairing Windows components...
echo.

if exist "%~dp0\AuroraModules\RepairWindows.cmd" (
    start "" /wait "%~dp0\AuroraModules\RepairWindows.cmd"
    echo - Launched Windows repair utility
) else (
    echo - Error: RepairWindows.cmd script not found in AuroraModules folder.
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
set /p input=══════════^> 

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
echo:                               [96m Auto Cleaner[0m     
echo:            ___________________________________________________ 
echo:                                                               
echo:                   	[1] [93m Temp and Prefetch  [0m
echo:                  	[2] [93m Event Viewer[0m 
echo:
echo:                                                               
echo:                            	 [0] [91mExit[0m
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
    echo                    [91m Invalid choice. Please enter 1, 2, or 0.[0m
    pause
    cls
    goto Auto-Cleaner
)


:TempPrefetch
echo.
echo [93m- Clean up temp folders[0m

rd /s /q !TEMP! >nul 2>&1
rd /s /q !windir!\temp >nul 2>&1
md !TEMP! >nul 2>&1
md !windir!\temp >nul 2>&1

echo  [92mTemp folders have been cleaned[0m
echo.
echo.
echo [93m- Clean up the Prefetch folder[0m
rd /s /q !windir!\Prefetch >nul 2>&1

echo  [92mPrefetch folder has been cleaned[0m
echo.


goto EventViewer

:EventViewer
echo.
echo [93m- Clear all Event Viewer logs[0m
echo.
echo.
for /f "tokens=*" %%a in ('wevtutil el') do (
    wevtutil cl "%%a"
) >nul 2>&1

echo [93m- Event Viewer logs has been cleaned[0m
echo.

goto :end

:end
C:\Windows\System32\TASKKILL.exe /f /im powershell.exe > nul 2> nul
C:\Windows\System32\TASKKILL.exe /f /im cmd.exe > nul 2> nul
exit /b

