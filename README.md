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
the [GPLv3](LICENSE). This protects the rights of the users and the 
developers. Here is an [explanation](https://www.gnu.org/licenses/gpl-3.0.en.html$)
of the GPLv3.

# System Requirements

1. Windows XP or above is required. 
   I want to eventually make it work on other operating systems, but 
   each operating system has its own way of installing desktop
   wallpapers/backgrounds, so they each require special code.
   
   It might work on Windows operating systems prior to Windows XP
   but I cannot test those.
   
2. Java 1.8 or above is required. You can check your version of Java by 
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
Wallpaper Switcher will still work with Java versions all the way back to 1.8.

# Install Instructions

1. Download the wallpaper-switcher.zip file.

2. Unzip wallpaper-switcher.zip to a folder of your choosing, for example:
   C:\Program Files or C:\Users\\<your-account>\opt. The "opt" folder name 
   stands for "optional software."  A wallpaper-switcher subfolder
   will automatically be created at that location for the application files.
   
3. Create Start Menu entry by running create-start-menu-entry.ps1. This will
   create a Start Menu entry that runs wallpaper-switcher.bat in the 
   current directory. You can also:
   1. Create a desktop shortcut: Right-click on wallpaper-switcher.bat and
      select Send to -> Desktop.
   2. Pin the Start Menu entry to the Taskbar or Start Menu by right-clicking
      on the shortcut and selecting Pin to Taskbar or Pin to Start.
4. (Optional) Use the Windows Scheduler to create a schedule that runs
   bin\wallpaper-switcher.bat once a day to get the latest wallpaper.
  
# Run Instructions

- If you created the Start Menu entry or shortcut in #3 above, just double-click
  it.

- (Optional) You can run wallpaper-switcher.bat by double-clicking it
  or typing its name on the command line. The batch file checks for:
  - The existence of JAVA_HOME environment variable. If it exists, it uses
    %JAVA_HOME%\bin\java.exe to run wallpaper-switcher.jar.
  - The correct version of Java (1.8 or above).

- (Optional) Run the Jar file directly. If Java is properly installed, you can
  double-click wallpaper-switcher.jar. Also, from the command line you can type:
  ```
  java -jar wallpaper-switcher.jar
  ```