# $workingPath = "D:\WinOS-Deploy-As-Code\Copy-VentoyFiles"
$workingPath = $PSScriptRoot
$DriveRootPath = $workingPath.Substring(0,3)
Copy-Item -Path $workingPath\ventoy -Destination $DriveRootPath -Recurse -Force -Verbose