<#
.SYNOPSIS
    A dynamic script to run the latest version of Aurora from https://github.com/IBRHUB/Aurora.
.DESCRIPTION
    This script fetches and executes the latest Aurora script from the IBR Pride domain.
    It is designed for ease of use and always runs the latest version available online.
    Ensure you are running PowerShell with administrative privileges for full functionality.
#>

# Set execution policy to bypass for the current process
# Set execution policy to bypass for the current process

try {
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
} catch {
    Write-Host "Failed to set execution policy: $_" -ForegroundColor Red
    exit 1
}

# Ensure TLS 1.2 is enabled for secure connections
try {
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
} catch {
    Write-Host "Failed to set SecurityProtocol: $_" -ForegroundColor Red
    exit 1
}

# Define file paths
$tempUACBypass = "$env:TEMP\\UACbypasses.bat"
$tempAuroraCmd = "$env:TEMP\\Aurora.cmd"

# Download UAC bypass script
try {
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/UACbypasses.bat' -OutFile $tempUACBypass
    Write-Host "Downloaded UAC bypass script to $tempUACBypass" -ForegroundColor Green
} catch {
    Write-Host "Failed to download UAC bypass script: $_" -ForegroundColor Red
    exit 1
}

# Download Aurora script
try {
    Invoke-WebRequest -Uri 'https://github.com/IBRHUB/Aurora/releases/download/0.3/Aurora.cmd' -OutFile $tempAuroraCmd
    Write-Host "Downloaded Aurora script to $tempAuroraCmd" -ForegroundColor Green
} catch {
    Write-Host "Failed to download Aurora script: $_" -ForegroundColor Red
    exit 1
}

# Execute the downloaded scripts
try {
    Start-Process -FilePath 'cmd.exe' -ArgumentList "/c `"$tempUACBypass cmd.exe /c `"$tempAuroraCmd`"`" -NoNewWindow -Wait
    Write-Host "Scripts executed successfully." -ForegroundColor Green
} catch {
    Write-Host "Failed to execute scripts: $_" -ForegroundColor Red
    exit 1
}

