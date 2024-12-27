<#
.SYNOPSIS
    A dynamic script to run the latest version of Aurora from https://github.com/IBRHUB/Aurora.
.DESCRIPTION
    This script fetches and executes the latest Aurora script from the IBR Pride domain.
    It is designed for ease of use and always runs the latest version available online.
    Ensure you are running PowerShell with administrative privileges for full functionality.
.EXAMPLE
    irm "https://ibrpride.com/Aurora" | iex
    OR
    Run in Admin PowerShell > ./aurora.ps1
#>

powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/IBRHUB/Aurora/refs/heads/main/AuroraModules/UACbypasses.bat' -OutFile \"$env:temp\UACbypasses.bat\"; Invoke-WebRequest -Uri 'https://github.com/IBRHUB/Aurora/releases/download/0.2/Aurora.cmd' -OutFile \"$env:temp\Aurora.cmd\"; Start-Process -FilePath 'cmd.exe' -ArgumentList '/c %temp%\UACbypasses.bat cmd.exe /c \"%temp%\Aurora.cmd\"'"