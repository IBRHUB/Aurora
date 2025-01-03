#Requires -Version 5.0

<#
.SYNOPSIS
    Sets console window opacity for PowerShell.

.DESCRIPTION
    This script modifies the opacity/transparency of the PowerShell console window
    using Windows API calls. It provides a semi-transparent effect while keeping
    the window usable.

    Key features:
    - Sets console opacity to 90% (230/255)
    - Uses Windows API for window manipulation
    - Handles errors gracefully
    - Requires PowerShell 5.0 or later

.NOTES
    Version: 1.0
    Author: IBRHUB
    Requirements: PowerShell 5.0+
    Warning: Uses Windows API calls that may change in future OS versions

.EXAMPLE
    .\SetConsoleOpacity.ps1
    Sets the PowerShell console window to 90% opacity
#>

# Define the ConsoleOpacity class using Add-Type
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class ConsoleOpacity {
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SetLayeredWindowAttributes(IntPtr hwnd, uint crKey, byte bAlpha, uint dwFlags);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern uint GetWindowLong(IntPtr hwnd, int nIndex);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern uint SetWindowLong(IntPtr hwnd, int nIndex, uint dwNewLong);

    public const uint LWA_ALPHA = 0x00000002;
    public const int GWL_EXSTYLE = -20;
    public const uint WS_EX_LAYERED = 0x80000;

    public static void SetOpacity(byte opacity) {
        IntPtr hwnd = GetConsoleWindow();
        if (hwnd == IntPtr.Zero) {
            throw new InvalidOperationException("Failed to get console window handle.");
        }

        uint currentStyle = GetWindowLong(hwnd, GWL_EXSTYLE);
        SetWindowLong(hwnd, GWL_EXSTYLE, currentStyle | WS_EX_LAYERED);

        bool result = SetLayeredWindowAttributes(hwnd, 0, opacity, LWA_ALPHA);
        if (!result) {
            throw new InvalidOperationException("Failed to set window opacity.");
        }
    }
}
"@ -Language CSharp -PassThru | Out-Null

# Try setting the console opacity
try {
    # Set opacity (0-255, where 255 is fully opaque and 0 is fully transparent)
    [ConsoleOpacity]::SetOpacity(230)
} catch {
    throw $_
}