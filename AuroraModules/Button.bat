@echo off
Setlocal Enabledelayedexpansion

Set _Ver=2.0


:: This script is modified by IBRAHIM
:: It includes the Button function to add interactive button-like effects to batch programs.
:: Please do not modify this function unless you understand its functionality.

:: PARAMETERS FOR THE BUTTON FUNCTION:
:: [%1 = X-coordinate (horizontal position)]
:: [%2 = Y-coordinate (vertical position)]
:: [%3 = Color code for the button (e.g., fc, 08, 70, 07)]
:: [%4 = Button text (e.g., OK, Retry)]
:: [%5 = Sequence terminating character ('X')]
:: [%6 = Variable to save button coordinates]
:: [%7 = Variable to save mouse hover color]


If /i "%~1" == "" (goto :help)
If /i "%~1" == "/?" (goto :help)
If /i "%~1" == "-h" (goto :help)
If /i "%~1" == "help" (goto :help)
If /i "%~1" == "-help" (goto :help)

If /i "%~1" == "ver" (echo.%_Ver%&&goto :eof)


If /i "%~2" == "" (goto :help)
If /i "%~3" == "" (goto :help)
If /i "%~4" == "" (goto :help)
If /i "%~5" == "" (goto :help)
If /i "%~6" == "" (goto :help)
If /i "%~7" == "" (goto :help)


REM Setting-up variables for necessary calculations.
Set _Hover=
Set _Box=
Set _Text=
Set Button_height=3


:Loop_of_button_fn
REM Getting Button parameters...
Set _X=%~1
Set _Y=%~2
set color=%~3
Set _Invert_Color=%Color:~1,1%%Color:~0,1%
set "Button_text=%~4"

REM Loop Breaking Statements...
if not defined _X (goto :EOF)
if /i "%_X%" == "X" (Goto :End)

REM Checking the length of button according to Button_text
Call Getlen "..%button_text%.."
set button_width=%errorlevel%

REM Little math is important... :)
Set /A _X_Text=%_X% + 2
Set /A _Y_Text=%_Y% + 1
Set /A _X_End=%_X% + %button_width% - 1
Set /A _Y_End=%_Y% + %Button_height% - 1

REM Printing a Button like layout using Box Function!
Call Box %_X% %_Y% %Button_height% %button_width% - - %Color% 0

REM Saving Global variables...
Set "_Text=!_Text!/g !_X_Text! !_Y_Text! /c 0x!color! /d "!Button_text!" "
Set "_Hover=!_Hover!!_Invert_Color! "
Set "_Box=!_Box!!_X! !_Y! !_X_End! !_Y_End! "

REM Shifting the parameters for next button Code...
For /L %%A In (1,1,4) Do (Shift /1)
Goto :Loop_of_button_fn

:End
Batbox %_Text% /c 0x07
Endlocal && set "%~2=%_Box%" && set "%~3=%_Hover%"
Goto :EOF

:help
Echo.
Echo. ==============================
Echo.          BUTTON FUNCTION
Echo. ==============================
Echo.
Echo. This script is modified by IBRAHIM.
Echo. It adds interactive buttons to batch programs with customizable effects.
Echo.
Echo. HOW TO USE:
Echo.
Echo. 1. To create buttons, use the syntax:
Echo.      call Button [X] [Y] [Color] "[Button Text]" ... X _Var_Box _Var_Hover
Echo. 2. To display the help menu, use:
Echo.      call Button [help | /? | -h | -help]
Echo. 3. To display the version of the function, use:
Echo.      call Button ver
Echo.
Echo. PARAMETERS:
Echo.   X           = X-coordinate (top-left corner of the button)
Echo.   Y           = Y-coordinate (top-left corner of the button)
Echo.   Color       = Color code (e.g., fc, 08, 70, 07)
Echo.   Button Text = Text displayed on the button (use quotes if spaces are included)
Echo.   X           = Sequence termination character (used to end the button list)
Echo.   _Var_Box    = Variable to store button coordinates
Echo.   _Var_Hover  = Variable to store hover effects
Echo.
Echo. EXAMPLES:
Echo.   1. Create two buttons:
Echo.      call Button 5 3 fc "OK" 15 3 fc "Cancel" X Box_Var Hover_Var
Echo.
Echo. NOTES:
Echo.   - Ensure "batbox.exe" is available in the script directory.
Echo.   - Use "GetInput.exe" with the generated variables for advanced interaction.
Echo.
Echo. Enjoy using this enhanced Button function!
Echo. ======================================
goto :EOF

