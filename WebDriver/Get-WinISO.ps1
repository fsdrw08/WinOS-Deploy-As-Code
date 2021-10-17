
$workingPath = "$env:userprofile\source\repos\WinOS-Deploy-As-Code\WebDriver"
# $workingPath = $PSScriptRoot

if ((Test-Path $workingPath\WebDriver.dll) -and (Test-Path $workingPath\msedgedriver.exe)) {
    "$true"
}

Add-Type -Path "$($workingPath)\WebDriver.dll"
Add-Type -Path "$($workingPath)\WebDriver.Support.dll" -PassThru

$edgeDriverOptions = New-Object OpenQA.Selenium.Edge.EdgeOptions

$edgeDriverOptions.AddArguments("--user-agent=Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5355d Safari/8536.25")

$edgeDriver = New-Object OpenQA.Selenium.Edge.EdgeDriver($edgeDriverOptions)

$edgeDriver.Navigate().GoToUrl("https://www.microsoft.com/en-us/software-download/windows10ISO")

# Select edition drop down list (Windows 10)
# $edgeDriver.FindElement([OpenQA.Selenium.By]::XPath('//*[@id="product-edition"]/optgroup/option[@value="2033"]')).Click()
# use selectbytext instead <- should be more stable than find by xpath (value is not constant)
[OpenQA.Selenium.Support.UI.WebDriverWait]$edgeDriver_Wait =  New-Object -TypeName OpenQA.Selenium.Support.UI.WebDriverWait($edgeDriver, (New-TimeSpan -Seconds 1))
$edgeDriver_Wait.PollingInterval = 500
# [OpenQA.Selenium.Support.UI.WebDriverWait]::new($edgeDriver, (New-TimeSpan -Seconds 3))
# Unable to find type: sealed class ExpectedConditions?
[void]$edgeDriver_Wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::Id("product-edition")))

$proEdition_Element = $edgeDriver.FindElement([OpenQA.Selenium.By]::Id("product-edition"))
$proEdition_Selection = [OpenQA.Selenium.Support.UI.SelectElement]::new($proEdition_Element)
$proEdition_Selection.SelectByText("Windows 10")
Start-Sleep -Seconds 1
$edgeDriver.FindElement([OpenQA.Selenium.By]::XPath('//*[@id="submit-product-edition"]')).Click()

# Start-Sleep -Seconds 3

# Select the product language (English)
# [OpenQA.Selenium.Support.UI.WebDriverWait]$prodLanguage_Wait = New-Object -TypeName OpenQA.Selenium.Support.UI.WebDriverWait($edgeDriver, (New-TimeSpan -Seconds 1))
# [OpenQA.Selenium.Support.UI.WebDriverWait]::new($edgeDriver, (New-TimeSpan -Seconds 3))
$null = [void]$edgeDriver_Wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::Id("product-languages")))
# $edgeDriver.FindElement([OpenQA.Selenium.By]::XPath('//*[@id="product-languages"]/option[11]')).Click()
# https://sqa.stackexchange.com/a/46477
$prodLanguage_Element = $edgeDriver.FindElement([OpenQA.Selenium.By]::Id("product-languages"))
$prodLanguage_Selection = [OpenQA.Selenium.Support.UI.SelectElement]::new($prodLanguage_Element)
$prodLanguage_Selection.SelectByText("English")
Start-Sleep -Seconds 1
$edgeDriver.FindElement([OpenQA.Selenium.By]::XPath('//*[@id="submit-sku"]')).Click()

# Start-Sleep -Seconds 5

# Select download link
# https://stackoverflow.com/a/64504671/10833894
$downloadLink = $null
# [OpenQA.Selenium.Support.UI.WebDriverWait]::new($edgeDriver, (New-TimeSpan -Seconds 3))
# [OpenQA.Selenium.Support.UI.WebDriverWait]$downloadLink_Wait = New-Object -TypeName OpenQA.Selenium.Support.UI.WebDriverWait($edgeDriver, (New-TimeSpan -Seconds 1))
# $null = [void]$edgeDriver_Wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::PartialLinkText("64-bit")))
$null = [void]$edgeDriver_Wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::XPath('//a[contains(@href,"iso")]')))
$downloadLink = $edgeDriver.FindElements([OpenQA.Selenium.By]::PartialLinkText("64-bit")).GetAttribute('href')
$downloadLink

$edgeDriver.Quit()

$indexofFirstLetter = $downloadLink.Substring(0,$downloadLink.IndexOf("?")).LastIndexOf("/")+1

$lengthOfFileName = $downloadLink.IndexOf("?")-$indexofFirstLetter

$isoFileName = $downloadLink.Substring($indexofFirstLetter,$lengthOfFileName)

Start-BitsTransfer -Source $downloadLink -Destination (Join-Path (Split-Path $workingPath) $isoFileName) -Confirm -WhatIf
