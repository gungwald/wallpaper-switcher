@echo off

setlocal EnableDelayedExpansion

set COMMAND_NOT_FOUND=9009
set JAVA=java
if defined JAVA_HOME (
    if exist "%JAVA_HOME%"\bin\java.exe (
        set JAVA=%JAVA_HOME%\bin\java.exe
        echo Using JAVA_HOME variable.
    ) else (
        echo JAVA_HOME references a directory with no java.exe program.
    )
)

set JAVA=BLAH
"%JAVA%" -jar %~dp0..\lib\wallpaper-switcher~runnable.jar %*

echo.
echo.
echo ERROR: %JAVA% was not found.

:LOOP

if %ERRORLEVEL% EQU %COMMAND_NOT_FOUND% (
    echo.
    echo.
    echo ******************************* ACTION REQUIRED *******************************
    echo.
    echo Wallpaper Switcher requires Java, but it was not found. How would you like to
    echo resolve this?
    echo.
    echo 1. Search your local drives for Java
    echo 2. Download and install Java
    echo 3. Give up and quit like a loser
    echo.
    choice /c 123 /m "Choose wisely"
    if !ERRORLEVEL! EQU 1 (
        set startDir=C:\
        echo Searching for Java from directory !startDir!...
        rem This "pushd" makes it work in Wine's cmd.exe
        pushd !startDir!
        set count=0
        for /d /r %%j in (*jre*) do (
            set javaExe=%%j\bin\java.exe
            if exist "!javaExe!" (
                set javaInstances[!count!]=!javaExe!
                echo Found Java: javaInstances[!count!]. Continuing search...
                rem "!javaExe!" -version
                set /a count+=1
            ) else (
                rem echo Java at %%j is broken because it has no !javaExe!.
            )
        )
        popd
        if !count! EQU 0 (
            choice /m "Java was not found. Do you want to download and install it"
            if !ERRORLEVEL! EQU 1 (
                goto :DOWNLOAD_AND_INSTALL
            ) else (
                echo Chicken
            )
        ) else (
            set i=0
            set opts=""
            :MENU_OPTIONS_LOOP_BEGIN
            echo before if
            if defined javaInstances[!i!] (
                echo !i!. !!javaInstances[!i!]!!
                set /a i+=1
                set opts=!opts!!i!
                goto :MENU_OPTIONS_LOOP_BEGIN
            )
            echo before choice, opts=!opts!
            echo javaInstances[0]=!javaInstances[0]!
            choice /c "!opts!" /m "Which one"
            "!javaInstances[!ERRORLEVEL!]!" -jar  %~dp0..\lib\wallpaper-switcher~runnable.jar %*
        )
    )
)


endlocal

goto :EOF

        start "" /b /ProgIDOpen htmlfile https://aka.ms/download-jdk/microsoft-jdk-21.0.7-windows-x64.msi
        echo      https://learn.microsoft.com/en-us/java/openjdk/download
