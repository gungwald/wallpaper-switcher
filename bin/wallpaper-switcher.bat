@echo off
rem Builds the classpath and starts Java, specifying the main class
rem as the same name as this file. This is completely generic.
setlocal enabledelayedexpansion
rem set MAINCLASS=%~n0
set TOPDIR=%~dp0..
set BINDIR=%TOPDIR%\bin
set LIBDIR=%TOPDIR%\lib
set JAR=%LIBDIR%\wallpaper-switcher.jar
rem eet CLASSPATH=%TOPDIR%\classes
rem title %MAINCLASS%
rem for %%j in ("%TOPDIR%\lib\*.jar") do set CLASSPATH=!CLASSPATH!;%%~j
rem java -classpath "%CLASSPATH%" %MAINCLASS%
java -jar %JAR% %*
endlocal
