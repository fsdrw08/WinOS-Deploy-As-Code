@ECHO OFF
@REM Set current=%~dp0
@REM echo current folder %current%

:CONFIRM
ECHO Are you confirm to DELETE ALL DATA IN THE COMPUTER DISK?
SET /p choice=Y or N?
IF '%choice%'=='Y' GOTO :choice1
IF '%choice%'=='N' GOTO :choice2
@REM https://stackoverflow.com/a/11094120/10833894
@REM CHOICE /T 5 /C YN /D N /M "Are you confirm to DELETE ALL DATA IN THE COMPUTER DISK? "
@REM GOTO OPTION-%ERRORLEVEL%
@REM IF %ERRORLEVEL% ==1 GOTO OPTION-1
@REM IF %ERRORLEVEL% ==2 GOTO OPTION-2

:choice1
diskpart.exe /s %~dp0Initialize-UEFIPartitions.txt
setup.exe /unattend:%~dp0unattend.xml
:choice2
EXIT
:end
EXIT