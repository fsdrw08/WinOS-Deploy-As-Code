
# $workingPath = "D:\WinOS-Deploy-As-Code\WebDriver"
$workingPath = $PSScriptRoot
if (!(Test-Path "$($workingPath)\WebDriver.dll") -or !(Test-Path "$($workingPath)\WebDriver.Support.dll")) {
. $PSScriptRoot\Get-WebDriver.ps1
}

Add-Type -Path "$workingPath\WebDriver.dll"
Add-Type -Path "$workingPath\WebDriver.Support.dll"

$url = "https://docs.microsoft.com/en-us/officeupdates/odt-release-history"

$edgeDriverOptions = New-Object OpenQA.Selenium.Edge.EdgeOptions

# https://csharp.hotexamples.com/examples/OpenQA.Selenium.Chrome/ChromeOptions/AddUserProfilePreference/php-chromeoptions-adduserprofilepreference-method-examples.html
# https://stackoverflow.com/questions/61608942/selenium-edge-chromium-browser-direct-option-to-set-default-download-path/70847078#70847078
$edgeDriverOptions.AddUserProfilePreference("download.default_directory", "D:\WinOS-Deploy-As-Code\oobeSystem\Software\MSOffice")
$edgeDriver = New-Object OpenQA.Selenium.Edge.EdgeDriver($edgeDriverOptions)
$edgeDriver.Navigate().GoToUrl("$url")

# https://coderoad.ru/38360545/%D0%9C%D0%BE%D0%B6%D0%BD%D0%BE-%D0%BB%D0%B8-%D0%B8%D1%81%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D0%BE%D0%B2%D0%B0%D1%82%D1%8C-LINQ-%D0%B2-PowerShell
# http://reza-aghaei.com/net-action-func-delegate-lambda-expression-in-powershell/
# https://www.selenium.dev/selenium/docs/api/dotnet/?topic=html/T_OpenQA_Selenium_Support_UI_WebDriverWait.htm

# https://www.softwaretestinghelp.com/selenium-find-element-by-text/#Difference_between_Text_Link_Text_and_Partial_Link_Text_Methods
$edgeDriver.FindElement([OpenQA.Selenium.By]::XPath("//*[contains(text(),'Download Office Deployment Tool')]")).Click()

$edgeDriver.Quit()

$downloadLink = "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_14527-20178.exe"
$destination = $PSScriptRoot
Start-BitsTransfer -Source $downloadLink -Destination $destination\officedeploymenttool.exe

Start-Sleep -Seconds 3
# extra the deployment tool
. $destination\officedeploymenttool.exe /quiet /extract:$destination\

Start-Sleep -Seconds 3
. $destination\setup.exe /download .\Configuration.xml