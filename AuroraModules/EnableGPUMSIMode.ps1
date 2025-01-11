# Check if running as Administrator, restart if not
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}

Get-CimInstance -ClassName Win32_VideoController | ForEach-Object {
    $path = "HKLM:\System\CurrentControlSet\Enum\$($_.PNPDeviceID)\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties"
    if (Test-Path $path) {
        Set-ItemProperty -Path $path -Name "MSISupported" -Value 1 -Type DWord
    }
}
