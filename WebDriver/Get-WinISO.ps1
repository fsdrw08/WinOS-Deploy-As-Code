
$seleniumDownloads = "www.selenium.dev/downloads/"

$downloadLink = (Invoke-WebRequest -Uri $seleniumDownloads -UseBasicParsing).Links.Href | Where-Object {$_ -match "nuget.org/api/v2"} | Select-Object -Unique

$LastIndexof = $downloadLink.LastIndexOf("/")
$LastSecondIndexof = $downloadLink.Substring(0,$LastIndexof).LastIndexOf("/")
$packageName = $downloadLink.Substring($LastSecondIndexof+1,$LastIndexof-$LastSecondIndexof-1)
$packageVersion = $downloadLink.Substring($LastIndexof+1,$downloadLink.Length-$LastIndexof-1)
$fileName = $packageName+"."+$packageVersion+".nupkg"

$workingPath = "C:\Users\drw_0\source\repos\WinOS-Deploy-As-Code\WebDriver"

Invoke-WebRequest -Uri $downloadLink -UseBasicParsing -OutFile (Join-Path $workingPath $fileName) -Verbose

Invoke-Expression -Command "7z e (Join-Path $workingPath $fileName) -o$workingPath lib\net48\WebDriver.dll -r"

Add-Type -Path "$($workingPath)\WebDriver.dll"

$edgeDriverOptions = New-Object OpenQA.Selenium.Edge.EdgeOptions

$edgeDriverOptions.AddArguments("--user-agent=Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5355d Safari/8536.25")

$edgeDriver = New-Object OpenQA.Selenium.Edge.EdgeDriver($edgeDriverOptions)

$edgeDriver.Navigate().GoToUrl("https://www.microsoft.com/en-us/software-download/windows10ISO")

$byXPath = [OpenQA.Selenium.By]::XPath('//*[@id="product-edition"]')

$edgeDriver.FindElement([OpenQA.Selenium.By]::XPath('//*[@id="product-edition"]')).Click()

$byXPath = [OpenQA.Selenium.By]::XPath('//*[@id="submit-product-edition"]')

$edgeDriver.FindElement($byXPath).Click()




$edgeDriver.FindElement([string]"ClassName",'mscom-accordion-item-title').Click()



$edgeDriver.Quit()

$options = New-SeDriverOptions -Browser Chrome -UserAgent "Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5355d Safari/8536.25"

Start-SeDriver -Options $options -WebDriverPath "C:\Users\drw_0\source\repos\WinOS-Deploy-As-Code\WebDriver\edgedriver_win64\" 

Stop-SeDriver

Get-SeElement -By XPath 