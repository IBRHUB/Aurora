# Check if the script is running with Administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Please run this script as Administrator." -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList ('-NoProfile -ExecutionPolicy Bypass -File "{0}"' -f `
        $MyInvocation.MyCommand.Definition) -Verb RunAs
    exit
}

# Set to silent mode
$SILENT = $true

$Host.UI.RawUI.BackgroundColor = "Black"

# Set the console window size
cmd /c "mode con: cols=70 lines=29"

# Set Console Opacity Transparent
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class ConsoleOpacity {
    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll", SetLastError = true)]
    private static extern bool SetLayeredWindowAttributes(IntPtr hwnd, uint crKey, byte bAlpha, uint dwFlags);

    private const uint LWA_ALPHA = 0x00000002;

    public static void SetOpacity(byte opacity) {
        IntPtr hwnd = GetConsoleWindow();
        if (hwnd == IntPtr.Zero) {
            throw new InvalidOperationException("Failed to get console window handle.");
        }
        bool result = SetLayeredWindowAttributes(hwnd, 0, opacity, LWA_ALPHA);
        if (!result) {
            throw new InvalidOperationException("Failed to set window opacity.");
        }
    }
}
"@

try {
    # Set opacity (0-255, where 255 is fully opaque and 0 is fully transparent)
    [ConsoleOpacity]::SetOpacity(230)
} catch {
    Write-Host "An error occurred: $_" -ForegroundColor Red
}

Clear-Host

# Progress bar function
function Show-ProgressBar {
    param (
        [double]$PercentComplete,
        [string]$Activity
    )
    
    $consoleWidth = 70
    $barWidth = 50
    $blocks = [math]::Floor($PercentComplete * $barWidth / 100)
    
    $progressBar = ""
    $progressBar += [char]0x1b + "[96m"
    for ($i = 0; $i -lt $blocks; $i++) {
        $progressBar += "─"
    }
    $progressBar += [char]0x1b + "[90m"
    for ($i = $blocks; $i -lt $barWidth; $i++) {
        $progressBar += "─"
    }
    $progressBar += [char]0x1b + "[0m"
    
    Clear-Host
    Write-Host ""
    Write-Host "    $([char]0x1b)[38;5;33m╭─────────────────────────────────────────────────────────╮$([char]0x1b)[0m"
    Write-Host "    $([char]0x1b)[38;5;33m│$([char]0x1b)[97m Processing:$([char]0x1b)[96m $Activity $([char]0x1b)[0m"
    Write-Host "    $([char]0x1b)[38;5;33m│$([char]0x1b)[0m [$progressBar] $([char]0x1b)[93m$($PercentComplete)%$([char]0x1b)[0m"
    Write-Host "    $([char]0x1b)[38;5;33m╰─────────────────────────────────────────────────────────╯$([char]0x1b)[0m"
}

function Disable-SystemSounds {
    Show-ProgressBar -PercentComplete 0 -Activity "Disabling System Sounds"
    
    # Launch mmsys.cpl and set sound scheme to "No Sounds"
    $process = Start-Process -FilePath "rundll32.exe" -ArgumentList "shell32.dll,Control_RunDLL mmsys.cpl,,2" -PassThru
    Start-Sleep -Seconds 2

    # Set registry keys for "No Sounds" scheme
    Set-ItemProperty -Path "HKCU:\AppEvents\Schemes" -Name "(Default)" -Value ".None" -Force
    
    # Disable all system sounds
    $schemeKeys = @(
        "HKCU:\AppEvents\Schemes\Apps\.Default\*",
        "HKCU:\AppEvents\Schemes\Apps\Explorer\*",
        "HKCU:\AppEvents\Schemes\Apps\sapisvr\*"
    )

    foreach ($keyPath in $schemeKeys) {
        Get-ChildItem -Path $keyPath -ErrorAction SilentlyContinue | ForEach-Object {
            Set-ItemProperty -Path "$($_.PSPath)\Current" -Name "(Default)" -Value "" -Force -ErrorAction SilentlyContinue
        }
    }

    # Close mmsys.cpl
    Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue

    Show-ProgressBar -PercentComplete 100 -Activity "Disabling System Sounds"
    Start-Sleep -Seconds 1
}

function Enable-EdgeUninstallation {
    Show-ProgressBar -PercentComplete 0 -Activity "Enabling Edge Uninstallation"
    $ErrorActionPreference = 'Stop'
    
    $jsonPath = 'C:\Windows\System32\IntegratedServicesRegionPolicySet.json'
    
    # Check if file exists
    if (-not (Test-Path $jsonPath)) {
        Write-Warning "Could not find $jsonPath. Edge uninstallation may not be possible."
        return
    }

    try {
        # Take ownership and set permissions
        $acl = Get-Acl $jsonPath
        $identity = "BUILTIN\Administrators"
        $fileSystemRights = "FullControl"
        $type = "Allow"
        $fileSystemAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($identity, $fileSystemRights, $type)
        $acl.SetAccessRule($fileSystemAccessRule)
        Set-Acl $jsonPath $acl
        
        Show-ProgressBar -PercentComplete 50 -Activity "Enabling Edge Uninstallation"

        # Read and modify JSON
        $params = @{
            LiteralPath = $jsonPath
            Encoding    = 'Utf8'
        }
        
        $jsonContent = Get-Content @params | ConvertFrom-Json
        
        # Enable Edge uninstallation and other EEA features
        $jsonContent.policies | ForEach-Object {
            switch ($_.guid) {
                # Edge uninstallation
                '{1bca278a-5d11-4acf-ad2f-f9ab6d7f93a6}' { $_.defaultState = 'enabled' }
                # Disable web search
                '{f0af080b-4337-4b5b-9561-c87b4e26d6ad}' { $_.defaultState = 'enabled' }
                # Third party search providers
                '{d9b1e12b-24fa-47c5-9c8e-eb8cd3adb084}' { $_.defaultState = 'enabled' }
                # Widgets customization
                '{4866ef06-9eeb-4876-8b14-86c3ad961f6c}' { $_.defaultState = 'enabled' }
                '{6f992394-0176-4e50-a99b-1a45c1c9a106}' { $_.defaultState = 'enabled' }
            }
        }
        
        # Save changes
        $jsonContent | ConvertTo-Json -Depth 9 | Out-File @params

        Show-ProgressBar -PercentComplete 100 -Activity "Enabling Edge Uninstallation"
        Start-Sleep -Seconds 1

    } catch {
        Write-Warning "Failed to modify $jsonPath. Error: $_"
    }
}

function Remove-UnwantedApps {
    Show-ProgressBar -PercentComplete 0 -Activity "Removing Unwanted Apps"

    $packagesToRemove = @(
        'Microsoft.Microsoft3DViewer'
        'Microsoft.BingSearch'
        'Microsoft.WindowsCamera' 
        'Clipchamp.Clipchamp'
        'Microsoft.WindowsAlarms'
        'Microsoft.549981C3F5F10'
        'Microsoft.Windows.DevHome'
        'MicrosoftCorporationII.MicrosoftFamily'
        'Microsoft.WindowsFeedbackHub'
        'Microsoft.GetHelp'
        'Microsoft.Getstarted'
        'microsoft.windowscommunicationsapps'
        'Microsoft.WindowsMaps'
        'Microsoft.MixedReality.Portal'
        'Microsoft.BingNews'
        'Microsoft.MicrosoftOfficeHub'
        'Microsoft.Office.OneNote'
        'Microsoft.OutlookForWindows'
        'Microsoft.MSPaint'
        'Microsoft.People'
        'Microsoft.PowerAutomateDesktop'
        'MicrosoftCorporationII.QuickAssist'
        'Microsoft.SkypeApp'
        'Microsoft.MicrosoftSolitaireCollection'
        'MicrosoftTeams'
        'MSTeams'
        'Microsoft.Todos'
        'Microsoft.WindowsSoundRecorder'
        'Microsoft.Wallet'
        'Microsoft.BingWeather'
        'Microsoft.YourPhone'
        'Microsoft.ZuneVideo'
    )

    $total = $packagesToRemove.Count
    $current = 0

    foreach ($package in $packagesToRemove) {
        $current++
        $percent = ($current / $total) * 100
        Show-ProgressBar -PercentComplete $percent -Activity "Removing: $package"

        try {
            Get-AppxPackage -AllUsers *$package* | Remove-AppxPackage -ErrorAction Stop
        } catch {
            # Continue silently
        }
    }

    Show-ProgressBar -PercentComplete 100 -Activity "Removing Unwanted Apps"
    Start-Sleep -Seconds 1
}

function Remove-WindowsFeatures {
    Show-ProgressBar -PercentComplete 0 -Activity "Removing Windows Features"
    
    $selectors = @(
        'MediaPlayback'
        'Microsoft-RemoteDesktopConnection'
        'Recall'
    )

    $installed = Get-WindowsOptionalFeature -Online | Where-Object { $_.State -notin @('Disabled','DisabledWithPayloadRemoved') }
    
    $total = $selectors.Count
    $current = 0

    foreach ($selector in $selectors) {
        $current++
        $percent = ($current / $total) * 100
        Show-ProgressBar -PercentComplete $percent -Activity "Removing Feature: $selector"

        $found = $installed | Where-Object { $_.FeatureName -eq $selector }
        if ($found) {
            try {
                $found | Disable-WindowsOptionalFeature -Online -Remove -NoRestart -ErrorAction 'Continue'
            }
            catch {
                # Continue silently
            }
        }
    }

    Show-ProgressBar -PercentComplete 100 -Activity "Removing Windows Features"
    Start-Sleep -Seconds 1
}

function Remove-WindowsCapabilities {
    Show-ProgressBar -PercentComplete 0 -Activity "Removing Windows Capabilities"
    
    $selectors = @(
        'Print.Fax.Scan'
        'Language.Handwriting'
        'Browser.InternetExplorer'
        'MathRecognizer'
        'OneCoreUAP.OneSync'
        'OpenSSH.Client'
        'App.Support.QuickAssist'
        'Language.Speech'
        'Language.TextToSpeech'
        'App.StepsRecorder'
        'Hello.Face.18967'
        'Hello.Face.Migration.18967'
        'Hello.Face.20134'
        'Media.WindowsMediaPlayer'
    )

    $installed = Get-WindowsCapability -Online | Where-Object { $_.State -notin @('NotPresent','Removed') }
    
    $total = $selectors.Count
    $current = 0

    foreach ($selector in $selectors) {
        $current++
        $percent = ($current / $total) * 100
        Show-ProgressBar -PercentComplete $percent -Activity "Removing Capability: $selector"

        $found = $installed | Where-Object { ($_.Name -split '~')[0] -eq $selector }
        if ($found) {
            try {
                $found | Remove-WindowsCapability -Online -ErrorAction 'Continue'
            }
            catch {
                # Continue silently
            }
        }
    }

    Show-ProgressBar -PercentComplete 100 -Activity "Removing Windows Capabilities"
    Start-Sleep -Seconds 1
}

Add-Type -TypeDefinition '
    using System.Drawing;
    using System.Runtime.InteropServices;
    
    public static class WallpaperSetter {
        [DllImport("user32.dll")]
        private static extern bool SetSysColors(
            int cElements, 
            int[] lpaElements,
            int[] lpaRgbValues
        );

        [DllImport("user32.dll")]
        private static extern bool SystemParametersInfo(
            uint uiAction,
            uint uiParam,
            string pvParam,
            uint fWinIni
        );

        public static void SetDesktopBackground(Color color) {
            SystemParametersInfo(20, 0, "", 0);
            SetSysColors(1, new int[] { 1 }, new int[] { ColorTranslator.ToWin32(color) });
        }

        public static void SetDesktopImage(string file) {
            SystemParametersInfo(20, 0, file, 0);
        }
    }
' -ReferencedAssemblies 'System.Drawing';

function Set-WallpaperColor {
    param(
        [string] $HtmlColor
    )

    Show-ProgressBar -PercentComplete 0 -Activity "Setting Wallpaper Color"
    
    $color = [System.Drawing.ColorTranslator]::FromHtml($HtmlColor);
    [WallpaperSetter]::SetDesktopBackground($color);

    Set-ItemProperty -Path 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers' -Name 'BackgroundType' -Value 1 -Force;
    Set-ItemProperty -Path 'Registry::HKCU\Control Panel\Desktop' -Name 'WallPaper' -Value '' -Force;
    Set-ItemProperty -Path 'Registry::HKCU\Control Panel\Colors' -Name 'Background' -Value "$($color.R) $($color.G) $($color.B)" -Force;
    
    Show-ProgressBar -PercentComplete 100 -Activity "Setting Wallpaper Color"
    Start-Sleep -Seconds 1
}

# Run all functions in sequence
Show-ProgressBar -PercentComplete 0 -Activity "Starting Aurora Configuration"
Start-Sleep -Seconds 1

# Run all functions in sequence with progress tracking
$totalSteps = 6
$currentStep = 0

$currentStep++
$overallProgress = ($currentStep / $totalSteps) * 100
Show-ProgressBar -PercentComplete $overallProgress -Activity "Step $($currentStep)/$($totalSteps): Disabling System Sounds"
Disable-SystemSounds

$currentStep++
$overallProgress = ($currentStep / $totalSteps) * 100
Show-ProgressBar -PercentComplete $overallProgress -Activity "Step $($currentStep)/$($totalSteps): Enabling Edge Uninstallation"
Enable-EdgeUninstallation

$currentStep++
$overallProgress = ($currentStep / $totalSteps) * 100
Show-ProgressBar -PercentComplete $overallProgress -Activity "Step $($currentStep)/$($totalSteps): Removing Unwanted Apps"
Remove-UnwantedApps

$currentStep++
$overallProgress = ($currentStep / $totalSteps) * 100
Show-ProgressBar -PercentComplete $overallProgress -Activity "Step $($currentStep)/$($totalSteps): Removing Windows Features"
Remove-WindowsFeatures

$currentStep++
$overallProgress = ($currentStep / $totalSteps) * 100
Show-ProgressBar -PercentComplete $overallProgress -Activity "Step $($currentStep)/$($totalSteps): Removing Windows Capabilities"
Remove-WindowsCapabilities

$currentStep++
$overallProgress = ($currentStep / $totalSteps) * 100
Show-ProgressBar -PercentComplete $overallProgress -Activity "Step $($currentStep)/$($totalSteps): Setting Black Wallpaper"
Set-WallpaperColor -HtmlColor "#000000"

Show-ProgressBar -PercentComplete 100 -Activity "Aurora Configuration Complete"
Start-Sleep -Seconds 2