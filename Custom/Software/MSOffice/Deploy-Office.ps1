$downloadLink = "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_14326-20404.exe"
$destination = $PSScriptRoot
Start-BitsTransfer -Source $downloadLink -Destination $destination\officedeploymenttool.exe

Start-Sleep -Seconds 3
# extra the deployment tool
. $destination\officedeploymenttool.exe /quiet /extract:$destination\

Start-Sleep -Seconds 3
. $destination\setup.exe /download .\Configuration.xml