#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Windows Power Optimization Script for Performance

.DESCRIPTION
    This script optimizes Windows power settings for maximum performance and reduced latency.
    It creates a custom power scheme based on Ultimate Performance and applies optimized settings.

    Key features:
    - Creates custom "@IBRHUB Power Scheme" based on Ultimate Performance
    - Disables power saving features that can impact latency/performance
    - Optimizes USB, NVMe, and processor power management
    - Includes special handling for laptop systems
    
    The script focuses on:
    - Disabling storage device power saving
    - Disabling USB selective suspend
    - Optimizing processor performance settings
    - Disabling display power management
    
.NOTES
    Version: 1.0
    Author: IBRHUB - IBRAHIM
    Requirements: Must be run with Administrator privileges
    Warning: Will increase power usage and heat output. Use adequate cooling.

.EXAMPLE
    .\Power.ps1
    Runs the script with interactive prompts and warnings

.EXAMPLE
    .\Power.ps1 -Silent
    Runs the script without prompts or warnings

.LINK
    https://github.com/IBRAHUB
    https://docs.ibrhub.net/
#>

param (
    [switch]$Silent
)

# Check if running as Administrator, restart if not
if (!$Silent -and !([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process PowerShell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

if (!$Silent) {
    $isLaptop = (Get-CimInstance -Class Win32_ComputerSystem -Property PCSystemType).PCSystemType -eq 2
    if ($isLaptop) {
        Write-Host @"
WARNING: You are on a laptop, disabling power saving will cause faster battery drainage and increased heat output.
        If you use your laptop on battery, certain power saving features will enable, but not all.
        Generally, it's NOT recommended to run this script on laptops.`n
"@ -ForegroundColor Yellow
        Start-Sleep 2
    }

    Write-Host @"
This script optimizes Windows power settings to reduce latency and enhance performance.
It includes creating a custom power scheme, disabling unnecessary power-saving features,

Make sure to have sufficient cooling in place, as these optimizations may increase power usage and heat output.`n
"@ -ForegroundColor Cyan
    Pause
}

try {
    # Restore default power schemes first
    powercfg -restoredefaultschemes
    Start-Sleep -Seconds 1

    Write-Host "`nAdding power scheme..." -ForegroundColor Yellow
    
    # Check if Aurora power scheme exists
    if (!(powercfg /l | Select-String "GUID: 11111111-1111-1111-1111-111111111111" -Quiet)) {
        # Create new scheme based on Ultimate Performance
        $result = powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 11111111-1111-1111-1111-111111111111
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to create power scheme: $result"
        }
    }

    # Set Aurora scheme as active
    $result = powercfg /setactive 11111111-1111-1111-1111-111111111111
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to set power scheme as active: $result"
    }

    # Configure power settings
    $powerSettings = @(
        @{guid="0012ee47-9041-4b5d-9b77-535fba8b1442"; subguid="d3d55efd-c1ff-424e-9dc3-441be7833010"; value=0} # Secondary NVMe Idle Timeout
        @{guid="0012ee47-9041-4b5d-9b77-535fba8b1442"; subguid="d639518a-e56d-4345-8af2-b9f32fb26109"; value=0} # Primary NVMe Idle Timeout
        @{guid="0012ee47-9041-4b5d-9b77-535fba8b1442"; subguid="fc7372b6-ab2d-43ee-8797-15e9841f2cca"; value=0} # NVME NOPPME
        @{guid="2a737441-1930-4402-8d77-b2bebba308a3"; subguid="0853a681-27c8-4100-a2fd-82013e970683"; value=0} # Hub Selective Suspend Timeout
        @{guid="2a737441-1930-4402-8d77-b2bebba308a3"; subguid="48e6b7a6-50f5-4782-a5d4-53bb8f07e226"; value=0} # USB selective suspend
        @{guid="2a737441-1930-4402-8d77-b2bebba308a3"; subguid="d4e98f31-5ffe-4ce1-be31-1b38b384c009"; value=0} # USB 3 Link Power Management
        @{guid="54533251-82be-4824-96c1-47b60b740d00"; subguid="3b04d4fd-1cc7-4f23-ab1c-d1337819c4bb"; value=0} # Allow Throttle States
        @{guid="7516b95f-f776-4464-8c53-06167f40cc99"; subguid="17aaa29b-8b43-4b94-aafe-35f64daaf1ee"; value=0} # Dim display after
        @{guid="7516b95f-f776-4464-8c53-06167f40cc99"; subguid="3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e"; value=0} # Turn off display after
        @{guid="54533251-82be-4824-96c1-47b60b740d00"; subguid="4d2b0152-7d5c-498b-88e2-34345392a2c5"; value=200} # Processor performance check interval
    )

    foreach ($setting in $powerSettings) {
        $result = powercfg /setacvalueindex scheme_current $setting.guid $setting.subguid $setting.value
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to set power setting $($setting.guid): $result"
        }
    }

    # Rename the scheme
    $result = powercfg /changename scheme_current "@Aurora Power Scheme" "Power scheme optimized for optimal latency and performance."
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to rename power scheme: $result"
    }

    # Delete other power schemes
    $Output = powercfg /L
    $PowerPlan = @()
    foreach ($Line in $Output) {
        if ($Line -match ':') {
            $Parse = $Line -split ':'
            $Index = $Parse[1].Trim().IndexOf('(')
            if ($Index -gt 0) {
                $Guid = $Parse[1].Trim().Substring(0, $Index).Trim()
                if ($Guid -ne "11111111-1111-1111-1111-111111111111") {
                    $PowerPlan += $Guid
                }
            }
        }
    }

    foreach ($Plan in $PowerPlan) {
        $result = powercfg /delete $Plan
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Failed to delete power plan $Plan"
        }
    }

    Write-Host "Power optimization completed successfully" -ForegroundColor Green

} catch {
    Write-Error "An error occurred during power optimization: $_"
    exit 1
}