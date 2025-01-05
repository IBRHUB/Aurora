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
    Author: IBRHUB
    Requirements: Must be run with Administrator privileges
    Warning: Will increase power usage and heat output. Use adequate cooling.

.EXAMPLE
    .\Power.ps1
    Runs the script with interactive prompts and warnings

.EXAMPLE
    .\Power.ps1 -Silent
    Runs the script without prompts or warnings
#>

param (
    [switch]$Silent
)

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
This script will disable many power saving features in Windows for reduced latency and increased performance.
Ensure that you have adequate cooling.`n
"@ -ForegroundColor Cyan
    Pause
}

Write-Host "`nAdding power scheme..." -ForegroundColor Yellow
# Duplicate Ultimate Performance power scheme, customize it and make it the Atlas power scheme
if (!(powercfg /l | Select-String "GUID: 11111111-1111-1111-1111-111111111111" -Quiet)) {
    powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 11111111-1111-1111-1111-111111111111 > $null
}
powercfg /setactive 11111111-1111-1111-1111-111111111111
powercfg /changename scheme_current "@Aurora Power Scheme" "Power scheme optimized for optimal latency and performance."
## Secondary NVMe Idle Timeout - 0 miliseconds
powercfg /setacvalueindex scheme_current 0012ee47-9041-4b5d-9b77-535fba8b1442 d3d55efd-c1ff-424e-9dc3-441be7833010 0
## Primary NVMe Idle Timeout - 0 miliseconds
powercfg /setacvalueindex scheme_current 0012ee47-9041-4b5d-9b77-535fba8b1442 d639518a-e56d-4345-8af2-b9f32fb26109 0
## NVME NOPPME - Off
powercfg /setacvalueindex scheme_current 0012ee47-9041-4b5d-9b77-535fba8b1442 fc7372b6-ab2d-43ee-8797-15e9841f2cca 0
## Hub Selective Suspend Timeout - 0 miliseconds
powercfg /setacvalueindex scheme_current 2a737441-1930-4402-8d77-b2bebba308a3 0853a681-27c8-4100-a2fd-82013e970683 0
## USB selective suspend - Disabled
powercfg /setacvalueindex scheme_current 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
## USB 3 Link Power Mangement - Off
powercfg /setacvalueindex scheme_current 2a737441-1930-4402-8d77-b2bebba308a3 d4e98f31-5ffe-4ce1-be31-1b38b384c009 0
## Allow Throttle States - Off
powercfg /setacvalueindex scheme_current 54533251-82be-4824-96c1-47b60b740d00 3b04d4fd-1cc7-4f23-ab1c-d1337819c4bb 0
## Dim display after - 0 seconds
powercfg /setacvalueindex scheme_current 7516b95f-f776-4464-8c53-06167f40cc99 17aaa29b-8b43-4b94-aafe-35f64daaf1ee 0
## Turn off display after - 0 seconds
powercfg /setacvalueindex scheme_current 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 0
## Processor performance time check interval - 200 miliseconds
## Reduces DPCs, can be set all the way to 5000ms for statically clocked systems
powercfg /setacvalueindex scheme_current 54533251-82be-4824-96c1-47b60b740d00 4d2b0152-7d5c-498b-88e2-34345392a2c5 200
# Set the active scheme as the current scheme
powercfg /setactive scheme_current


