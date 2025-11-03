#
# This script creates a Start Menu shortcut and other shortcuts for a specified program.
#

<#
Below are links to relevant documentation for the COM objects, methods, and properties used in this script.
Because PowerShell does not have built-in type annotations for COM objects, these links serve as references for
understanding the types involved.

Powershell only supports basic type annotations for COM objects using [System.__ComObject], so the specific COM
types are indicated in comments, like this: [System.__ComObject]<# WshShortcut #\>.

If Powershell was a real language like Java, with static typing, this would not be necessary.

COM Object Types:
    WScript.Shell https://learn.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/windows-scripting/aew9yb99(v=vs.84)
    WshShell https://learn.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/windows-scripting/aew9yb99(v=vs.84)
    WshShortcut https://learn.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/windows-scripting/xk6kst2k(v=vs.84)
    Folder https://learn.microsoft.com/en-us/windows/win32/shell/folder
    FolderItem https://learn.microsoft.com/en-us/windows/win32/shell/folderitem
    FolderItemVerbs https://learn.microsoft.com/en-us/windows/win32/shell/folderitemverbs

Methods:
    WshShell.CreateShortcut https://learn.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/windows-scripting/xsy6k3ys(v=vs.84)
    WshShell.Namespace https://learn.microsoft.com/en-us/windows/win32/shell/shell-namespace
    WshShell.ParseName https://learn.microsoft.com/en-us/windows/win32/shell/folder-parsename
    FolderItem.Verbs https://learn.microsoft.com/en-us/windows/win32/shell/folderitem-verbs
    FolderItemVerbs.DoIt https://learn.microsoft.com/en-us/windows/win32/shell/folderitemverb-doit

Properties:
    WshShortcut.FullName https://learn.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/windows-scripting/7c7x465d(v=vs.84)
    WshShortcut.TargetPath https://learn.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/windows-scripting/594k4c67(v=vs.84)
#>

# Function to create directory if it doesn't exist
function makeDirectory {
    param (
        [string]$path
    )
    if (-not (Test-Path -Path $path)) {
        try {
            New-Item -Path $path -ItemType Directory
        } catch {
            Write-Error "Failed to create directory: $_.Exception.Message"
            Write-Error "Stack Trace: $_.ScriptStackTrace"
            exit 1
        }
    }
}

function createShortcut {
    param (
        [string]$targetFile,
        [string]$shortcutPath
    )

    try {
        [System.__ComObject]<# WshShell #>   $wshShell = New-Object -ComObject WScript.Shell
        [System.__ComObject]<# WshShortcut #>$shortcut = $wshShell.CreateShortcut($shortcutPath)
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
    [string]$targetFile = "$PSScriptRoot\wallpaper-switcher.bat"
    [string]$shortcutName = "Update Wallpaper from Bing" # Desired name for the shortcut
    [string]$shortcutDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Wallpaper Switcher"
    makeDirectory -path $shortcutDir
    [string]$shortcutPath = "$shortcutDir\$shortcutName.lnk" # For current user
    [System.__ComObject]<# WshShortcut #>$shortcut = createShortcut -targetFile $targetFile -shortcutPath $shortcutPath
    Write-Host "Start Menu entry created"
    return $shortcut
}

function createDesktopShortcut {
    [string]$targetFile = "$PSScriptRoot\wallpaper-switcher.bat"
    [string]$shortcutName = "Update Wallpaper from Bing" # Desired name for the shortcut
    [string]$desktopPath = [System.Environment]::GetFolderPath("Desktop") # Get the current user's desktop path, CommonDesktop can be used for all users
    [string]$shortcutPath = "$desktopPath\$shortcutName.lnk"
    [System.__ComObject]<# WshShortcut #>$shortcut = createShortcut -targetFile $targetFile -shortcutPath $shortcutPath
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

<#
.SYNOPSIS
    Pins a shortcut to the Taskbar.

.PARAMETER targetShortcut
    [System.__ComObject] A WshShortcut COM object to be pinned

.OUTPUTS
    [System.Void] This function does not return a value.
#>
function pinToTaskbar {
    OutputType([System.Void])
    param (
        [System.__ComObject]$targetShortcut # The COM type is WshShortcut
    )

    [System.__ComObject]<# WshShell #>        $shell = New-Object -ComObject Shell.Application # Not sure why this is Shell.Application object and not WScript.Shell
    [string]                                  $targetFullName = $targetShortcut.FullName
    [System.__ComObject]<# Folder #>          $folder = $shell.Namespace((Split-Path $targetFullName))
    [System.__ComObject]<# FolderItem #>      $folderItem = $folder.ParseName((Split-Path $targetFullName -Leaf))
    [System.__ComObject]<# FolderItemVerbs #> $verbs = $folderItem.Verbs()
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

function createAllShortcuts
{
    try
    {
        [System.__ComObject]<# WshShortcut #>$shortcut = createStartMenuEntry
        createDesktopShortcut
        pinToStartMenu $shortcut
        pinToTaskbar $shortcut
    }
    catch
    {
        Write-Error "An error occurred during execution: $_.Exception.Message"
        Write-Error "Stack Trace: $_.ScriptStackTrace"
    }
}

# Main script execution
createAllShortcuts
pause
