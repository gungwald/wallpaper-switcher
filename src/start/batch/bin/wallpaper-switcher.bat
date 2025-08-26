@echo off

setlocal EnableDelayedExpansion

set COMMAND_NOT_FOUND=9009
set JAVA=java
set JAR=%~dp0..\lib\wallpaper-switcher~uber.jar

if defined JAVA_HOME (
    if exist "%JAVA_HOME%"\bin\java.exe (
        set JAVA=%JAVA_HOME%\bin\java.exe
        echo Using JAVA_HOME variable.
    ) else (
        echo JAVA_HOME references a directory with no java.exe program.
    )
)

"%JAVA%" -jar "%JAR%" %*

:LOOP

if "%ERRORLEVEL%"=="%COMMAND_NOT_FOUND%" (
    call %~dp0..\libexec\find-java.bat
)

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
