
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

Start-Sleep -Seconds 5

$edgeDriver.FindElement([OpenQA.Selenium.By]::XPath('//*[@id="product-edition"]/optgroup/option[@value="2033"]')).Click()

$edgeDriver.FindElement([OpenQA.Selenium.By]::XPath('//*[@id="submit-product-edition"]')).Click()

Start-Sleep -Seconds 7

$edgeDriver.FindElement([OpenQA.Selenium.By]::XPath('//*[@id="product-languages"]/option[11]')).Click()

$edgeDriver.FindElement([OpenQA.Selenium.By]::XPath('//*[@id="submit-sku"]')).Click()

Start-Sleep -Seconds 7

$link = $edgeDriver.FindElement([OpenQA.Selenium.By]::XPath('//*[@id="card-info-content"]/div/div[1]/div/a')).getattribute('href')

$edgeDriver.Quit()

$indexofFirstLetter = $link.Substring(0,$link.IndexOf("?")).LastIndexOf("/")+1

$lengthOfFileName = $link.IndexOf("?")-$indexofFirstLetter

$fileName = $link.Substring($indexofFirstLetter,$lengthOfFileName)

Start-BitsTransfer -Source $link -Destination (Join-Path "C:\Users\drw_0\source\repos\WinOS-Deploy-As-Code\" $fileName)
