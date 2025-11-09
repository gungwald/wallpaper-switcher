@echo off

rem ----------------------------------------------------------------------------
rem Generic Java Application Launcher
rem
rem Copyright (c) 2025 Bill Chatfield
rem
rem This program is free software; you can redistribute it and/or modify
rem it under the terms of the GNU General Public License as published by
rem the Free Software Foundation; either version 2 of the License, or (at
rem your option) any later version.
rem
rem This program is distributed in the hope that it will be useful, but
rem WITHOUT ANY WARRANTY; without even implied warranty of
rem MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
rem General Public License for more details.
rem
rem You should have received a copy of the GNU General Public License along
rem with this program; If not, see <http://www.gnu.org/licenses/>.
rem ----------------------------------------------------------------------------

rem DESCRIPTION:
rem This script runs any .JAR file named the same as this script but with a
rem .jar extension instead of a .bat extension. So, these script does not
rem need to be modified for each different application. Just copy this script
rem and name it the same as the .JAR file you want to run.
rem    Example: wallpaper-switcher.bat runs wallpaper-switcher.jar
rem    Example: myapp.bat runs myapp.jar

rem WHY NOT POWERSHELL?
rem This script must be written in batch because we can't depend on PowerShell
rem being enabled on the user's system. It is disabled by default by Microsoft
rem on all Windows systems because Microsoft is stupid. Why not disable CMD,
rem too, while they're at it? And .BAT files and .EXE files too. Then the
rem system would be really secure. /sarcasm


setlocal EnableDelayedExpansion

rem Define constants
set COMMAND_NOT_FOUND=9009
set REQUIRED_JAVA_VERSION=8
set JAVA_DOWNLOAD_URLS=https://adoptium.net or https://learn.microsoft.com/en-us/java/openjdk/download
set JAVA_VERSION_WITH_NATIVE_ACCESS_RESTRICTED=22

rem Determine the directory this script is in.
set SCRIPT_DIR=%~dp0
rem Remove the trailing backslash. There are cases where it is needed and
rem cases where it is not needed. Making a decision in every case would be
rem complex, so just remove it here and always add it when concatenating
rem paths. Slashes & backslashes are never stored in variables. They are
rem always added during concatenation. This eliminates confusion about
rem whether a variable contains a trailing slash or not.
set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%

rem Check if JAVA_HOME is set and points to a valid java.exe
if defined JAVA_HOME (
    if exist "%JAVA_HOME%"\bin\java.exe (
        set JAVA=%JAVA_HOME%\bin\java.exe
        echo Using JAVA_HOME=%JAVA_HOME%.
    ) else (
        echo JAVA_HOME references a directory with no java.exe program.
        echo Falling back to java from PATH.
        set JAVA=java
    )
) else (
    echo Using java from PATH.
    set JAVA=java
)

rem Extract the Java version from the "java -version" output, which is sent to
rem stderr, so redirect stderr to stdout. The version string is on the first
rem line, in the format: openjdk version "x.y.z"
rem The code below gets the third token from the first line and then exits
rem the loop.
set JAVA_VERSION_OUTPUT=
for /f "tokens=3" %%v in ('"%JAVA%" -version 2^>^&1') do (
    rem Pull out the version string and remove the quotes
    set JAVA_VERSION_OUTPUT=%%~v
    rem Exit the loop after the first line because the version is on the
    rem first line. If we don't exit here, we would get the 3rd token from
    rem all lines, and the last line would win.
    goto :JAVA_VERSION_DETECTED
)
:JAVA_VERSION_DETECTED

rem Get the major version number from the version string.
rem For version strings starting with "1.", the major version is the second
rem number (e.g., "1.8.0_292" -> 8).
rem For version strings starting with a number greater than "1.", the major
rem version is the first number (e.g., "11.0.11" -> 11).
set JAVA_MAJOR_VERSION=
if "%JAVA_VERSION_OUTPUT:~0,2%"=="1." (
    for /f "tokens=2 delims==." %%m in ("%JAVA_VERSION_OUTPUT%") do (
        set JAVA_MAJOR_VERSION=%%m
    )
) else (
    for /f "tokens=1 delims==." %%m in ("%JAVA_VERSION_OUTPUT%") do (
        set JAVA_MAJOR_VERSION=%%m
    )
)

rem Compare the major version number to the required version. The arguments
rem must be numeric to get a numeric comparison. So they can't be surrounded
rem by quotes. This means that if the version detection failed, the first
rem argument will be empty, which will cause a syntax error. A potential
rem solution would be to surround them both with zeros instead of quotes.
if %JAVA_MAJOR_VERSION% LSS %REQUIRED_JAVA_VERSION% (
    echo.
    echo %~n0 requires Java %REQUIRED_JAVA_VERSION% or higher.
    echo     Detected version: %JAVA_VERSION_OUTPUT%
    echo     Detected major version: %JAVA_MAJOR_VERSION%
    echo.
    echo Please upgrade Java. You can download it from
    echo %JAVA_DOWNLOAD_URLS%.
    echo.
    goto :CHECK_FOR_PAUSE_AT_END
)

if %JAVA_MAJOR_VERSION% GEQ %JAVA_VERSION_WITH_NATIVE_ACCESS_RESTRICTED% (
    set JVM_OPTS=%JVM_OPTS% --enable-native-access=ALL-UNNAMED
)

rem Locate the JAR file. Check in the same directory as this script,
rem then in ../lib, then in ../share/java.
set JAR=
for %%L in ("%SCRIPT_DIR%" "%SCRIPT_DIR%\..\lib" "%SCRIPT_DIR%\..\share\java") do (
    if exist "%%~L\%~n0.jar" (
        set JAR=%%~L\%~n0.jar
    )
)
if not defined JAR (
    echo Could not find %~n0.jar in %~dp0 or %~dp0..\lib or %~dp0..\share\java.
    goto :CHECK_FOR_PAUSE_AT_END
)

rem Run the Java application
echo Starting %JAR%...
"%JAVA%" %JVM_OPTS% -jar "%JAR%" %*

rem Check if the java command was not found
if "%ERRORLEVEL%"=="%COMMAND_NOT_FOUND%" (
    echo Java was not found. Please install Java or set the JAVA_HOME environment
    echo variable to the directory where Java is installed. You can download Java
    echo from %JAVA_DOWNLOAD_URLS%.
)

:CHECK_FOR_PAUSE_AT_END

rem This determines whether it has been double-clicked as an icon in Windows
rem so that it is known that a prompt is needed to stop the Command Prompt
rem window from closing before the user can see what it says. There might be
rem an error that the user needs to see. There might be a final message that
rem is important. And it generally is frustrating to users when windows
rem disappear before they can read the text.
for /f "tokens=2" %%a in ("%CMDCMDLINE%") do (
    if "%%a"=="/c" (
        pause
    )
)

rem This can be set before calling this script to ensure a pause happens.
if "%PAUSE_AT_END%"=="true" pause

endlocal
