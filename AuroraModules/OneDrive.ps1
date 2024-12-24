# Function to Debloat Teams and OneDrive
function Debloat-TeamsOneDrive {
    # Step 1: Copy OneDrive Files to C:\OneDrive\Desktop, C:\OneDrive\Documents, C:\OneDrive\Pictures
    $OneDrivePath = "$env:userprofile\OneDrive"
    $FoldersToCopy = @("Desktop", "Documents", "Pictures")
    $DestinationBase = "C:\OneDrive"

    # Create the main destination folder if it doesn't exist
    if (-not (Test-Path $DestinationBase)) {
        try {
            New-Item -Path $DestinationBase -ItemType Directory -Force | Out-Null
        }
        catch {
            # Log the error to a file and exit
            Add-Content -Path "C:\OneDrive\OneDriveDebloat.log" -Value "[$(Get-Date)] ERROR: Failed to create destination base folder ${DestinationBase}: $_"
            exit 1
        }
    }

    foreach ($folder in $FoldersToCopy) {
        $Source = Join-Path -Path $OneDrivePath -ChildPath $folder
        $Destination = Join-Path -Path $DestinationBase -ChildPath $folder

        if (Test-Path $Source) {
            # Create the subfolder in destination if it doesn't exist
            if (-not (Test-Path $Destination)) {
                try {
                    New-Item -Path $Destination -ItemType Directory -Force | Out-Null
                }
                catch {
                    # Log the error to a file and exit
                    Add-Content -Path "C:\OneDrive\OneDriveDebloat.log" -Value "[$(Get-Date)] ERROR: Failed to create destination subfolder ${Destination}: $_"
                    exit 1
                }
            }

            # Copy the contents while preserving the folder structure
            try {
                Copy-Item -Path "$Source\*" -Destination $Destination -Recurse -Force -ErrorAction Stop
                Add-Content -Path "C:\OneDrive\OneDriveDebloat.log" -Value "[$(Get-Date)] INFO: Successfully copied contents of ${folder}."
            }
            catch {
                # Log the error to a file and exit
                Add-Content -Path "C:\OneDrive\OneDriveDebloat.log" -Value "[$(Get-Date)] ERROR: Error occurred while copying contents of ${folder}: $_"
                exit 1
            }
        }
        else {
            # Log that the source folder does not exist
            Add-Content -Path "C:\OneDrive\OneDriveDebloat.log" -Value "[$(Get-Date)] INFO: Source folder ${Source} does not exist. Skipping."
        }
    }

    # Step 2: Stop OneDrive and Explorer Processes
    try {
        taskkill.exe /F /IM 'OneDrive.exe' >$null 2>&1
        taskkill.exe /F /IM 'explorer.exe' >$null 2>&1
        Add-Content -Path "C:\OneDrive\OneDriveDebloat.log" -Value "[$(Get-Date)] INFO: Stopped OneDrive and Explorer processes."
    }
    catch {
        Add-Content -Path "C:\OneDrive\OneDriveDebloat.log" -Value "[$(Get-Date)] ERROR: Failed to stop OneDrive and Explorer processes: $_"
    }

    # Step 3: Uninstall OneDrive
    try {
        if (Test-Path "$env:systemroot\System32\OneDriveSetup.exe") {
            & "$env:systemroot\System32\OneDriveSetup.exe" /uninstall
        }
        if (Test-Path "$env:systemroot\SysWOW64\OneDriveSetup.exe") {
            & "$env:systemroot\SysWOW64\OneDriveSetup.exe" /uninstall
        }
        Add-Content -Path "C:\OneDrive\OneDriveDebloat.log" -Value "[$(Get-Date)] INFO: Uninstalled OneDrive."
    }
    catch {
        Add-Content -Path "C:\OneDrive\OneDriveDebloat.log" -Value "[$(Get-Date)] ERROR: Failed to uninstall OneDrive: $_"
    }

    # Step 4: Remove OneDrive Leftover Files
    try {
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:localappdata\Microsoft\OneDrive"
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:programdata\Microsoft OneDrive"
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:systemdrive\OneDriveTemp"
        If ((Get-ChildItem "$env:userprofile\OneDrive" -Recurse | Measure-Object).Count -eq 0) {
            Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:userprofile\OneDrive"
        }
        Add-Content -Path "C:\OneDrive\OneDriveDebloat.log" -Value "[$(Get-Date)] INFO: Removed OneDrive leftover files."
    }
    catch {
        Add-Content -Path "C:\OneDrive\OneDriveDebloat.log" -Value "[$(Get-Date)] ERROR: Failed to remove OneDrive leftover files: $_"
    }

    # Step 5: Remove OneDrive from Explorer Sidebar
    try {
        New-PSDrive -PSProvider 'Registry' -Root 'HKEY_CLASSES_ROOT' -Name 'HKCR' | Out-Null
        mkdir -Force 'HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}' | Out-Null
        Set-ItemProperty -Path 'HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}' 'System.IsPinnedToNameSpaceTree' 0
        mkdir -Force 'HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}' | Out-Null
        Set-ItemProperty -Path 'HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}' 'System.IsPinnedToNameSpaceTree' 0
        Remove-PSDrive 'HKCR'
        Add-Content -Path "C:\OneDrive\OneDriveDebloat.log" -Value "[$(Get-Date)] INFO: Removed OneDrive from Explorer sidebar."
    }
    catch {
        Add-Content -Path "C:\OneDrive\OneDriveDebloat.log" -Value "[$(Get-Date)] ERROR: Failed to remove OneDrive from Explorer sidebar: $_"
    }

    # Step 6: Remove "Run Hook" for New Users
    try {
        reg load 'hku\Default' 'C:\Users\Default\NTUSER.DAT' | Out-Null
        reg delete 'HKEY_USERS\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' /v 'OneDriveSetup' /f | Out-Null
        reg unload 'hku\Default' | Out-Null
        Add-Content -Path "C:\OneDrive\OneDriveDebloat.log" -Value "[$(Get-Date)] INFO: Removed 'Run Hook' for new users."
    }
    catch {
        Add-Content -Path "C:\OneDrive\OneDriveDebloat.log" -Value "[$(Get-Date)] ERROR: Failed to remove 'Run Hook' for new users: $_"
    }

    # Step 7: Remove OneDrive Start Menu Entry
    try {
        Remove-Item -Force -ErrorAction SilentlyContinue "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.exe"
        Add-Content -Path "C:\OneDrive\OneDriveDebloat.log" -Value "[$(Get-Date)] INFO: Removed OneDrive Start Menu entry."
    }
    catch {
        Add-Content -Path "C:\OneDrive\OneDriveDebloat.log" -Value "[$(Get-Date)] ERROR: Failed to remove OneDrive Start Menu entry: $_"
    }

    # Step 8: Restart Explorer and Wait
    try {
        Start-Process 'explorer.exe'
        Start-Sleep 10
        Add-Content -Path "C:\OneDrive\OneDriveDebloat.log" -Value "[$(Get-Date)] INFO: Restarted Explorer and waited for 10 seconds."
    }
    catch {
        Add-Content -Path "C:\OneDrive\OneDriveDebloat.log" -Value "[$(Get-Date)] ERROR: Failed to restart Explorer: $_"
    }

    ## Step 9: Remove Teams
    # Function to get the uninstall string for a given application
    function getUninstallString($match) {
        return (Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, `
                            HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | `
                            Get-ItemProperty | `
                            Where-Object { $_.DisplayName -like "*$match*" }).UninstallString
    }

    $TeamsPath = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft', 'Teams')
    $TeamsUpdateExePath = [System.IO.Path]::Combine($TeamsPath, 'Update.exe')

    # Stop Teams processes
    try {
        Stop-Process -Name '*teams*' -Force -ErrorAction SilentlyContinue
        Add-Content -Path "C:\OneDrive\OneDriveDebloat.log" -Value "[$(Get-Date)] INFO: Stopped Teams processes."
    }
    catch {
        Add-Content -Path "C:\OneDrive\OneDriveDebloat.log" -Value "[$(Get-Date)] ERROR: Failed to stop Teams processes: $_"
    }

    # Uninstall Teams using Update.exe
    try {
        if ([System.IO.File]::Exists($TeamsUpdateExePath)) {
            $proc = Start-Process $TeamsUpdateExePath '-uninstall -s' -PassThru
            $proc.WaitForExit()
            Add-Content -Path "C:\OneDrive\OneDriveDebloat.log" -Value "[$(Get-Date)] INFO: Uninstalled Teams using Update.exe."
        }
    }
    catch {
        Add-Content -Path "C:\OneDrive\OneDriveDebloat.log" -Value "[$(Get-Date)] ERROR: Failed to uninstall Teams using Update.exe: $_"
    }

    # Remove Teams AppxPackage for all users
    try {
        Get-AppxPackage '*Teams*' | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxPackage '*Teams*' -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
        Add-Content -Path "C:\OneDrive\OneDriveDebloat.log" -Value "[$(Get-Date)] INFO: Removed Teams AppxPackages."
    }
    catch {
        Add-Content -Path "C:\OneDrive\OneDriveDebloat.log" -Value "[$(Get-Date)] ERROR: Failed to remove Teams AppxPackages: $_"
    }

    # Delete Teams directory
    try {
        if ([System.IO.Directory]::Exists($TeamsPath)) {
            Remove-Item $TeamsPath -Force -Recurse -ErrorAction SilentlyContinue
            Add-Content -Path "C:\OneDrive\OneDriveDebloat.log" -Value "[$(Get-Date)] INFO: Deleted Teams directory."
        }
    }
    catch {
        Add-Content -Path "C:\OneDrive\OneDriveDebloat.log" -Value "[$(Get-Date)] ERROR: Failed to delete Teams directory: $_"
    }

    # Delete Teams uninstall registry key
    try {
        $us = getUninstallString('Teams')
        if ($us.Length -gt 0) {
            $us = ($us.Replace('/I', '/uninstall ') + ' /quiet').Replace('  ', ' ')
            $FilePath = ($us.Substring(0, $us.IndexOf('.exe') + 4).Trim())
            $ProcessArgs = ($us.Substring($us.IndexOf('.exe') + 5).Trim().Replace('  ', ' '))
            $proc = Start-Process -FilePath $FilePath -Args $ProcessArgs -PassThru
            $proc.WaitForExit()
            Add-Content -Path "C:\OneDrive\OneDriveDebloat.log" -Value "[$(Get-Date)] INFO: Deleted Teams uninstall registry key."
        }
    }
    catch {
        Add-Content -Path "C:\OneDrive\OneDriveDebloat.log" -Value "[$(Get-Date)] ERROR: Failed to delete Teams uninstall registry key: $_"
    }

    # Final log entry
    Add-Content -Path "C:\OneDrive\OneDriveDebloat.log" -Value "[$(Get-Date)] INFO: Successfully removed Teams and OneDrive."
}

# Invoke the Debloat function
Debloat-TeamsOneDrive