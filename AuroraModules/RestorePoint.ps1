<#
.SYNOPSIS
Script to create or restore a system restore point.

.DESCRIPTION
This script checks if it is running with administrative privileges, then prompts the user to create or restore a system restore point. The script uses PowerShell cmdlets for creating and restoring restore points.

.NOTES
Author: Ibrahim
Website: https://ibrpride.com
Script Version: 1.3
Last Updated: December 2024
#>

# Function to pause the script
function Pause-Script {
    Read-Host -Prompt "Press Enter to continue..."
}

# Check if the script is running as an admin
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Relaunch as an administrator
    Start-Process powershell.exe -ArgumentList ('-NoProfile -ExecutionPolicy Bypass -File "{0}"' -f $MyInvocation.MyCommand.Definition) -Verb RunAs
    exit
}

# Set Console Opacity Transparent
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class ConsoleOpacity {
    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll", SetLastError = true)]
    private static extern bool SetLayeredWindowAttributes(IntPtr hwnd, uint crKey, byte bAlpha, uint dwFlags);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern uint GetWindowLong(IntPtr hwnd, int nIndex);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern uint SetWindowLong(IntPtr hwnd, int nIndex, uint dwNewLong);

    private const uint LWA_ALPHA = 0x00000002;
    private const int GWL_EXSTYLE = -20;
    private const uint WS_EX_LAYERED = 0x80000;

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

try {
    # Set opacity (0-255, where 255 is fully opaque and 0 is fully transparent)
    [ConsoleOpacity]::SetOpacity(230)
    Write-Host "Console opacity set successfully." -ForegroundColor Green
} catch {
    Write-Host "An error occurred: $_" -ForegroundColor Red
}

# Clear the console screen
Clear-Host

# Function to check if the script is running as an administrator
function Check-Admin {
    if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "This script must be run as Administrator."
        Pause-Script
        exit 1
    }
}

# Function to create a restore point
function Create-RestorePoint {
    param (
        [Parameter(Mandatory = $true)]
        [string]$RestoreName
    )
    Write-Host "Creating Restore Point with name: $RestoreName ..." -ForegroundColor Green

    # Enable system protection for C: drive
    try {
        Enable-ComputerRestore -Drive "C:\"
        Write-Host "System protection enabled successfully for drive C:" -ForegroundColor Green
    } catch {
        Write-Host "Failed to enable system protection: $_" -ForegroundColor Red
        try {
            Write-Host "Opening 'Create a restore point' window..." -ForegroundColor Yellow
            Start-Process "SystemPropertiesProtection.exe"
            return
        } catch {
            Write-Host "Failed to open 'Create a restore point' window: $_" -ForegroundColor Red
            return
        }
    }

    # Create the restore point
    try {
        Checkpoint-Computer -Description $RestoreName -RestorePointType "MODIFY_SETTINGS"
        Write-Host "Restore point created successfully." -ForegroundColor Green
    } catch {
        Write-Host "An error occurred while creating the restore point: $_" -ForegroundColor Red
    }
    Pause-Script
}

# Function to restore a backup from a selected restore point
function Restore-Backup {
    $restorePoints = Get-ComputerRestorePoint | Select-Object -Property SequenceNumber, Description, CreationTime
    if ($restorePoints) {
        Write-Host "Available restore points:" -ForegroundColor Green
        $restorePoints | ForEach-Object { Write-Host "$($_.SequenceNumber) - $($_.Description) - $($_.CreationTime)" }
        $sequenceNumber = Read-Host "Enter the Sequence Number of the restore point you want to restore"
        $restorePoint = $restorePoints | Where-Object { $_.SequenceNumber -eq [int]$sequenceNumber }
        if ($restorePoint) {
            try {
                Restore-Computer -RestorePoint $restorePoint.SequenceNumber -Confirm:$false
                Write-Host "Backup restored successfully. The system will restart shortly." -ForegroundColor Green
            } catch {
                Write-Host "Failed to restore the backup: $_" -ForegroundColor Red
            }
        } else {
            Write-Host "Invalid Sequence Number. Restore point not found." -ForegroundColor Red
        }
    } else {
        Write-Host "No restore points available." -ForegroundColor Red
    }
    Pause-Script
}

# Main script execution
Check-Admin
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host "                            Select an option:" -ForegroundColor Yellow
Write-Host ""
Write-Host "            ___________________________________________________ "
Write-Host ""
Write-Host "                [1] Create a Restore Point" -ForegroundColor Green
Write-Host "                [2] Restore from an available restore point" -ForegroundColor Cyan
Write-Host "                [3] Exit" -ForegroundColor Red
Write-Host ""
Write-Host "            ___________________________________________________ "
Write-Host ""
$choice = Read-Host "               Enter a menu option on the Keyboard [1,2,3]"
Write-Host ""
Write-Host ""
switch ($choice) {
    1 {
        $restoreName = Read-Host "                Enter the name for the Restore Point"
        Create-RestorePoint -RestoreName $restoreName
    }
    2 {
        Restore-Backup
    }
    3 {
        exit
    }
    default {
        Write-Host "Invalid choice. Please enter 1, 2, or 3." -ForegroundColor Red
        Pause-Script
    }
}

# Pause the script to view the output
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
