# Check if running as Administrator, restart if not
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}

# Disable StorPort Power Management
Get-ChildItem "HKLM:\System\CurrentControlSet\Enum" -Recurse | Where-Object { $_.Name -like "*StorPort*" } | ForEach-Object {
    Set-ItemProperty -Path $_.PSPath -Name "EnableIdlePowerManagement" -Value 0 -Type DWord
}

# Disable USB Power Management
Get-PnpDevice | Where-Object { $_.InstanceId -like "USB\VID*" } | ForEach-Object {
    $path = "HKLM:\System\CurrentControlSet\Enum\$($_.InstanceId)\Device Parameters"
    if (Test-Path $path) {
        Set-ItemProperty -Path $path -Name "EnhancedPowerManagementEnabled" -Value 0 -Type DWord
        Set-ItemProperty -Path $path -Name "AllowIdleIrpInD3" -Value 0 -Type DWord
        Set-ItemProperty -Path $path -Name "EnableSelectiveSuspend" -Value 0 -Type DWord
        Set-ItemProperty -Path $path -Name "DeviceSelectiveSuspended" -Value 0 -Type DWord
        Set-ItemProperty -Path $path -Name "SelectiveSuspendEnabled" -Value 0 -Type DWord
        Set-ItemProperty -Path $path -Name "SelectiveSuspendOn" -Value 0 -Type DWord
        Set-ItemProperty -Path $path -Name "D3ColdSupported" -Value 0 -Type DWord
    }
}
