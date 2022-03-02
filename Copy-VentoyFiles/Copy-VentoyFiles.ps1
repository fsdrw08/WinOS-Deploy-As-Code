# $workingPath = "D:\WinOS-Deploy-As-Code\Copy-VentoyFiles"
$workingPath = $PSScriptRoot
$DriveRootPath = Split-Path -Path $workingPath -Qualifier
Copy-Item -Path $workingPath\ventoy -Destination $DriveRootPath'\' -Recurse -Force -Verbose