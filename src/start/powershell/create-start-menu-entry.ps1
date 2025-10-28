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

function createShortCut {
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

function createStartMenuEntry {
    $targetFile = "$PSScriptRoot\wallpaper-switcher.bat"
    $shortcutName = "Update Wallpaper from Bing" # Desired name for the shortcut
    $shortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Wallpaper Switcher\$shortcutName.lnk" # For current user
    createShortCut -shortcutName $shortcutName -targetFile $targetFile -shortcutPath $shortcutPath
}

function pinToStartMenu {
    $targetFile = "$PSScriptRoot\wallpaper-switcher.bat"
    $shell = New-Object -ComObject Shell.Application
    $folder = $shell.Namespace((Split-Path $targetFile))
    $item = $folder.ParseName((Split-Path $targetFile -Leaf))
    $verbs = $item.Verbs()
    foreach ($verb in $verbs) {
        if ($verb.Name -match "Pin to Start") {
            $verb.DoIt()
            Write-Host "Pinned '$targetFile' to Start Menu."
            return
        }
    }
    Write-Host "Pin to Start option not found for '$targetFile'. It may already be pinned."
}

function createDesktopShortcut {
    $targetFile = "$PSScriptRoot\wallpaper-switcher.bat"
    $shortcutName = "Update Wallpaper from Bing" # Desired name for the shortcut
    $desktopPath = [User.Environment]::GetFolderPath("Desktop")
    $shortcutPath = "$desktopPath\$shortcutName.lnk"
    createShortCut -shortcutName $shortcutName -targetFile $targetFile -shortcutPath $shortcutPath
}

function pinToTaskbar {
    $targetFile = "$PSScriptRoot\wallpaper-switcher.bat"
    $shell = New-Object -ComObject Shell.Application
    $folder = $shell.Namespace((Split-Path $targetFile))
    $item = $folder.ParseName((Split-Path $targetFile -Leaf))
    $verbs = $item.Verbs()
    foreach ($verb in $verbs) {
        if ($verb.Name -match "Pin to Taskbar") {
            $verb.DoIt()
            Write-Host "Pinned '$targetFile' to Taskbar."
            return
        }
    }
    Write-Host "Pin to Taskbar option not found for '$targetFile'. It may already be pinned."
}

# Main script execution
createStartMenuEntry
pinToStartMenu
createDesktopShortcut
pinToTaskbar
pause
