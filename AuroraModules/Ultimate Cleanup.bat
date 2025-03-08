@Echo off

TITLE [ Aurora Ultimate Cleanup ]

mode con: cols=100 lines=30

:: Define ANSI escape character for colored output
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "ESC=%%b"
)

cls
echo.
echo    %ESC%[38;5;33m╭──────────────────────────────────────────────────────────────────────────────────╮%ESC%[0m
echo    %ESC%[38;5;33m│%ESC%[97m                           Aurora Ultimate Cleanup                                 %ESC%[38;5;33m│%ESC%[0m
echo    %ESC%[38;5;33m╰──────────────────────────────────────────────────────────────────────────────────╯%ESC%[0m
echo.

:: Check for admin rights
FOR /F "tokens=1, 2 * " %%V IN ('bcdedit') DO SET adminTest=%%V
IF (%adminTest%)==(Access) goto noAdmin

echo    %ESC%[38;5;33m- Performing Ultimate Cleanup...%ESC%[0m

:: Progress indicator setup
set "percentage=0"
call :UpdateProgress 0 "Windows Temp Files"

set folder="C:\Windows\Temp"
cd /d %folder%
for /F "delims=" %%i in ('dir /b') do (rmdir "%%i" /s/q || del "%%i" /s/q) >nul 2>&1

call :UpdateProgress 25 "User Temp Files"
set folder="%userprofile%\AppData\Local\Temp"
cd /d %folder%
for /F "delims=" %%i in ('dir /b') do (rmdir "%%i" /s/q || del "%%i" /s/q) >nul 2>&1

call :UpdateProgress 50 "Setting Up Disk Cleanup"
:: Automatic Disk Cleanup Registry Settings
set R_Key=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches
reg add "%R_Key%\Active Setup Temp Folders" /v StateFlags0011 /t REG_DWORD /d 00000002 /f >nul 2>&1
reg add "%R_Key%\Thumbnail Cache" /v StateFlags0011 /t REG_DWORD /d 00000002 /f >nul 2>&1
reg add "%R_Key%\Delivery Optimization Files" /v StateFlags0011 /t REG_DWORD /d 00000002 /f >nul 2>&1
reg add "%R_Key%\D3D Shader Cache" /v StateFlags0011 /t REG_DWORD /d 00000002 /f >nul 2>&1
reg add "%R_Key%\Downloaded Program Files" /v StateFlags0011 /t REG_DWORD /d 00000002 /f >nul 2>&1
reg add "%R_Key%\Internet Cache Files" /v StateFlags0011 /t REG_DWORD /d 00000002 /f >nul 2>&1
reg add "%R_Key%\Setup Log Files" /v StateFlags0011 /t REG_DWORD /d 00000002 /f >nul 2>&1
reg add "%R_Key%\Temporary Files" /v StateFlags0011 /t REG_DWORD /d 00000002 /f >nul 2>&1
reg add "%R_Key%\Windows Error Reporting Files" /v StateFlags0011 /t REG_DWORD /d 00000002 /f >nul 2>&1
reg add "%R_Key%\Offline Pages Files" /v StateFlags0011 /t REG_DWORD /d 00000002 /f >nul 2>&1

call :UpdateProgress 75 "Running Disk Cleanup"
cleanmgr.exe /sagerun:11 >nul 2>&1

call :UpdateProgress 100 "Completed"

echo.
echo    %ESC%[38;5;33m╭──────────────────────────────────────────────────────────────────────────────────╮%ESC%[0m
echo    %ESC%[38;5;33m│%ESC%[92m                        Ultimate Cleanup Complete!                                 %ESC%[38;5;33m│%ESC%[0m
echo    %ESC%[38;5;33m╰──────────────────────────────────────────────────────────────────────────────────╯%ESC%[0m
echo.
echo    Press any key to exit...
pause >nul
goto theEnd

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
echo.
echo    %ESC%[38;5;33m╭──────────────────────────────────────────────────────────────────────────────────╮%ESC%[0m
echo    %ESC%[38;5;33m│%ESC%[97m                           Aurora Ultimate Cleanup                                 %ESC%[38;5;33m│%ESC%[0m
echo    %ESC%[38;5;33m╰──────────────────────────────────────────────────────────────────────────────────╯%ESC%[0m
echo.
echo    %ESC%[38;5;33m╭──────────────────────────────────────────────────────────────────────────────────╮%ESC%[0m
echo    %ESC%[38;5;33m│%ESC%[97m Cleaning:%ESC%[96m %filename% %ESC%[0m
echo    %ESC%[38;5;33m│%ESC%[0m [%progressBar%] %ESC%[93m%percentage%%%%ESC%[0m
echo    %ESC%[38;5;33m╰──────────────────────────────────────────────────────────────────────────────────╯%ESC%[0m

endlocal
goto :eof

:noAdmin
echo    %ESC%[38;5;33m╭──────────────────────────────────────────────────────────────────────────────────╮%ESC%[0m
echo    %ESC%[38;5;33m│%ESC%[91m                   You must run this script as an Administrator!                   %ESC%[38;5;33m│%ESC%[0m
echo    %ESC%[38;5;33m╰──────────────────────────────────────────────────────────────────────────────────╯%ESC%[0m
echo.
echo    Press any key to exit...
pause >nul
exit /b

:theEnd
exit /b

