<# : batch portion
@echo off
powershell -nop Get-Content """%~f0""" -Raw ^| iex & exit
: end batch / begin PowerShell #>

 Clear-Host

# Function to set console window size and properties
function Set-ConsoleProperties {
    try {
        $Host.UI.RawUI.WindowTitle = 'Aurora Manual Services | by IBRHUB.net'
        $Host.UI.RawUI.BackgroundColor = "Black"
        $Host.PrivateData.ProgressBackgroundColor = "Black"
        # Set console colors: Background Black, Foreground Cyan
        $Host.UI.RawUI.BackgroundColor = "Black"
        $Host.UI.RawUI.ForegroundColor = "Cyan"
        Clear-Host
    }
    catch {
        Write-Warning "Failed to set console properties: $_"
    }
}

# Function to display a progress bar
function Show-ProgressBar {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateRange(0, 100)]
        [int]$Percentage
    )

    $width = 50
    $filled = [math]::Round($Percentage / 2)
    $empty = $width - $filled
    $bar = ('█' * $filled) + ('░' * $empty)
    Write-Host " Progress: [$bar] $Percentage% " -ForegroundColor Cyan
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
            Write-Host "Set 'Start' for service '$ServiceName' to '$StartValue'."
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
Write-Host " [1] Initializing core services..." -ForegroundColor red
Set-ServiceStart -ServiceName "SysMain"
Set-ServiceStart -ServiceName "Themes"
Show-ProgressBar -Percentage 20
sleep 1

Write-Host ""

# Configure System Services
Write-Host " [2] Configuring system services..." -ForegroundColor red
Set-ServiceStart -ServiceName "shpamsvc"
Set-ServiceStart -ServiceName "RemoteRegistry"
Set-ServiceStart -ServiceName "RmSvc"
Set-ServiceStart -ServiceName "wisvc"
Show-ProgressBar -Percentage 40
sleep 1

Write-Host ""

# Optimize Windows Services
Write-Host " [3] Optimizing Windows services..." -ForegroundColor red
Set-ServiceStart -ServiceName "SEMgrSvc"
Set-ServiceStart -ServiceName "AxInstSV"
Set-ServiceStart -ServiceName "tzautoupdate"
Set-ServiceStart -ServiceName "lfsvc"
Set-ServiceStart -ServiceName "SharedAccess"
Show-ProgressBar -Percentage 60
sleep 1

Write-Host ""


# Configure Network Services
Write-Host " [4] Configuring network services..." -ForegroundColor red
Set-ServiceStart -ServiceName "CscService"
Set-ServiceStart -ServiceName "PhoneSvc"
Set-ServiceStart -ServiceName "RemoteAccess"
Set-ServiceStart -ServiceName "upnphost"
Set-ServiceStart -ServiceName "UevAgentService"
Show-ProgressBar -Percentage 80
sleep 1

Write-Host ""


# Configure Additional Services
Write-Host " [5] Finalizing Additional Services..." -ForegroundColor red
Set-ServiceStart -ServiceName "Ndu"
Set-ServiceStart -ServiceName "fdPHost"
Set-ServiceStart -ServiceName "FDResPub"
Set-ServiceStart -ServiceName "lmhosts"
Set-ServiceStart -ServiceName "SSDPSRV"


