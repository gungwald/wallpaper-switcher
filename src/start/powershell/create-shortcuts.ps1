<#
----------------------------------------------------------------------------
Shortcut Creation Script for Wallpaper Switcher

Copyright (c) 2025 Bill Chatfield

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; If not, see <http://www.gnu.org/licenses/>.
----------------------------------------------------------------------------
#>

<#
This script creates a Start Menu shortcut and other shortcuts for a specified program.

Below are links to relevant documentation for the COM objects, methods, and properties used in this script.
Because PowerShell does not have built-in type annotations for COM objects, these links serve as references for
understanding the types involved.

PowerShell only supports basic type annotations for COM objects using [System.__ComObject], so the specific COM
types are indicated in comments, like this: [System.__ComObject]<# WshShortcut #\>.

If PowerShell was a real language like Java, with static typing, this would not be necessary.

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

# Global variables
[int]$global:EXIT_SUCCESS = 0
[int]$global:EXIT_FAILURE = 1
[System.__ComObject]$global:shell = $null # The COM type will be WshShell. Creation needs to be in try/catch block

<#
.SYNOPSIS
    Creates a directory if it does not already exist.
.PARAMETER path
    [string] The path of the directory to create.
.OUTPUTS
    [System.Void] This function does not return a value.
#>
function makeDirectory {
    [OutputType([System.Void])] # This is an attribute, not a command. So it is enclosed in square brackets.
    param (
        [string]$path
    )
    if (-not (Test-Path -Path $path)) {
        try {
            New-Item -Path $path -ItemType Directory
        } catch {
            Write-Error "Failed to create directory: $_.Exception.Message"
            Write-Error "Stack Trace: $_.ScriptStackTrace"
            exit $global:EXIT_FAILURE
        }
    }
}

<#
.SYNOPSIS
    Creates a shortcut at the specified path pointing to the target file.
.PARAMETER targetFile
    [string] The file that the shortcut will point to.
.PARAMETER shortcutPath
    [string] The path where the shortcut will be created.
.OUTPUTS
    [System.__ComObject] A WshShortcut COM object representing the created shortcut.
#>
function createShortcut {
    [OutputType([System.__ComObject])] # The COM type is WshShortcut
    param (
        [string]$targetFile,
        [string]$shortcutPath
    )
    try {
        [System.__ComObject]$shortcut = $global:shell.CreateShortcut($shortcutPath) # $shortcut gets WshShortcut COM type
        $shortcut.TargetPath = $targetFile
        $shortcut.Save() # This is where the error might occur
        return $shortcut
    } catch {
        Write-Error "Failed to create shortcut: $_.Exception.Message"
        Write-Error "Stack Trace: $_.ScriptStackTrace"
        exit $global:EXIT_FAILURE
    }
}

<#
.SYNOPSIS
    Pauses execution and waits for the user to press any key.
.OUTPUTS
    [System.Void] This function does not return a value.
#>
function pause {
    [OutputType([System.Void])] # This is an attribute, not a command. So it is enclosed in square brackets.
    Write-Host "Press any key to continue..."
    [void][System.Console]::ReadKey($FALSE)
}

<#
.SYNOPSIS
    Creates a Start Menu entry for the wallpaper switcher.
.OUTPUTS
    [System.__ComObject] A WshShortcut COM object representing the created shortcut.
#>
function createStartMenuEntry {
    [OutputType([System.__ComObject])] # The COM type is WshShortcut
    [string]$targetFile = "$PSScriptRoot\wallpaper-switcher.bat"
    [string]$shortcutName = "Update Wallpaper from Bing" # Desired name for the shortcut
    [string]$shortcutDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Wallpaper Switcher"
    makeDirectory -path $shortcutDir
    [string]$shortcutPath = "$shortcutDir\$shortcutName.lnk" # For current user
    [System.__ComObject]$shortcut = createShortcut -targetFile $targetFile -shortcutPath $shortcutPath # $shortcut gets WshShortcut COM type
    Write-Host "Start Menu entry created"
    return $shortcut
}

function createDesktopShortcut {
    [OutputType([System.__ComObject])] # The COM type is WshShortcut
    [string]$targetFile = "$PSScriptRoot\wallpaper-switcher.bat"
    [string]$shortcutName = "Update Wallpaper from Bing" # Desired name for the shortcut
    [string]$desktopPath = [System.Environment]::GetFolderPath("Desktop") # Get the current user's desktop path, CommonDesktop can be used for all users
    [string]$shortcutPath = "$desktopPath\$shortcutName.lnk"
    [System.__ComObject]$shortcut = createShortcut -targetFile $targetFile -shortcutPath $shortcutPath # COM type WshShortcut is assigned to $shortcut
    Write-host "Desktop shortcut created."
    return $shortcut
}

function pinToStartMenu {
    [OutputType([System.Void])] # This is an attribute, not a command. So it is enclosed in square brackets.
    [string]$targetFile = "$PSScriptRoot\wallpaper-switcher.bat"
    [System.__ComObject]$folder = $global:shell.Namespace((Split-Path $targetFile)) # COM type Folder is returned
    [System.__ComObject]$item = $folder.ParseName((Split-Path $targetFile -Leaf)) # COM type FolderItem is returned
    [System.__ComObject]$verbs = $item.Verbs() # COM type FolderItemVerbs is assigned to $verbs
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
    [OutputType([System.Void])] # This is an attribute, not a command. So it is enclosed in square brackets.
    param (
        [System.__ComObject]$targetShortcut # The COM type is WshShortcut
    )

    [string]                                  $targetFullName = $targetShortcut.FullName
    [System.__ComObject]<# Folder #>          $folder = $global:shell.Namespace((Split-Path $targetFullName))
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

function createAllShortcuts {
    [OutputType([System.Void])] # This is an attribute, not a command. So it is enclosed in square brackets.
    [System.__ComObject]$shortcut = createStartMenuEntry # WshShortcut COM type is assigned to $shortcut
    createDesktopShortcut
    pinToStartMenu $shortcut
    pinToTaskbar $shortcut
}

function main
{
    try
    {
        $global:shell = New-Object -ComObject WScript.Shell # $shell gets WshShell COM type
        createAllShortcuts
        pause
    }
    catch
    {
        Write-Error "An error occurred during execution: $_.Exception.Message"
        Write-Error "Stack Trace: $_.ScriptStackTrace"
    }
}

main
