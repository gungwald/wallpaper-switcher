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
            Write-Error "Failed to create directory: $_.Exception.Message"
            Write-Error "Stack Trace: $_.ScriptStackTrace"
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

    try {
        $wshShell = New-Object -ComObject WScript.Shell
        $shortcut = $wshShell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $targetFile
        $shortcut.Save() # This is where the error might occur
        return $shortcut
    } catch {
        Write-Error "Failed to create shortcut: $_.Exception.Message"
        Write-Error "Stack Trace: $_.ScriptStackTrace"
        exit 1
    }
}

function pause {
    Write-Host "Press any key to continue..."
    [void][System.Console]::ReadKey($FALSE)
}

function createStartMenuEntry {
    $targetFile = "$PSScriptRoot\wallpaper-switcher.bat"
    $shortcutName = "Update Wallpaper from Bing" # Desired name for the shortcut
    $shortcutDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Wallpaper Switcher"
    makeDirectory -path $shortcutDir
    $shortcutPath = "$shortcutDir\$shortcutName.lnk" # For current user
    $shortcut = createShortCut -shortcutName $shortcutName -targetFile $targetFile -shortcutPath $shortcutPath
    Write-Host "Start Menu entry created"
    return $shortcut
}

function createDesktopShortcut {
    $targetFile = "$PSScriptRoot\wallpaper-switcher.bat"
    $shortcutName = "Update Wallpaper from Bing" # Desired name for the shortcut
    $desktopPath = [System.Environment]::GetFolderPath("Desktop") # Get the current user's desktop path, CommonDesktop can be used for all users
    $shortcutPath = "$desktopPath\$shortcutName.lnk"
    createShortCut -shortcutName $shortcutName -targetFile $targetFile -shortcutPath $shortcutPath
    Write-host "Desktop shortcut created."
    return $shortcut
}

function pinToStartMenu {
    $targetFile = "$PSScriptRoot\wallpaper-switcher.bat"
    $shell = New-Object -ComObject Shell.Application
    $folder = $shell.Namespace((Split-Path $targetFile))
    $item = $folder.ParseName((Split-Path $targetFile -Leaf))
    $verbs = $item.Verbs()
    foreach ($verb in $verbs) {
        write-host "pinToStartMenu: Found verb: $($verb.Name)"
        if ($verb.Name -match "Pin to Start") {
            $verb.DoIt()
            Get-Error
            Write-Host "Pinned to Start Menu."
            return
        }
    }
    Write-Error "Pin to Start failed"
}

function pinToTaskbar {
    $targetFile = "$PSScriptRoot\wallpaper-switcher.bat"
    $shell = New-Object -ComObject Shell.Application
    $folder = $shell.Namespace((Split-Path $targetFile))
    $item = $folder.ParseName((Split-Path $targetFile -Leaf))
    $verbs = $item.Verbs()
    foreach ($verb in $verbs) {
        write-host "pinToTaskbar: Found verb: $($verb.Name)"
        if ($verb.Name -match "Pin to Taskbar") {
            $verb.DoIt()
            Get-Error
            Write-Host "Pinned to Taskbar."
            return
        }
    }
    Write-Error "Pin to Taskbar failed"
}

# Main script execution
try {
    $shortcut = createStartMenuEntry
    Write-host $shortcut.getType().FullName
    $shortcut | Get-Member -Force
    createDesktopShortcut
    pinToStartMenu $shortcut
    pinToTaskbar $shortcut
} catch {
    Write-Error "An error occurred during execution: $_.Exception.Message"
    Write-Error "Stack Trace: $_.ScriptStackTrace"
}

pause
