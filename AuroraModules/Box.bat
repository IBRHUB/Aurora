@Echo off

Set _Ver=4.0

:: This script is modified by IBRAHIM
:: It includes the Box function to add simple GUI effects to batch programs.
:: Please do not modify this function unless you understand its functionality.

:: Parameters for the Box function:
:: [%1 = X-coordinate (horizontal position)]
:: [%2 = Y-coordinate (vertical position)]
:: [%3 = Box height]
:: [%4 = Box width] 
:: [%5 = Width for internal separation line, use "-" to disable.]
:: [%6 = Background character for the box, use "-" to disable.]
:: [%7 = Color code for the box (e.g., fc, 08, 70, 07). Use "-" to disable color changes.]
:: [%8 = Box style/type (e.g., single border, double border, etc.).]
:: [%9 = Variable to save the output instead of printing directly.]


:: Validate inputs or display help
If /i "%~1" == "" (goto :help)
If /i "%~1" == "/?" (goto :help)
If /i "%~1" == "-h" (goto :help)
If /i "%~1" == "help" (goto :help)
If /i "%~1" == "-help" (goto :help)

If /i "%~1" == "ver" (echo.4.0&&goto :eof)


If /i "%~2" == "" (goto :help)
If /i "%~3" == "" (goto :help)
If /i "%~4" == "" (goto :help)

:Box
setlocal Enabledelayedexpansion
set _string=
set "_SpaceWidth=/d ""
set _final=


:: Initialize parameters
set x_val=%~1
set y_val=%~2
set sepr=%~5
if /i "!sepr!" == "-" (set sepr=)
set char=%~6
if /i "!char!" == "-" (set char=)
if defined char (set char=!char:~0,1!) ELSE (set "char= ")
set color=%~7
if defined color (if /i "!color!" == "-" (set color=) Else (set "color=/c 0x%~7"))


:: Set box style/type
Set Type=%~8
If not defined Type (Set Type=1)
If %Type% Gtr 4 (Set Type=1)

If /i "%Type%" == "0" (
	If /I "%~6" == "-" (
		set _Hor_line=/a 32
		set _Ver_line=/a 32
		set _Top_sepr=/a 32
		set _Base_sepr=/a 32
		set _Top_left=/a 32
		set _Top_right=/a 32
		set _Base_right=/a 32
		set _Base_left=/a 32
		) ELSE (
		set _Hor_line=/d "%char%"
		set _Ver_line=/d "%char%"
		set _Top_sepr=/d "%char%"
		set _Base_sepr=/d "%char%"
		set _Top_left=/d "%char%"
		set _Top_right=/d "%char%"
		set _Base_right=/d "%char%"
		set _Base_left=/d "%char%"
		)
)

If /i "%Type%" == "1" (
set _Hor_line=/a 196
set _Ver_line=/a 179
set _Top_sepr=/a 194
set _Base_sepr=/a 193
set _Top_left=/a 218
set _Top_right=/a 191
set _Base_right=/a 217
set _Base_left=/a 192
)

If /i "%Type%" == "2" (
set _Hor_line=/a 205
set _Ver_line=/a 186
set _Top_sepr=/a 203
set _Base_sepr=/a 202
set _Top_left=/a 201
set _Top_right=/a 187
set _Base_right=/a 188
set _Base_left=/a 200
)

If /i "%Type%" == "3" (
set _Hor_line=/a 205
set _Ver_line=/a 179
set _Top_sepr=/a 209
set _Base_sepr=/a 207
set _Top_left=/a 213
set _Top_right=/a 184
set _Base_right=/a 190
set _Base_left=/a 212
)

If /i "%Type%" == "4" (
set _Hor_line=/a 196
set _Ver_line=/a 186
set _Top_sepr=/a 210
set _Base_sepr=/a 208
set _Top_left=/a 214
set _Top_right=/a 183
set _Base_right=/a 189
set _Base_left=/a 211
)


:: Calculate dimensions
set /a _char_width=%~4-2
set /a _box_height=%~3-2

for /l %%A in (1,1,!_char_width!) do (
	if /i "%%A" == "%~5" (
	set "_string=!_string! !_Top_sepr!"
	set "_SpaceWidth=!_SpaceWidth!" !_Ver_line! /d ""
	) ELSE (
	set "_string=!_string! !_Hor_line!"
	set "_SpaceWidth=!_SpaceWidth!!char!"
	)
)

set "_SpaceWidth=!_SpaceWidth!""
set "_final=/g !x_val! !y_val! !_Top_left! !_string! !_Top_right! !_final! "
set /a y_val+=1

for /l %%A in (1,1,!_box_height!) do (
set "_final=/g !x_val! !y_val! !_Ver_line! !_SpaceWidth! !_Ver_line! !_final! "
set /a y_val+=1
)

:: Improved algorithm for variable generation
Set _To_Replace=!_Top_sepr:~-3!
Set _Replace_With=!_Base_sepr:~-3!

For %%A in ("!_To_Replace!") do For %%B in ("!_Replace_With!") do set "_final=/g !x_val! !y_val! !_Base_left! !_string:%%~A=%%~B! !_Base_right! !_final! "

IF /i "%~9" == "" (batbox %color% %_final% /c 0x07) ELSE (ENDLOCAL && Set "%~9=%color% %_final% /c 0x07")
goto :eof


:help
Echo.
Echo. ==============================
Echo.          BOX FUNCTION
Echo. ==============================
Echo.
Echo. This script is modified by IBRAHIM.
Echo. It adds simple GUI effects to batch programs by displaying boxes.
Echo.
Echo. HOW TO USE:
Echo.
Echo. 1. To create a box, use the syntax:
Echo.      call Box [X] [Y] [Height] [Width] [Separation] [BG_Char] [Color] [Type]

Echo. 2. To display the help menu, use:
Echo.      call Box [help | /? | -h | -help]

Echo. 3. To display the version of the function, use:
Echo.      call Box ver
Echo.

Echo. PARAMETERS:

Echo.   X           = X-coordinate (top-left corner of the box)
Echo.   Y           = Y-coordinate (top-left corner of the box)
Echo.   Height      = Box height
Echo.   Width       = Box width
Echo.   Separation  = Width of internal line (use "-" to disable)
Echo.   BG_Char     = Background character (use "-" to disable)
Echo.   Color       = Color code (e.g., fc, 08, 70, 07)
Echo.   Type        = Box style (valid values: 0 to 4)
Echo.   _Var        = Optional variable to store the output
Echo.
Echo. EXAMPLES:

Echo.   1. Create a simple box at position (10,5):
Echo.      call Box 10 5 10 20 - - fc 1
Echo.   2. Create a box with a separation line:
Echo.      call Box 15 8 12 25 5 # 0c 2
Echo.
Echo. NOTES:

Echo.   - Ensure "batbox.exe" is available in the script directory.
Echo.   - Adjust parameters carefully for the desired layout.
Echo.

Echo.
Echo. ======================================
goto :eof