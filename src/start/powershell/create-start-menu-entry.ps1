#
# This script creates a Start Menu shortcut for a specified program.
#

# Function to create directory if it doesn't exist
function makeDirectory {
    param (
        [string]$path
    )
    if (-not (Test-Path -Path $path)) {
        try {
            New-Item -Path $path -ItemType Directory -ErrorAction Stop | Out-Null
        } catch {
            Write-Error "Failed to create directory: $_"
            exit 1
        }
    }
}

function createStartMenuEntry {
    param (
        [string]$shortcutName,
        [string]$targetFile,
        [string]$shortcutPath
    )

    # Create the shortcut
    $wshShell = New-Object -ComObject WScript.Shell
    $shortcut = $wshShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $targetFile
    $shortcut.Save()
    Write-Host "Shortcut '$shortcutName' created at '$shortcutPath'"
}

function pause {
    Write-Host "Press any key to continue..."
    [void][System.Console]::ReadKey($FALSE)
}

$targetFile = "$PSScriptRoot\wallpaper-switcher.bat"
$shortcutName = "Update Wallpaper from Bing" # Desired name for the shortcut
$shortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Wallpaper Switcher\$shortcutName.lnk" # For current user

createStartMenuEntry -shortcutName $shortcutName -targetFile $targetFile -shortcutPath $shortcutPath
pause