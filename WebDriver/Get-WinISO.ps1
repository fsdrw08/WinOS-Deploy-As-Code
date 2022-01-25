[CmdletBinding()]
param (
    # [Parameter(Mandatory = $true)]
    # [ValidateNotNullOrEmpty()]
    # [ValidateSet('10','11')]
    [int16]
    $WindowsVersion = "10",
    # [Parameter(Mandatory = $true)]
    [string]
    $Language="English"
)
begin {

    # $workingPath = "D:\WinOS-Deploy-As-Code\WebDriver"
    $workingPath = $PSScriptRoot

    if (!(Test-Path "$($workingPath)\WebDriver.dll") -or !(Test-Path "$($workingPath)\WebDriver.Support.dll")) {
    . $PSScriptRoot\Get-WebDriver.ps1
    }

    Add-Type -Path "$workingPath\WebDriver.dll"
    Add-Type -Path "$workingPath\WebDriver.Support.dll" #-PassThru
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
    # "@ -ReferencedAssemblies 'System.dll','System.Data.dll', "$workingPath\WebDriver.dll","$workingPath\WebDriver.Support.dll"

    $edgeDriverOptions = New-Object OpenQA.Selenium.Edge.EdgeOptions

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
        
        begin {
            
        }
        
        process {
            
        }
        
        end {
            return $EdgeDriver.FindElement([OpenQA.Selenium.By]::$by($target))
        }
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
    
    $downloadLink
    
    $edgeDriver.Quit()
    
    $indexofFirstLetter = $downloadLink.Substring(0,$downloadLink.IndexOf("?")).LastIndexOf("/")+1
    
    $lengthOfFileName = $downloadLink.IndexOf("?")-$indexofFirstLetter
    
    $isoFileName = $downloadLink.Substring($indexofFirstLetter,$lengthOfFileName)
    
    $Title = "Get-WinISO"
    $Info = "download the iso to $(Join-Path (Split-Path (Split-Path $workingPath)) $isoFileName) in powershell now?"
    $options = [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes", "&No")
    [int]$defaultchoice = 1
    $opt = $host.UI.PromptForChoice($Title , $Info , $Options, $defaultchoice)
    switch($opt) {
        0 { 
            Write-Host "download now" -ForegroundColor Yellow
            Start-BitsTransfer -Source $downloadLink -Destination (Join-Path (Split-Path (Split-Path $workingPath)) $isoFileName) -Confirm
        }
        1 { 
            Write-Host "Cancel" -ForegroundColor Green
        }
    }
    
}
