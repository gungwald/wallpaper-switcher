# Wallpaper Switcher

This program downloads the Bing wallpaper of the day and installs it as 
the desktop background. 

It is also stored in
C:\Users\\<your-account>\Pictures\Wallpaper Switcher,
in case you want to use it later. But, these pictures are only copyrighted
for use as your desktop background/wallpaper. You can't use them for anything
else.

# License
Wallpaper Switcher is free and open source software, distributed under 
the [GPL3](LICENSE). This protects the rights of the users and the 
developers.

# System Requirements

1. Windows XP or above is required. 
   I want to eventually make it work on other operating systems, but 
   each operating system has its own way of installing desktop
   wallpapers/backgrounds, so they each require special code.
   
   It might work on Windows operating systems prior to Windows XP
   but I cannot test those.
   
2. Java 1.6 or above is required. You can check your version of Java by 
   opening a Command Prompt and typing "java -version":
   1. Hold down the Windows Key and press "R".
   2. Type "cmd" and hit the [Enter] key.
   3. Type "java -version" and hit the [Enter] key.
        
   Output looks similar to this, with the version in the first line:
   ```` 
   java version "1.7.0_45"
   Java(TM) SE Runtime Environment (build 1.7.0_45-b18)
   Java HotSpot(TM) 64-Bit Server VM (build 24.45-b08, mixed mode)
   ````

# Recommend Software

If you have a supported version of Windows (Windows 10 or 11 as of the time of
this writing), then
the latest version of Java is recommended. It can be downloaded from 
[Microsoft](https://learn.microsoft.com/en-us/java/openjdk/download)
for Windows on Intel/AMD or ARM.

If you have an older version of Windows, the latest version of Java may not work.
Wallpaper Switcher will still work with Java versions all the way back to 1.6.

# Install Instructions

1. Download the wallpaper-switcher.zip file.

2. Unzip wallpaper-switcher.zip to a folder of your choosing, for example:
   C:\Program Files or C:\Users\\<your-account>\opt. The "opt" folder name 
   stands for "optional software."  A wallpaper-switcher subfolder
   will automatically be created at that location for the application files.
   
3. Create a desktop shortcut to bin\wallpaper-switcher.bat.
   Right-click 
   on bin\wallpaper-switcher.bat and select Send to -> Desktop.
   You can give the shortcut the name "Wallpaper Switcher".
4. (Optional) Use the Windows Scheduler to create a schedule that runs
   bin\wallpaper-switcher.bat once a day to get the latest wallpaper.
  
# Run Instructions
## From the Desktop

- If you created the shortcut in #3 above, just double-click the shortcut.

- (Optional) If not, then double-click 
   C:\Program Files\wallpaper-switcher\bin\wallpaper-switcher.bat.
   Replace C:\Program Files above with the folder you unzipped it to if
   you did not unzip it to C:\Program Files.
- (Optional) If Java is properly installed, you should be able to
  double-click lib\wallpaper-switcher.jar. The bin\wallpaper-switch.bat
  is really only a convenience file for some use-cases. The jar file
  is the real "executable" program file.
   
## From the Command Line
There are multiple options:
- cd to the wallpaper-switcher\bin folder and type .\wallpaper-switcher
- Add the wallpaper-switcher\bin directory to your PATH. Then you can
type wallpaper-switcher from any location to invoke wallpaper-switcher.bat
- You can directly invoke the jar file:
  ```
  java -jar <path-to-install-dir>\lib\wallpaper-switcher.jar
  ```