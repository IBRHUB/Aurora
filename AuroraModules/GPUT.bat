:NVIDIATweaks
start /wait cmd /c "%currentDir%\NvidiaProfileInspector.cmd"
timeout /t 1 /nobreak > NUL

set AuroraAsAdmin=%currentDir%\AuroraSudo.exe
%AuroraAsAdmin% --NoLogo -S -P --WorkDir="%~dp0AuroraModules\AuroraNvidia\NvidiaProfileInspector" "%~dp0AuroraModules\AuroraNvidia\NvidiaProfileInspector\nvidiaProfileInspector.exe" "%~dp0AuroraModules\AuroraNvidia\NvidiaProfileInspector\AuroraON.nip"
goto :cleanup

:AMDTweaks
timeout /t 3 /nobreak > NUL
start /wait cmd /c "%currentDir%\AuroraAMD.bat"
