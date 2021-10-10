
$workingPath = "$env:userprofile\source\repos\WinOS-Deploy-As-Code\WebDriver"

"Detect OS Architecture, .Net version and EDGE browser version"

$OSArchitecture = (Get-CimInstance Win32_operatingsystem).OSArchitecture

# https://stackoverflow.com/questions/3344855/which-net-version-is-my-powershell-script-using
if ($DotNetVersion = [System.Runtime.InteropServices.RuntimeInformation]::FrameworkDescription) {
    $DotNetVersion = $DotNetVersion = [System.Runtime.InteropServices.RuntimeInformation]::FrameworkDescription
}  else {
    $DotNetVersion = [System.Runtime.InteropServices.RuntimeInformation, mscorlib]::FrameworkDescription
}

switch ($OSArchitecture) {
    # https://www.tenforums.com/tutorials/161325-how-find-version-microsoft-edge-chromium-installed.html
    # https://devblogs.microsoft.com/scripting/use-powershell-to-look-for-phone-numbers-in-text/
    # https://msedgewebdriverstorage.z22.web.core.windows.net/
    "64-bit" { 
        $msedgeVersion = Get-ChildItem "C:\Program Files (x86)\Microsoft\Edge\Application" | `
                            Where-Object {$_.Name -match "^\d"} | `
                            Select-Object -ExpandProperty name 
        $msedgeDriver_Link = "https://msedgedriver.azureedge.net/$($msedgeVersion)/edgedriver_win64.zip"
                        }
    "32-bit" { 
        $msedgeVersion = Get-ChildItem "C:\Program Files\Microsoft\Edge\Application" | `
                            Where-Object {$_.Name -match "^\d"} | `
                            Select-Object -ExpandProperty name 
        $msedgeDriver_Link = "https://msedgedriver.azureedge.net/$($msedgeVersion)/edgedriver_win32.zip"
                        }
    Default {}
}

$msedgeDriver_Link

"Download edge webdriver"
Start-BitsTransfer -Source $msedgeDriver_Link -Destination (Join-Path $workingPath "edgedriver.zip")

"extract msedgedriver.exe"
Invoke-Expression -Command "7z e (Join-Path $workingPath 'edgedriver.zip') -o$workingPath msedgedriver.exe -r"


"detect selenium web driver download link and file name"
$SeDriver_Site = "www.selenium.dev/downloads/"
$SeDriver_Link = (Invoke-WebRequest -Uri $SeDriver_Site -UseBasicParsing).Links.Href | Where-Object {$_ -match "nuget.org/api/v2"} | Select-Object -Unique

$LastIndexof = $SeDriver_Link.LastIndexOf("/")
$LastSecondIndexof = $SeDriver_Link.Substring(0,$LastIndexof).LastIndexOf("/")
$packageName = $SeDriver_Link.Substring($LastSecondIndexof+1,$LastIndexof-$LastSecondIndexof-1)
$packageVersion = $SeDriver_Link.Substring($LastIndexof+1,$SeDriver_Link.Length-$LastIndexof-1)
$SeDriver_nupkg = $packageName+"."+$packageVersion+".nupkg"

"selenium nupkg download link and file name"
$SeDriver_Link
$SeDriver_nupkg

Invoke-WebRequest -Uri $SeDriver_Link -UseBasicParsing -OutFile (Join-Path $workingPath $SeDriver_nupkg) -Verbose

$targetDLL = "net" + ($DotNetVersion -replace "[^\d]", '').Substring(0,2)

if ($targetDLL) {
    Invoke-Expression -Command "7z e (Join-Path $($workingPath) $($SeDriver_nupkg)) -o$workingPath lib\$($targetDll)\WebDriver.dll -r"
}

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
