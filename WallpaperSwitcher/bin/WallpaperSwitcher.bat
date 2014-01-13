@echo off
rem Builds the classpath and starts Java, specifying the main class
rem as the same name as this file. This is completely generic.
setlocal enabledelayedexpansion
set MAINCLASS=%~n0
set TOPDIR=%~dp0..
set CLASSPATH=%TOPDIR%\classes
title %MAINCLASS%
for %%j in ("%TOPDIR%\lib\*.jar") do set CLASSPATH=!CLASSPATH!;%%~j
java -classpath %CLASSPATH% %MAINCLASS%
endlocal
