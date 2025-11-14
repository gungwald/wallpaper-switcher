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
    WshShell https://learn.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/windows-scripting/aew9yb99(v=vs.84)
    Shell https://learn.microsoft.com/en-us/windows/win32/shell/shell
    WshShortcut https://learn.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/windows-scripting/xk6kst2k(v=vs.84)
    Folder https://learn.microsoft.com/en-us/windows/win32/shell/folder
    FolderItem https://learn.microsoft.com/en-us/windows/win32/shell/folderitem
    FolderItemVerbs https://learn.microsoft.com/en-us/windows/win32/shell/folderitemverbs

Methods:
    WshShell.CreateShortcut https://learn.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/windows-scripting/xsy6k3ys(v=vs.84)
    Shell.NameSpace https://learn.microsoft.com/en-us/windows/win32/shell/shell-namespace
    Folder.ParseName https://learn.microsoft.com/en-us/windows/win32/shell/folder-parsename
    FolderItem.Verbs https://learn.microsoft.com/en-us/windows/win32/shell/folderitem-verbs
    FolderItemVerbs.DoIt https://learn.microsoft.com/en-us/windows/win32/shell/folderitemverb-doit

Properties:
    WshShortcut.FullName https://learn.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/windows-scripting/7c7x465d(v=vs.84)
    WshShortcut.TargetPath https://learn.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/windows-scripting/594k4c67(v=vs.84)
#>

# Global variables
[int]$global:EXIT_SUCCESS = 0
[int]$global:EXIT_FAILURE = 1
[System.__ComObject]$global:wshShell = $null # The COM type will be WshShell. Creation needs to be inside try/catch block
[System.__ComObject]$global:shellApp = $null # The COM type will be Shell. Creation needs to be inside try/catch block

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
        New-Item -Path $path -ItemType Directory # Should throw exception on failure
    }
}

<#
.SYNOPSIS
    Creates a shortcut at the specified path pointing to Wallpaper Switcher batch file.
.PARAMETER shortcutPath
    [string] The shortcut file that will point to the Wallpaper Switcher batch file.
.OUTPUTS
    [System.__ComObject] A WshShortcut COM object representing the created shortcut.
#>
function createShortcutToWS {
    [OutputType([System.__ComObject])] # The COM type is WshShortcut
    param (
        [string]$shortcutPath
    )
    [System.__ComObject]$shortcut = $global:wshShell.CreateShortcut($shortcutPath) # $shortcut gets WshShortcut COM type
    $shortcut.TargetPath = "$PSScriptRoot\wallpaper-switcher.bat" # Always the same for this script
    $shortcut.WorkingDirectory = $env:USERPROFILE # Set working directory to user's home directory
    $shortcut.Description = "Update your desktop wallpaper with the daily Bing image." # Always the same for this script
    $shortcut.Save() # This is where the error might occur. It should throw an exception on failure which will be caught in main.
    return $shortcut
}

<#
.SYNOPSIS
    Pauses execution and waits for the user to press any key.
.OUTPUTS
    [System.Void] This function does not return a value.
#>
function pause {
    [OutputType([System.Void])] # This is an attribute, not a command. So it is enclosed in square brackets.
    param() # This is required to be here or the above OutputType attribute will cause an error.
    Write-Host "Press any key to close this window..." # Same as pause in cmd.exe
    [void][System.Console]::ReadKey($FALSE) # Read a key without displaying it and without requiring Enter
}

<#
.SYNOPSIS
    Creates a Start Menu entry for the wallpaper switcher.
.OUTPUTS
    [System.__ComObject] A WshShortcut COM object representing the created shortcut.
#>
function createStartMenuEntry {
    [OutputType([System.__ComObject])] # The COM type is WshShortcut
    param() # This is required to be here or the above OutputType attribute will cause an error.
    [string]$shortcutDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Wallpaper Switcher"
    makeDirectory -path $shortcutDir
    [string]$shortcutPath = "$shortcutDir\Wallpaper Switcher.lnk" # For current user
    [System.__ComObject]$shortcut = createShortcutToWS -shortcutPath $shortcutPath # $shortcut gets WshShortcut COM type
    Write-Host "Start Menu entries created."
    return $shortcut
}

function createDesktopShortcut {
    [OutputType([System.__ComObject])] # The COM type is WshShortcut
    param() # This is required to be here or the above OutputType attribute will cause an error.
    [string]$shortcutName = "Wallpaper Switcher" # Desired name for the shortcut
    [string]$desktopPath = [System.Environment]::GetFolderPath("Desktop") # Get the current user's desktop path, CommonDesktop can be used for all users
    [string]$shortcutPath = "$desktopPath\$shortcutName.lnk"
    [System.__ComObject]$shortcut = createShortcutToWS -shortcutPath $shortcutPath # COM type WshShortcut is assigned to $shortcut
    Write-host "Desktop shortcut created."
    return $shortcut
}

<#
.SYNOPSIS
    Performs a specified verb on a file. This DOES NOT WORK for Pin to Start or Pin to Taskbar
    because Microsoft has disabled programmatic pinning.
.PARAMETER textOfVerbToPerform
    [string] The text of the verb to perform (e.g., "Pin to Start").
.PARAMETER fileToPerformVerbOn
    [string] The file on which to perform the verb.
.OUTPUTS
    [System.Void] This function does not return a value.
#>
function performVerb
{
    [OutputType([System.Void])] # This is an attribute, not a command. So it is enclosed in square brackets.
    param (
        [string]$textOfVerbToPerform,
        [string]$fileToPerformVerbOn
    )
    [System.__ComObject]<# Folder #>$folder = $global:shellApp.NameSpace((Split-Path $fileToPerformVerbOn))
    [System.__ComObject]<# FolderItem #>$item = $folder.ParseName((Split-Path $fileToPerformVerbOn -Leaf))
    [System.__ComObject]<# FolderItemVerbs #>$verbs = $item.Verbs()
    # $verb will have type System.__ComObject and COM type FolderItemVerb
    foreach ($verb in $verbs)
    {
        write-host "pinToStartMenu: Found verb: $( $verb.Name )"
        [string]$verbPlainText = $verb.Name -replace "&", "" # Remove ampersands used for keyboard shortcuts
        if ($verbPlainText -match $textOfVerbToPerform)
        {
            $verb.DoIt()
            Write-Host "Performed: $textOfVerbToPerform."
            return
        }
    }
    throw "Failed to $textOfVerbToPerform"
}

<#
.SYNOPSIS
    Pins a shortcut to the Start Menu.

    DOES NOT WORK!!!!!!!

    Microsoft has disabled programmatic pinning because it is functionality
    that is reserved for user preferences and because it was abused by every installer.

.OUTPUTS
    [System.Void] This function does not return a value.
#>
function pinToStartMenu {
    [OutputType([System.Void])] # This is an attribute, not a command. So it is enclosed in square brackets.
    param() # This is required to be here or the above OutputType attribute will cause an error.
    performVerb "Pin to Start" "$PSScriptRoot\wallpaper-switcher.bat"
}

<#
.SYNOPSIS
    Pins a shortcut to the Taskbar.

    DOES NOT WORK!!!!!!!

    Microsoft has disabled programmatic pinning because it is functionality
    that is reserved for user preferences and because it was abused by every installer.

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
    performVerb "Pin to Taskbar" $targetShortcut.TargetPath
}

function createAllShortcuts {
    [OutputType([System.Void])] # This is an attribute, not a command. So it is enclosed in square brackets.
    param() # This is required to be here or the above OutputType attribute will cause an error.
    createStartMenuEntry
    createDesktopShortcut
}

function main {
    try {
        $global:wshShell = New-Object -ComObject WScript.Shell # $wshShell gets an object of WshShell COM type
        $global:shellApp = New-Object -ComObject Shell.Application # $shellApp gets an object of Shell COM type
        createAllShortcuts
        $status = 0
    } catch {
        Write-Error $_.Exception.Message
        Write-Error $_.ScriptStackTrace
        $status = 1
    }
    pause # Pause to allow user to see any errors before the window closes. Can't be inside try/catch because we want it to always execute.
    exit $status # We can't exit until after the pause, because we want the user to see any errors before the window closes.
}

main
