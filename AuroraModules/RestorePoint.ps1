<#
.SYNOPSIS
Function to create a system restore point.

.DESCRIPTION
This function checks if it is running with administrative privileges and creates a system restore point with the specified name.
It includes a -Silent parameter to suppress output messages.

.NOTES
Author: Ibrahim
Website: https://ibrpride.com
Script Version: 1.5
Last Updated: April 2024
#>

function New-SystemRestorePoint {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$RestoreName,

        [Parameter()]
        [switch]$Silent
    )

    # Function to check if the script is running as an administrator
    function Check-Admin {
        if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            try {
                # Relaunch the script as administrator
                $scriptPath = $MyInvocation.MyCommand.Definition
                $arguments = '-NoProfile -ExecutionPolicy Bypass -File "{0}" -RestoreName "{1}"' -f $scriptPath, $RestoreName
                if ($Silent) {
                    $arguments += ' -Silent'
                }
                Start-Process powershell.exe -ArgumentList $arguments -Verb RunAs
                if (-not $Silent) {
                    Write-Host "The script has been relaunched with administrator privileges. Please try again after the restore point is created." -ForegroundColor Yellow
                }
                exit
            } catch {
                if (-not $Silent) {
                    Write-Host "Failed to relaunch the script as administrator: $_" -ForegroundColor Red
                }
                exit 1
            }
        }
    }

    # Function to create a restore point
    function Create-RestorePoint {
        param (
            [Parameter(Mandatory = $true)]
            [string]$Name,

            [switch]$Silent
        )
        if (-not $Silent) {
            Write-Host "Creating Restore Point with name: $Name ..." -ForegroundColor Green
        }

        # Enable system protection for C: drive
        try {
            Enable-ComputerRestore -Drive "C:\"
            if (-not $Silent) {
                Write-Host "System protection enabled successfully for drive C:" -ForegroundColor Green
            }
        } catch {
            if (-not $Silent) {
                Write-Host "Failed to enable system protection: $_" -ForegroundColor Red
            }
            return
        }

        # Create the restore point
        try {
            Checkpoint-Computer -Description $Name -RestorePointType "MODIFY_SETTINGS"
            if (-not $Silent) {
                Write-Host "Restore point created successfully." -ForegroundColor Green
            }
        } catch {
            if (-not $Silent) {
                Write-Host "An error occurred while creating the restore point: $_" -ForegroundColor Red
            }
        }
    }

    # Check for administrative privileges
    Check-Admin

    # Create the restore point
    Create-RestorePoint -Name $RestoreName -Silent:$Silent
}
