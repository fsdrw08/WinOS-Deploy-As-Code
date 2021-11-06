@ECHO OFF
@REM Set current=%~dp0
@REM echo current folder %current%
diskpart.exe /s %~dp0CreatePartitions-UEFI.txt
setup.exe /unattend:%~dp0unattend.xml