@ECHO off 

call :Main %* & exit /b

:Trim
SetLocal EnableDelayedExpansion
set Params=%*
for /f "tokens=1*" %%a in ("!Params!") do EndLocal & set %1=%%b
exit /b

:Main
set PRIO=below normal 

IF NOT "%1"=="" SET NAME=%1
SHIFT

IF NOT "%1"=="" SET PRIO=%1
SHIFT

REM SET PRIO=%PRIO: =%
IF NOT "%1"=="" SET PRIO=%PRIO% %1

REM for /l %%a in (1,1,31) do if "!PRIO:~-1!"==" " set PRIO=!PRIO:~0,-1!

call :Trim PRIO %PRIO%

REM SET PRIO=%PRIO:##=#%
REM SET PRIO=%PRIO:  ##=##%
REM SET PRIO=%PRIO: ##=##%
REM SET PRIO=%PRIO:##=%
REM SET PRIO=%PRIO: ##=##%


ECHO on
wmic process where name="%NAME%" CALL setpriority "%PRIO%"
@echo OFF
exit /b
