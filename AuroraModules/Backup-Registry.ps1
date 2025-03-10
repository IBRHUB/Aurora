# ============================================================
#                            Aurora
# ============================================================
# Silent Registry Backup Script
#
# AUTHOR:
#   IBRHUB - IBRAHIM
#   https://github.com/IBRHUB
#   https://docs.ibrhub.net/
#   https://ibrpride.com
#
# DESCRIPTION:
#   This script performs a silent backup of Windows registry settings.
#   It creates backup files in a dedicated directory and supports both
#   first-time and subsequent backups. The script handles various registry
#   categories including system settings, privacy, security, and custom
#   configurations.
#
# This script backs up registry settings and runs in silent mode

# Define comprehensive BaseKeys structure based on the provided registry values
$SCRIPT:BaseKeys = @{
    # HKEY_LOCAL_MACHINE (HKLM) keys
    "HKLM_SOFTWARE" = @{ Hive = [Microsoft.Win32.RegistryHive]::LocalMachine; SubKey = "SOFTWARE" }
    "HKLM_SYSTEM" = @{ Hive = [Microsoft.Win32.RegistryHive]::LocalMachine; SubKey = "SYSTEM" }
    "HKLM_SECURITY" = @{ Hive = [Microsoft.Win32.RegistryHive]::LocalMachine; SubKey = "SECURITY" }
    "HKLM_HARDWARE" = @{ Hive = [Microsoft.Win32.RegistryHive]::LocalMachine; SubKey = "HARDWARE" }
    
    # HKEY_CURRENT_USER (HKCU) keys
    "HKCU_SOFTWARE" = @{ Hive = [Microsoft.Win32.RegistryHive]::CurrentUser; SubKey = "SOFTWARE" }
    "HKCU_CONTROL_PANEL" = @{ Hive = [Microsoft.Win32.RegistryHive]::CurrentUser; SubKey = "Control Panel" }
    "HKCU_ENVIRONMENT" = @{ Hive = [Microsoft.Win32.RegistryHive]::CurrentUser; SubKey = "Environment" }
    "HKCU_NETWORK" = @{ Hive = [Microsoft.Win32.RegistryHive]::CurrentUser; SubKey = "Network" }
}

# Define RegConfig with all the provided registry values from the batch scripts
$SCRIPT:RegConfig = @{}

# Security Settings
$SCRIPT:RegConfig["Security"] = @(
    # UAC Settings
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Policies\System"; Name = "PromptOnSecureDesktop" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Policies\System"; Name = "EnableLUA" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Policies\System"; Name = "ConsentPromptBehaviorAdmin" },
    
    # Windows Defender settings
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Microsoft\Windows Defender"; Name = "" },
    
    # Device Health & Location
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\DeviceHealthAttestationService"; Name = "EnableDeviceHealthAttestationService" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\FindMyDevice"; Name = "AllowFindMyDevice" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\FindMyDevice"; Name = "LocationSyncEnabled" }
)

# Privacy & Telemetry Settings
$SCRIPT:RegConfig["PrivacyAndTelemetry"] = @(
    # Instrumentation and Telemetry
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Policies\Explorer"; Name = "NoInstrumentation" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Privacy"; Name = "TailoredExperiencesWithDiagnosticDataEnabled" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\CloudContent"; Name = "DisableTailoredExperiencesWithDiagnosticData" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\UserProfileEngagement"; Name = "ScoobeSystemSettingEnabled" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack"; Name = "ShowedToastAtLevel" },
    
    # Error Reporting
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\Windows Error Reporting"; Name = "Disabled" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\Windows Error Reporting"; Name = "Disabled" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\PCHealth\ErrorReporting"; Name = "DoReport" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\DeviceInstall\Settings"; Name = "DisableSendGenericDriverNotFoundToWER" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\DeviceInstall\Settings"; Name = "DisableSendRequestAdditionalSoftwareToWER" },
    
    # Activity History
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\System"; Name = "UploadUserActivities" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\System"; Name = "PublishUserActivities" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\System"; Name = "EnableActivityFeed" },
    
    # Input Personalization
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\InputPersonalization"; Name = "RestrictImplicitInkCollection" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\InputPersonalization"; Name = "RestrictImplicitTextCollection" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\InputPersonalization\TrainedDataStore"; Name = "HarvestContacts" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Personalization\Settings"; Name = "AcceptedPrivacyPolicy" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Input\Settings"; Name = "InsightsEnabled" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Input\TIPC"; Name = "Enabled" },
    
    # Telemetry
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\AppV\CEIP"; Name = "CEIPEnable" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\SQMClient\Windows"; Name = "CEIPEnable" },
    @{ BaseKey = "HKLM_SYSTEM"; SubKeySuffix = "CurrentControlSet\Control\Diagnostics\Performance"; Name = "DisableDiagnosticTracing" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\TabletPC"; Name = "PreventHandwritingDataSharing" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\HandwritingErrorReports"; Name = "PreventHandwritingErrorReports" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform"; Name = "NoGenTicket" },
    @{ BaseKey = "HKLM_SYSTEM"; SubKeySuffix = "CurrentControlSet\Services\DiagTrack"; Name = "Start" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Policies\DataCollection"; Name = "AllowTelemetry" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Policies\DataCollection"; Name = "MaxTelemetryAllowed" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection"; Name = "AllowTelemetry" },
    @{ BaseKey = "HKLM_SYSTEM"; SubKeySuffix = "CurrentControlSet\Control\WMI\Autologger\Diagtrack-Listener"; Name = "Start" }
)

# Settings Sync
$SCRIPT:RegConfig["SettingsSync"] = @(
    # Sync Settings
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\SettingSync"; Name = "DisableSettingSync" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\SettingSync"; Name = "DisableSettingSyncUserOverride" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\SettingSync"; Name = "DisableSyncOnPaidNetwork" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\SettingSync"; Name = "DisableWindowsSettingSync" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization"; Name = "Enabled" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\SettingSync\Groups\BrowserSettings"; Name = "Enabled" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\SettingSync\Groups\Credentials"; Name = "Enabled" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility"; Name = "Enabled" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\SettingSync\Groups\Windows"; Name = "Enabled" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\SettingSync"; Name = "SyncPolicy" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\Messaging"; Name = "AllowMessageSync" }
)

# Search & Cortana
$SCRIPT:RegConfig["SearchAndCortana"] = @(
    # Search & Tracking
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "Start_TrackProgs" },
    
    # Bing & Search Settings
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Search"; Name = "BingSearchEnabled" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\SearchSettings"; Name = "IsAADCloudSearchEnabled" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\SearchSettings"; Name = "IsDeviceSearchHistoryEnabled" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\SearchSettings"; Name = "IsMSACloudSearchEnabled" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\SearchSettings"; Name = "SafeSearchMode" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\Windows Search"; Name = "ConnectedSearchUseWeb" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\Windows Search"; Name = "DisableWebSearch" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\Windows Search"; Name = "EnableDynamicContentInWSB" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\Explorer"; Name = "DisableSearchBoxSuggestions" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Search"; Name = "SearchboxTaskbarMode" },
    
    # Cortana Settings
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\Windows Search"; Name = "PrimaryIntranetSearchScopeUrl" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\Windows Search"; Name = "SecondaryIntranetSearchScopeUrl" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\Windows Search"; Name = "AllowCloudSearch" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\Windows Search"; Name = "AllowCortanaAboveLock" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\Windows Search"; Name = "AllowCortana" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\Windows Search"; Name = "AllowCortanaInAAD" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\Windows Search"; Name = "AllowCortanaInAADPathOOBE" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\Windows Search"; Name = "AllowSearchToUseLocation" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\Windows Search"; Name = "ConnectedSearchUseWebOverMeteredConnections" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\Windows Search"; Name = "ConnectedSearchSafeSearch" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\Windows Search"; Name = "ConnectedSearchPrivacy" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Search"; Name = "CortanaConsent" },
    
    # Speech Recognition & Voice
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Microsoft\Speech_OneCore\Preferences"; Name = "ModelDownloadAllowed" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Microsoft\Speech_OneCore\Preferences"; Name = "VoiceActivationEnableAboveLockscreen" },
    
    # Search Indexing
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Microsoft\Windows Search\Gather\Windows\SystemIndex"; Name = "RespectPowerModes" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\Windows Search"; Name = "PreventIndexOnBattery" }
)

# Browser Optimizations
$SCRIPT:RegConfig["Browsers"] = @(
    # Edge Settings
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Edge"; Name = "StartupBoostEnabled" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Edge"; Name = "HardwareAccelerationModeEnabled" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Edge"; Name = "BackgroundModeEnabled" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Edge"; Name = "BatterySaverModeAvailability" },
    
    # Edge Services
    @{ BaseKey = "HKLM_SYSTEM"; SubKeySuffix = "CurrentControlSet\Services\MicrosoftEdgeElevationService"; Name = "Start" },
    @{ BaseKey = "HKLM_SYSTEM"; SubKeySuffix = "CurrentControlSet\Services\edgeupdate"; Name = "Start" },
    @{ BaseKey = "HKLM_SYSTEM"; SubKeySuffix = "CurrentControlSet\Services\edgeupdatem"; Name = "Start" },
    
    # Chrome Settings
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Google\Chrome"; Name = "StartupBoostEnabled" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Google\Chrome"; Name = "BackgroundModeEnabled" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Google\Chrome"; Name = "HighEfficiencyModeEnabled" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Google\Chrome"; Name = "BatterySaverModeAvailability" },
    
    # Chrome Services
    @{ BaseKey = "HKLM_SYSTEM"; SubKeySuffix = "CurrentControlSet\Services\GoogleChromeElevationService"; Name = "Start" },
    @{ BaseKey = "HKLM_SYSTEM"; SubKeySuffix = "CurrentControlSet\Services\gupdate"; Name = "Start" },
    @{ BaseKey = "HKLM_SYSTEM"; SubKeySuffix = "CurrentControlSet\Services\gupdatem"; Name = "Start" },
    
    # Brave Settings
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\BraveSoftware\Brave"; Name = "HighEfficiencyModeEnabled" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\BraveSoftware\Brave"; Name = "BatterySaverModeAvailability" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\BraveSoftware\Brave\Recommended"; Name = "BackgroundModeEnabled" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\BraveSoftware\Brave\Recommended"; Name = "BatterySaverModeAvailability" },
    
    # Firefox Settings
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Mozilla\Firefox"; Name = "DisableAppUpdate" }
)

# Gaming Optimizations
$SCRIPT:RegConfig["Gaming"] = @(
    # NVIDIA Settings
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Run"; Name = "NvBackend" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "NVIDIA Corporation\NvControlPanel2\Client"; Name = "OptInOrOutPreference" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "NVIDIA Corporation\Global\FTS"; Name = "EnableRID66610" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "NVIDIA Corporation\Global\FTS"; Name = "EnableRID64640" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "NVIDIA Corporation\Global\FTS"; Name = "EnableRID44231" },
    
    # Steam Settings
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Valve\Steam"; Name = "GPUAccelWebViewsV2" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Valve\Steam"; Name = "H264HWAccel" },
    
    # DWM Settings
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\Dwm"; Name = "OverlayTestMode" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\Dwm"; Name = "ForceEffectMode" },
    
    # Game Scheduling
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"; Name = "Affinity" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"; Name = "Background Only" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"; Name = "Clock Rate" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"; Name = "GPU Priority" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"; Name = "Priority" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"; Name = "Scheduling Category" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"; Name = "SFIO Priority" },
    
    # GPU Scheduling
    @{ BaseKey = "HKLM_SYSTEM"; SubKeySuffix = "CurrentControlSet\Control\GraphicsDrivers"; Name = "HwSchMode" },
    @{ BaseKey = "HKLM_SYSTEM"; SubKeySuffix = "CurrentControlSet\Control\GraphicsDrivers"; Name = "TdrDelay" },
    
    # Game Mode
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\GameBar"; Name = "AllowAutoGameMode" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\GameBar"; Name = "AutoGameModeEnabled" }
)

# System Optimizations
$SCRIPT:RegConfig["SystemOptimizations"] = @(
    # Background Apps
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"; Name = "GlobalUserDisabled" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\AppPrivacy"; Name = "LetAppsRunInBackground" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Search"; Name = "BackgroundAppGlobalToggle" },
    
    # System Priority
    @{ BaseKey = "HKLM_SYSTEM"; SubKeySuffix = "CurrentControlSet\Control\PriorityControl"; Name = "Win32PrioritySeparation" },
    
    # File System
    @{ BaseKey = "HKLM_SYSTEM"; SubKeySuffix = "CurrentControlSet\Control\FileSystem"; Name = "LongPathsEnabled" },
    
    # Maintenance and Diagnostics
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance"; Name = "MaintenanceDisabled" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\ScheduledDiagnostics"; Name = "EnabledExecution" },
    
    # Auto Restart Explorer
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Microsoft\Windows NT\CurrentVersion\Winlogon"; Name = "AutoRestartShell" },
    
    # Debug Settings
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Microsoft\Windows NT\CurrentVersion\AeDebug"; Name = "Auto" }
)

# Explorer and UI Settings
$SCRIPT:RegConfig["ExplorerUI"] = @(
    # Menu and UI Response
    @{ BaseKey = "HKCU_CONTROL_PANEL"; SubKeySuffix = "Desktop"; Name = "MenuShowDelay" },
    @{ BaseKey = "HKCU_CONTROL_PANEL"; SubKeySuffix = "Mouse"; Name = "MouseHoverTime" },
    
    # Explorer Advanced Settings
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ListviewShadow" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "NoNetCrawling" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "EnableBalloonTips" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "DisallowShaking" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "HideFileExt" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "TaskbarSh" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "TaskbarAnimations" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "IconsOnly" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ListviewAlphaSelect" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "UseOLEDTaskbarTransparency" },
    
    # Explorer Settings
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Explorer"; Name = "ShowFrequent" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Explorer"; Name = "ShowRecent" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Explorer"; Name = "link" },
    
    # Autocomplete
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Explorer\AutoComplete"; Name = "Append Completion" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Explorer\AutoComplete"; Name = "AutoSuggest" },
    
    # Explorer Policies
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Policies\Explorer"; Name = "NoLowDiskSpaceChecks" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Policies\Explorer"; Name = "LinkResolveIgnoreLinkInfo" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Policies\Explorer"; Name = "NoResolveSearch" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Policies\Explorer"; Name = "NoResolveTrack" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Policies\Explorer"; Name = "NoInternetOpenWith" },
    
    # Folder Types
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell"; Name = "FolderType" },
    
    # Explorer Recent Items
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Policies\Explorer"; Name = "HideRecentlyAddedApps" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\Explorer"; Name = "HideRecentlyAddedApps" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\Explorer"; Name = "ShowOrHideMostUsedApps" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Policies\Explorer"; Name = "NoRecentDocsHistory" },
    
    # Start Menu
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Microsoft\PolicyManager\current\device\Start"; Name = "HideRecommendedSection" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Microsoft\PolicyManager\current\device\Education"; Name = "IsEducationEnvironment" },
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "Policies\Microsoft\Windows\Explorer"; Name = "HideRecommendedSection" }
)

# Visual Effects
$SCRIPT:RegConfig["VisualEffects"] = @(
    # Font Smoothing
    @{ BaseKey = "HKCU_CONTROL_PANEL"; SubKeySuffix = "Desktop"; Name = "FontSmoothing" },
    
    # Visual Effects Preferences
    @{ BaseKey = "HKCU_CONTROL_PANEL"; SubKeySuffix = "Desktop"; Name = "UserPreferencesMask" },
    @{ BaseKey = "HKCU_CONTROL_PANEL"; SubKeySuffix = "Desktop"; Name = "DragFullWindows" },
    
    # Window Animations
    @{ BaseKey = "HKCU_CONTROL_PANEL"; SubKeySuffix = "Desktop\WindowMetrics"; Name = "MinAnimate" },
    
    # DWM Settings
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\DWM"; Name = "EnableAeroPeek" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\DWM"; Name = "AlwaysHibernateThumbnails" },
    
    # Visual Effects Setting
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"; Name = "VisualFXSetting" }
)

# Startup Items
$SCRIPT:RegConfig["StartupItems"] = @(
    # Startup Run
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Run"; Name = "" },
    
    # Startup Approved
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run"; Name = "" }
)

# Custom IBRHUB Settings
$SCRIPT:RegConfig["IBRHUB"] = @(
    # Add your custom IBRHUB related registry keys here
    @{ BaseKey = "HKLM_SOFTWARE"; SubKeySuffix = "IBRHUB"; Name = "" },
    @{ BaseKey = "HKCU_SOFTWARE"; SubKeySuffix = "IBRHUB"; Name = "" }
)

function Backup-Registry {
    [CmdletBinding()]
    param(
        [switch]$Silent = $true
    )
    
    try {
        # Define backup directory in Program Files
        $backupDir = Join-Path $env:ProgramFiles "IBRHUB\Backups\REG"
        
        # Create backup directory if it doesn't exist
        if (-not (Test-Path $backupDir)) {
            New-Item -ItemType Directory -Path $backupDir -Force -ErrorAction SilentlyContinue | Out-Null
        }

        # Check if this is first run by looking for FirstRun backup
        $isFirstRun = -not (Get-ChildItem -Path $backupDir -Filter "IBRHUBBackup_FirstRun.reg" -ErrorAction SilentlyContinue)
        
        # Set backup filename based on whether it's first run
        if ($isFirstRun) {
            $backupFile = Join-Path -Path $backupDir -ChildPath "IBRHUBBackup_FirstRun.reg"
        }
        else {
            $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
            $backupFile = Join-Path -Path $backupDir -ChildPath "IBRHUBBackup_$timestamp.reg"
        }
        
        # Initialize StringBuilder for better performance with large strings
        $regContent = New-Object System.Text.StringBuilder
        $regContent.AppendLine("Windows Registry Editor Version 5.00") | Out-Null
        
        # Process each category in RegConfig
        foreach ($category in $SCRIPT:RegConfig.Keys) {
            foreach ($setting in $SCRIPT:RegConfig[$category]) {
                try {
                    $baseKey = $SCRIPT:BaseKeys[$setting.BaseKey]
                    if ($null -eq $baseKey) { continue }
                    
                    $fullPath = $baseKey.SubKey
                    if ($setting.SubKeySuffix) {
                        $fullPath = Join-Path -Path $fullPath -ChildPath $setting.SubKeySuffix
                    }
                    
                    $hive = switch ($baseKey.Hive) {
                        ([Microsoft.Win32.RegistryHive]::LocalMachine) {
                            $regContent.AppendLine("`n[HKEY_LOCAL_MACHINE\$fullPath]") | Out-Null
                            [Microsoft.Win32.Registry]::LocalMachine
                        }
                        ([Microsoft.Win32.RegistryHive]::CurrentUser) {
                            $regContent.AppendLine("`n[HKEY_CURRENT_USER\$fullPath]") | Out-Null
                            [Microsoft.Win32.Registry]::CurrentUser
                        }
                        default { continue }
                    }
                    
                    $key = $hive.OpenSubKey($fullPath)
                    if ($key) {
                        # If Name is empty, backup all values in the key
                        if ([string]::IsNullOrEmpty($setting.Name)) {
                            foreach ($valueName in $key.GetValueNames()) {
                                if ($null -ne $key.GetValue($valueName, $null)) {
                                    $value = $key.GetValue($valueName)
                                    $kind = $key.GetValueKind($valueName)
                                    
                                    $formattedValue = switch ($kind) {
                                        "String" { "`"$value`"" }
                                        "DWord" { "dword:$('{0:X8}' -f $value)" }
                                        "QWord" { "qword:$('{0:X16}' -f $value)" }
                                        "Binary" { 
                                            if ($value) {
                                                "hex:" + (($value | ForEach-Object { "{0:X2}" -f $_ }) -join ',')
                                            }
                                            else { "" }
                                        }
                                        "MultiString" { 
                                            "hex(7):" + (($value | ForEach-Object { 
                                                        [System.Text.Encoding]::Unicode.GetBytes("$_`0") | ForEach-Object { 
                                                            "{0:X2}" -f $_ 
                                                        }
                                                    }) -join ',')
                                        }
                                        "ExpandString" { 
                                            "hex(2):" + (([System.Text.Encoding]::Unicode.GetBytes("$value`0") | ForEach-Object { 
                                                        "{0:X2}" -f $_ 
                                                    }) -join ',')
                                        }
                                        default { "`"$value`"" }
                                    }
                                    
                                    if (![string]::IsNullOrEmpty($valueName)) {
                                        $regContent.AppendLine("`"$valueName`"=$formattedValue") | Out-Null
                                    }
                                    else {
                                        $regContent.AppendLine("@=$formattedValue") | Out-Null
                                    }
                                }
                            }
                        }
                        # Backup specific value
                        elseif ($null -ne $key.GetValue($setting.Name, $null)) {
                            $value = $key.GetValue($setting.Name)
                            $kind = $key.GetValueKind($setting.Name)
                            
                            $formattedValue = switch ($kind) {
                                "String" { "`"$value`"" }
                                "DWord" { "dword:$('{0:X8}' -f $value)" }
                                "QWord" { "qword:$('{0:X16}' -f $value)" }
                                "Binary" { 
                                    if ($value) {
                                        "hex:" + (($value | ForEach-Object { "{0:X2}" -f $_ }) -join ',')
                                    }
                                    else { "" }
                                }
                                "MultiString" { 
                                    "hex(7):" + (($value | ForEach-Object { 
                                                [System.Text.Encoding]::Unicode.GetBytes("$_`0") | ForEach-Object { 
                                                    "{0:X2}" -f $_ 
                                                }
                                            }) -join ',')
                                }
                                "ExpandString" { 
                                    "hex(2):" + (([System.Text.Encoding]::Unicode.GetBytes("$value`0") | ForEach-Object { 
                                                "{0:X2}" -f $_ 
                                            }) -join ',')
                                }
                                default { "`"$value`"" }
                            }
                            
                            if (![string]::IsNullOrEmpty($setting.Name)) {
                                $regContent.AppendLine("`"$($setting.Name)`"=$formattedValue") | Out-Null
                            }
                            else {
                                $regContent.AppendLine("@=$formattedValue") | Out-Null
                            }
                        }
                        $key.Close()
                    }
                }
                catch {
                    # Silently continue on errors in individual settings
                    continue
                }
            }
        }
        
        # Write the entire content at once - silently handle any errors
        try {
            [System.IO.File]::WriteAllText($backupFile, $regContent.ToString(), [System.Text.Encoding]::Unicode)
        }
        catch {
            # If we can't write with System.IO.File, try Set-Content as fallback
            $regContent.ToString() | Set-Content -Path $backupFile -Encoding Unicode -ErrorAction SilentlyContinue
        }
        
        # Verify backup was created
        if (-not (Test-Path -Path $backupFile)) {
            if (-not $Silent) { Write-Error "Failed to create backup file" }
            return $false
        }

        # Cleanup old backups if this isn't the first run
        if (-not $isFirstRun) {
            # Get all backup files except FirstRun
            $backups = Get-ChildItem -Path $backupDir -Filter "IBRHUBBackup_*.reg" -ErrorAction SilentlyContinue | 
            Where-Object { $_.Name -ne "IBRHUBBackup_FirstRun.reg" } |
            Sort-Object CreationTime -Descending

            # Keep only the 2 most recent backups
            if ($backups.Count -gt 2) {
                $backups | Select-Object -Skip 2 | Remove-Item -Force -ErrorAction SilentlyContinue
            }
        }

        # Return the path to the backup file
        return $backupFile
    }
    catch {
        # Return false in case of any unhandled exceptions
        if (-not $Silent) { Write-Error $_.Exception.Message }
        return $false
    }
}

# Main execution - run silently
$result = Backup-Registry -Silent
# No output to console
exit 0