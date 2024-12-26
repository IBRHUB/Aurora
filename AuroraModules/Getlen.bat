@echo off
Setlocal EnableDelayedExpansion

REM This Getlen function is modified and enhanced by IBRAHIM.
REM It is designed to calculate the length of a given string efficiently.
REM 
REM Modified: 06-FEB-2016
REM Version: 2.0

REM INITIALIZE LENGTH VARIABLE
Set ver=2.0

REM Setting up initial length...
set len=0

REM VALIDATE INPUT
IF /i "%~1" == "" (Goto :End)
IF /i "%~1" == "/h" (Goto :Help)
IF /i "%~1" == "/?" (Goto :Help)
IF /i "%~1" == "-h" (Goto :Help)
IF /i "%~1" == "Help" (Goto :Help)
IF /i "%~1" == "" (Echo.%ver% && Goto :EOF)

:Main
REM CALCULATE LENGTH
set "s=%~1#"
for %%P in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
    if "!s:~%%P,1!" NEQ "" ( 
        set /a "len+=%%P"
        set "s=!s:~%%P!"
    )
)

:End
REM RETURN LENGTH TO CALLER
Endlocal && Exit /b %len%

:Help
Echo.
Echo. ===============================
Echo.           GETLEN FUNCTION
Echo. ===============================
Echo.
Echo. This function calculates the length of a given string.
Echo.
Echo. USAGE:
Echo.   Call Getlen [String]
Echo.
Echo. PARAMETERS:
Echo.   String: The string whose length you want to calculate.
Echo.
Echo. OUTPUT:
Echo.   The length of the string is returned via the Errorlevel variable.
Echo.
Echo. EXAMPLES:
Echo.   Call Getlen "IBRAHIM"
Echo.   Echo. %%Errorlevel%%
Echo.
Echo. NOTES:
Echo.   - Ensure the string does not exceed 8100 characters.
Echo.   - Efficient for long strings with minimal iterations.
Echo.
Echo. Enjoy using this enhanced Getlen function!
Echo. ===============================
Goto :End


