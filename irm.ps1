<#
.SYNOPSIS
    A dynamic script to run the latest version of Aurora from https://github.com/IBRHUB/Aurora.
.DESCRIPTION
    This script fetches and executes the latest Aurora script from the IBR Pride domain.
    It is designed for ease of use and always runs the latest version available online.
    Ensure you are running PowerShell with administrative privileges for full functionality.
#>

## powershell Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-WebRequest "https://github.com/IBRHUB/Aurora/releases/download/0.3/Aurora.cmd" -OutFile "$env:temp\Aurora.cmd"; Start-process $env:temp\Aurora.cmd


# 1) Check for any 3rd-party Antivirus
function Check3rdAV {
    $avList = Get-CimInstance -Namespace root\SecurityCenter2 -Class AntiVirusProduct |
        Where-Object { $_.displayName -notlike '*windows*' } |
        Select-Object -ExpandProperty displayName
    if ($avList) {
        Write-Host "3rd-party Antivirus might be blocking the script:" -ForegroundColor Yellow
        Write-Host " $($avList -join ', ')" -ForegroundColor Red
    }
}

# 2) Relaunch as Administrator if not already
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Script not running as Admin, re-launching..." -ForegroundColor Cyan
    Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSCommandPath`" $args" -Verb RunAs
    exit
}

# Ensure TLS1.2 for secure connections
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 3) Download Aurora to the system temp folder
$AuroraPath = Join-Path $env:Temp "Aurora.cmd"
$url        = 'https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/Aurora.cmd'

try {
    Invoke-WebRequest -Uri $url -UseBasicParsing -OutFile $AuroraPath -ErrorAction Stop
} catch {
    Check3rdAV
    Write-Host "Failed to download Aurora from $url, aborting!" -ForegroundColor Red
    Write-Host "Help - https://github.com/IBRHUB/Aurora/troubleshoot.md" -ForegroundColor Cyan
    return
}

# Confirm the file actually exists
if (-not (Test-Path $AuroraPath)) {
    Check3rdAV
    Write-Host "Aurora.cmd not found after download, aborting!" -ForegroundColor Red
    return
}

# 4) Verify the downloaded file's SHA-256 hash
#    This is the hash you provided:
$releaseHash = 'E22276F6FB7C358D395DA5BD663F7D7ACEE7295059800B1769A8D4773B75188E'

$fileBytes     = [System.IO.File]::ReadAllBytes($AuroraPath)
$downloadedHash = [BitConverter]::ToString(
    [Security.Cryptography.SHA256]::Create().ComputeHash($fileBytes)
) -replace '-'

if ($downloadedHash -ne $releaseHash) {
    Write-Host "Hash mismatch! Expected $releaseHash but got $downloadedHash" -ForegroundColor Red
    Write-Host "Aborting..." -ForegroundColor Yellow
    Remove-Item $AuroraPath -ErrorAction SilentlyContinue
    return
}

# 5) Run Aurora and then remove the file
Write-Host "Running Aurora..." -ForegroundColor Green
Start-Process -FilePath $AuroraPath -Wait

# Remove-Item $AuroraPath -ErrorAction SilentlyContinue
Write-Host "Done." -ForegroundColor Green

