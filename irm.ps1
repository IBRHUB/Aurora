<#
.SYNOPSIS
    Script to run the latest Aurora version 

.DESCRIPTION
    Downloads and runs Aurora tool 
    
.NOTES
    Requirements:
    - Windows 10/11
    - Admin privileges
    - Internet connection

.EXAMPLE
    .\irm.ps1
    Downloads and runs latest Aurora release

.LINK
    https://github.com/IBRHUB/Aurora
#>


function Set-ConsoleBackground {
    param (
        [string]$BackgroundColor = "Black",
        [string]$ProgressBackgroundColor = "Black",
        [string]$ProgressForegroundColor = "White"
    )
    
    try {
        $Host.UI.RawUI.BackgroundColor = $BackgroundColor
        $Host.PrivateData.ProgressBackgroundColor = $ProgressBackgroundColor
        $Host.PrivateData.ProgressForegroundColor = $ProgressForegroundColor
        Clear-Host

        Write-Host "Console background and progress colors updated successfully." -ForegroundColor Green
    } catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Set-ConsoleBackground

Clear-Host

# 1) Check for any 3rd-party Antivirus and System Type
# Purpose: Detects antivirus software that might interfere with Aurora's operation
Clear-Host
function Check3rdAV {
    $avList = Get-CimInstance -Namespace root\SecurityCenter2 -Class AntiVirusProduct |
        Where-Object { $_.displayName -notlike '*windows*' } |
        Select-Object -ExpandProperty displayName
    if ($avList) {
        Write-Host "3rd-party Antivirus might be blocking the script:" -ForegroundColor Yellow
        Write-Host " $($avList -join ', ')" -ForegroundColor Red
    }
}
Write-Host "`n"
# Purpose: Identifies if running on laptop or desktop for optimized settings
$systemType = (Get-CimInstance -ClassName Win32_ComputerSystem).PCSystemType
$isLaptop = $systemType -eq 2
$isDesktop = $systemType -eq 1

Write-Host "Detected system type: $(if ($isLaptop) { 'Laptop' } else { 'Desktop PC' })" -ForegroundColor Cyan

# 2) Purpose: Ensures script runs with admin rights for system modifications
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Script not running as Admin, re-launching..." -ForegroundColor Cyan
    try {
        Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSCommandPath`" $args" -Verb RunAs
    } catch {
        Write-Host "Failed to relaunch as administrator. Please run this script as administrator manually." -ForegroundColor Red
        pause
        exit
    }
    exit
}

# Purpose: Enables secure HTTPS communications and bypasses certificate validation
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    # Bypass certificate validation
    if (-not ([System.Management.Automation.PSTypeName]'ServerCertificateValidationCallback').Type) {
        $certCallback = @"
            using System;
            using System.Net;
            using System.Net.Security;
            using System.Security.Cryptography.X509Certificates;
            public class ServerCertificateValidationCallback {
                public static void Ignore() {
                    ServicePointManager.ServerCertificateValidationCallback += 
                        delegate (
                            Object obj, 
                            X509Certificate certificate, 
                            X509Chain chain, 
                            SslPolicyErrors errors
                        ) { return true; };
                }
            }
"@
        Add-Type $certCallback
    }
    [ServerCertificateValidationCallback]::Ignore()
} catch {
    Write-Host "Failed to set TLS 1.2 and certificate bypass. This might cause download issues." -ForegroundColor Yellow
}

# 3) Purpose: Sets up temporary storage location for Aurora
$AuroraPath = Join-Path $env:Temp "Aurora.cmd"

# Purpose: Provides fallback download sources if primary fails
$urls = @(
    'https://github.com/IBRHUB/Aurora/releases/download/Aurora/Aurora.cmd'
)

$downloadSuccess = $false

# Purpose: Attempts download from multiple sources with fallback methods and retry logic
foreach ($url in $urls) {
    Write-Host "Attempting download from: $url" -ForegroundColor Cyan
    $retryCount = 0
    $maxRetries = 3
    
    while ($retryCount -lt $maxRetries) {
        try {
            # Try direct download with custom headers
            $webClient = New-Object System.Net.WebClient
            $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
            $webClient.Headers.Add("Accept", "*/*")
            $webClient.DownloadFile($url, $AuroraPath)
            $downloadSuccess = $true
            Write-Host "Successfully downloaded from $url" -ForegroundColor Green
            break
        } catch {
            try {
                # Fallback to Invoke-WebRequest with custom parameters
                $params = @{
                    Uri = $url
                    OutFile = $AuroraPath
                    UseBasicParsing = $true
                    Headers = @{
                        "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
                    }
                    ErrorAction = "Stop"
                }
                Invoke-WebRequest @params
                $downloadSuccess = $true
                Write-Host "Successfully downloaded using WebRequest from $url" -ForegroundColor Green
                break
            } catch {
                $retryCount++
                if ($retryCount -lt $maxRetries) {
                    Write-Host "Attempt $retryCount failed, retrying in 5 seconds..." -ForegroundColor Yellow
                    Start-Sleep -Seconds 5
                } else {
                    Write-Host "Failed to download from $url after $maxRetries attempts, trying next source..." -ForegroundColor Yellow
                    break
                }
            }
        }
    }
    
    if ($downloadSuccess) { break }
}
Write-Host "`n"
# Purpose: Provides troubleshooting steps if download fails
if (-not $downloadSuccess) {
    Check3rdAV
    Write-Host "Failed to download Aurora from all sources!" -ForegroundColor Red
    Write-Host "Please try one of these alternatives:" -ForegroundColor Yellow
    Write-Host "1. Visit https://github.com/IBRHUB/Aurora/releases/download/0.7/Aurora.cmd and download manually" -ForegroundColor Cyan
    Write-Host "2. Check your internet connection and try again" -ForegroundColor Cyan
    Write-Host "3. Help - https://docs.ibrhub.net/ar/troubleshooting/" -ForegroundColor Cyan
    Write-Host "4. Try using a VPN or different network connection" -ForegroundColor Cyan
    Write-Host "5. Check if your firewall is blocking the connection" -ForegroundColor Cyan
    pause
    return
}

# Purpose: Validates downloaded file exists and isn't empty
if (-not (Test-Path $AuroraPath) -or (Get-Item $AuroraPath).Length -eq 0) {
    Check3rdAV
    Write-Host "Aurora.cmd not found or empty after download, aborting!" -ForegroundColor Red
    pause
    return
}
Write-Host "`n"
Clear-Host

Write-Host @"
                         @@@%    %@@-    @@@   @@@@@@@@+    -@@@@@@@+   -@@@@@@@@-     @@@@                             
                        @@@@@=  .@@@@   -@@@- =@@@   .@@@  @@@=   .@@@  @@@@   @@@@   *@@@@@                            
                       #@@@@@@  +@@@@   +@.@+ #@ @@@@@@@@ @@%@@@@@@@@@@ @@@@@@@@@@@   @@@@@@%                           
                      .@@@@@ @@ +@@@@   +@ @+ #@*@@@@@@@@ @@@@.   .@@@@ @@@@@@@@@@@  @@ @@@@@.                          
                      @@*@@@@@@@-@@@@   @@ @= #@=@  @@@@% @@@@.    @@@@ @@ @ +@@@@@ @@@@@@@ @@                          
"@ -ForegroundColor Cyan
Write-Host @"
                     @@=@@ @@@@@-@@+@@@@@@@@  *@#@@@@@@@* +@ @@@@@@@=@@ @@@@@@@@@@-%@@@@% @@@@@                         
                     @@@@   @@@@@*@@# -- @@+ -+@%@+=-# @@*=.= -##*..@@  @@@@ .@@@@*@@@@@  =@@@@                         
"@ -ForegroundColor Magenta
Write-Host @"
                     @@@*    @@@=  @@@@@@@ =*#*+ *@@@# .%@@#  #@@@@@-    @@*   @@@-*@@@    @@@@                         
"@ -ForegroundColor Yellow
Write-Host @"
                                          ...        .=*%@@@@@@@@@%*=--                                                 
                                 .-==+*%@@@@@@@@@@@@@@@@@@@@@@@@@@@#**+=--.                                             
                                 .=+#%@@@@@@@@@@@@@@@%*-                                                                
"@ -ForegroundColor DarkCyan
Write-Host "`n"

# 5) Purpose: Executes Aurora and cleans up temporary files
Write-Host "Preparing system for Aurora..." -ForegroundColor Yellow

# Remove and restore CodePage registry values before running Aurora
try {
    Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage" -Name "OEMCP" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage" -Name "ACP" -ErrorAction SilentlyContinue
    
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage" -Name "OEMCP" -Value "437" -PropertyType String -Force
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage" -Name "ACP" -Value "1252" -PropertyType String -Force
} catch {
    Write-Host "Warning: Could not update CodePage settings. Continuing anyway..." -ForegroundColor Yellow
}

Write-Host "Aurora is Running ..." -ForegroundColor Green
try {
    Start-Process "conhost.exe" -ArgumentList "cmd /c $AuroraPath" -Wait -Verb RunAs 
    Write-Host "Aurora completed successfully." -ForegroundColor Green
} catch {
    Write-Host "Error running Aurora: $($_.Exception.Message)" -ForegroundColor Red
    pause
}

Remove-Item $AuroraPath -ErrorAction SilentlyContinue
Write-Host "Thank you! Don't forget to rate us on our Discord server." -ForegroundColor Green
