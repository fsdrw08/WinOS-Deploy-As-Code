begin {
    # $workingPath = "D:\WinOS-Deploy-As-Code\oobeSystem\Software\MSOffice"
    $workingPath = $PSScriptRoot
    $url = "https://docs.microsoft.com/en-us/officeupdates/odt-release-history"
    
    $downloadLink = (
        Invoke-WebRequest -uri (
            (
                Invoke-WebRequest -Uri $url -UseBasicParsing
            ).Links.Href | Where-Object -FilterScript {$_ -match "download/confirmation"}
        ) -UseBasicParsing
    ).links.href | Where-Object {$_ -like "*exe"} | Select-Object -Unique
        # $workingPath = "D:\WinOS-Deploy-As-Code\oobeSystem\Software\MSOffice"
        # $workingPath = $PSScriptRoot
        # $webDriverPath = $workingPath | Split-Path | Split-Path | Split-Path | Join-Path -ChildPath "WebDriver"
        # if (!(Test-Path "$webDriverPath\WebDriver.dll") -or !(Test-Path "$($webDriverPath)\WebDriver.Support.dll")) {
            #     . $webDriverPath\Get-WebDriver.ps1
            # }
            
            # Add-Type -Path "$webDriverPath\WebDriver.dll"
            # Add-Type -Path "$webDriverPath\WebDriver.Support.dll"
            
}
        
process {
    Start-BitsTransfer -Source $downloadLink -Destination $workingPath
            
    # $edgeDriverOptions = New-Object OpenQA.Selenium.Edge.EdgeOptions
    
    # # https://csharp.hotexamples.com/examples/OpenQA.Selenium.Chrome/ChromeOptions/AddUserProfilePreference/php-chromeoptions-adduserprofilepreference-method-examples.html
    # # https://stackoverflow.com/questions/61608942/selenium-edge-chromium-browser-direct-option-to-set-default-download-path/70847078#70847078
    # # https://mcpmag.com/articles/2019/05/01/monitor-windows-folder-for-new-files.aspx
    
    # $File = "$workingPath\officedeploymenttool*.exe"
    # $FilePath = Split-Path $File -Parent
    # $FileName = Split-Path $File -Leaf
    
    # $Action = {
    #     $path = $event.SourceEventArgs.FullPath
    #     $changetype = $event.SourceEventArgs.ChangeType
    #     Write-Host "$path was $changetype at $(get-date)"
    #     $edgeDriver.Quit()
    #     Get-EventSubscriber | Unregister-Event
    # }
    
    # $Watcher = New-Object IO.FileSystemWatcher $FilePath, $FileName -Property @{ 
    #     IncludeSubdirectories = $false
    #     EnableRaisingEvents = $true
    # }
    
    # Register-ObjectEvent -InputObject $watcher -EventName 'Renamed' -Action $action
    
    # $edgeDriverOptions.AddUserProfilePreference("download.default_directory", "$workingPath")
    # $edgeDriver = New-Object OpenQA.Selenium.Edge.EdgeDriver($edgeDriverOptions)
    # $edgeDriver.Navigate().GoToUrl("$url")
    
    # # https://coderoad.ru/38360545/%D0%9C%D0%BE%D0%B6%D0%BD%D0%BE-%D0%BB%D0%B8-%D0%B8%D1%81%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D0%BE%D0%B2%D0%B0%D1%82%D1%8C-LINQ-%D0%B2-PowerShell
    # # http://reza-aghaei.com/net-action-func-delegate-lambda-expression-in-powershell/
    # # https://www.selenium.dev/selenium/docs/api/dotnet/?topic=html/T_OpenQA_Selenium_Support_UI_WebDriverWait.htm
    
    # # https://www.softwaretestinghelp.com/selenium-find-element-by-text/#Difference_between_Text_Link_Text_and_Partial_Link_Text_Methods
    # $edgeDriver.FindElement([OpenQA.Selenium.By]::XPath("//*[contains(text(),'Download Office Deployment Tool')]")).Click()
    
    # $edgeDriver.Quit()
}

end {

}