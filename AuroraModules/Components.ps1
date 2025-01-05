param (
    [switch]
    $SILENT
)

$Host.UI.RawUI.BackgroundColor = "Black"

function Disable-SystemSounds {
    if ($SILENT) {
        Write-Progress -Activity "Disabling System Sounds" -Status "In Progress..." -PercentComplete 0
        $ProgressPreference = 'SilentlyContinue'
    }

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
            Set-ItemProperty -Path "$($_.PSPath)\Current" -Name "(Default)" -Value "" -Type String -Force -ErrorAction SilentlyContinue
        }
    }

    # Close mmsys.cpl
    Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue

    if ($SILENT) {
        Write-Progress -Activity "Disabling System Sounds" -Status "Complete" -PercentComplete 100
    }
}

function Enable-EdgeUninstallation {
    if ($SILENT) {
        Write-Progress -Activity "Enabling Edge Uninstallation" -Status "In Progress..." -PercentComplete 0
        $ProgressPreference = 'SilentlyContinue'
    }
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
        
        if ($SILENT) {
            Write-Progress -Activity "Enabling Edge Uninstallation" -Status "Modifying JSON..." -PercentComplete 50
        }

        # Read and modify JSON
        $params = @{
            LiteralPath = $jsonPath
            Encoding = 'Utf8'
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

        if ($SILENT) {
            Write-Progress -Activity "Enabling Edge Uninstallation" -Status "Complete" -PercentComplete 100
        }

    } catch {
        Write-Warning "Failed to modify $jsonPath. Error: $_"
    }
}

function Remove-UnwantedApps {
    if ($SILENT) {
        Write-Progress -Activity "Removing Unwanted Apps" -Status "In Progress..." -PercentComplete 0
        $ProgressPreference = 'SilentlyContinue'
    }

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
        if ($SILENT) {
            $percent = ($current / $total) * 100
            Write-Progress -Activity "Removing Unwanted Apps" -Status "Removing $package" -PercentComplete $percent
        }

        try {
            Get-AppxPackage -AllUsers *$package* | Remove-AppxPackage -ErrorAction Stop
            if (-not $SILENT) {
                Write-Host "Removed AppxPackage: $package" -ForegroundColor Green
            }
        } catch {
            if (-not $SILENT) {
                Write-Host "Failed to remove AppxPackage: $package. Continuing..." -ForegroundColor Yellow
            }
        }
    }

    if ($SILENT) {
        Write-Progress -Activity "Removing Unwanted Apps" -Status "Complete" -PercentComplete 100
    }
}

function Remove-WindowsFeatures {
    if ($SILENT) {
        Write-Progress -Activity "Removing Windows Features" -Status "In Progress..." -PercentComplete 0
        $ProgressPreference = 'SilentlyContinue'
    }
    $selectors = @(
        'MediaPlayback'
        'Microsoft-RemoteDesktopConnection'
        'Recall'
    )

    $installed = Get-WindowsOptionalFeature -Online | Where-Object -Property 'State' -NotIn -Value @(
        'Disabled'
        'DisabledWithPayloadRemoved'
    )
    
    $total = $selectors.Count
    $current = 0

    foreach ($selector in $selectors) {
        $current++
        if ($SILENT) {
            $percent = ($current / $total) * 100
            Write-Progress -Activity "Removing Windows Features" -Status "Removing $selector" -PercentComplete $percent
        }

        $found = $installed | Where-Object { $_.FeatureName -eq $selector }
        if ($found) {
            try {
                $found | Disable-WindowsOptionalFeature -Online -Remove -NoRestart -ErrorAction 'Continue'
                if (-not $SILENT) { Write-Host "Removed feature $selector" }
            }
            catch {
                if (-not $SILENT) { Write-Warning "Failed to remove feature $selector" }
            }
        }
    }

    if ($SILENT) {
        Write-Progress -Activity "Removing Windows Features" -Status "Complete" -PercentComplete 100
    }
}

function Remove-WindowsCapabilities {
    if ($SILENT) {
        Write-Progress -Activity "Removing Windows Capabilities" -Status "In Progress..." -PercentComplete 0
        $ProgressPreference = 'SilentlyContinue'
    }
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

    $installed = Get-WindowsCapability -Online | Where-Object -Property 'State' -NotIn -Value @(
        'NotPresent'
        'Removed'
    )
    
    $total = $selectors.Count
    $current = 0

    foreach ($selector in $selectors) {
        $current++
        if ($SILENT) {
            $percent = ($current / $total) * 100
            Write-Progress -Activity "Removing Windows Capabilities" -Status "Removing $selector" -PercentComplete $percent
        }

        $found = $installed | Where-Object { ($_.Name -split '~')[0] -eq $selector }
        if ($found) {
            try {
                $found | Remove-WindowsCapability -Online -ErrorAction 'Continue'
                if (-not $SILENT) { Write-Host "Removed capability $selector" }
            }
            catch {
                if (-not $SILENT) { Write-Warning "Failed to remove capability $selector" }
            }
        }
    }

    if ($SILENT) {
        Write-Progress -Activity "Removing Windows Capabilities" -Status "Complete" -PercentComplete 100
    }
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
        [string]
        $HtmlColor
    );

    if ($SILENT) {
        Write-Progress -Activity "Setting Wallpaper Color" -Status "In Progress..." -PercentComplete 0
        $ProgressPreference = 'SilentlyContinue'
    }
    $color = [System.Drawing.ColorTranslator]::FromHtml($HtmlColor);
    [WallpaperSetter]::SetDesktopBackground($color);
    Set-ItemProperty -Path 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers' -Name 'BackgroundType' -Type 'DWord' -Value 1 -Force;
    Set-ItemProperty -Path 'Registry::HKCU\Control Panel\Desktop' -Name 'WallPaper' -Type 'String' -Value '' -Force;
    Set-ItemProperty -Path 'Registry::HKCU\Control Panel\Colors' -Name 'Background' -Type 'String' -Value "$($color.R) $($color.G) $($color.B)" -Force;
    if ($SILENT) {
        Write-Progress -Activity "Setting Wallpaper Color" -Status "Complete" -PercentComplete 100
    }
}

function Set-WallpaperImage {
    param(
        [string]
        $LiteralPath
    );

    if ($SILENT) {
        Write-Progress -Activity "Setting Wallpaper Image" -Status "In Progress..." -PercentComplete 0
        $ProgressPreference = 'SilentlyContinue'
    }
    [WallpaperSetter]::SetDesktopImage($LiteralPath);
    Set-ItemProperty -Path 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers' -Name 'BackgroundType' -Type 'DWord' -Value 0 -Force;
    Set-ItemProperty -Path 'Registry::HKCU\Control Panel\Desktop' -Name 'WallPaper' -Type 'String' -Value $LiteralPath -Force;
    if ($SILENT) {
        Write-Progress -Activity "Setting Wallpaper Image" -Status "Complete" -PercentComplete 100
    }
}

# Main menu function
function Show-Menu {
    if (-not $SILENT) {
        Clear-Host
        Write-Host "================ Windows Configuration Menu ================"
        Write-Host "1: Disable System Sounds"
        Write-Host "2: Enable Edge Uninstallation"
        Write-Host "3: Remove Unwanted Apps"
        Write-Host "4: Remove Windows Features"
        Write-Host "5: Remove Windows Capabilities"
        Write-Host "6: Set Black Wallpaper"
        Write-Host "Q: Quit"
        Write-Host "========================================================"
    }
}

# Main program loop
do {
    Show-Menu
    if (-not $SILENT) {
        $input = Read-Host "Please make a selection"
    }
    
    switch ($input) {
        '1' {
            if (-not $SILENT) { Write-Host "Disabling system sounds..." }
            Disable-SystemSounds
            if (-not $SILENT) { pause }
        }
        '2' {
            if (-not $SILENT) { Write-Host "Enabling Edge uninstallation..." }
            Enable-EdgeUninstallation
            if (-not $SILENT) { pause }
        }
        '3' {
            if (-not $SILENT) { Write-Host "Removing unwanted apps..." }
            Remove-UnwantedApps
            if (-not $SILENT) { pause }
        }
        '4' {
            if (-not $SILENT) { Write-Host "Removing Windows features..." }
            Remove-WindowsFeatures
            if (-not $SILENT) { pause }
        }
        '5' {
            if (-not $SILENT) { Write-Host "Removing Windows capabilities..." }
            Remove-WindowsCapabilities
            if (-not $SILENT) { pause }
        }
        '6' {
            if (-not $SILENT) { Write-Host "Setting black wallpaper..." }
            Set-WallpaperColor -HtmlColor '#000000'
            if (-not $SILENT) { pause }
        }
        'q' {
            return
        }
    }
} until ($input -eq 'q')
