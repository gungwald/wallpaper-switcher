@echo off

rem Some JVMs require this to allow access to native code.
rem If your JVM does not require this, you can comment out this line.
rem If your JVM requires other options, you can add them here.
set JVM_OPTS=--enable-native-access=ALL-UNNAMED

setlocal EnableDelayedExpansion

rem Constants
set COMMAND_NOT_FOUND=9009
set REQUIRED_JAVA_VERSION=8
set JAVA_DOWNLOAD_URLS=https://adoptium.net or https://learn.microsoft.com/en-us/java/openjdk/download

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

rem Check if Java version is high enough to run the application.
rem Copilot couldn't get this right, but I did. I wrote it before Copilot
rem even existed.
set JAVA_VERSION_OUTPUT=
for /f "tokens=3" %%v in ('"%JAVA%" -version 2^>^&1') do (
    set JAVA_VERSION_OUTPUT=%%~v
)
for /f "tokens=2 delims==." %%a in ("%JAVA_VERSION_OUTPUT%") do (
    set JAVA_MAJOR_VERSION=%%a
)
if "%JAVA_MAJOR_VERSION%" LSS "%REQUIRED_JAVA_VERSION%" (
    echo.
    echo Wallpaper Switcher requires Java %REQUIRED_JAVA_VERSION% or higher. Detected version: %JAVA_VERSION_OUTPUT%
    echo Please upgrade Java. You can download it from
    echo %JAVA_DOWNLOAD_URLS%.
    echo.
    goto :CHECK_FOR_PAUSE_AT_END
)

rem Locate the JAR file
set JAR=
for %%L in ("%~dp0" "%~dp0..\lib" "%~dp0..\share\java") do (
    if exist "%%~L\%~n0.jar" (
        set JAR=%%~L\%~n0.jar
    )
)
if not defined JAR (
    echo Could not find %~n0.jar in %~dp0 or %~dp0..\lib or %~dp0..\share\java.
    goto :CHECK_FOR_PAUSE_AT_END
)

echo Starting Wallpaper Switcher...
"%JAVA%" %JVM_OPTS% -jar "%JAR%" %*

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

rem Another option to force a pause at the end.
if "%PAUSE_AT_END%"=="true" pause

endlocal
