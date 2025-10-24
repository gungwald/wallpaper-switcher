#
# This script creates a Start Menu shortcut for a specified program.
#

# Setup variables
$targetFile = "$PSScriptRoot\wallpaper-switcher.bat"
$shortcutName = "Wallpaper Switcher" # Desired name for the shortcut
$shortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\$shortcutName.lnk" # For current user

# For all users, use:
# $shortcutPath = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\$shortcutName.lnk"

# Create the shortcut
$wshShell = New-Object -ComObject WScript.Shell
$shortcut = $wshShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $targetFile
$shortcut.Save()
Write-Host "Shortcut '$shortcutName' created at '$shortcutPath'"