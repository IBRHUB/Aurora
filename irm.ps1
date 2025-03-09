<#
.SYNOPSIS
    Aurora - Modern Windows Performance Tool Installer
.DESCRIPTION
    Downloads and runs the latest Aurora optimization tool
.NOTES
    Version: 2.0
    Requirements: Windows 10/11, Admin privileges, Internet connection
.LINK
    https://github.com/IBRHUB/Aurora
#>

[CmdletBinding()]
param (
    [Parameter(HelpMessage = "Run script in silent mode with minimal output")]
    [switch]$Silent,
    
    [Parameter(HelpMessage = "Skip Winfetch system information display")]
    [switch]$NoWinfetch,
    
    [Parameter(HelpMessage = "Skip system restore point creation")]
    [switch]$NoRestore,
    
    [Parameter(HelpMessage = "Create a detailed report of operations")]
    [switch]$Report,
    
    [Parameter(HelpMessage = "Check for script updates")]
    [switch]$CheckUpdate,
    
    [Parameter(HelpMessage = "Path to custom configuration file")]
    [string]$ConfigFile
)

#region Configuration
$Global:Config = @{
    Colors = @{
        Primary   = "Cyan"      # Main UI elements
        Secondary = "Magenta"   # Highlight elements
        Success   = "Green"     # Success messages
        Warning   = "Yellow"    # Warning messages
        Error     = "Red"       # Error messages
        Accent    = "White"     # Accent text
    }
    Paths = @{
        TempFile = (Join-Path $env:TEMP "Aurora.cmd")
        WinfetchModule = (Join-Path $env:TEMP "winfetch.psm1")
        ReportFile = (Join-Path $env:TEMP "Aurora_Report_$(Get-Date -Format 'yyyyMMdd_HHmmss').log")
        ConfigFile = if ($ConfigFile) { $ConfigFile } else { (Join-Path $env:LOCALAPPDATA "Aurora\settings.json") }
    }
    URLs = @{
        Aurora = 'https://github.com/IBRHUB/Aurora/releases/download/Aurora/AuroraOneClick.cmd'
        Winfetch = 'https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/winfetch.psm1'
        ScriptUpdate = 'https://raw.githubusercontent.com/IBRHUB/Aurora/main/version.json'
    }
    Version = "2.1"
    RetrySettings = @{
        MaxAttempts = 3
        DelaySeconds = 5
    }
    Flags = @{
        Silent = $Silent.IsPresent
        NoWinfetch = $NoWinfetch.IsPresent
        NoRestore = $NoRestore.IsPresent
        GenerateReport = $Report.IsPresent
        CheckUpdate = $True  # Always check for updates unless in silent mode
    }
    Report = @{
        Lines = [System.Collections.ArrayList]@()
    }
}

# If in silent mode, disable certain features
if ($Silent) {
    $Config.Flags.NoWinfetch = $true
    $Config.Flags.CheckUpdate = $false
}
#endregion

#region Helper Functions
function Write-StatusMessage {
    param (
        [string]$Message, 
        [string]$Color = $Config.Colors.Primary,
        [switch]$NoNewLine,
        [switch]$LogOnly
    )
    
    # Add to report log
    if ($Config.Flags.GenerateReport) {
        $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        $logMessage = "[$timestamp] $Message"
        $null = $Config.Report.Lines.Add($logMessage)
    }
    
    # Display to console if not log-only and not in silent mode
    if (-not $LogOnly -and (-not $Config.Flags.Silent -or $Message.Contains("Error") -or $Message.Contains("Failed"))) {
        if ($NoNewLine) {
            Write-Host $Message -ForegroundColor $Color -NoNewline
        } else {
            Write-Host $Message -ForegroundColor $Color
        }
    }
}

function Write-ProgressBar {
    param (
        [string]$Activity,
        [int]$PercentComplete,
        [string]$Status = "Working..."
    )
    
    if (-not $Config.Flags.Silent) {
        # Calculate bar width based on console width
        try {
            $consoleWidth = $Host.UI.RawUI.WindowSize.Width
            $barWidth = [Math]::Max(20, $consoleWidth - 40)
        } catch {
            $barWidth = 50 # Default if can't get console width
        }
        
        $completedWidth = [Math]::Floor($barWidth * ($PercentComplete / 100))
        $remainingWidth = $barWidth - $completedWidth
        
        # Create progress bar
        $progressBar = "[" + ("=" * $completedWidth) + (" " * $remainingWidth) + "]"
        
        # Clear line and write progress (fixing the variable interpolation issue)
        Write-Host "`r                                                                   " -NoNewline
        Write-Host "`r" -NoNewline
        Write-Host "$Activity`: $progressBar $PercentComplete% - $Status" -NoNewline
        
        # If complete, add new line
        if ($PercentComplete -eq 100) {
            Write-Host ""
        }
    }
}

function Initialize-Console {
    $Host.UI.RawUI.BackgroundColor = "Black"
    $Host.PrivateData.ProgressBackgroundColor = "Black"
    $Host.PrivateData.ProgressForegroundColor = "White"
    Clear-Host
}

function Test-AdminPrivileges {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal $identity
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Start-ElevatedSession {
    try {
        # Build command line including all original parameters
        $paramString = ""
        if ($Silent) { $paramString += " -Silent" }
        if ($NoWinfetch) { $paramString += " -NoWinfetch" }
        if ($NoRestore) { $paramString += " -NoRestore" }
        if ($Report) { $paramString += " -Report" }
        if ($CheckUpdate) { $paramString += " -CheckUpdate" }
        if ($ConfigFile) { $paramString += " -ConfigFile `"$ConfigFile`"" }
        
        Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSCommandPath`"$paramString" -Verb RunAs
        exit
    } catch {
        Write-StatusMessage "Failed to launch with administrator privileges. Please run manually as administrator." $Config.Colors.Error
        pause
        exit
    }
}

function Initialize-SecureConnection {
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        if (-not ([System.Management.Automation.PSTypeName]'ServerCertificateValidationCallback').Type) {
            $certCallback = @"
                using System;
                using System.Net;
                using System.Net.Security;
                using System.Security.Cryptography.X509Certificates;
                public class ServerCertificateValidationCallback {
                    public static void Ignore() {
                        ServicePointManager.ServerCertificateValidationCallback += 
                            delegate (Object obj, X509Certificate certificate, X509Chain chain, SslPolicyErrors errors) { 
                                return true; 
                            };
                    }
                }
"@
            Add-Type $certCallback
        }
        [ServerCertificateValidationCallback]::Ignore()
    } catch {
        Write-StatusMessage "Warning: Could not configure TLS 1.2." $Config.Colors.Warning
    }
}

function Test-InternetConnection {
    $testUrls = @(
        "https://www.google.com",
        "https://www.microsoft.com",
        "https://github.com"
    )
    
    Write-StatusMessage "Checking internet connection..." -NoNewLine
    
    foreach ($url in $testUrls) {
        try {
            $request = [System.Net.WebRequest]::Create($url)
            $request.Timeout = 5000 # 5 seconds timeout
            $response = $request.GetResponse()
            $response.Close()
            Write-StatusMessage " Connected" $Config.Colors.Success
            return $true
        } catch {
            # Try next URL
            continue
        }
    }
    
    Write-StatusMessage " Failed" $Config.Colors.Error
    Write-StatusMessage "No internet connection available. Please check your network settings." $Config.Colors.Error
    return $false
}

function Get-SystemType {
    $systemTypeCode = (Get-CimInstance -ClassName Win32_ComputerSystem).PCSystemType
    switch ($systemTypeCode) {
        2 { return "Laptop" }
        1 { return "Desktop PC" }
        default { return "Unknown" }
    }
}

function Get-ThirdPartyAntivirus {
    return Get-CimInstance -Namespace root\SecurityCenter2 -Class AntiVirusProduct | 
        Where-Object { $_.displayName -notlike '*windows*' } |
        Select-Object -ExpandProperty displayName
}

function Reset-CodePageSettings {
    try {
        # Remove existing CodePage registry values
        Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage" -Name "OEMCP" -ErrorAction SilentlyContinue >$null
        Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage" -Name "ACP" -ErrorAction SilentlyContinue >$null
        
        # Restore default CodePage values
        New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage" -Name "OEMCP" -Value "437" -PropertyType String -Force >$null
        New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage" -Name "ACP" -Value "1252" -PropertyType String -Force >$null
        
        # Enable virtual terminal processing for ANSI color support
        New-ItemProperty -Path "HKCU:\CONSOLE" -Name "VirtualTerminalLevel" -Value 1 -PropertyType DWord -Force >$null
    } catch {
        Write-StatusMessage "Warning: Could not update CodePage settings." $Config.Colors.Warning
    }
}

function Create-SystemRestorePoint {
    if ($Config.Flags.NoRestore) {
        Write-StatusMessage "System restore point creation skipped (NoRestore flag)" $Config.Colors.Warning -LogOnly
        return
    }
    
    Write-StatusMessage "Creating system restore point..." -NoNewLine
    
    try {
        # Enable System Restore if needed
        $null = Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
        
        # Create restore point
        $description = "Aurora Installation - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
        $null = Checkpoint-Computer -Description $description -RestorePointType "APPLICATION_INSTALL" -ErrorAction Stop
        
        return $true
    } catch {
        Write-StatusMessage " Failed" $Config.Colors.Warning
        Write-StatusMessage "Could not create system restore point: $($_.Exception.Message)" $Config.Colors.Warning
        return $false
    }
}

function Save-ReportToFile {
    if (-not $Config.Flags.GenerateReport -or $Config.Report.Lines.Count -eq 0) {
        return
    }
    
    try {
        $reportContent = $Config.Report.Lines -join [Environment]::NewLine
        
        # Add summary at the end
        $reportContent += [Environment]::NewLine + [Environment]::NewLine
        $reportContent += "--- Aurora Execution Summary ---" + [Environment]::NewLine
        $reportContent += "Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" + [Environment]::NewLine
        $reportContent += "Script Version: $($Config.Version)" + [Environment]::NewLine
        $reportContent += "System Type: $(Get-SystemType)" + [Environment]::NewLine
        
        # Save to file
        Set-Content -Path $Config.Paths.ReportFile -Value $reportContent -Force
        
        Write-StatusMessage "Report saved to: $($Config.Paths.ReportFile)" $Config.Colors.Success
    } catch {
        Write-StatusMessage "Failed to save report: $($_.Exception.Message)" $Config.Colors.Warning
    }
}

function Load-CustomConfiguration {
    if (-not $ConfigFile -or -not (Test-Path $ConfigFile)) {
        # If no config file specified or doesn't exist, use default settings
        return
    }
    
    try {
        Write-StatusMessage "Loading configuration from: $ConfigFile" -NoNewLine
        
        # Read and parse JSON config
        $customConfig = Get-Content -Path $ConfigFile -Raw | ConvertFrom-Json
        
        # Apply custom settings
        if ($customConfig.Colors) {
            foreach ($colorKey in $customConfig.Colors.PSObject.Properties.Name) {
                $Config.Colors[$colorKey] = $customConfig.Colors.$colorKey
            }
        }
        
        if ($customConfig.RetrySettings) {
            if ($customConfig.RetrySettings.MaxAttempts) {
                $Config.RetrySettings.MaxAttempts = $customConfig.RetrySettings.MaxAttempts
            }
            if ($customConfig.RetrySettings.DelaySeconds) {
                $Config.RetrySettings.DelaySeconds = $customConfig.RetrySettings.DelaySeconds
            }
        }
        
        # Override URLs if specified
        if ($customConfig.URLs) {
            foreach ($urlKey in $customConfig.URLs.PSObject.Properties.Name) {
                $Config.URLs[$urlKey] = $customConfig.URLs.$urlKey
            }
        }
        
    } catch {
        Write-StatusMessage " Failed" $Config.Colors.Warning
        Write-StatusMessage "Error loading configuration: $($_.Exception.Message)" $Config.Colors.Warning
    }
}

function Check-ScriptUpdate {
    if (-not $Config.Flags.CheckUpdate) {
        return $false
    }
    
    Write-StatusMessage "Checking for script updates..." -NoNewLine
    
    try {
        # Get version information from remote
        $params = @{
            Uri = $Config.URLs.ScriptUpdate
            UseBasicParsing = $true
            ErrorAction = "Stop"
            TimeoutSec = 5
        }
        
        $response = Invoke-WebRequest @params
        $versionInfo = $response.Content | ConvertFrom-Json
        
        if ($versionInfo.version -gt $Config.Version) {
            Write-StatusMessage " Update available!" $Config.Colors.Warning
            Write-StatusMessage "Current version: $($Config.Version) | Latest version: $($versionInfo.version)" $Config.Colors.Primary
            Write-StatusMessage "Update notes: $($versionInfo.notes)" $Config.Colors.Primary
            Write-StatusMessage "Download new version from: $($versionInfo.download_url)" $Config.Colors.Primary
            
            return $true
        } else {
            Write-StatusMessage " Current version" $Config.Colors.Success
            return $false
        }
    } catch {
        Write-StatusMessage " Failed" $Config.Colors.Warning
        Write-StatusMessage "Could not check for updates: $($_.Exception.Message)" $Config.Colors.Warning -LogOnly
        return $false
    }
}
#endregion

#region Download Functions
function Get-AuroraFile {
    $downloadSuccess = $false
    
    $url = $Config.URLs.Aurora
    $retryCount = 0
    
    while ($retryCount -lt $Config.RetrySettings.MaxAttempts) {
        try {
            # Method 1: WebClient
            $webClient = New-Object System.Net.WebClient
            $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
            $webClient.Headers.Add("Accept", "*/*")
            $webClient.DownloadFile($url, $Config.Paths.TempFile)
            $downloadSuccess = $true
            break
        } 
        catch {
            try {
                # Method 2: Invoke-WebRequest
                $params = @{
                    Uri = $url
                    OutFile = $Config.Paths.TempFile
                    UseBasicParsing = $true
                    Headers = @{ "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" }
                    ErrorAction = "Stop"
                }
                Invoke-WebRequest @params
                $downloadSuccess = $true
                Write-StatusMessage "Download successful (alternate method)" $Config.Colors.Success
                break
            } 
            catch {
                $retryCount++
                if ($retryCount -lt $Config.RetrySettings.MaxAttempts) {
                    Write-StatusMessage "Attempt $retryCount failed, retrying in $($Config.RetrySettings.DelaySeconds) seconds..." $Config.Colors.Warning
                    Start-Sleep -Seconds $Config.RetrySettings.DelaySeconds
                } 
                else {
                    Write-StatusMessage "Failed after $($Config.RetrySettings.MaxAttempts) attempts" $Config.Colors.Warning
                    break
                }
            }
        }
    }
    
    return $downloadSuccess
}

function Get-WinfetchModule {
    $downloadSuccess = $false
    
    $url = $Config.URLs.Winfetch
    $retryCount = 0
    
    while ($retryCount -lt $Config.RetrySettings.MaxAttempts) {
        try {
            # Method 1: WebClient (Silent mode)
            $webClient = New-Object System.Net.WebClient
            $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
            $webClient.Headers.Add("Accept", "*/*")
            $webClient.DownloadFile($url, $Config.Paths.WinfetchModule)
            $downloadSuccess = $true
            break
        } 
        catch {
            try {
                # Method 2: Invoke-WebRequest (Silent mode)
                $params = @{
                    Uri = $url
                    OutFile = $Config.Paths.WinfetchModule
                    UseBasicParsing = $true
                    Headers = @{ "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" }
                    ErrorAction = "Stop"
                }
                Invoke-WebRequest @params
                $downloadSuccess = $true
                break
            } 
            catch {
                $retryCount++
                if ($retryCount -lt $Config.RetrySettings.MaxAttempts) {
                    # Silent retry
                    Start-Sleep -Seconds $Config.RetrySettings.DelaySeconds
                } 
                else {
                    Write-StatusMessage " Failed" $Config.Colors.Error
                    break
                }
            }
        }
    }
    
    return $downloadSuccess
}

function Show-DownloadHelp {
    $avProducts = Get-ThirdPartyAntivirus
    if ($avProducts) {
        Write-StatusMessage "Detected antivirus software that might be blocking the download:" $Config.Colors.Warning
        Write-StatusMessage " $($avProducts -join ', ')" $Config.Colors.Error
    }
    
    Write-StatusMessage "Download failed. Please try one of these alternatives:" $Config.Colors.Warning
    Write-StatusMessage "1. Visit https://github.com/IBRHUB/Aurora/releases and download manually" $Config.Colors.Primary
    Write-StatusMessage "2. Check your internet connection and firewall settings" $Config.Colors.Primary
    Write-StatusMessage "3. Try using a VPN or different network connection" $Config.Colors.Primary
    Write-StatusMessage "4. Visit https://docs.ibrhub.net/ar/troubleshooting/ for help" $Config.Colors.Primary
}
#endregion

#region Main Process
function Start-AuroraInstaller {
    # Initialize console
    Initialize-Console
    
    # Display welcome message
    Write-StatusMessage "-------------------------------------------------------------" $Config.Colors.Primary
    Write-StatusMessage "          Aurora Performance Optimization Tool v$($Config.Version)          " $Config.Colors.Success
    Write-StatusMessage "-------------------------------------------------------------" $Config.Colors.Primary
    Write-StatusMessage ""
    
    # Check admin privileges
    if (-not (Test-AdminPrivileges)) {
        Write-StatusMessage "Elevating to administrator privileges..." $Config.Colors.Primary
        Start-ElevatedSession
    }
    
    # Setup secure connection
    Initialize-SecureConnection
    
    # Display system information
    $systemType = Get-SystemType
    Write-StatusMessage "System Type: $systemType" $Config.Colors.Primary
    Write-StatusMessage ""
    
    # Download Winfetch module
    $winfetchSuccess = Get-WinfetchModule
    
    # Download Aurora
    $downloadSuccess = Get-AuroraFile
    
    if (-not $downloadSuccess) {
        Show-DownloadHelp
        pause
        return
    }
    
    # Validate downloaded file
    if (-not (Test-Path $Config.Paths.TempFile) -or (Get-Item $Config.Paths.TempFile).Length -eq 0) {
        Write-StatusMessage "Error: Downloaded file is empty or missing!" $Config.Colors.Error
        Show-DownloadHelp
        pause
        return
    }
    
    # Load and run Winfetch if downloaded successfully
    if ($winfetchSuccess -and (Test-Path $Config.Paths.WinfetchModule)) {
        try {
            # Import the Winfetch module silently
            Import-Module -Name $Config.Paths.WinfetchModule -Force -Global *>$null
            # Import the Winfetch module silently
            Import-Module -Name $Config.Paths.WinfetchModule -Force -Global *>$null
            
            # Run Winfetch with default settings
            Invoke-Command -ScriptBlock { 
                winfetch 
            } -ErrorAction SilentlyContinue
            
            Write-StatusMessage ""
        } catch {
            Write-StatusMessage "Notice: Winfetch information could not be displayed." $Config.Colors.Warning
        }
    }
    
    # Reset CodePage settings for better compatibility
    Write-StatusMessage "Preparing system for Aurora..." $Config.Colors.Warning
    Reset-CodePageSettings
    
    # Run Aurora
    Write-StatusMessage "Aurora is running..." $Config.Colors.Success
    try {
        Start-Process "conhost.exe" -ArgumentList "cmd /c $($Config.Paths.TempFile)" -Wait -Verb RunAs 
        Write-StatusMessage "Aurora completed successfully." $Config.Colors.Success
    } catch {
        Write-StatusMessage "Error running Aurora: $($_.Exception.Message)" $Config.Colors.Error
        pause
    }
    
    # Clean up
    Remove-Item $Config.Paths.TempFile -ErrorAction SilentlyContinue
    Remove-Item $Config.Paths.WinfetchModule -ErrorAction SilentlyContinue
    Write-StatusMessage "Thank you for using Aurora!" $Config.Colors.Success
    Write-StatusMessage ""
}

# Start the installation process
Start-AuroraInstaller
#endregion
