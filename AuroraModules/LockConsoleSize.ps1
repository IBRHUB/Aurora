<#
.SYNOPSIS
Locks the PowerShell console window size by disabling resizing and maximizing capabilities.

.DESCRIPTION
This script modifies the console window properties using Windows API calls to remove the ability
to resize or maximize the window. This ensures the console maintains a fixed size during execution.
It provides two methods to lock the window size - using Windows API calls and modifying Windows Terminal settings.

.NOTES
- Uses Windows API functions from kernel32.dll and user32.dll
- Modifies window styles by removing WS_SIZEBOX and WS_MAXIMIZEBOX flags
- Changes are active for the current console session only
- Method 2 modifies Windows Terminal settings file directly

.LINK
    https://github.com/IBRHUB
    https://docs.ibrhub.net/
    https://ibrpride.com
#>

# Method 1: Using Windows API
Add-Type -MemberDefinition @"
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")] 
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
    [DllImport("user32.dll")]
    public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);
    [DllImport("user32.dll")]
    public static extern int GetWindowLong(IntPtr hWnd, int nIndex);
"@ -Name "NativeMethods" -Namespace "Win32" | Out-Null

# Get window handle for either Console or Terminal
$HWND = [Win32.NativeMethods]::GetConsoleWindow()
if ($null -eq $HWND) {
    # Try to find Windows Terminal window
    $HWND = [Win32.NativeMethods]::FindWindow("CASCADIA_HOSTING_WINDOW_CLASS", $null)
}

if ($null -ne $HWND) {
    # Constants
    $GWL_STYLE = -16
    $WS_SIZEBOX = 0x40000
    $WS_MAXIMIZEBOX = 0x10000

    # Get current style
    $style = [Win32.NativeMethods]::GetWindowLong($HWND, $GWL_STYLE)

    # Remove resizing and maximizing capabilities
    $newStyle = $style -band -bnot ($WS_SIZEBOX -bor $WS_MAXIMIZEBOX)
    [Win32.NativeMethods]::SetWindowLong($HWND, $GWL_STYLE, $newStyle) | Out-Null
}

# Method 2: Modify Windows Terminal Settings
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path $settingsPath) {
    $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
    
    # Modify default profile settings
    if ($settings.profiles.defaults) {
        $settings.profiles.defaults | Add-Member -NotePropertyName "initialCols" -NotePropertyValue 120 -Force
        $settings.profiles.defaults | Add-Member -NotePropertyName "initialRows" -NotePropertyValue 30 -Force
        $settings.profiles.defaults | Add-Member -NotePropertyName "suppressApplicationTitle" -NotePropertyValue $true -Force
    }
    
    # Add launch size constraints
    $settings | Add-Member -NotePropertyName "disableResizeGesture" -NotePropertyValue $true -Force
    
    # Save modified settings
    $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath
}
