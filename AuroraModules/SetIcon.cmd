@echo off

:: Ensure admin privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Administrator privileges are required.
    PowerShell Start-Process -Verb RunAs -FilePath '%0' 2>nul || (
        echo Right-click on the script and select "Run as administrator".
        pause & exit 1
    )
    exit 0
)

setlocal EnableDelayedExpansion

:: Set variables
set "ICON_PATH=%~dp0\Docs\Assets\AuroraAvatar.ico"
set "SHORTCUT_NAME=Aurora"
set "SCRIPT_PATH="

:: Function to find Aurora file
:FindAuroraFile
echo Looking for Aurora file...
echo.

:: Check parent directory first since we know SetIcon.cmd is in AuroraModules
if exist "%~dp0\..\Aurora.cmd" (
    set "SCRIPT_PATH=%~dp0\..\Aurora.cmd"
    goto :CreateShortcut
)

:: Check common locations as fallback
if exist "%temp%\Aurora.cmd" (
    set "SCRIPT_PATH=%temp%\Aurora.cmd"
    goto :CreateShortcut
)

if exist "%USERPROFILE%\Desktop\Aurora.cmd" (
    set "SCRIPT_PATH=%USERPROFILE%\Desktop\Aurora.cmd"
    goto :CreateShortcut
)

if exist "%USERPROFILE%\Downloads\Aurora.cmd" (
    set "SCRIPT_PATH=%USERPROFILE%\Downloads\Aurora.cmd"
    goto :CreateShortcut
)

:: Manual search option
echo Aurora.cmd not found in common locations.
echo.
echo [1] Search for Aurora.cmd
echo [2] Exit
echo.
choice /c:12 /n /m "Please choose an option: "
if errorlevel 2 exit /b 1
if errorlevel 1 (
    set /p "SCRIPT_PATH=Please enter the full path to Aurora.cmd: "
    if exist "!SCRIPT_PATH!" (
        goto :CreateShortcut
    ) else (
        echo File not found at specified location.
        timeout /t 2 /nobreak > NUL
        exit /b 1
    )
)

:: Function to create desktop shortcut with custom icon
:CreateShortcut
:: Verify script is running with admin rights
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo Error: This script requires administrator privileges.
    echo Please run as administrator.
    timeout /t 3 /nobreak > NUL
    exit /b 1
)

:: Check if icon file exists
if not exist "%ICON_PATH%" (
    echo Error: AuroraAvatar.ico not found in Docs\Assets folder.
    echo Please ensure AuroraAvatar.ico exists in: %ICON_PATH%
    timeout /t 3 /nobreak > NUL
    exit /b 1
)

echo Attempting Method 1 (PowerShell)...
:: Try PowerShell method first
powershell -Command "$shell = New-Object -COM WScript.Shell; $shortcut = $shell.CreateShortcut([Environment]::GetFolderPath('Desktop') + '\%SHORTCUT_NAME%.lnk'); $shortcut.TargetPath = '%SCRIPT_PATH%'; $shortcut.IconLocation = '%ICON_PATH%'; $shortcut.Save()" >nul 2>&1

if %ERRORLEVEL% EQU 0 (
    if exist "%USERPROFILE%\Desktop\%SHORTCUT_NAME%.lnk" (
        echo Desktop shortcut created successfully with Method 1 (PowerShell).
        timeout /t 2 /nobreak > NUL
        exit /b 0
    )
)

echo Method 1 failed. Attempting Method 2 (COM Object)...
:: Try COM Object method
echo Set oWS = WScript.CreateObject("WScript.Shell") > "%temp%\CreateShortcut.vbs"
echo sLinkFile = oWS.ExpandEnvironmentStrings("%%USERPROFILE%%") ^& "\Desktop\%SHORTCUT_NAME%.lnk" >> "%temp%\CreateShortcut.vbs"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%temp%\CreateShortcut.vbs"
echo oLink.TargetPath = "%SCRIPT_PATH%" >> "%temp%\CreateShortcut.vbs"
echo oLink.IconLocation = "%ICON_PATH%" >> "%temp%\CreateShortcut.vbs"
echo oLink.Save >> "%temp%\CreateShortcut.vbs"

cscript //nologo "%temp%\CreateShortcut.vbs" >nul 2>&1
del "%temp%\CreateShortcut.vbs"

if exist "%USERPROFILE%\Desktop\%SHORTCUT_NAME%.lnk" (
    echo Desktop shortcut created successfully with Method 2 (COM Object).
    timeout /t 2 /nobreak > NUL
    exit /b 0
)

echo Method 2 failed. Attempting Method 3 (Shell.Application)...
:: Create temporary VBScript to use Shell.Application
echo Set objShell = CreateObject("Shell.Application") > "%temp%\CreateLink.vbs"
echo Set DesktopFolder = objShell.NameSpace(0) >> "%temp%\CreateLink.vbs"
echo Set NewShortcut = DesktopFolder.ParseName("%SHORTCUT_NAME%.lnk") >> "%temp%\CreateLink.vbs"
echo If Not NewShortcut Is Nothing Then >> "%temp%\CreateLink.vbs"
echo     NewShortcut.Delete >> "%temp%\CreateLink.vbs"
echo End If >> "%temp%\CreateLink.vbs"
echo Set NewShortcut = DesktopFolder.CreateShortcut("%SHORTCUT_NAME%.lnk") >> "%temp%\CreateLink.vbs"
echo NewShortcut.Path = "%SCRIPT_PATH%" >> "%temp%\CreateLink.vbs"
echo NewShortcut.SetIconLocation "%ICON_PATH%", 0 >> "%temp%\CreateLink.vbs"
echo NewShortcut.Save >> "%temp%\CreateLink.vbs"

cscript //nologo "%temp%\CreateLink.vbs" >nul 2>&1
del "%temp%\CreateLink.vbs"

if exist "%USERPROFILE%\Desktop\%SHORTCUT_NAME%.lnk" (
    echo Desktop shortcut created successfully with Method 3 (Shell.Application).
    timeout /t 2 /nobreak > NUL
    exit /b 0
)

echo All methods failed to create desktop shortcut.
timeout /t 2 /nobreak > NUL
exit /b 1
