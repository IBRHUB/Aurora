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


curl -g -k -L -# -o "%temp%\nvidiaProfileInspector.zip" "https://github.com/Orbmu2k/nvidiaProfileInspector/releases/latest/download/nvidiaProfileInspector.zip" > NUL 2>&1
powershell -NoProfile Expand-Archive '%temp%\nvidiaProfileInspector.zip' -DestinationPath '%~dp0AuroraNvidia\NvidiaProfileInspector\' -Force

curl -g -k -L -# -o "%~dp0AuroraNvidia\NvidiaProfileInspector\AuroraOFF.nip" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/AuroraOFF.nip" > NUL 2>&1
curl -g -k -L -# -o "%~dp0AuroraNvidia\NvidiaProfileInspector\AuroraON.nip" "https://raw.githubusercontent.com/IBRHUB/Aurora/main/AuroraModules/AuroraON.nip" > NUL 2>&1
