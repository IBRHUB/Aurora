#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Creates a system restore point for Aurora configuration changes.

.DESCRIPTION
    This script creates a system restore point before making Aurora configuration changes.
    It provides a safety net by allowing users to revert system changes if needed.

    Key features:
    - Creates restore point named "Aurora" 
    - Enables system protection on C: drive if needed
    - Logs all operations for troubleshooting
    - Requires administrator privileges
    - Handles errors gracefully with logging

.NOTES
    Version: 1.0
    Author: IBRHUB - IBRAHIM
    Requirements: Must be run with Administrator privileges
    Warning: Modifies system restore settings

.LINK
    https://github.com/IBRAHUB
    https://docs.ibrhub.net/
#>

# Define constants
$RestorePointName = "Aurora"
$LogFile = "$env:Temp\AuroraRestorePoint.log"
$DriveLetter = "C:\"

# Function to log messages to a file
function Log-Message {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp [$Level] $Message"
    Add-Content -Path $LogFile -Value $logEntry
}

# Function to check if running as Administrator
function Test-Administrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to enable system protection on specified drive
function Enable-SystemProtection {
    param (
        [string]$Drive
    )
    try {
        Log-Message "Enabling System Restore on drive ${Drive}..." "INFO"
        Enable-ComputerRestore -Drive $Drive -ErrorAction Stop
        Log-Message "System Restore enabled on drive ${Drive}." "INFO"
    } catch {
        Log-Message "Error enabling System Restore on drive ${Drive}: $_" "ERROR"
        exit 1
    }
}

# Function to create a restore point
function Create-RestorePoint {
    param (
        [string]$Description,
        [string]$Type = "MODIFY_SETTINGS"  # Options: APPLICATION_INSTALL, DEVICE_DRIVER_INSTALL, MODIFY_SETTINGS, CANCELLED_OPERATION, etc.
    )
    try {
        Log-Message "Creating restore point: '${Description}' ..." "INFO"
        Checkpoint-Computer -Description $Description -RestorePointType $Type -ErrorAction Stop
        Log-Message "Restore point '${Description}' created successfully." "INFO"
    } catch {
        Log-Message "Error creating restore point '${Description}': $_" "ERROR"
        exit 1
    }
}

# Main Execution Flow
Log-Message "=== Aurora Restore Point Script Execution Started ===" "INFO"

# Check for administrative privileges
if (-not (Test-Administrator)) {
    Log-Message "Script is not running as Administrator. Attempting to relaunch with elevated privileges..." "WARN"
    try {
        # Get the full path to the script
        $scriptPath = $MyInvocation.MyCommand.Definition
        if (-not $scriptPath) {
            throw "Cannot determine the script path. Please run the script from a .ps1 file."
        }

        # Prepare arguments
        $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""

        # Start elevated process
        Start-Process -FilePath "powershell.exe" -ArgumentList $arguments -Verb RunAs -WindowStyle Hidden
        Log-Message "Relaunched the script with administrative privileges. Exiting current process." "INFO"
        exit
    } catch {
        Log-Message "Failed to relaunch the script as Administrator: $_" "ERROR"
        exit 1
    }
} else {
    Log-Message "Script is running with Administrator privileges." "INFO"
}

# Function to check for an existing restore point with the same description within the last N hours
function Check-RecentRestorePoint {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Description,
        [Parameter(Mandatory=$false)]
        [int]$HoursAgo = 48
    )
    try {
        $cutoff = (Get-Date).AddHours(-$HoursAgo)
        $restorePoints = Get-WmiObject -Class SystemRestore -Namespace "root/default" -ErrorAction Stop
        if ($restorePoints) {
            foreach ($rp in $restorePoints) {
                $rpCreationTime = [Management.ManagementDateTimeConverter]::ToDateTime($rp.CreationTime)
                if ($rpCreationTime -ge $cutoff -and $rp.Description -eq $Description) {
                    return $true
                }
            }
        }
        return $false
    } catch {
        Log-Message "Error checking recent restore points: $($_.Exception.Message)" "WARN"
        return $false
    }
}

# Check if system protection is enabled on the specified drive
$protection = Get-WmiObject -Class SystemRestore -Namespace "root\default" | Where-Object { $_.Drive -eq $DriveLetter }

if ($protection -and $protection.IsEnabled) {
    Log-Message "System protection is already enabled on drive ${DriveLetter}." "INFO"
} else {
    Enable-SystemProtection -Drive $DriveLetter
}

# Check for recent restore point before creating a new one
if (Check-RecentRestorePoint -Description $RestorePointName) {
    Log-Message "Recent restore point '${RestorePointName}' already exists. Skipping creation." "INFO"
} else {
    # Create the restore point
    Create-RestorePoint -Description $RestorePointName -Type "MODIFY_SETTINGS"
}

Log-Message "=== Aurora Restore Point Script Execution Completed ===" "INFO"
