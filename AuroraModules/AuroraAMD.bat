@echo off

:: ============================================================================
:: AMD GPU Registry Optimization Script
:: ============================================================================
::
:: DESCRIPTION:
::   This script optimizes AMD GPU settings by modifying various registry values
::   to enhance gaming performance and disable unnecessary features. It adjusts
::   settings related to:
::   - AMD Control Panel behavior and notifications
::   - GPU performance and power settings  
::   - Graphics quality and rendering options
::   - Driver update and auto-configuration features
:: ============================================================================
:: set ANSI escape characters
cd /d "%~dp0"
for /f %%a in ('forfiles /m "%~nx0" /c "cmd /c echo 0x1B"') do set "ESC=%%a"
set "right=%ESC%[<x>C"
set "bullet= %ESC%[34m-%ESC%[0m"
chcp 65001 >NUL

:menu
cls
:: Get user choice for AMD registry modifications
echo.
echo %ESC%[38;5;33m╔══════════════════════════════════════════════════════╗%ESC%[0m
echo %ESC%[38;5;33m║%ESC%[97m             AMD GPU REGISTRY OPTIMIZER              %ESC%[38;5;33m║%ESC%[0m
echo %ESC%[38;5;33m╠══════════════════════════════════════════════════════╣%ESC%[0m
echo %ESC%[38;5;33m║%ESC%[92m  ► 1. %ESC%[97mApply AMD GPU optimizations                    %ESC%[38;5;33m║%ESC%[0m
echo %ESC%[38;5;33m║%ESC%[91m  ► 2. %ESC%[97mRevert AMD GPU optimizations                   %ESC%[38;5;33m║%ESC%[0m
echo %ESC%[38;5;33m║%ESC%[96m  ► 3. %ESC%[97mExit                                           %ESC%[38;5;33m║%ESC%[0m
echo %ESC%[38;5;33m╚══════════════════════════════════════════════════════╝%ESC%[0m
echo.

set /p choice=%ESC%[1;38;5;214m[%ESC%[93mAurora%ESC%[1;38;5;214m]%ESC%[38;5;87m Select option [1-3]: %ESC%[0m

if "%choice%"=="1" (
    echo.
    echo %ESC%[38;5;33m╔══════════════════════════════════════════════════════╗%ESC%[0m
    echo %ESC%[38;5;33m║%ESC%[92m  ✓ Applying AMD GPU optimizations...                  %ESC%[38;5;33m║%ESC%[0m
    echo %ESC%[38;5;33m╚══════════════════════════════════════════════════════╝%ESC%[0m
    timeout /t 1 /nobreak > NUL
    goto apply_optimizations
) else if "%choice%"=="2" (
    echo.
    echo %ESC%[38;5;33m╔══════════════════════════════════════════════════════╗%ESC%[0m
    echo %ESC%[38;5;33m║%ESC%[91m  ✗ Reverting AMD GPU optimizations...                %ESC%[38;5;33m║%ESC%[0m
    echo %ESC%[38;5;33m╚══════════════════════════════════════════════════════╝%ESC%[0m
    timeout /t 1 /nobreak > NUL
    goto revert_optimizations
) else if "%choice%"=="3" (
    echo.
    echo %ESC%[38;5;33m╔══════════════════════════════════════════════════════╗%ESC%[0m
    echo %ESC%[38;5;33m║%ESC%[96m  Exiting...                                          %ESC%[38;5;33m║%ESC%[0m
    echo %ESC%[38;5;33m╚══════════════════════════════════════════════════════╝%ESC%[0m
    timeout /t 1 /nobreak > NUL
    exit /b
) else (
    echo.
    echo %ESC%[38;5;33m╔══════════════════════════════════════════════════════╗%ESC%[0m
    echo %ESC%[38;5;33m║%ESC%[91m  Invalid selection! Please choose 1, 2, or 3         %ESC%[38;5;33m║%ESC%[0m
    echo %ESC%[38;5;33m╚══════════════════════════════════════════════════════╝%ESC%[0m
    timeout /t 2 /nobreak > NUL
    goto menu
)

:apply_optimizations
:: Registry modifications
:: AMD Control Panel settings
Reg.exe add "HKCU\Software\AMD\CN" /v "AutoUpdateTriggered" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\AMD\CN" /v "PowerSaverAutoEnable_CUR" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\AMD\CN" /v "BuildType" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\AMD\CN" /v "WizardProfile" /t REG_SZ /d "PROFILE_CUSTOM" /f >nul 2>&1
Reg.exe add "HKCU\Software\AMD\CN" /v "UserTypeWizardShown" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKCU\Software\AMD\CN" /v "AutoUpdate" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\AMD\CN" /v "RSXBrowserUnavailable" /t REG_SZ /d "true" /f >nul 2>&1
Reg.exe add "HKCU\Software\AMD\CN" /v "SystemTray" /t REG_SZ /d "false" /f >nul 2>&1
Reg.exe add "HKCU\Software\AMD\CN" /v "AllowWebContent" /t REG_SZ /d "false" /f >nul 2>&1
Reg.exe add "HKCU\Software\AMD\CN" /v "CN_Hide_Toast_Notification" /t REG_SZ /d "true" /f >nul 2>&1
Reg.exe add "HKCU\Software\AMD\CN" /v "AnimationEffect" /t REG_SZ /d "false" /f >nul 2>&1
Reg.exe add "HKCU\Software\AMD\CN\OverlayNotification" /v "AlreadyNotified" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKCU\Software\AMD\CN\VirtualSuperResolution" /v "AlreadyNotified" /t REG_DWORD /d "1" /f >nul 2>&1

:: AMD DVR settings
Reg.exe add "HKCU\Software\AMD\DVR" /v "PerformanceMonitorOpacityWA" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\AMD\DVR" /v "DvrEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\AMD\DVR" /v "ActiveSceneId" /t REG_SZ /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\AMD\DVR" /v "PrevInstantReplayEnable" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\AMD\DVR" /v "PrevInGameReplayEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\AMD\DVR" /v "PrevInstantGifEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\AMD\DVR" /v "RemoteServerStatus" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\AMD\DVR" /v "ShowRSOverlay" /t REG_SZ /d "false" /f >nul 2>&1

:: AMD ACE settings
Reg.exe add "HKCU\Software\ATI\ACE\Settings\ADL\AppProfiles" /v "AplReloadCounter" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\Software\AMD\Install" /v "AUEP" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\Software\AUEP" /v "RSX_AUEPStatus" /t REG_DWORD /d "2" /f >nul 2>&1

:: GPU driver settings
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "NotifySubscription" /t REG_BINARY /d "3000" /f >nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "IsComponentControl" /t REG_BINARY /d "00000000" /f >nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "KMD_USUEnable" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "KMD_RadeonBoostEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "IsAutoDefault" /t REG_BINARY /d "01000000" /f >nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "KMD_ChillEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "KMD_DeLagEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "ACE" /t REG_BINARY /d "3000" /f >nul 2>&1

:: UMD settings
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "Main3D_DEF" /t REG_SZ /d "1" /f >nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "Main3D" /t REG_BINARY /d "3100" /f >nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "AnisoDegree_SET" /t REG_BINARY /d "3020322034203820313600" /f >nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "Tessellation_OPTION" /t REG_BINARY /d "3200" /f >nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "Tessellation" /t REG_BINARY /d "3100" /f >nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "VSyncControl" /t REG_BINARY /d "3000" /f >nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "ShaderCache" /t REG_BINARY /d "3100" /f >nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "AntiStuttering" /t REG_BINARY /d "3000" /f >nul 2>&1

:: DXVA settings
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD\DXVA" /v "LRTCEnable" /t REG_BINARY /d "30000000" /f >nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD\DXVA" /v "3to2Pulldown" /t REG_BINARY /d "31000000" /f >nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD\DXVA" /v "MosquitoNoiseRemoval_ENABLE" /t REG_BINARY /d "30000000" /f >nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD\DXVA" /v "Deblocking_ENABLE" /t REG_BINARY /d "30000000" /f >nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD\DXVA" /v "DynamicRange" /t REG_BINARY /d "30000000" /f >nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD\DXVA" /v "ColorVibrance_ENABLE" /t REG_BINARY /d "31000000" /f >nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD\DXVA" /v "Detail_ENABLE" /t REG_BINARY /d "30000000" /f >nul 2>&1

:: Additional performance settings
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableDMACopy" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableBlockWrite" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PP_ThermalAutoThrottlingEnable" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableDrmdmaPowerGating" /t REG_DWORD /d "1" /f >nul 2>&1

:: Service configurations
Reg.exe add "HKLM\System\CurrentControlSet\Services\amdwddmg" /v "ChillEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Services\AMD Crash Defender Service" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Services\AMD External Events Utility" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Services\amdfendr" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Services\amdfendrmgr" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
Reg.exe add "HKLM\System\CurrentControlSet\Services\amdlog" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1

echo.
echo %ESC%[38;5;33m╔══════════════════════════════════════════════════════╗%ESC%[0m
echo %ESC%[38;5;33m║%ESC%[92m  ✓ AMD GPU optimizations applied successfully!        %ESC%[38;5;33m║%ESC%[0m
echo %ESC%[38;5;33m╚══════════════════════════════════════════════════════╝%ESC%[0m
timeout /t 3 /nobreak > NUL
exit /b

:revert_optimizations
:: AMD GPU Registry Default Settings Restore Script

:: AMD Control Panel settings
Reg.exe delete "HKCU\Software\AMD\CN" /f >nul 2>&1
Reg.exe delete "HKCU\Software\AMD\CN\OverlayNotification" /f >nul 2>&1
Reg.exe delete "HKCU\Software\AMD\CN\VirtualSuperResolution" /f >nul 2>&1

:: AMD DVR settings
Reg.exe delete "HKCU\Software\AMD\DVR" /f >nul 2>&1

:: AMD ACE settings
Reg.exe delete "HKCU\Software\ATI\ACE\Settings\ADL\AppProfiles" /f >nul 2>&1
Reg.exe delete "HKLM\Software\AMD\Install" /v "AUEP" /f >nul 2>&1
Reg.exe delete "HKLM\Software\AUEP" /f >nul 2>&1

:: GPU driver settings
Reg.exe delete "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "NotifySubscription" /f >nul 2>&1
Reg.exe delete "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "IsComponentControl" /f >nul 2>&1
Reg.exe delete "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /f >nul 2>&1

:: UMD settings
Reg.exe delete "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /f >nul 2>&1

:: DXVA settings
Reg.exe delete "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD\DXVA" /f >nul 2>&1

:: Additional performance settings
Reg.exe delete "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableDMACopy" /f >nul 2>&1
Reg.exe delete "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableBlockWrite" /f >nul 2>&1
Reg.exe delete "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PP_ThermalAutoThrottlingEnable" /f >nul 2>&1
Reg.exe delete "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableDrmdmaPowerGating" /f >nul 2>&1

:: Service configurations
Reg.exe delete "HKLM\System\CurrentControlSet\Services\amdwddmg" /v "ChillEnabled" /f >nul 2>&1
Reg.exe delete "HKLM\System\CurrentControlSet\Services\AMD Crash Defender Service" /v "Start" /f >nul 2>&1
Reg.exe delete "HKLM\System\CurrentControlSet\Services\AMD External Events Utility" /v "Start" /f >nul 2>&1
Reg.exe delete "HKLM\System\CurrentControlSet\Services\amdfendr" /v "Start" /f >nul 2>&1
Reg.exe delete "HKLM\System\CurrentControlSet\Services\amdfendrmgr" /v "Start" /f >nul 2>&1
Reg.exe delete "HKLM\System\CurrentControlSet\Services\amdlog" /v "Start" /f >nul 2>&1

echo.
echo %ESC%[38;5;33m╔══════════════════════════════════════════════════════╗%ESC%[0m
echo %ESC%[38;5;33m║%ESC%[91m  ✓ AMD GPU optimizations reverted successfully!      %ESC%[38;5;33m║%ESC%[0m
echo %ESC%[38;5;33m╚══════════════════════════════════════════════════════╝%ESC%[0m
timeout /t 3 /nobreak > NUL
exit /b
