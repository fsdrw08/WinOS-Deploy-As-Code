set "scriptpath=%~dp0"
set script=%scriptpath%firstLogonScript.ps1

powershell -ExecutionPolicy bypass -command "start-process powershell -argumentlist {-ExecutionPolicy bypass -file "%script%"} -verb runas"

pause