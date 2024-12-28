<#
.SYNOPSIS
    A dynamic script to run the latest version of Aurora from https://github.com/IBRHUB/Aurora.
.DESCRIPTION
    This script fetches and executes the latest Aurora script from the IBR Pride domain.
    It is designed for ease of use and always runs the latest version available online.
    Ensure you are running PowerShell with administrative privileges for full functionality.
#>

## powershell Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-WebRequest "https://github.com/IBRHUB/Aurora/releases/download/0.3/Aurora.cmd" -OutFile "$env:temp\Aurora.cmd"; Start-process $env:temp\Aurora.cmd


# 1. Check 3rd-party Antivirus
function Check3rdAV {
    $avList = Get-CimInstance -Namespace root\SecurityCenter2 -Class AntiVirusProduct |
        Where-Object { $_.displayName -notlike '*windows*' } |
        Select-Object -ExpandProperty displayName
    if ($avList) {
        Write-Host "3rd-party Antivirus might be blocking the script:" -ForegroundColor Yellow
        Write-Host " $($avList -join ', ')" -ForegroundColor Red
    }
}

# 2. Relaunch as Administrator if not already
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Script not running as Admin, re-launching..." -ForegroundColor Cyan
    Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSCommandPath`" $args" -Verb RunAs
    exit
}

# Ensure TLS1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 3. Attempt to download Aurora from multiple URLs
$url = 'https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/Aurora.cmd'

$AuroraContent = $null
foreach ($URL in $URLs) {
    try {
        $AuroraContent = Invoke-WebRequest -Uri $URL -UseBasicParsing -ErrorAction Stop
        if ($AuroraContent.Content) { break }
    } catch {}
}

if (-not $AuroraContent) {
    Check3rdAV
    Write-Host "Failed to retrieve Aurora from any available link, aborting!" -ForegroundColor Red
    Write-Host "Help - https://github.com/IBRHUB/Aurora/troubleshoot.md" -ForegroundColor Cyan
    return
}

# 4.  Verify script integrity
$releaseHash = "<13F97E3AFA79519D17FF46F8BB17014262CF41F3BE454B76EFECD59A8C05F19B>" # e.g. 1234ABC... (NO dashes, uppercase)
if ($releaseHash -and $releaseHash -ne "<13F97E3AFA79519D17FF46F8BB17014262CF41F3BE454B76EFECD59A8C05F19B>") {
    $downloadedHash = [BitConverter]::ToString(
        [Security.Cryptography.SHA256]::Create().ComputeHash(
            [System.Text.Encoding]::UTF8.GetBytes($AuroraContent.Content)
        )
    ) -replace '-'
    if ($downloadedHash -ne $releaseHash) {
        Write-Host "Hash mismatch! Expected $releaseHash but got $downloadedHash" -ForegroundColor Red
        Write-Host "Aborting..." -ForegroundColor Yellow
        return
    }
}

# 5. Save Aurora as a .cmd, run, then remove it
$tempCmd = Join-Path $env:Temp "Aurora_$([guid]::NewGuid()).cmd"
Set-Content -Path $tempCmd -Value $AuroraContent.Content
Write-Host "Running Aurora..." -ForegroundColor Green

Start-Process -FilePath $tempCmd -Wait

Remove-Item $tempCmd -ErrorAction SilentlyContinue
Write-Host "Done." -ForegroundColor Green

