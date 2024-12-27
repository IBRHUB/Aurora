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