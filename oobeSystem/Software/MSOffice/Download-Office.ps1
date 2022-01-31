# $workingPath = "D:\WinOS-Deploy-As-Code\oobeSystem\Software\MSOffice"
$workingPath = $PSScriptRoot

if (!(Test-Path "$workingPath\officedeploymenttool*.exe")) {
    . $workingPath\Download-ODT.ps1
}

$odtexe = Get-ChildItem $workingPath | Where-Object -FilterScript {$_.Name -like 'officedeploymenttool*.exe'} | Select-Object -ExpandProperty Name

Start-Sleep -Seconds 3
# extra the deployment tool
. "$workingPath\$odtexe" /quiet /extract:$workingPath\

# https://docs.microsoft.com/en-us/DeployOffice/overview-office-deployment-tool#get-started-with-the-office-deployment-tool
Start-Sleep -Seconds 3
Set-Location $workingPath
. .\setup.exe /download $workingPath\Configuration.xml
# . .\setup.exe /configure $workingPath\Configuration.xml