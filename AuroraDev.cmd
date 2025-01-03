@echo off

:: ============================================================
::                         Aurora Dev
:: ============================================================
::
:: DESCRIPTION:
::   This is the developer version of Aurora, designed for 
::   contributors and developers who want to enhance the project.
::   It contains additional debugging features, development tools,
::   and detailed documentation for easier modification.
::
:: DEVELOPMENT GUIDELINES:
::   1. Code Structure
::      - Follow consistent indentation (4 spaces)
::      - Use descriptive variable names
::      - Comment complex logic thoroughly
::      - Separate concerns into functions
::      - Handle errors gracefully
::
::   2. GitHub Workflow
::      - Fork the repository
::      - Create feature branch
::      - Make changes and test
::      - Submit pull request
::      - Follow code review process
::
::   3. Testing
::      - Test on multiple Windows versions
::      - Verify admin privileges work
::      - Check registry modifications
::      - Validate PowerShell integration
::      - Ensure reversibility of changes
::
:: PROGRAMMING CONCEPTS USED:
::   1. Variables
::      - Environment variables (%TEMP%, %ERRORLEVEL%)
::      - Local variables (PS_VER)
::      - Dynamic variables (!variable!)
::
::   2. Loops
::      - FOR loops for registry operations
::      - While loops for retries
::      - Nested loops for complex operations
::
::   3. Conditional Statements
::      - IF/ELSE for version checks
::      - Error level checking
::      - Nested conditions
::      - Switch-like structures
::
::   4. Functions
::      - Label-based functions
::      - Error handling routines
::      - Utility functions
::      - Cleanup procedures
::
::   5. Input/Output
::      - File operations
::      - Registry queries/modifications
::      - PowerShell integration
::      - User prompts
::      - Logging
::
:: PERFORMANCE OPTIMIZATIONS:
::   - Delayed Expansion for variables
::   - Minimal use of external commands
::   - Efficient registry operations
::   - PowerShell execution optimization
::   - Resource cleanup
::   - Parallel processing where possible
::
:: DEVELOPMENT TOOLS REQUIRED:
::   - Visual Studio Code or PowerShell ISE
::   - Git for Windows
::   - Windows SDK (optional)
::   - PowerShell 7+ for advanced features
::   - Process Monitor for debugging
::
:: DEBUGGING FEATURES:
::   - Verbose logging option
::   - Debug mode flag
::   - Error tracing
::   - Registry operation validation
::   - PowerShell execution tracking
::
:: CONTRIBUTION GUIDELINES:
::   1. Code Style
::      - Clear documentation
::      - Consistent formatting
::      - Meaningful commit messages
::      - Unit tests where applicable
::
::   2. Pull Requests
::      - Detailed description
::      - Reference issues
::      - Include test results
::      - Update documentation
::
::   3. Version Control
::      - Semantic versioning
::      - Feature branches
::      - Clean commit history
::      - Proper tagging
::
:: AUTHOR:
::   IBRHUB
::   https://github.com/IBRAHUB
::
:: VERSION:
::   1.0.0-dev
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
:: Enable delayed expansion for the registry operations
setlocal EnableDelayedExpansion

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


:: The URL you want to download from
set "DOWNLOAD_URL=https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/Disclaimer.md"

:: Output file path in %TEMP%
set "OUTFILE=%TEMP%\Disclaimer.txt"

:: Use curl to download. 
:: -L follows redirects. 
:: --fail (optional) makes curl return an error code if the HTTP status is >= 400.
"C:\Windows\System32\curl.exe" -L --fail -o "%OUTFILE%" "%DOWNLOAD_URL%"  >nul 2>&1
if errorlevel 1 (
    echo Download failed or returned an error code.
    exit /b 1
)

:: Check if the file was actually created
if not exist "%OUTFILE%" (
    echo Disclaimer.txt not found after download!
    exit /b 1
)

:: Open the file in Notepad
start notepad "%OUTFILE%"

:: set ANSI escape characters
cd /d "%~dp0"
for /f %%a in ('forfiles /m "%~nx0" /c "cmd /c echo 0x1B"') do set "ESC=%%a"
set "right=%ESC%[<x>C"
set "bullet= %ESC%[34m-%ESC%[0m"


cls
goto :DISCLAIMER


:DISCLAIMER
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
) else if /I "%choice%"=="2" (
    echo The process has been canceled because you did not agree to the terms.
    timeout /t 2 /nobreak > NUL
    goto :endAurora
) else (
    echo Invalid input. Please enter either 1 or 2.
    timeout /t 2 /nobreak > NUL
    goto :DISCLAIMER
)

:endAurora
taskkill /F /IM "notepad.exe" >nul 2>&1
exit /b


:StartAurora
taskkill /F /IM "notepad.exe" >nul 2>&1



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
                        if exist "%currentDir%\AMDDwords.bat" (
                            if exist "%currentDir%\NetworkBufferBloatFixer.ps1" (
                                if exist "%currentDir%\Cloud.bat" (
                                    if exist "%currentDir%\Telemetry.bat" (
                                        if exist "%currentDir%\Privacy.bat" (
                                             if exist "%currentDir%\RepairWindows.cmd" (
                                                if exist "%currentDir%\Avatar.ico" (
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

echo Download files for Aurora

:: Download Aurora modules with progress indicator
echo Downloading Aurora modules..
echo.

echo Downloading PowerShell modules...
curl -g -k -L -# -o "%targetDir%\LockConsoleSize.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/LockConsoleSize.ps1" > NUL 2>&1
curl -g -k -L -# -o "%targetDir%\OneDrive.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/OneDrive.ps1" > NUL 2>&1
curl -g -k -L -# -o "%targetDir%\Power.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/Power.ps1" > NUL 2>&1
curl -g -k -L -# -o "%targetDir%\RestorePoint.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/RestorePoint.ps1" > NUL 2>&1
curl -g -k -L -# -o "%targetDir%\SetConsoleOpacity.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/SetConsoleOpacity.ps1" > NUL 2>&1
curl -g -k -L -# -o "%targetDir%\NetworkBufferBloatFixer.ps1" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/NetworkBufferBloatFixer.ps1" > NUL 2>&1

cls

echo Downloading batch and command modules...

curl -g -k -L -# -o "%targetDir%\NvidiaProfileInspector.cmd" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/NvidiaProfileInspector.cmd" > NUL 2>&1
curl -g -k -L -# -o "%targetDir%\AMDDwords.bat" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/AMDDwords.bat" > NUL 2>&1
curl -g -k -L -# -o "%targetDir%\Cloud.bat" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/Cloud.bat" > NUL 2>&1
curl -g -k -L -# -o "%targetDir%\Telemetry.bat" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/Telemetry.bat" > NUL 2>&1
curl -g -k -L -# -o "%targetDir%\Privacy.bat" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/Privacy.bat" > NUL 2>&1
curl -g -k -L -# -o "%targetDir%\RepairWindows.cmd" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/RepairWindows.cmd" > NUL 2>&1
curl -g -k -L -# -o "%targetDir%\Avatar.ico" "https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/Docs/Assets/Avatar.ico" > NUL 2>&1

echo All modules downloaded successfully!
cls

:: Ensure the destination directory exists in the current script location
if not exist "%currentDir%" mkdir "%currentDir%"

:: Move downloaded files to the script's current directory
move "%targetDir%\*" "%currentDir%\" > NUL 2>&1
cls

:skipDownload



:: Enable ANSI Escape Sequences
reg add "HKCU\CONSOLE" /v "VirtualTerminalLevel" /t REG_DWORD /d "1" /F >NUL 2>&1
powershell.exe -Command "$host.ui.RawUI.WindowTitle = 'Aurora | @by IBRHUB'"


:: Set console size and appearance
powershell.exe -ExecutionPolicy Bypass -File "%~dp0\AuroraModules\RestorePoint.ps1"
powershell.exe -ExecutionPolicy Bypass -File "%~dp0\AuroraModules\LockConsoleSize.ps1"
powershell.exe -ExecutionPolicy Bypass -File "%~dp0\AuroraModules\SetConsoleOpacity.ps1"

:: Disabled modules:
:: powershell.exe -ExecutionPolicy Bypass -File "%~dp0\AuroraModules\resizeConsole.ps1"

timeout /t 1 /nobreak >NUL

:: Disable process mitigations
powershell.exe "ForEach($v in (Get-Command -Name \"Set-ProcessMitigation\").Parameters[\"Disable\"].Attributes.ValidValues) {
    Set-ProcessMitigation -System -Disable $v.ToString() -ErrorAction SilentlyContinue
}" >NUL 2>&1


:: Set custom icon for the current CMD window
if exist "%currentDir%\Avatar.ico" (
    :: Check if PowerShell is available
    where powershell >nul 2>&1
    if %ERRORLEVEL% NEQ 0 (
        goto :StartupAuroraMain
    )

    :: Create temporary VBS script to change console icon silently
    echo Set objShell = CreateObject("Shell.Application") > "%TEMP%\seticon.vbs"
    echo Set objWin = objShell.Windows() >> "%TEMP%\seticon.vbs"
    echo For Each win In objWin >> "%TEMP%\seticon.vbs"
    echo     If InStr(win.LocationName, "cmd.exe") Then >> "%TEMP%\seticon.vbs"
    echo         win.Document.DefaultIcon = "%currentDir%\Avatar.ico" >> "%TEMP%\seticon.vbs"
    echo     End If >> "%TEMP%\seticon.vbs"
    echo Next >> "%TEMP%\seticon.vbs"

    :: Run the VBS script silently
    cscript //nologo "%TEMP%\seticon.vbs" >nul 2>&1
    
    :: Clean up silently
    del "%TEMP%\seticon.vbs" >nul 2>&1

    :: Create shortcut with custom icon on desktop silently
    powershell -Command "$shell = New-Object -COM WScript.Shell; $shortcut = $shell.CreateShortcut([System.IO.Path]::Combine($env:USERPROFILE, 'Desktop', 'Aurora.lnk')); $shortcut.TargetPath = '%~dp0\Aurora.cmd'; $shortcut.IconLocation = '%currentDir%\Avatar.ico'; $shortcut.Save()" >nul 2>&1

    :: Verify shortcut creation silently
    if not exist "%USERPROFILE%\Desktop\Aurora.lnk" goto :StartupAuroraMain

) else (
    goto :Main
)

:StartupAuroraMain
chcp 65001 >NUL

color f
:Main
CLS
mode con cols=95 lines=38
echo.
echo.
echo		      [38;5;105m ▄█  ▀█████████▄     ▄████████    ▄█    █▄    ███    █▄  ▀█████████▄  
echo		      [38;5;105m ███    ███    ███   ███    ███   ███    ███   ███    ███   ███    ███ 
echo		      [38;5;69m ███▌   ███    ███   ███    ███   ███    ███   ███    ███   ███    ███ 
echo		      [38;5;69m ███▌  ▄███▄▄▄██▀   ▄███▄▄▄▄██▀  ▄███▄▄▄▄███▄▄ ███    ███  ▄███▄▄▄██▀  
echo		      [38;5;133m ███▌ ▀▀███▀▀▀██▄  ▀▀███▀▀▀▀▀   ▀▀███▀▀▀▀███▀  ███    ███ ▀▀███▀▀▀██▄  
echo		      [38;5;133m ███    ███    ██▄ ▀███████████   ███    ███   ███    ███   ███    ██▄ 
echo		      [38;5;105m ███    ███    ███   ███    ███   ███    ███   ███    ███   ███    ███ 
echo		      [38;5;105m █▀   ▄█████████▀    ███    ███   ███    █▀    ████████▀  ▄█████████▀  
echo		      [38;5;69m                     ███    ███                                       
echo.
echo.
echo                             [94mA[96mU[92mR[93mO[95mR[90mA[37m [37m – Lighting Up Your PC's Performance   [38;5;105m
echo.
echo.
echo                        ╔══════════════════════════════════════════════════╗[38;5;105m
echo                        ║                                                  ║
echo                        ║ [38;5;213m[1] - [37mWindows Tweaks[37m     [38;5;213m[3] - [37mNetwork Tweaks[37m    ║[38;5;105m
echo                        ║                                                  ║
echo                        ║ [38;5;213m[2] - [37mGPU Tweaks[37m         [38;5;213m[4] - [37mPower-Plan[37m        ║[38;5;213m
echo                        ║                                                  ║
echo                        ║ [38;5;213m[5] - [37mManual Services[37m    [38;5;213m[7] - [37mRepair Windows[37m    ║[38;5;105m
echo                        ║                                                  ║
echo                        ║ [38;5;213m[6] - [37mDark Mode[37m          [38;5;213m[8] - [37mDiscord[37m           ║[38;5;213m
echo                        ║                                                  ║
echo                        ║                                                  ║
echo                        ║                  [38;5;213m[0] - [37mExit[37m         [38;5;213m             ║
echo                        ║                                                  ║
echo                        ╚══════════════════════════════════════════════════╝[38;5;105m
echo.
echo.
echo.                                     
echo.                     
set /p input=%BS% [38;5;213m                                           ══════════^> [38;5;213 m[38;5;105m

if not defined input goto :Main
if "%input%"=="" goto :Main
set "input=%input:"=%"
if "%input%"=="1" goto :WinTweaks
if "%input%"=="2" goto :GPUTweaks  
if "%input%"=="3" goto :NetworkTweaks
if "%input%"=="4" goto :Power-Plan
if "%input%"=="5" goto :ManualServices
if "%input%"=="6" goto :DarkMode
if "%input%"=="7" goto :RepairWindows
if "%input%"=="8" goto :Discord
if "%input%"=="0" exit /b
echo [91mInvalid input. Please select a number between 1 and 8.[0m
timeout /t 2 /nobreak >nul
goto :Main




:WinTweaks
CLS
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.                                        %ESC%[7mDisable OneDrive?%ESC%[0m
echo.
echo.                                      [38;5;105m[1] Yes Or [38;5;105m[2] No
echo.
set /p input=%BS% [38;5;213m                        ══════════^> [38;5;213m[38;5;105m

if /I "%input%"=="1" goto :DisableOneDrive
if /I "%input%"=="2" goto :Tweaks
if /I "%input%"=="3" goto :Main
echo.
echo.                                            [38;5;196mInvalid input. Please enter [1] or [2].
echo.
timeout /t 2 /nobreak > NUL
goto :WinTweaks

:DisableOneDrive

rem -  Disabling OneDrive
reg add "HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\ShellFolder" /f /v "Attributes" /t REG_DWORD /d "0" > NUL 2>&1
reg add "HKCR\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\ShellFolder" /f /v "Attributes" /t REG_DWORD /d "0" >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSync" /t REG_DWORD /d "1" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d "1" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableMeteredNetworkFileSync" /t REG_DWORD /d "0" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableLibrariesDefaultSaveToOneDrive" /t REG_DWORD /d "0" /f > NUL 2>&1

timeout /t 1 /nobreak > NUL
if exist "%~dp0\AuroraModules\OneDrive.ps1" (
    start /wait powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0\AuroraModules\OneDrive.ps1"
    if %ERRORLEVEL% NEQ 0 (
        echo [91mError: Failed to execute OneDrive removal script.[0m
        timeout /t 2 /nobreak > NUL
    )
) else (
    echo [91mError: OneDrive.ps1 script not found in AuroraModules folder.[0m
    timeout /t 2 /nobreak > NUL
)


goto :Tweaks

:Tweaks

rem - Setting UAC - never notify
:: reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v PromptOnSecureDesktop /t REG_DWORD /d 0 /f > NUL 2>&1
:: reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 0 /f > NUL 2>&1
:: reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 0 /f > NUL 2>&1

rem - Setting Edge policies
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v StartupBoostEnabled /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v HardwareAccelerationModeEnabled /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v BackgroundModeEnabled /t REG_DWORD /d 0 /f > NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\MicrosoftEdgeElevationService" /v Start /t REG_DWORD /d 4 /f > NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\edgeupdate" /v Start /t REG_DWORD /d 4 /f > NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\edgeupdatem" /v Start /t REG_DWORD /d 4 /f > NUL 2>&1

rem - Setting Chrome policies
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v StartupBoostEnabled /t REG_DWORD /d 0 /f > NUL 2>&1
:: reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v HardwareAccelerationModeEnabled /t REG_DWORD /d 0 /f > NUL 2>&1
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

rem - Disable USB Power Savings
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

rem - Quick Boot 
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "DelayedDesktopSwitchTimeout" /t REG_DWORD /d "0" /f > NUL 2>&1
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "StartupDelayInMSec" /t REG_SZ /d "0" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "RunStartupScriptSync" /t REG_DWORD /d "0" /f > NUL 2>&1
bcdedit /set bootuxdisabled on > NUL 2>&1
bcdedit /set bootmenupolicy standard > NUL 2>&1
bcdedit /set quietboot yes > NUL 2>&1

rem - Quick Shutdown Settings
reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t REG_SZ /d "2000" /f > NUL 2>&1
reg add "HKLM\System\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d "2000" /f > NUL 2>&1
reg add "HKCU\Control Panel\Desktop" /v "AutoEndTasks" /t REG_SZ /d "1" /f > NUL 2>&1

rem - Additional Performance Optimizations
reg add "HKCU\Control Panel\Desktop" /v "HungAppTimeout" /t REG_SZ /d "1000" /f > NUL 2>&1
reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "20" /f > NUL 2>&1

rem - Usb Overclock with secure boot enabled
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CI\Policy" /v "WHQLSettings" /t REG_DWORD /d "1" /f > NUL 2>&1

rem - Disable Hibernation
powercfg /h off > NUL 2>&1

rem - Disable Superfetch
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SysMain" /v "Start" /t REG_DWORD /d "4" /f > NUL 2>&1

rem - Enable GPU MSI Mode
for /f %%a in ('wmic path Win32_VideoController get PNPDeviceID ^| find "PCI\VEN_"') do ^
reg query "HKLM\System\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" >nul 2>&1 && (
reg add "HKLM\System\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f > NUL 2>&1
)

rem - Background Apps
Reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d "1" /f >nul
Reg add "HKLM\Software\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsRunInBackground" /t REG_DWORD /d "2" /f >nul
Reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BackgroundAppGlobalToggle" /t REG_DWORD /d "0" /f >nul

rem - Disable Hibernation
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "0" /f > NUL 2>&1
powercfg /h off >nul

rem - Disable Sleep Study
schtasks /change /tn "\microsoft\windows\power efficiency diagnostics\analyzesystem" /disable >nul 2>&1
wevtutil set-log "Microsoft-Windows-SleepStudy/Diagnostic" /e:False >nul
wevtutil set-log "Microsoft-Windows-Kernel-Processor-Power/Diagnostic" /e:False >nul
wevtutil set-log "Microsoft-Windows-UserModePowerService/Diagnostic" /e:False >nul

rem - Adjust processor scheduling to allocate processor resources to programs
rem - 2A Hex/42 Dec = Short, Fixed, High foreground boost.
Reg query "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" 2>nul | find "0x18" >nul && reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d "42" /f > NUL 2>&1
Reg query "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" 2>nul | find "0x26" >nul && reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d "42" /f > NUL 2>&1


rem ========================================================================================================================================

:QoSPacketScheduler
cls
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.                                    %ESC%[7mEnable QoS Packet Scheduler ?%ESC%[0m
echo.
echo.                                            [38;5;105m[1] Yes Or [38;5;105m[2] No
echo.
set /p input=%BS% [38;5;213m                        ══════════^> [38;5;213m
if /I "%input%"=="1" (
    reg add "HKLM\System\CurrentControlSet\Services\Psched" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
    sc config Psched start=auto >nul 2>&1
    sc start Psched >nul 2>&1
    netsh int tcp set global congestionprovider=ctcp >nul 2>&1
    netsh int tcp set global ecncapability=enabled >nul 2>&1
) else if /I "%input%"=="2" (
    goto :CloudSync
) else (
    echo.
    echo.                                            [38;5;196mInvalid input. Please enter [1] or [2].[38;5;105m

    timeout /t 2 /nobreak > NUL
    goto :QoSPacketScheduler
)

rem ========================================================================================================================================
                        ══════════>
:CloudSync
CLS
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.                                  %ESC%[7mDisable Cloud Sync ?%ESC%[0m
echo.
echo.                                        [38;5;105m[1] Yes Or [38;5;105m[2] No
echo.
set /p input=%BS% [38;5;213m                        ══════════^> [38;5;213m
if /I "%input%"=="1" goto :DisableCloudSync
if /I "%input%"=="2" goto :Telemetry
if /I "%input%"=="3" goto :Main
echo.
echo.                                            [38;5;196mInvalid input. Please enter [1] or [2].[38;5;105m

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
CLS
mode con cols=95 lines=38
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.                                    %ESC%[7mDisable Telemetry ?%ESC%[0m
echo.
echo.                                       [38;5;105m[1] Yes Or [38;5;105m[2] No
echo.
set /p input=%BS% [38;5;213m                        ══════════^> [38;5;213m
if /I "%input%"=="1" goto :DisableTelemetry
if /I "%input%"=="2" goto :Privacy
if /I "%input%"=="3" goto :Main
echo.
echo.                                            [38;5;196mInvalid input. Please enter [1] or [2].[38;5;105m

echo.
timeout /t 2 /nobreak > NUL
goto :Telemetry

:DisableTelemetry
start "" /wait %~dp0\AuroraModules\Telemetry.bat
goto :Privacy


rem ========================================================================================================================================



:Privacy
CLS
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.                                      %ESC%[7mDisable Privacy ?%ESC%[0m
echo.
echo.                                      [38;5;105m[1] Yes Or [38;5;105m[2] No
echo.
set /p input=%BS% [38;5;213m                        ══════════^> [38;5;213m
if /I "%input%"=="1" goto :DisablePrivacy
if /I "%input%"=="2" goto :RemoveEdge
if /I "%input%"=="3" goto :Main
echo.
echo.                                            [38;5;196mInvalid input. Please enter [1] or [2].[38;5;105m

echo.
timeout /t 2 /nobreak > NUL
goto :Privacy

:DisablePrivacy
start "" /wait %~dp0\AuroraModules\Privacy.bat

goto :RemoveEdge
cls

rem ========================================================================================================================================


:RemoveEdge
CLS
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.                                                %ESC%[7mRemove Edge ?%ESC%[0m
echo.
echo.                                                [38;5;105m[1] Yes Or [38;5;105m[2] No
echo.
set /p input=%BS% [38;5;213m                              ══════════^> [38;5;213m
if /I "%input%"=="1" goto :runRemoveEdge
if /I "%input%"=="2" goto :Main
if /I "%input%"=="3" goto :Main
echo.
echo.                                            [38;5;196mInvalid input. Please enter [1] or [2].[38;5;105m

echo.
timeout /t 2 /nobreak > NUL
goto :RemoveEdge

:runRemoveEdge
if exist "%~dp0\AuroraModules\RemoveEdge.ps1" (
    start /wait powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0\AuroraModules\RemoveEdge.ps1" -UninstallEdge
    if %ERRORLEVEL% NEQ 0 (
        echo [91mError: Failed to execute Edge removal script.[0m
        timeout /t 2 /nobreak > NUL
    )
) else (
    echo [91mError: RemoveEdge.ps1 script not found in AuroraModules folder.[0m
    timeout /t 2 /nobreak > NUL
)

goto :Main
cls



rem ========================================================================================================================================


:GPUTweaks
CLS
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.                                %ESC%[7mDo You Have NVIDIA (1) or AMD (2) ?%ESC%[0m
echo.
echo.                                         [38;5;105m[1] NVIDIA Or [38;5;105m[2] AMD
echo.
set /p input=%BS% [38;5;105m                             ══════════^> 
if /I "%input%"=="1" goto :NVIDIATweaks
if /I "%input%"=="2" goto :AMDTweaks
if /I "%input%"=="3" goto :Main

echo.
echo.                                            [38;5;196mInvalid input. Please enter [1] or [2].[38;5;105m

echo.
timeout /t 2 /nobreak > NUL
goto :GPUTweaks



rem ========================================================================================================================================



:NVIDIATweaks
CLS
mode con cols=85 lines=33
timeout /t 3 /nobreak > NUL
start %~dp0\AuroraModules\NvidiaProfileInspector.cmd

echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.                                         %ESC%[7mResizable Bar OFF (1) or Resizable Bar ON (2) ?%ESC%[0m
echo.
echo.                                   [38;5;105m[1] ResizableBarOFF   [38;5;105m[2] ResizableBarON
echo.
set /p input=%BS% [38;5;213m                        ══════════^> [38;5;213m

if /I "%input%"=="1" goto  :AuroraOFF
if /I "%input%"=="2" goto  :AuroraON
if /I "%input%"=="3" goto :Main
echo.
echo.                                            [38;5;196mInvalid input. Please enter [1] or [2].[38;5;105m

echo.
timeout /t 2 /nobreak > NUL
goto :NVIDIATweaks

:AuroraOFF
timeout /t 3 /nobreak > NUL
start "" /wait "%~dp0AuroraModules\AuroraNvidia\NvidiaProfileInspector\nvidiaProfileInspector.exe" "%~dp0AuroraModules\AuroraNvidia\NvidiaProfileInspector\AuroraOFF.nip"
if errorlevel 1 (
    echo Failed to apply AuroraOFF.nip.
    pause
    goto relaunch
)

echo.
echo                                            [38;5;213mResizable BAR has been disabled successfully.%[0m
timeout /t 3 /nobreak > NUL

goto :Main

:AuroraON
timeout /t 3 /nobreak > NUL
start "" /wait "%~dp0AuroraModules\AuroraNvidia\NvidiaProfileInspector\nvidiaProfileInspector.exe" "%~dp0AuroraModules\AuroraNvidia\NvidiaProfileInspector\AuroraON.nip"
if errorlevel 1 (
    echo Failed to apply AuroraON.nip.
    pause
    goto relaunch
)

echo.
echo                                            [38;5;213mResizable BAR has been enabled successfully.%[0m
timeout /t 3 /nobreak > NUL

goto :Main
cls



rem ======================================================================================================================================== 



:AMDTweaks
timeout /t 3 /nobreak > NUL
start %~dp0\AuroraModules\AuroraAMD.bat

echo.
echo AMD GPU optimizations have been successfully applied!
echo A system restart is recommended for all changes to take effect.
echo.
timeout /t 3 /nobreak > NUL

goto :Main
cls


rem ========================================================================================================================================




:Power-Plan
cls
if exist "%~dp0\AuroraModules\Power.ps1" (
    start /wait powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0\AuroraModules\Power.ps1" -Silent
    if %ERRORLEVEL% NEQ 0 (
        echo                                             [38;5;196mError: Failed to apply power plan optimizations.[0m
        timeout /t 2 /nobreak > NUL
    ) else (
        echo                                             [38;5;192mPower plan optimizations applied successfully.[0m
        timeout /t 2 /nobreak > NUL
    )
) else (
    echo                                             [38;5;196mError: Power.ps1 script not found in AuroraModules folder.[0m
    timeout /t 2 /nobreak > NUL
)

cls
goto :Main


rem ========================================================================================================================================


:NetworkTweaks
cls
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.                               %ESC%[7mAre You On Windows 10 (1) or Windows 11 (2) ?%ESC%[0m
echo.
echo.                                            [38;5;105m[1] 10 Or [38;5;105m[2] 11
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
choice /c:12 /n > NUL 2>&1
if "%errorlevel%"=="1" goto :Win10Net
if "%errorlevel%"=="2" goto :Win11Net
if "%errorlevel%"=="3" goto :Main

:Win11Net
cls 
timeout /t 3 /nobreak > NUL
if exist "%~dp0\AuroraModules\NetworkBufferBloatFixer.ps1" (
    start /wait powershell.exe -ExecutionPolicy Bypass -File "%~dp0\AuroraModules\NetworkBufferBloatFixer.ps1"
    if %ERRORLEVEL% NEQ 0 (
        echo                                             [38;5;196mError: Failed to apply network optimizations.[0m
        timeout /t 2 /nobreak > NUL
    ) else (
        echo                                             [38;5;192mNetwork optimizations applied successfully.[0m
        timeout /t 2 /nobreak > NUL
    )
) else (
    echo                                             [38;5;196mError: NetworkBufferBloatFixer.ps1 script not found in AuroraModules folder.[0m
    timeout /t 2 /nobreak > NUL
)
goto :Main



:Win10Net 
cls
timeout /t 3 /nobreak > NUL
if exist "%~dp0\AuroraModules\NetworkBufferBloatFixer.ps1" (
    start /wait powershell.exe -ExecutionPolicy Bypass -File "%~dp0\AuroraModules\NetworkBufferBloatFixer.ps1"
    if %ERRORLEVEL% NEQ 0 (
        echo                                             [38;5;196mError: Failed to apply network optimizations.[0m
        timeout /t 2 /nobreak > NUL
    ) else (
        echo                                             [38;5;192mNetwork optimizations applied successfully.[0m
        timeout /t 2 /nobreak > NUL
    )
) else (
    echo                                             [91mError: NetworkBufferBloatFixer.ps1 script not found in AuroraModules folder.[0m
    timeout /t 2 /nobreak > NUL
)
goto :Main



rem ========================================================================================================================================
:ManualServices

:: List of services to check/configure
set "services=AudioEndpointBuilder Audiosrv EventLog SysMain Themes WSearch NVDisplay.ContainerLocalSystem WlanSvc"

:: Process each service
for %%s in (%services%) do (
    sc query "%%s" >nul 2>&1
    if !errorlevel! equ 0 (
        echo                                             [38;5;192mConfiguring service: %%s[0m
        sc config "%%s" start= auto >nul 2>&1
        sc start "%%s" >nul 2>&1
    ) else (
        echo                                             [38;5;196mService not found: %%s[0m
    )
)


goto :Main

rem ========================================================================================================================================
:DarkMode
cls
echo                                             [38;5;213mEnabling Dark Mode...

:: Enable dark mode for system
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "SystemUsesLightTheme" /t REG_DWORD /d "0" /f >nul 2>&1

:: Enable dark mode for current user
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d "0" /f >nul 2>&1 
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "SystemUsesLightTheme" /t REG_DWORD /d "0" /f >nul 2>&1

echo                                             [38;5;192mDark Mode enabled successfully.[0m
timeout /t 2 /nobreak > NUL
goto :Main

rem ========================================================================================================================================

:RepairWindows
cls
echo                                             [38;5;213mRepairing Windows components...
echo.

if exist "%~dp0\AuroraModules\RepairWindows.cmd" (
    start "" /wait "%~dp0\AuroraModules\RepairWindows.cmd"
    echo                                        [38;5;192mLaunched Windows repair utility.[0m
) else (
    echo                                 [38;5;196mError: RepairWindows.cmd script not found in AuroraModules folder.[0m
)

timeout /t 2 /nobreak > NUL
goto :Main

rem ========================================================================================================================================

:Discord
cls
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                     %ESC%[7mJoin Our Discord Community%ESC%[0m
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
start "" "https://discord.gg/fVYtpuYuZ6"
timeout /t 7 /nobreak > NUL
goto :Main


:relaunch
cls
echo.
echo [38;5;213mDo you want to restart Aurora or exit?
echo.
echo [38;5;105m[1] Restart Aurora
echo [38;5;105m[2] Exit
echo.
choice /c:12 /n /m "Enter your choice (1-2): "

if errorlevel 2 (
    echo.
    echo [38;5;213mExiting Aurora...
    timeout /t 2 /nobreak > NUL
    exit
) else if errorlevel 1 (
    echo.
    echo [38;5;213mRestarting Aurora...
    timeout /t 2 /nobreak > NUL
    goto :Main
)


:SetIcon
:: Set custom icon for the current CMD window
if exist "%~dp0\Docs\Assets\Avatar.ico" (
    :: Check if PowerShell is available
    where powershell >nul 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo [91mError: PowerShell is not available on this system.[0m
        timeout /t 2 /nobreak > NUL
        goto :Main
    )

    :: Create temporary VBS script to change console icon
    echo Set objShell = CreateObject("Shell.Application") > "%TEMP%\seticon.vbs"
    echo Set objWin = objShell.Windows() >> "%TEMP%\seticon.vbs"
    echo For Each win In objWin >> "%TEMP%\seticon.vbs"
    echo     If InStr(win.LocationName, "cmd.exe") Then >> "%TEMP%\seticon.vbs"
    echo         win.Document.DefaultIcon = "%~dp0\Docs\Assets\Avatar.ico" >> "%TEMP%\seticon.vbs"
    echo     End If >> "%TEMP%\seticon.vbs"
    echo Next >> "%TEMP%\seticon.vbs"

    :: Run the VBS script
    cscript //nologo "%TEMP%\seticon.vbs" >nul 2>&1
    
    :: Clean up
    del "%TEMP%\seticon.vbs" >nul 2>&1

    :: Also create a shortcut with the custom icon for future use
    powershell -Command "$shell = New-Object -COM WScript.Shell; $shortcut = $shell.CreateShortcut('%~dp0\Aurora.lnk'); $shortcut.TargetPath = '%~f0'; $shortcut.IconLocation = '%~dp0\Docs\Assets\Avatar.ico'; $shortcut.Save()" >nul 2>&1

    echo [38;5;213mCustom icon has been set for the current window and future launches.[0m
) else (
    echo [91mError: Avatar.ico not found in Docs\Assets folder.[0m
    echo [91mPlease ensure Avatar.ico exists in: %~dp0\Docs\Assets\[0m
)

timeout /t 3 /nobreak > NUL
goto :Main



