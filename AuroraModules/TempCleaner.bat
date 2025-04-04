@Echo off
:: ============================================================
::                            Aurora
:: ============================================================
:: AUTHOR:
::   IBRHUB - IBRAHIM
::   https://github.com/IBRAHUB
::	 https://docs.ibrhub.net/

TITLE [ Aurora Temp Cleaner ]

mode con: cols=100 lines=30

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

:: Define ANSI escape character for colored output
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "ESC=%%b"
)

cls
echo.
echo    %ESC%[38;5;33m╭──────────────────────────────────────────────────────────────────────────────────╮%ESC%[0m
echo    %ESC%[38;5;33m│%ESC%[97m                             Aurora Temp Cleaner                                   %ESC%[38;5;33m│%ESC%[0m
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

call :UpdateProgress 100 "Completed"

echo.
echo    %ESC%[38;5;33m╭──────────────────────────────────────────────────────────────────────────────────╮%ESC%[0m
echo    %ESC%[38;5;33m│%ESC%[92m                          Temp Cleaning Complete!                                 %ESC%[38;5;33m│%ESC%[0m
echo    %ESC%[38;5;33m╰──────────────────────────────────────────────────────────────────────────────────╯%ESC%[0m
echo.
echo    Press any key to exit...
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
echo    %ESC%[38;5;33m│%ESC%[97m                             Aurora Temp Cleaner                                   %ESC%[38;5;33m│%ESC%[0m
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
exit /b

:theEnd
exit /b