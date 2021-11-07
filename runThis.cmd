@ECHO OFF
@REM Set current=%~dp0
@REM echo current folder %current%

:CONFIRM
@REM https://stackoverflow.com/a/11094120/10833894
CHOICE /T 5 /C YN /D N /M "Are you confirm to DELETE ALL DATA IN THE COMPUTER DISK? "
GOTO OPTION-%ERRORLEVEL%
@REM IF %ERRORLEVEL% ==1 GOTO OPTION-1
@REM IF %ERRORLEVEL% ==2 GOTO OPTION-2

:OPTION-1
echo "diskpart.exe /s %~dp0CreatePartitions-UEFI.txt"
echo "setup.exe /unattend:%~dp0unattend.xml"

:OPTION-2
EXIT