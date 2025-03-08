<# : batch portion
@echo off
powershell -nop Get-Content """%~f0""" -Raw ^| iex & exit
: end batch / begin PowerShell #>

Clear-Host

# Define ANSI escape code for colors
$ESC = [char]27

# Function to set console window properties
function Set-ConsoleProperties {
    try {
        $Host.UI.RawUI.WindowTitle = 'Aurora Manual Services | by IBRHUB.net'
        $Host.UI.RawUI.BackgroundColor = "Black"
        $Host.PrivateData.ProgressBackgroundColor = "Black"
        Clear-Host
    }
    catch {
        Write-Warning "Failed to set console properties: $_"
    }
}

# Function to update progress with visual bar
function Update-Progress {
    param (
        [Parameter(Mandatory = $true)]
        [int]$Percentage,
        
        [Parameter(Mandatory = $true)]
        [string]$TaskName
    )
    
    # Clear previous lines
    Clear-Host
    
    # Progress bar calculation
    $blocks = [math]::Floor($Percentage / 2)
    $progressBar = "$($ESC)[92m"
    for ($i = 1; $i -le $blocks; $i++) {
        $progressBar += "█"
    }
    $progressBar += "$($ESC)[90m"
    for ($i = $blocks; $i -lt 50; $i++) {
        $progressBar += "─"
    }
    $progressBar += "$($ESC)[0m"
    
    # Update display
    Write-Host "   $($ESC)[38;5;33m╭─────────────────────────────────────────────────────────╮$($ESC)[0m"
    Write-Host "   $($ESC)[38;5;33m│$($ESC)[97m Processing:$($ESC)[96m $TaskName $($ESC)[0m"
    Write-Host "   $($ESC)[38;5;33m│$($ESC)[0m [$progressBar] $($ESC)[93m$Percentage%$($ESC)[0m"
    Write-Host "   $($ESC)[38;5;33m╰─────────────────────────────────────────────────────────╯$($ESC)[0m"
    
    # Small delay
    Start-Sleep -Milliseconds 100
}

# Function to set the "Start" value for a given service
function Set-ServiceStart {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ServiceName,
        
        [int]$StartValue = 3  # Default to "Manual" startup
    )

    $servicePath = "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName"
    try {
        if (Test-Path $servicePath) {
            Set-ItemProperty -Path $servicePath -Name "Start" -Value $StartValue -Type DWord -Force
        }
        else {
            Write-Warning "Service '$ServiceName' does not exist."
        }
    }
    catch {
        Write-Warning "Failed to set 'Start' for service '$ServiceName': $_"
    }
}

# Initialize Console
Set-ConsoleProperties

# Initialize Services
Update-Progress -Percentage 10 -TaskName "Initializing core services"
Set-ServiceStart -ServiceName "SysMain"
Set-ServiceStart -ServiceName "Themes"
Start-Sleep -Seconds 1

# Configure System Services
Update-Progress -Percentage 30 -TaskName "Configuring system services"
Set-ServiceStart -ServiceName "shpamsvc"
Set-ServiceStart -ServiceName "RemoteRegistry"
Set-ServiceStart -ServiceName "RmSvc"
Set-ServiceStart -ServiceName "wisvc"
Start-Sleep -Seconds 1

# Optimize Windows Services
Update-Progress -Percentage 50 -TaskName "Optimizing Windows services"
Set-ServiceStart -ServiceName "SEMgrSvc"
Set-ServiceStart -ServiceName "AxInstSV"
Set-ServiceStart -ServiceName "tzautoupdate"
Set-ServiceStart -ServiceName "lfsvc"
Set-ServiceStart -ServiceName "SharedAccess"
Start-Sleep -Seconds 1

# Configure Network Services
Update-Progress -Percentage 70 -TaskName "Configuring network services"
Set-ServiceStart -ServiceName "CscService"
Set-ServiceStart -ServiceName "PhoneSvc"
Set-ServiceStart -ServiceName "RemoteAccess"
Set-ServiceStart -ServiceName "upnphost"
Set-ServiceStart -ServiceName "UevAgentService"
Start-Sleep -Seconds 1

# Configure Additional Services
Update-Progress -Percentage 90 -TaskName "Finalizing Additional Services"
Set-ServiceStart -ServiceName "Ndu"
Set-ServiceStart -ServiceName "fdPHost"
Set-ServiceStart -ServiceName "FDResPub"
Set-ServiceStart -ServiceName "lmhosts"
Set-ServiceStart -ServiceName "SSDPSRV"

function Set-SvcHostSplitDisable {
    Update-Progress -Percentage 95 -TaskName "Setting SvcHostSplitDisable"
    Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services" |
        Where-Object { $_.Name -notmatch 'Xbl|Xbox' } |
        ForEach-Object {
            $regPath = "Registry::$_"
            $itemProps = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue
            if ($null -ne $itemProps.Start) {
                Set-ItemProperty -Path $regPath -Name "SvcHostSplitDisable" `
                    -Type DWORD -Value 1 -Force -ErrorAction SilentlyContinue
            }
        }
}

Set-SvcHostSplitDisable
Update-Progress -Percentage 100 -TaskName "Services configuration complete"
Start-Sleep -Seconds 2
