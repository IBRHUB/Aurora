# Function to Debloat Teams and OneDrive
function Debloat-TeamsOneDrive {
    Write-Output 'Starting the debloat process for Teams and OneDrive...'

    ## Step 1: Copy OneDrive Files to C:\OneDrive\Desktop, C:\OneDrive\Documents, C:\OneDrive\Pictures
    Write-Output 'Copying OneDrive files to C:\OneDrive\Desktop, C:\OneDrive\Documents, C:\OneDrive\Pictures'

    $OneDrivePath = "$env:userprofile\OneDrive"
    $FoldersToCopy = @("Desktop", "Documents", "Pictures")
    $DestinationBase = "C:\OneDrive"

    # Create the main destination folder if it doesn't exist
    if (-not (Test-Path $DestinationBase)) {
        Write-Output "Creating destination base folder: $DestinationBase"
        try {
            New-Item -Path $DestinationBase -ItemType Directory -Force | Out-Null
        }
        catch {
            Write-Error "Failed to create destination base folder $DestinationBase: $_"
            exit 1
        }
    }

    foreach ($folder in $FoldersToCopy) {
        $Source = Join-Path -Path $OneDrivePath -ChildPath $folder
        $Destination = Join-Path -Path $DestinationBase -ChildPath $folder

        if (Test-Path $Source) {
            Write-Output "Copying contents from $Source to $Destination"
            # Create the subfolder in destination if it doesn't exist
            if (-not (Test-Path $Destination)) {
                Write-Output "Creating destination subfolder: $Destination"
                try {
                    New-Item -Path $Destination -ItemType Directory -Force | Out-Null
                }
                catch {
                    Write-Error "Failed to create destination subfolder $Destination: $_"
                    exit 1
                }
            }

            # Copy the contents while preserving the folder structure
            try {
                Copy-Item -Path "$Source\*" -Destination $Destination -Recurse -Force -ErrorAction Stop
                Write-Output "Successfully copied contents of $folder."
            }
            catch {
                Write-Error "Error occurred while copying contents of $folder: $_"
                exit 1
            }
        }
        else {
            Write-Output "Source folder $Source does not exist. Skipping."
        }
    }

    ## Step 2: Stop OneDrive and Explorer Processes
    Write-Output 'Stopping OneDrive and Explorer processes'
    taskkill.exe /F /IM 'OneDrive.exe' >$null 2>&1
    taskkill.exe /F /IM 'explorer.exe' >$null 2>&1

    ## Step 3: Uninstall OneDrive
    Write-Output 'Uninstalling OneDrive'
    if (Test-Path "$env:systemroot\System32\OneDriveSetup.exe") {
        & "$env:systemroot\System32\OneDriveSetup.exe" /uninstall
    }
    if (Test-Path "$env:systemroot\SysWOW64\OneDriveSetup.exe") {
        & "$env:systemroot\SysWOW64\OneDriveSetup.exe" /uninstall
    }

    ## Step 4: Remove OneDrive Leftover Files
    Write-Output 'Removing OneDrive leftover files'
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:localappdata\Microsoft\OneDrive"
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:programdata\Microsoft OneDrive"
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:systemdrive\OneDriveTemp"
    If ((Get-ChildItem "$env:userprofile\OneDrive" -Recurse | Measure-Object).Count -eq 0) {
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:userprofile\OneDrive"
    }

    ## Step 5: Remove OneDrive from Explorer Sidebar
    Write-Output 'Removing OneDrive from Explorer sidebar'
    New-PSDrive -PSProvider 'Registry' -Root 'HKEY_CLASSES_ROOT' -Name 'HKCR' | Out-Null
    mkdir -Force 'HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}' | Out-Null
    Set-ItemProperty -Path 'HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}' 'System.IsPinnedToNameSpaceTree' 0
    mkdir -Force 'HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}' | Out-Null
    Set-ItemProperty -Path 'HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}' 'System.IsPinnedToNameSpaceTree' 0
    Remove-PSDrive 'HKCR'

    ## Step 6: Remove "Run Hook" for New Users
    Write-Output 'Removing "Run Hook" for new users'
    reg load 'hku\Default' 'C:\Users\Default\NTUSER.DAT' | Out-Null
    reg delete 'HKEY_USERS\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' /v 'OneDriveSetup' /f
    reg unload 'hku\Default'

    ## Step 7: Remove OneDrive Start Menu Entry
    Write-Output 'Removing OneDrive Start Menu entry'
    Remove-Item -Force -ErrorAction SilentlyContinue "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.exe"

    ## Step 8: Restart Explorer and Wait
    Write-Output 'Restarting Explorer and waiting for 10 seconds'
    Start-Process 'explorer.exe'
    Start-Sleep 10

    ## Step 9: Remove Teams
    Write-Output 'Starting Teams removal process'

    # Function to get the uninstall string for a given application
    function getUninstallString($match) {
        return (Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, `
                            HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | `
                            Get-ItemProperty | `
                            Where-Object { $_.DisplayName -like "*$match*" }).UninstallString
    }

    $TeamsPath = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft', 'Teams')
    $TeamsUpdateExePath = [System.IO.Path]::Combine($TeamsPath, 'Update.exe')

    Write-Output 'Stopping Teams processes'
    Stop-Process -Name '*teams*' -Force -ErrorAction SilentlyContinue

    Write-Output 'Uninstalling Teams from AppData\Microsoft\Teams'
    if ([System.IO.File]::Exists($TeamsUpdateExePath)) {
        $proc = Start-Process $TeamsUpdateExePath '-uninstall -s' -PassThru
        $proc.WaitForExit()
    }

    Write-Output 'Removing Teams AppxPackage'
    Get-AppxPackage '*Teams*' | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxPackage '*Teams*' -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue

    Write-Output 'Deleting Teams directory'
    if ([System.IO.Directory]::Exists($TeamsPath)) {
        Remove-Item $TeamsPath -Force -Recurse -ErrorAction SilentlyContinue
    }

    Write-Output 'Deleting Teams uninstall registry key'
    $us = getUninstallString('Teams')
    if ($us.Length -gt 0) {
        $us = ($us.Replace('/I', '/uninstall ') + ' /quiet').Replace('  ', ' ')
        $FilePath = ($us.Substring(0, $us.IndexOf('.exe') + 4).Trim())
        $ProcessArgs = ($us.Substring($us.IndexOf('.exe') + 5).Trim().Replace('  ', ' '))
        $proc = Start-Process -FilePath $FilePath -Args $ProcessArgs -PassThru
        $proc.WaitForExit()
    }

    Write-Output 'Successfully removed Teams and OneDrive.'
}

# Invoke the Debloat function
Debloat-TeamsOneDrive
