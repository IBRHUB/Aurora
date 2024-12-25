# LockConsoleSize.ps1
# Lock the console window size and disable Exit and Minimize buttons

# Import necessary Windows API functions using TypeDefinition
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

namespace Win32
{
    public static class NativeMethods
    {
        [DllImport("kernel32.dll")]
        public static extern IntPtr GetConsoleWindow();
        
        [DllImport("user32.dll", SetLastError = true)]
        public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);
        
        [DllImport("user32.dll", SetLastError = true)]
        public static extern int GetWindowLong(IntPtr hWnd, int nIndex);
        
        [DllImport("user32.dll")]
        public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);
    }
}
"@

# Get the console window handle
$HWND = [Win32.NativeMethods]::GetConsoleWindow()

if ($HWND -eq [IntPtr]::Zero) {
    Write-Error "Unable to obtain console window handle."
    exit 1
}

# Constants for window styles
$GWL_STYLE = -16
$WS_SIZEBOX = 0x40000
$WS_MAXIMIZEBOX = 0x10000
$WS_SYSMENU = 0x00080000
$WS_MINIMIZEBOX = 0x00020000

# Get current style
$style = [Win32.NativeMethods]::GetWindowLong($HWND, $GWL_STYLE)

# Remove resizing, maximizing, minimizing, and system menu (Exit) capabilities
$newStyle = $style -band -bnot ($WS_SIZEBOX -bor $WS_MAXIMIZEBOX -bor $WS_SYSMENU -bor $WS_MINIMIZEBOX)

# Apply the new style
$result = [Win32.NativeMethods]::SetWindowLong($HWND, $GWL_STYLE, $newStyle)
if ($result -eq 0) {
    Write-Error "Failed to set window style. Error code: $( [Runtime.InteropServices.Marshal]::GetLastWin32Error() )"
    exit 1
}

# Constants for SetWindowPos
$SWP_NOSIZE = 0x0001
$SWP_NOMOVE = 0x0002
$SWP_NOZORDER = 0x0004
$SWP_FRAMECHANGED = 0x0020

# Refresh the window to apply style changes
$refreshResult = [Win32.NativeMethods]::SetWindowPos($HWND, [IntPtr]::Zero, 0, 0, 0, 0, $SWP_NOSIZE -bor $SWP_NOMOVE -bor $SWP_NOZORDER -bor $SWP_FRAMECHANGED)
if (-not $refreshResult) {
    Write-Error "Failed to refresh window styles."
    exit 1
}

# Optional: Lock the window size by handling the window resize event
# This part requires a more advanced approach, such as creating a window hook.
# For simplicity, this script only removes the ability to resize via the window border.

Write-Output "Console window size locked and Exit/Minimize buttons disabled."
