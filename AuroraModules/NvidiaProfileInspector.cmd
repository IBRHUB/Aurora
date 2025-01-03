@echo off
Title Aurora NVIDIA Profile Inspector
:: ============================================================
:: NVIDIA Profile Inspector Configuration Script
:: ============================================================
::
:: DESCRIPTION:
::   This script downloads and configures NVIDIA Profile Inspector with
::   optimized graphics settings for gaming performance. It handles:
::   - Downloading the latest NVIDIA Profile Inspector
::   - Extracting the tool to the Aurora directory
::   - Downloading optimized Aurora profile configurations
::   - Setting up performance-focused graphics driver settings
::
:: REQUIREMENTS:
::   - Windows OS with NVIDIA graphics card
::   - Active internet connection for downloads
::   - Administrator privileges
::
:: NOTES:
::   - AuroraON.nip contains performance-optimized settings
::   - AuroraOFF.nip restores default NVIDIA settings
::   - Script will create AuroraNvidia directory if needed
::
:: ============================================================


:: NVIDIA Inspector Profile
echo Applying NVIDIA Inspector Profile

REM Download NVIDIA Profile Inspector
curl -g -k -L -# -o "%temp%\nvidiaProfileInspector.zip" "https://github.com/Orbmu2k/nvidiaProfileInspector/releases/latest/download/nvidiaProfileInspector.zip"
if errorlevel 1 (
    echo Failed to download NVIDIA Profile Inspector.
    pause
    goto b
)

REM Extract the downloaded ZIP
powershell -NoProfile Expand-Archive '%temp%\nvidiaProfileInspector.zip' -DestinationPath '%~dp0AuroraNvidia\NvidiaProfileInspector\' -Force
if errorlevel 1 (
    echo Failed to extract NVIDIA Profile Inspector.
    pause
    goto b
)

REM Download Aurora profiles
curl -g -k -L -# -o "%~dp0AuroraNvidia\NvidiaProfileInspector\AuroraOFF.nip" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/AuroraOFF.nip"
if errorlevel 1 (
    echo Failed to download AuroraOFF.nip.
    pause
    goto b
)

curl -g -k -L -# -o "%~dp0AuroraNvidia\NvidiaProfileInspector\AuroraON.nip" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/AuroraON.nip"
if errorlevel 1 (
    echo Failed to download AuroraON.nip.
    pause
    goto b
)
:b
exit \b