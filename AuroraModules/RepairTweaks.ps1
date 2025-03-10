#region Admin Check
# Check for admin rights and self-elevate if needed
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    Write-Host "`n  [" -NoNewline
    Write-Host "!" -ForegroundColor Yellow -NoNewline
    Write-Host "] Administrator privileges required" -ForegroundColor White
    Write-Host "    Requesting elevation..." -ForegroundColor Gray
    Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}
#region Setup

# Set console properties for better UI
$host.UI.RawUI.WindowTitle = "Windows Tweaks Repair Tool"
$host.UI.RawUI.BackgroundColor = "Black"
$host.UI.RawUI.ForegroundColor = "White"
Clear-Host

# Try to set console width if possible
try {
    $size = $host.UI.RawUI.WindowSize
    if ($size.Width -lt 100) {
        $size.Width = 100
        $host.UI.RawUI.WindowSize = $size
    }
} catch { }

# Console colors
$Global:ColorScheme = @{
    Title       = "Cyan"
    Highlight   = "Magenta"
    Good        = "Green"
    Warning     = "Yellow"
    Danger      = "Red"
    Info        = "White"
    Subtle      = "Gray"
    BorderLight = "DarkCyan"
    BorderDark  = "DarkBlue"
}

# Global Registry Paths
$Global:currentControlSet = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet'
$Global:controlSet001 = 'HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001'
$Global:startTime = Get-Date
$Global:spinner = @('|', '/', '-', '\')

# Clear console
Clear-Host

# Spinner animation function
function Show-Spinner {
    param (
        [int]$CurrentItem,
        [int]$TotalItems = 1
    )
    
    $percentage = [math]::Min(100, [math]::Round(($CurrentItem / $TotalItems) * 100))
    $spinChar = $spinner[$CurrentItem % $spinner.Length]
    $elapsedTime = (Get-Date) - $startTime
    $formattedTime = "{0:mm}:{0:ss}" -f $elapsedTime
    
    Write-Host "`r  " -NoNewline
    Write-Host "$spinChar " -ForegroundColor $ColorScheme.Highlight -NoNewline
    Write-Host "[$percentage% complete] " -ForegroundColor $ColorScheme.Info -NoNewline
    Write-Host "Elapsed: $formattedTime" -ForegroundColor $ColorScheme.Subtle -NoNewline
    
    # Add spaces to clear any trailing characters from previous lines
    Write-Host "                    " -NoNewline
}

# Function to draw horizontal divider
function Show-Divider {
    param (
        [string]$Style = "heavy",  # "single", "double", "heavy", "light"
        [string]$Color = $ColorScheme.BorderLight
    )
    
    $width = 80  # Fixed width for consistent appearance
    $char = "─"  # Default divider character
    
    switch ($Style) {
        "double" { $char = "═" }
        "heavy"  { $char = "━" }
        "light"  { $char = "┄" }
    }
    
    $divider = $char * $width
    Write-Host "  $divider" -ForegroundColor $Color
}

# Function to create a text box with a title
function Show-TextBox {
    param (
        [string]$Title,
        [string[]]$Content,
        [string]$TitleColor = $ColorScheme.Title,
        [string]$BorderColor = $ColorScheme.BorderLight,
        [string]$ContentColor = $ColorScheme.Info,
        [string]$Style = "single"  # "single", "double"
    )
    
    $width = 80  # Fixed width for consistent appearance
    
    # Determine box characters based on style
    $topLeft = "┌"
    $topRight = "┐"
    $bottomLeft = "└"
    $bottomRight = "┘"
    $horizontal = "─"
    $vertical = "│"
    
    if ($Style -eq "double") {
        $topLeft = "╔"
        $topRight = "╗"
        $bottomLeft = "╚"
        $bottomRight = "╝"
        $horizontal = "═"
        $vertical = "║"
    }
    
    # Calculate padding
    $titlePadding = " $Title "
    $innerWidth = $width - 4  # 4 = 2 spaces + 2 border chars
    
    # Draw top border with title
    Write-Host "  $topLeft" -ForegroundColor $BorderColor -NoNewline
    Write-Host "$titlePadding" -ForegroundColor $TitleColor -NoNewline
    $remainingWidth = $width - $titlePadding.Length - 2
    Write-Host "$($horizontal * $remainingWidth)$topRight" -ForegroundColor $BorderColor
    
    # Draw content with vertical borders
    foreach ($line in $Content) {
        # Truncate or pad line to fit box
        if ($line.Length -gt $innerWidth) {
            $displayLine = $line.Substring(0, $innerWidth)
        } else {
            $displayLine = $line.PadRight($innerWidth)
        }
        
        Write-Host "  $vertical " -ForegroundColor $BorderColor -NoNewline
        Write-Host "$displayLine" -ForegroundColor $ContentColor -NoNewline
        Write-Host " $vertical" -ForegroundColor $BorderColor
    }
    
    # Draw bottom border
    Write-Host "  $bottomLeft$($horizontal * ($width - 2))$bottomRight" -ForegroundColor $BorderColor
}

# ASCII Art Banner
function Show-Banner {
    $title = @(
        "╔══════════════════════════════════════════════════════════════════════════╗",
        "║                                                                          ║",
        "║                      WINDOWS TWEAKS REPAIR TOOL                          ║",
        "║                                                                          ║",
        "╚══════════════════════════════════════════════════════════════════════════╝"
    )
    
    $subtitle = @(
        "Detects and repairs potentially harmful system tweaks",
        "Version 1.0 | by IBRHUB "
    )
    
    Write-Host "`n"
    foreach ($line in $title) {
        Write-Host "  $line" -ForegroundColor $ColorScheme.Title
    }
    
    Write-Host "`n  " -NoNewline
    Write-Host $subtitle[0] -ForegroundColor $ColorScheme.Info
    Write-Host "  " -NoNewline
    Write-Host $subtitle[1] -ForegroundColor $ColorScheme.Subtle
    Write-Host "`n"
}
#endregion

#region Tweak Check Functions
# Tweak descriptions and impact information
$Global:TweakInfo = @{
    'Svc Split Threshold' = @{
        Description = "Controls how Windows allocates memory to service host processes"
        Impact = "Medium"
        Color = "Yellow"
        BestValue = "3670016"
    }
    'Bcdedit' = @{
        Description = "Boot Configuration Data settings affecting system timers and clocks"
        Impact = "High"
        Color = "Red"
        BestValue = "Default values (no custom flags)"
    }
    'Timer Resolution' = @{
        Description = "Third-party tools that modify Windows timer resolution"
        Impact = "Medium"
        Color = "Yellow"
        BestValue = "Default timer resolution (no external tools)"
    }
    'Win32PrioritySeparation' = @{
        Description = "Controls how Windows allocates processor time between applications"
        Impact = "Medium"
        Color = "Yellow"
        BestValue = "38 (default value)"
    }
    'Tcp Auto-Tuning' = @{
        Description = "Controls how Windows optimizes TCP/IP network performance"
        Impact = "Medium"
        Color = "Yellow"
        BestValue = "Normal"
    }
    'Prefetch' = @{
        Description = "Windows feature that preloads frequently used applications"
        Impact = "Medium"
        Color = "Yellow"
        BestValue = "3 (Enabled for applications and boot)"
    }
    'Windows Error Reporting' = @{
        Description = "Service that sends error reports to Microsoft"
        Impact = "Low"
        Color = "Green"
        BestValue = "Manual startup"
    }
    'Sysmain Service' = @{
        Description = "Service that improves system performance over time (formerly Superfetch)"
        Impact = "Medium"
        Color = "Yellow"
        BestValue = "Automatic startup"
    }
    'Ordinary DPCs' = @{
        Description = "Deferred Procedure Call settings affecting interrupt handling"
        Impact = "High"
        Color = "Red"
        BestValue = "Not disabled (ThreadDpcEnable should not exist)"
    }
    'Meltdown and Spectre' = @{
        Description = "Mitigations for CPU security vulnerabilities"
        Impact = "High"
        Color = "Red"
        BestValue = "Enabled (default security settings)"
    }
    'HPET' = @{
        Description = "High Precision Event Timer hardware feature"
        Impact = "Medium"
        Color = "Yellow"
        BestValue = "Enabled (Status: OK)"
    }
    'Mouse Keyboard Queue Size' = @{
        Description = "Buffer size for keyboard and mouse input"
        Impact = "Low"
        Color = "Green"
        BestValue = "100 (default value)"
    }
    'Csrss Priority' = @{
        Description = "Priority of critical Windows Client/Server Runtime Subsystem"
        Impact = "High"
        Color = "Red"
        BestValue = "Default (no custom priority)"
    }
}

# Function to check for bad tweaks and return hashtable
function Check-Tweaks {
    Write-Host "  Scanning system for potentially harmful tweaks...`n" -ForegroundColor $ColorScheme.Info
    
    # Hashtable for tweaks
    $tweaksTable = @{}
    $tweaks = @(
        'Svc Split Threshold',
        'Bcdedit',
        'Timer Resolution',
        'Win32PrioritySeparation',
        'Tcp Auto-Tuning',
        'Prefetch',
        'Windows Error Reporting',
        'Sysmain Service',
        'Ordinary DPCs',
        'Meltdown and Spectre',
        'HPET',
        'Mouse Keyboard Queue Size',
        'Csrss Priority'
    )
    
    # Add to hashtable and initialize all to false
    foreach ($tweak in $tweaks) {
        $tweaksTable[$tweak] = $false
    }
    
    # Check each tweak with progress updates
    $i = 0
    $totalTweaks = $tweaks.Count
    
    # Check svc split threshold
    Show-Spinner -CurrentItem $i -TotalItems $totalTweaks
    $svcSplitCurrent = Get-ItemPropertyValue -Path "registry::$currentControlSet\Control" -Name 'SvcHostSplitThresholdInKB' -ErrorAction SilentlyContinue
    $svcSplitControl = Get-ItemPropertyValue -Path "registry::$controlSet001\Control" -Name 'SvcHostSplitThresholdInKB' -ErrorAction SilentlyContinue
    if ($svcSplitCurrent -ne 3670016 -or $svcSplitControl -ne 3670016) {
        $tweaksTable['Svc Split Threshold'] = $true
    }
    $i++

    # Check bcdedit tweaks
    Show-Spinner -CurrentItem $i -TotalItems $totalTweaks
    $bcd = bcdedit.exe
    # RegEX with | for 'or'
    $values = 'useplatformclock|disabledynamictick|useplatformtick|tscsyncpolicy'
    if ($bcd -match $values) {
        $tweaksTable['Bcdedit'] = $true
    }
    $i++

    # Check for timer res, timer res service, islc
    Show-Spinner -CurrentItem $i -TotalItems $totalTweaks
    $Global:timerRes = Get-Process -Name TimerResolution -ErrorAction SilentlyContinue
    $Global:timerResService = Get-Service -Name 'STR', 'Set Timer Resolution Service' -ErrorAction SilentlyContinue
    $Global:islc = Get-Process -Name 'Intelligent standby list cleaner ISLC' -ErrorAction SilentlyContinue

    if ($timerRes -or $timerResService -or $islc) {
        $tweaksTable['Timer Resolution'] = $true
    }
    $i++

    # Check win32priority 
    Show-Spinner -CurrentItem $i -TotalItems $totalTweaks
    $controlSetP = Get-ItemPropertyValue -Path "registry::$controlSet001\Control\PriorityControl" -Name 'Win32PrioritySeparation' -ErrorAction SilentlyContinue
    $currentControlSetP = Get-ItemPropertyValue -Path "registry::$currentControlSet\Control\PriorityControl" -Name 'Win32PrioritySeparation' -ErrorAction SilentlyContinue
    if ($currentControlSetP -ne 38 -or $controlSetP -ne 38) {
        $tweaksTable['Win32PrioritySeparation'] = $true
    }
    $i++

    # Check auto-tuning 
    Show-Spinner -CurrentItem $i -TotalItems $totalTweaks
    $autotuning = netsh interface tcp show global | Select-String 'Receive Window Auto-Tuning Level'
    if ($autotuning -notlike '*normal*') {
        $tweaksTable['Tcp Auto-Tuning'] = $true
    }
    $i++

    # Check prefetch
    Show-Spinner -CurrentItem $i -TotalItems $totalTweaks
    $prefetchCurrent = Get-ItemPropertyValue -Path "registry::$currentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name 'EnablePrefetcher' -ErrorAction SilentlyContinue
    $prefetchControl = Get-ItemPropertyValue -Path "registry::$controlSet001\Control\Session Manager\Memory Management\PrefetchParameters" -Name 'EnablePrefetcher' -ErrorAction SilentlyContinue
    if ($prefetchCurrent -ne 3 -or $prefetchControl -ne 3) {
        $tweaksTable['Prefetch'] = $true
    }
    $i++

    # Check sysmain service (superfetch)
    Show-Spinner -CurrentItem $i -TotalItems $totalTweaks
    $start = (Get-Service -Name SysMain -ErrorAction SilentlyContinue).StartType
    if ($start -ne 'Automatic') {
        $tweaksTable['Sysmain Service'] = $true
    }
    $i++

    # Check ordinary dpcs
    Show-Spinner -CurrentItem $i -TotalItems $totalTweaks
    $currentDpc = (Get-ItemProperty -Path "registry::$currentControlSet\Control\Session Manager\kernel" -ErrorAction SilentlyContinue).ThreadDpcEnable
    $controlDpc = (Get-ItemProperty -Path "registry::$controlSet001\Control\Session Manager\kernel" -ErrorAction SilentlyContinue).ThreadDpcEnable
    if ($currentDpc -eq 0 -or $controlDpc -eq 0) {
        $tweaksTable['Ordinary DPCs'] = $true
    }
    $i++

    # Windows error reporting
    Show-Spinner -CurrentItem $i -TotalItems $totalTweaks
    $svcStart = (Get-Service -Name WerSvc -ErrorAction SilentlyContinue).StartType
    $policy = (Get-ItemProperty -Path 'registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting' -ErrorAction SilentlyContinue).Disabled
    if ($svcStart -ne 'Manual' -or $policy -eq 1) {
        $tweaksTable['Windows Error Reporting'] = $true
    }
    $i++

    # Check spectre and meltdown mitigations
    Show-Spinner -CurrentItem $i -TotalItems $totalTweaks
    $overrideCurrent = (Get-ItemProperty -Path "registry::$currentControlSet\Control\Session Manager\Memory Management" -ErrorAction SilentlyContinue).FeatureSettingsOverride
    $overrideMaskCurrent = (Get-ItemProperty -Path "registry::$currentControlSet\Control\Session Manager\Memory Management" -ErrorAction SilentlyContinue).FeatureSettingsOverrideMask
    $overrideControl = (Get-ItemProperty -Path "registry::$controlSet001\Control\Session Manager\Memory Management" -ErrorAction SilentlyContinue).FeatureSettingsOverride
    $overrideMaskControl = (Get-ItemProperty -Path "registry::$controlSet001\Control\Session Manager\Memory Management" -ErrorAction SilentlyContinue).FeatureSettingsOverrideMask
    if ($overrideCurrent -eq 3 -or $overrideMaskCurrent -eq 3 -or $overrideControl -eq 3 -or $overrideMaskControl -eq 3) {
        $tweaksTable['Meltdown and Spectre'] = $true
    }
    $i++

    # Check High precision event timer
    Show-Spinner -CurrentItem $i -TotalItems $totalTweaks
    $hpet = Get-PnpDevice -FriendlyName 'High precision event timer' -ErrorAction SilentlyContinue
    if ($hpet -and $hpet.Status -ne 'OK') {
        $tweaksTable['HPET'] = $true
    }
    $i++

    # Check mouse and keyboard queue size
    Show-Spinner -CurrentItem $i -TotalItems $totalTweaks
    try {
        $keyboardCurrent = Get-ItemPropertyValue -Path "registry::$currentControlSet\Services\kbdclass\Parameters" -Name 'KeyboardDataQueueSize' -ErrorAction SilentlyContinue
    } catch { }
    
    try {
        $mouseCurrent = Get-ItemPropertyValue -Path "registry::$currentControlSet\Services\mouclass\Parameters" -Name 'MouseDataQueueSize' -ErrorAction SilentlyContinue
    } catch { }
    
    try {
        $keyboardControl = Get-ItemPropertyValue -Path "registry::$controlSet001\Services\kbdclass\Parameters" -Name 'KeyboardDataQueueSize' -ErrorAction SilentlyContinue
    } catch { }
    
    try {
        $mouseControl = Get-ItemPropertyValue -Path "registry::$controlSet001\Services\mouclass\Parameters" -Name 'MouseDataQueueSize' -ErrorAction SilentlyContinue
    } catch { }
    
    # If value is null that is fine too (default value 100)
    if (($keyboardCurrent -and $keyboardCurrent -ne 100) -or 
        ($mouseCurrent -and $mouseCurrent -ne 100) -or 
        ($keyboardControl -and $keyboardControl -ne 100) -or 
        ($mouseControl -and $mouseControl -ne 100)) {
        $tweaksTable['Mouse Keyboard Queue Size'] = $true
    }
    $i++

    # Check csrss priority
    Show-Spinner -CurrentItem $i -TotalItems $totalTweaks
    if (Test-Path -Path 'registry::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions' -ErrorAction SilentlyContinue) {
        $tweaksTable['Csrss Priority'] = $true
    }
    $i++

    # Complete progress bar and clear spinner line
    Show-Spinner -CurrentItem $totalTweaks -TotalItems $totalTweaks
    Write-Host "`r                                                                                " -NoNewline
    Write-Host "`r  Scan complete!`n" -ForegroundColor $ColorScheme.Good
    
    Start-Sleep -Milliseconds 500  # Slight pause for better UX
    return $tweaksTable
}
#endregion

#region Repair Functions
# Function to repair tweaks
function Repair-Tweaks($tweakNames) {
    $totalTweaks = $tweakNames.Count
    $i = 0
    
    Write-Host "`n  Repairing tweaks..." -ForegroundColor $ColorScheme.Info
    
    # Display tweak repair progress
    foreach ($tweak in $tweakNames) {
        $progress = [math]::Round(($i / $totalTweaks) * 100)
        Show-Spinner -CurrentItem $i -TotalItems $totalTweaks
        Write-Host "`r  Fixing: $tweak" -ForegroundColor $ColorScheme.Highlight -NoNewline
        Write-Host "                                                  " -NoNewline
        
        # Repair superfetch
        if ($tweak -eq 'Sysmain Service') {
            Set-Service -Name SysMain -StartupType Automatic -ErrorAction SilentlyContinue
        }
        
        # Repair threaded dpcs
        if ($tweak -eq 'Ordinary DPCs') {
            Remove-ItemProperty -Path "registry::$currentControlSet\Control\Session Manager\kernel" -Name ThreadDpcEnable -Force -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path "registry::$controlSet001\Control\Session Manager\kernel" -Name ThreadDpcEnable -Force -ErrorAction SilentlyContinue
        }
        
        # Repair hpet
        if ($tweak -eq 'HPET') {
            Get-PnpDevice -FriendlyName 'High precision event timer' -ErrorAction SilentlyContinue | Enable-PnpDevice -Confirm:$false -ErrorAction SilentlyContinue
        }
        
        # Repair mouse keyboard queue size
        if ($tweak -eq 'Mouse Keyboard Queue Size') {
            Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters' /v 'KeyboardDataQueueSize' /t REG_DWORD /d '100' /f *>$null
            Reg.exe add 'HKLM\SYSTEM\ControlSet001\Services\kbdclass\Parameters' /v 'KeyboardDataQueueSize' /t REG_DWORD /d '100' /f *>$null
            Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters' /v 'MouseDataQueueSize' /t REG_DWORD /d '100' /f *>$null
            Reg.exe add 'HKLM\SYSTEM\ControlSet001\Services\mouclass\Parameters' /v 'MouseDataQueueSize' /t REG_DWORD /d '100' /f *>$null
        }
        
        # Repair timer res
        if ($tweak -eq 'Timer Resolution') {
            # Cleanup timer res depending on which is being used
            if ($timerRes) {
                $filePath = (Get-Process -Name TimerResolution -FileVersionInfo).FileName
                Stop-Process -Name TimerResolution -Force -ErrorAction SilentlyContinue
                Remove-Item -Path $filePath -Force -ErrorAction SilentlyContinue
            }
            if ($timerResService) {
                $name = (Get-Service -Name 'Set Timer Resolution Service', 'STR' -ErrorAction SilentlyContinue).Name
                $serviceExePath = (Get-Process -Name SetTimerResolutionService -FileVersionInfo -ErrorAction SilentlyContinue).FileName
                Stop-Service -Name $name -Force -ErrorAction SilentlyContinue
                Stop-Process -Name SetTimerResolutionService -Force -ErrorAction SilentlyContinue
                sc.exe delete $name *>$null
                if ($serviceExePath) {
                    Remove-Item -Path $serviceExePath -Force -ErrorAction SilentlyContinue
                }
            }
            if ($islc) {
                $filePath = (Get-Process -Name 'Intelligent standby list cleaner ISLC' -FileVersionInfo).FileName
                Stop-Process -Name 'Intelligent standby list cleaner ISLC' -Force -ErrorAction SilentlyContinue
                if ($filePath) {
                    Remove-Item -Path $filePath -Force -ErrorAction SilentlyContinue
                }
            }
        }
        
        # Repair svc split threshold
        if ($tweak -eq 'Svc Split Threshold') {
            Reg.exe add 'HKLM\SYSTEM\ControlSet001\Control' /v 'SvcHostSplitThresholdInKB' /t REG_DWORD /d '3670016' /f *>$null
            Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Control' /v 'SvcHostSplitThresholdInKB' /t REG_DWORD /d '3670016' /f *>$null
        }
        
        # Repair bcdedit 
        if ($tweak -eq 'Bcdedit') {
            bcdedit.exe /deletevalue useplatformclock *>$null
            bcdedit.exe /deletevalue disabledynamictick *>$null
            bcdedit.exe /deletevalue useplatformtick *>$null
            bcdedit.exe /deletevalue tscsyncpolicy *>$null
        }
        
        # Repair prefetch
        if ($tweak -eq 'Prefetch') {
            Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters' /v 'EnablePrefetcher' /t REG_DWORD /d '3' /f *>$null
            Reg.exe add 'HKLM\SYSTEM\ControlSet001\Control\Session Manager\Memory Management\PrefetchParameters' /v 'EnablePrefetcher' /t REG_DWORD /d '3' /f *>$null
        }
        
        # Repair win32priorityseperation
        if ($tweak -eq 'Win32PrioritySeparation') {
            Reg.exe add 'HKLM\SYSTEM\ControlSet001\Control\PriorityControl' /v 'Win32PrioritySeparation' /t REG_DWORD /d '38' /f *>$null
            Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl' /v 'Win32PrioritySeparation' /t REG_DWORD /d '38' /f *>$null
        }
        
        # Repair tcp autotuning
        if ($tweak -eq 'Tcp Auto-Tuning') {
            netsh.exe interface tcp set global autotuninglevel=normal *>$null
        }
        
        # Repair spectre meltdown
        if ($tweak -eq 'Meltdown and Spectre') {
            Remove-ItemProperty -Path "registry::$currentControlSet\Control\Session Manager\Memory Management" -Name FeatureSettingsOverride -Force -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path "registry::$controlSet001\Control\Session Manager\Memory Management" -Name FeatureSettingsOverride -Force -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path "registry::$currentControlSet\Control\Session Manager\Memory Management" -Name FeatureSettingsOverrideMask -Force -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path "registry::$controlSet001\Control\Session Manager\Memory Management" -Name FeatureSettingsOverrideMask -Force -ErrorAction SilentlyContinue
        }
        
        # Repair windows error reporting
        if ($tweak -eq 'Windows Error Reporting') {
            Set-Service -Name WerSvc -StartupType Manual -Force -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path 'registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting' -Name 'Disabled' -Force -ErrorAction SilentlyContinue
        }
        
        # Repair csrss priority
        if ($tweak -eq 'Csrss Priority') {
            Remove-Item -Path 'registry::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions' -Recurse -Force -ErrorAction SilentlyContinue
        }
        
        $i++
        Start-Sleep -Milliseconds 200  # Small delay for better visual feedback
    }
    
    # Complete progress and clear spinner line
    Write-Host "`r                                                                                " -NoNewline
    Write-Host "`r  All repairs applied!" -ForegroundColor $ColorScheme.Good
}

# Function to display tweak status with detailed information
function Show-TweakStatus($tweaksTable) {
    $badTweaksName = @()
    $goodCount = 0
    
    # Section header
    Show-Divider -Style "double" -Color $ColorScheme.Title
    Write-Host "  SYSTEM TWEAK STATUS" -ForegroundColor $ColorScheme.Title
    Show-Divider -Style "single" -Color $ColorScheme.BorderLight
    
    # Calculate column widths for table
    $col1Width = 25  # Tweak name width
    $col2Width = 10  # Status width
    $col3Width = 15  # Impact width
    $col4Width = 28  # Description width (truncated if needed)
    
    # Display table header
    Write-Host "  " -NoNewline
    Write-Host "TWEAK".PadRight($col1Width) -ForegroundColor $ColorScheme.Highlight -NoNewline
    Write-Host "STATUS".PadRight($col2Width) -ForegroundColor $ColorScheme.Highlight -NoNewline
    Write-Host "IMPACT".PadRight($col3Width) -ForegroundColor $ColorScheme.Highlight -NoNewline
    Write-Host "RECOMMENDED VALUE" -ForegroundColor $ColorScheme.Highlight
    Show-Divider -Style "light" -Color $ColorScheme.Subtle
    
    # Sort tweaks by impact level for better visualization (High impact first)
    $sortedTweaks = $tweaksTable.GetEnumerator() | Sort-Object {
        switch ($TweakInfo[$_.Key].Impact) {
            "High"   { return 1 }
            "Medium" { return 2 }
            "Low"    { return 3 }
            default  { return 4 }
        }
    }
    
    # Display each tweak with its status and information
    foreach ($tweak in $sortedTweaks) {
        $name = $tweak.Key
        $isBad = $tweak.Value
        $info = $TweakInfo[$name]
        
        if ($isBad) {
            $badTweaksName += $name
            $statusSymbol = "❌"
            $statusColor = $ColorScheme.Danger
        } else {
            $goodCount++
            $statusSymbol = "✓"
            $statusColor = $ColorScheme.Good
        }
        
        # Display tweak row
        Write-Host "  " -NoNewline
        Write-Host $name.PadRight($col1Width) -ForegroundColor $ColorScheme.Info -NoNewline
        
        Write-Host $statusSymbol.PadRight($col2Width) -ForegroundColor $statusColor -NoNewline
        
        # Impact level with color
        $impactColor = switch ($info.Impact) {
            "High"   { $ColorScheme.Danger }
            "Medium" { $ColorScheme.Warning }
            "Low"    { $ColorScheme.Good }
            default  { $ColorScheme.Info }
        }
        Write-Host $info.Impact.PadRight($col3Width) -ForegroundColor $impactColor -NoNewline
        
        # Recommended value
        Write-Host $info.BestValue -ForegroundColor $ColorScheme.Info
    }
    
    # Display summary with counts
    Show-Divider -Style "single" -Color $ColorScheme.BorderLight
    $summaryInfo = @()
    
    if ($goodCount -eq $tweaksTable.Count) {
        $summaryInfo += "✓ All tweaks are in their recommended state."
        Show-TextBox -Title "SUMMARY" -Content $summaryInfo -TitleColor $ColorScheme.Good -ContentColor $ColorScheme.Good -Style "double"
        return @()
    } else {
        $badCount = $tweaksTable.Count - $goodCount
        
        # Group issues by impact level
        $highImpact = 0
        $mediumImpact = 0
        $lowImpact = 0
        
        foreach ($name in $badTweaksName) {
            switch ($TweakInfo[$name].Impact) {
                "High"   { $highImpact++ }
                "Medium" { $mediumImpact++ }
                "Low"    { $lowImpact++ }
            }
        }
        
        # Create summary information
        $summaryInfo += "Found $badCount potentially harmful tweak(s) that can be repaired:"
        $summaryInfo += ""
        if ($highImpact -gt 0) {
            $summaryInfo += "• $highImpact High Impact - May significantly affect system stability"
        }
        if ($mediumImpact -gt 0) {
            $summaryInfo += "• $mediumImpact Medium Impact - May affect performance or resource usage"
        }
        if ($lowImpact -gt 0) {
            $summaryInfo += "• $lowImpact Low Impact - Minor or cosmetic issues"
        }
        
        $titleColor = if ($highImpact -gt 0) { $ColorScheme.Danger } else { $ColorScheme.Warning }
        Show-TextBox -Title "SUMMARY" -Content $summaryInfo -TitleColor $titleColor -ContentColor $ColorScheme.Info -Style "double"
        
        return $badTweaksName
    }
}
#endregion

#region Main Program
# Main program execution
function Start-Main {
    Clear-Host
    Show-Banner
    
    $getTweaks = Check-Tweaks
    $badTweaksName = Show-TweakStatus $getTweaks
    
    if ($badTweaksName.Count -eq 0) {
        Write-Host "`n  Press Enter to exit..." -ForegroundColor $ColorScheme.Subtle
        Read-Host
        exit
    } else {
        # Display menu options
        $menuOptions = @(
            "1. Repair all detected tweaks",
            "2. Exit without making changes"
        )
        
        Show-TextBox -Title "OPTIONS" -Content $menuOptions -TitleColor $ColorScheme.Highlight
        
        $choice = ""
        while ($choice -ne "1" -and $choice -ne "2") {
            Write-Host "  Enter option (1-2): " -NoNewline -ForegroundColor $ColorScheme.Info
            $choice = Read-Host
            
            switch ($choice) {
                "1" {
                    Repair-Tweaks $badTweaksName
                    
                    # Verify fixes
                    Write-Host "`n  Verifying repairs..." -ForegroundColor $ColorScheme.Info
                    $verifyTweaks = Check-Tweaks
                    $stillBadTweaks = @()
                    
                    foreach ($tweak in $verifyTweaks.GetEnumerator()) {
                        if ($tweak.Value) {
                            $stillBadTweaks += $tweak.Key
                        }
                    }
                    
                    if ($stillBadTweaks.Count -eq 0) {
                        $successMsg = @(
                            "All tweaks were successfully repaired!",
                            "",
                            "NOTE: Some changes may require a system restart to take full effect."
                        )
                        Show-TextBox -Title "SUCCESS" -Content $successMsg -TitleColor $ColorScheme.Good -ContentColor $ColorScheme.Info -Style "double"
                    } else {
                        $failMsg = @(
                            "Some tweaks could not be repaired:",
                            ""
                        )
                        
                        foreach ($name in $stillBadTweaks) {
                            $failMsg += "• $name"
                        }
                        
                        $failMsg += ""
                        $failMsg += "Please try restarting your system and running this tool again."
                        
                        Show-TextBox -Title "ATTENTION" -Content $failMsg -TitleColor $ColorScheme.Danger -ContentColor $ColorScheme.Info -Style "double"
                    }
                }
                "2" {
                    Write-Host "`n  Exiting without making changes." -ForegroundColor $ColorScheme.Info
                }
                default {
                    Write-Host "  Invalid option. Please enter 1 or 2." -ForegroundColor $ColorScheme.Danger
                }
            }
        }
        
        # Exit prompt
        Write-Host "`n  Press Enter to exit..." -ForegroundColor $ColorScheme.Subtle
        Read-Host
        exit
    }
}

# Start the program
Start-Main
#endregion