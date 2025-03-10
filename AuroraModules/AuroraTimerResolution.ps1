<#
.LINK
    https://github.com/IBRHUB
    https://docs.ibrhub.net/
    https://ibrpride.com
#>
# Check if running as Administrator, restart if not
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}

# Check Windows version
$buildNumber = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentBuildNumber
if ($buildNumber -lt 22000) {
    Write-Error "This script is designed for Windows 11 only. Exiting..."
	sleep 5
    exit 1
}
cls
Write-Host "Installing: Aurora Timer Resolution Service . . ."

# Get current script directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

# Verify source file exists
if (-not (Test-Path "$scriptPath\AuroraTimerResolution.cs")) {
    Write-Error "AuroraTimerResolution.cs not found in script directory"
    exit 1
}

# Copy .cs file from script directory
try {
    Copy-Item "$scriptPath\AuroraTimerResolution.cs" -Destination "C:\Windows\AuroraTimerResolution.cs" -Force
} catch {
    Write-Error "Failed to copy source file: $_"
    exit 1
}

# Verify compiler exists
$cscPath = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if (-not (Test-Path $cscPath)) {
    Write-Error "C# compiler not found at $cscPath"
    exit 1
}

# Compile and create service
$compileArgs = @(
    "-out:C:\Windows\AuroraTimerResolution.exe",
    "C:\Windows\AuroraTimerResolution.cs",
    "-reference:System.ServiceProcess.dll",
    "-win32icon:$scriptPath\AuroraAvatar.ico"
)
try {
    Start-Process -Wait $cscPath -ArgumentList $compileArgs -WindowStyle Hidden
} catch {
    Write-Error "Failed to compile service: $_"
    exit 1
}

# Verify compilation succeeded
if (-not (Test-Path "C:\Windows\AuroraTimerResolution.exe")) {
    Write-Error "Service executable not created"
    exit 1
}

# Delete source file
Remove-Item "C:\Windows\AuroraTimerResolution.cs" -ErrorAction SilentlyContinue

# Define service name
$serviceName = "AuroraTimerResolution"

# Remove existing service if it exists
if (Get-Service $serviceName -ErrorAction SilentlyContinue) {
    Stop-Service $serviceName -Force -ErrorAction SilentlyContinue
    sc.exe delete $serviceName | Out-Null
}

# Install and start service
try {
    New-Service -Name $serviceName -BinaryPathName "C:\Windows\AuroraTimerResolution.exe" -StartupType Automatic -DisplayName "Aurora Timer Resolution"
    Start-Service $serviceName
} catch {
    Write-Error "Failed to create or start service: $_"
    exit 1
}

# Verify service is running
if ((Get-Service $serviceName).Status -ne 'Running') {
    Write-Error "Service failed to start"
    exit 1
}

# Configure timer resolution registry
try {
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "GlobalTimerResolutionRequests" /t REG_DWORD /d "1" /f | Out-Null
} catch {
    Write-Error "Failed to set registry key: $_"
    exit 1
}

# Start Task Manager and attempt to select Aurora service
try {
    Start-Process taskmgr.exe
    Start-Sleep -Seconds 2 # Wait for Task Manager to load
    
    # Note: SendKeys is unreliable and may not work consistently
    # This is left as a best-effort attempt
    $shell = New-Object -ComObject "WScript.Shell" 
    $shell.SendKeys("^") # Ctrl key to switch to Details tab
    $shell.SendKeys("{TAB}") # Tab to services column
    $shell.SendKeys("aurora") # Type to filter to Aurora service
} catch {
    Write-Warning "Could not automate Task Manager selection. Please check the service manually."
}

Write-Host "Aurora Timer Resolution Service installed and started successfully."
exit
