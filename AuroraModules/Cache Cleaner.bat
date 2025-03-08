@Echo off

TITLE [ Aurora Cache Cleaner ]

mode con: cols=100 lines=30

:: Define ANSI escape character for colored output
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "ESC=%%b"
)

cls
echo.
echo    %ESC%[38;5;33m╭──────────────────────────────────────────────────────────────────────────────────╮%ESC%[0m
echo    %ESC%[38;5;33m│%ESC%[97m                             Aurora Cache Cleaner                                  %ESC%[38;5;33m│%ESC%[0m
echo    %ESC%[38;5;33m╰──────────────────────────────────────────────────────────────────────────────────╯%ESC%[0m
echo.

:: Check for admin rights
FOR /F "tokens=1, 2 * " %%V IN ('bcdedit') DO SET adminTest=%%V
IF (%adminTest%)==(Access) goto noAdmin

echo    %ESC%[38;5;33m- Cleaning Temporary Files...%ESC%[0m

:: Progress indicator setup
set "percentage=0"
call :UpdateProgress 0 "Windows Temp Files"

del /s /f /q c:\windows\temp\*.* >nul 2>&1
rd /s /q c:\windows\temp >nul 2>&1
md c:\windows\temp >nul 2>&1

call :UpdateProgress 20 "Prefetch Files"
del /s /f /q C:\WINDOWS\Prefetch\*.* >nul 2>&1

call :UpdateProgress 40 "User Temp Files"
del /s /f /q %temp%\*.* >nul 2>&1
rd /s /q %temp% >nul 2>&1
md %temp% >nul 2>&1

call :UpdateProgress 60 "System Cache Files"
:: Using modern commands instead of deltree (deprecated)
rd /s /q c:\windows\tempor~1 >nul 2>&1
rd /s /q c:\windows\tmp >nul 2>&1
del /s /f /q c:\windows\ff*.tmp >nul 2>&1
rd /s /q c:\windows\history >nul 2>&1
rd /s /q c:\windows\cookies >nul 2>&1
rd /s /q c:\windows\recent >nul 2>&1
rd /s /q c:\windows\spool\printers >nul 2>&1
del /f /q c:\WIN386.SWP >nul 2>&1

call :UpdateProgress 80 "Event Logs"
for /F "tokens=*" %%G in ('wevtutil.exe el') DO (call :do_clear "%%G")

call :UpdateProgress 100 "Completed"

echo.
echo    %ESC%[38;5;33m╭──────────────────────────────────────────────────────────────────────────────────╮%ESC%[0m
echo    %ESC%[38;5;33m│%ESC%[92m                          Cache Cleaning Complete!                                %ESC%[38;5;33m│%ESC%[0m
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
echo    %ESC%[38;5;33m│%ESC%[97m                             Aurora Cache Cleaner                                  %ESC%[38;5;33m│%ESC%[0m
echo    %ESC%[38;5;33m╰──────────────────────────────────────────────────────────────────────────────────╯%ESC%[0m
echo.
echo    %ESC%[38;5;33m╭──────────────────────────────────────────────────────────────────────────────────╮%ESC%[0m
echo    %ESC%[38;5;33m│%ESC%[97m Cleaning:%ESC%[96m %filename% %ESC%[0m
echo    %ESC%[38;5;33m│%ESC%[0m [%progressBar%] %ESC%[93m%percentage%%%%ESC%[0m
echo    %ESC%[38;5;33m╰──────────────────────────────────────────────────────────────────────────────────╯%ESC%[0m

endlocal
goto :eof

:do_clear
echo    %ESC%[38;5;33m- Clearing log: %ESC%[96m%1%ESC%[0m
wevtutil.exe cl %1 >nul 2>&1
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
