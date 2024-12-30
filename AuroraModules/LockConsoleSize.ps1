<#
.SYNOPSIS
Locks the PowerShell console window size by disabling resizing and maximizing capabilities.

.DESCRIPTION
This script modifies the console window properties using Windows API calls to remove the ability
to resize or maximize the window. This ensures the console maintains a fixed size during execution.

.NOTES
- Uses Windows API functions from kernel32.dll and user32.dll
- Modifies window styles by removing WS_SIZEBOX and WS_MAXIMIZEBOX flags
- Changes are active for the current console session only
#>

# Import necessary Windows API function
Add-Type -MemberDefinition @"
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")]
    public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);
    [DllImport("user32.dll")]
    public static extern int GetWindowLong(IntPtr hWnd, int nIndex);
"@ -Name "NativeMethods" -Namespace "Win32" | Out-Null

# Get the console window handle
$HWND = [Win32.NativeMethods]::GetConsoleWindow()

# Constants
$GWL_STYLE = -16
$WS_SIZEBOX = 0x40000
$WS_MAXIMIZEBOX = 0x10000

# Get current style
$style = [Win32.NativeMethods]::GetWindowLong($HWND, $GWL_STYLE)

# Remove resizing and maximizing capabilities
$newStyle = $style -band -bnot ($WS_SIZEBOX -bor $WS_MAXIMIZEBOX)
[Win32.NativeMethods]::SetWindowLong($HWND, $GWL_STYLE, $newStyle) | Out-Null
