[CmdletBinding()]
param (
    [Parameter()]
    [ValidateSet('10','11')]
    [int16]
    $WindowsVersion = "10",
    [Parameter()]
    [string]
    $Language="English"
)
begin {

    # $workingPath = "D:\WinOS-Deploy-As-Code\Download-WinISO"
    $workingPath = $PSScriptRoot
    $webDriverPath = Split-Path -Path $workingPath  | Join-Path -ChildPath "WebDriver"

    if (!(Test-Path "$($webDriverPath)\WebDriver.dll") -or !(Test-Path "$webDriverPath\WebDriver.Support.dll")) {
    . $webDriverPath\Download-WebDriver.ps1
    }

    Add-Type -Path "$webDriverPath\WebDriver.dll"
    Add-Type -Path "$webDriverPath\WebDriver.Support.dll" #-PassThru
    # ref: https://github.com/sergueik/powershell_selenium/blob/master/powershell/page_ready.ps1
    # Add-Type -TypeDefinition @"
    # using System;
    # using System.Collections.Generic;
    # using System.Text;
    # using OpenQA.Selenium;
    # namespace PSCustom.Selenium.Support.UI
    # {
    #     public static class WebDriverWait
    #     {
    #         // Based on c# extension method. 
    #         // NOTE: no signature change, makine this method no longer be extension method
    #         public static void Until(IWebDriver driver, string by, string target) {
    #             var webDriverWait = new OpenQA.Selenium.Support.UI.WebDriverWait(driver, TimeSpan.FromSeconds(30.00));
    #             webDriverWait.PollingInterval = TimeSpan.FromSeconds(0.50);
    #             if (by == "Id") {
    #                 webDriverWait.Until(lamda => lamda.FindElement(By.Id(target)));
    #             }
    #             if (by == "PartialLinkText") {
    #                 webDriverWait.Until(lamda => lamda.FindElement(By.PartialLinkText(target)));
    #             }
    #         }
    #     }
    # }
    # "@ -ReferencedAssemblies 'System.dll','System.Data.dll', "$webDriverPath\WebDriver.dll","$webDriverPath\WebDriver.Support.dll"

    $edgeDriverOptions = New-Object OpenQA.Selenium.Edge.EdgeOptions

    # ref Directly Download Latest Windows 10 WIM-BASE ISO from Microsoft
    # https://www.tenforums.com/tutorials/9230-download-windows-10-iso-file.html#option3
    $edgeDriverOptions.AddArguments("--user-agent=Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5355d Safari/8536.25")

    switch ($WindowsVersion) {
        "11" {
            $url = "https://www.microsoft.com/en-us/software-download/windows11"
          }
        "10" {
            $url = "https://www.microsoft.com/en-us/software-download/windows10ISO"
          }
        Default {
            $url = "https://www.microsoft.com/en-us/software-download/windows10ISO"
        }
    }
}

process {
    $edgeDriver = New-Object OpenQA.Selenium.Edge.EdgeDriver($edgeDriverOptions)
    
    $edgeDriver.Navigate().GoToUrl("$url")
    
    # Select edition drop down list (Windows 10)
    # $edgeDriver.FindElement([OpenQA.Selenium.By]::XPath('//*[@id="product-edition"]/optgroup/option[@value="2033"]')).Click()
    # use selectbytext instead <- should be more stable than find by xpath (value is not constant)
    [OpenQA.Selenium.Support.UI.WebDriverWait]$edgeDriver_Wait =  New-Object -TypeName OpenQA.Selenium.Support.UI.WebDriverWait($edgeDriver, (New-TimeSpan -Seconds 10))
    $edgeDriver_Wait.PollingInterval = New-TimeSpan -Seconds 1
    
    function Find-Element {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $true)]
            [ValidateNotNullOrEmpty()]
            [OpenQA.Selenium.Edge.EdgeDriver]$EdgeDriver,
            [Parameter(Mandatory = $true)]
            [ValidateNotNullOrEmpty()]
            [ValidateSet('Id','PartialLinkText')]
            [string]$by,
            [Parameter(Mandatory = $true)]
            [ValidateNotNullOrEmpty()]
            [string]$target
        )
        return $EdgeDriver.FindElement([OpenQA.Selenium.By]::$by($target))
    }
    
    # https://coderoad.ru/38360545/%D0%9C%D0%BE%D0%B6%D0%BD%D0%BE-%D0%BB%D0%B8-%D0%B8%D1%81%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D0%BE%D0%B2%D0%B0%D1%82%D1%8C-LINQ-%D0%B2-PowerShell
    # http://reza-aghaei.com/net-action-func-delegate-lambda-expression-in-powershell/
    # https://www.selenium.dev/selenium/docs/api/dotnet/?topic=html/T_OpenQA_Selenium_Support_UI_WebDriverWait.htm
    $proEdition_Element = $edgeDriver_Wait.Until([Func[object,OpenQA.Selenium.WebElement]]{
        param($edgeDriver)
            Find-Element -EdgeDriver $edgeDriver -by "Id" -target "product-edition" -ErrorAction SilentlyContinue
    })
    # $proEdition_Element = $edgeDriver.FindElement([OpenQA.Selenium.By]::Id("product-edition"))
    $proEdition_Selection = [OpenQA.Selenium.Support.UI.SelectElement]::new($proEdition_Element)
    # $proEdition_Selection.SelectByText("Windows $WindowsVersion *")
    $proEdition_Selection.SelectByIndex(1)
    # Start-Sleep -Seconds 1
    $edgeDriver.FindElement([OpenQA.Selenium.By]::XPath('//*[@id="submit-product-edition"]')).Click()
    
    # Start-Sleep -Seconds 3
    
    # Select the product language (English by default)
    # $edgeDriver.FindElement([OpenQA.Selenium.By]::XPath('//*[@id="product-languages"]/option[11]')).Click()
    # https://sqa.stackexchange.com/a/46477
    # [PSCustom.Selenium.Support.UI.WebDriverWait]::Until($edgeDriver, "Id", "product-languages")
    $prodLanguage_Element = $edgeDriver_Wait.Until([Func[object,OpenQA.Selenium.WebElement]]{
        param($edgeDriver)
        Find-Element -EdgeDriver $edgeDriver -by "Id" -target "product-languages" -ErrorAction SilentlyContinue
    })
    # $prodLanguage_Element = $edgeDriver.FindElement([OpenQA.Selenium.By]::Id("product-languages"))
    $prodLanguage_Selection = [OpenQA.Selenium.Support.UI.SelectElement]::new($prodLanguage_Element)
    $prodLanguage_Selection.SelectByText("$Language")
    Start-Sleep -Seconds 1
    $edgeDriver.FindElement([OpenQA.Selenium.By]::XPath('//*[@id="submit-sku"]')).Click()
    
    # Start-Sleep -Seconds 5
    
    # Select download link
    # https://stackoverflow.com/a/64504671/10833894
    $downloadLink = $null
    # $null = [void]$edgeDriver_Wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::PartialLinkText("64-bit")))
    # $null = [void]$edgeDriver_Wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::XPath('//a[contains(@href,"iso")]')))
    # [PSCustom.Selenium.Support.UI.WebDriverWait]::Until($edgeDriver, "PartialLinkText", "64-bit")
    $downloadLink_Element = $edgeDriver_Wait.Until([Func[object,OpenQA.Selenium.WebElement]]{
        param($edgeDriver)
        Find-Element -EdgeDriver $edgeDriver -by "PartialLinkText" -target "64-bit" -ErrorAction SilentlyContinue
    })
    $downloadLink = $downloadLink_Element.GetAttribute('href')
}

end {
    # https://stackoverflow.com/questions/45470999/powershell-try-catch-and-retry
    function Retry-Command {
        [CmdletBinding()]
        Param(
            [Parameter(Position=0, Mandatory=$true)]
            [scriptblock]$ScriptBlock,
    
            [Parameter(Position=1, Mandatory=$false)]
            [int]$Maximum = 5,
    
            [Parameter(Position=2, Mandatory=$false)]
            [int]$Delay = 500
        )
    
        Begin {
            $cnt = 0
        }
    
        Process {
            do {
                $cnt++
                try {
                    $ScriptBlock.Invoke()
                    return
                } catch {
                    Write-Error $_.Exception.InnerException.Message -ErrorAction Continue
                    Start-Sleep -Milliseconds $Delay
                }
            } while ($cnt -lt $Maximum)
    
            # Throw an error after $Maximum unsuccessful invocations. Doesn't need
            # a condition, since the function returns upon successful invocation.
            throw 'Execution failed.'
        }
    }
    function Start-WinISODownload {
        [CmdletBinding()]
        param (
            [uri]$DownloadLink,
            [string]$Path
        )
        
        begin {
            $indexofFirstLetter = $DownloadLink.ToString().Substring(0,$DownloadLink.ToString().IndexOf("?")).LastIndexOf("/")+1
            $lengthOfFileName = $DownloadLink.ToString().IndexOf("?")-$indexofFirstLetter
            $isoFileName = $DownloadLink.ToString().Substring($indexofFirstLetter,$lengthOfFileName)

            $Title = "Get-WinISO"
            $Info = "download the iso from $DownloadLink to $(Join-Path -Path $Path -ChildPath $isoFileName) in powershell now?"
            $options = [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes", "&No")
            [int]$defaultchoice = 1
            $opt = $host.UI.PromptForChoice($Title , $Info , $Options, $defaultchoice)
        }
        
        process {
            switch($opt) {
                0 { 
                    Write-Host "download now" -ForegroundColor Yellow
                    Retry-Command -ScriptBlock {
                        $WebClient = New-Object System.Net.WebClient
                        $WebClient.DownloadFile($DownloadLink, (Join-Path -Path $Path -ChildPath $isoFileName))
                    }
                }
                1 { 
                    Write-Host "Cancel" -ForegroundColor Green
                }
            }
        }
        
        end {
            
        }
    }

    $DownloadLink

    $edgeDriver.Quit()
    
    $ISOSaveTo = Split-Path -Path $workingPath -Qualifier | Join-Path -ChildPath "\ISO\Windows"
    if (-not (Test-Path -Path $ISOSaveTo)) {
        New-Item -Path $ISOSaveTo -ItemType Directory
    }
    Start-WinISODownload -DownloadLink $downloadLink -Path $ISOSaveTo
    
    # https://stackoverflow.com/questions/45470999/powershell-try-catch-and-retry

    
    Pause
    
}
