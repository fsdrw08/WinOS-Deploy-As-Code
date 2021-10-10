
$workingPath = "$env:userprofile\source\repos\WinOS-Deploy-As-Code\WebDriver"
# $workingPath = $PSScriptRoot

if ((Test-Path $workingPath\WebDriver.dll) -and (Test-Path $workingPath\msedgedriver.exe)) {
    "$true"
}

Add-Type -Path "$($workingPath)\WebDriver.dll"

$edgeDriverOptions = New-Object OpenQA.Selenium.Edge.EdgeOptions

$edgeDriverOptions.AddArguments("--user-agent=Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5355d Safari/8536.25")

$edgeDriver = New-Object OpenQA.Selenium.Edge.EdgeDriver($edgeDriverOptions)

$edgeDriver.Navigate().GoToUrl("https://www.microsoft.com/en-us/software-download/windows10ISO")

Start-Sleep -Seconds 3

# 2021 may update
$edgeDriver.FindElement([OpenQA.Selenium.By]::XPath('//*[@id="product-edition"]/optgroup/option[@value="2033"]')).Click()

$edgeDriver.FindElement([OpenQA.Selenium.By]::XPath('//*[@id="submit-product-edition"]')).Click()

Start-Sleep -Seconds 3

# en-us
$edgeDriver.FindElement([OpenQA.Selenium.By]::XPath('//*[@id="product-languages"]/option[11]')).Click()

$edgeDriver.FindElement([OpenQA.Selenium.By]::XPath('//*[@id="submit-sku"]')).Click()

Start-Sleep -Seconds 5

$ISODownloadLink = $edgeDriver.FindElement([OpenQA.Selenium.By]::XPath('//*[@id="card-info-content"]/div/div[1]/div/a')).getattribute('href')

$correctISODownloadLink = $ISODownloadLink.Replace("x32.iso","x64.iso")

$ISODownloadLink
$correctISODownloadLink

$edgeDriver.Quit()

$indexofFirstLetter = $ISODownloadLink.Substring(0,$ISODownloadLink.IndexOf("?")).LastIndexOf("/")+1

$lengthOfFileName = $ISODownloadLink.IndexOf("?")-$indexofFirstLetter

$isoFileName = $ISODownloadLink.Substring($indexofFirstLetter,$lengthOfFileName)

Start-BitsTransfer -Source $ISODownloadLink -Destination (Join-Path "C:\Users\drw_0\source\repos\WinOS-Deploy-As-Code\" $isoFileName) -Confirm -WhatIf
