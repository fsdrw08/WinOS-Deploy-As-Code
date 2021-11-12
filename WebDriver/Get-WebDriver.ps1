[CmdletBinding()]
param (
    [Parameter()]
    [switch]$Force,
    [Parameter()]
    [string]$Destination = $PSScriptRoot
)
# $workingPath = "$env:userprofile\source\repos\WinOS-Deploy-As-Code\WebDriver"
# $workingPath = $PSScriptRoot

if (!$Destination) {
    $Destination =$PSScriptRoot
}

if ((Test-Path $Destination\msedgedriver.exe) -and !$Force) {
    # https://social.technet.microsoft.com/wiki/contents/articles/24030.powershell-demo-prompt-for-choice.aspx
    $Title = "Get-WebDriver"
    $Info = "msedgedriver.exe is already there, override?"
    $options = [System.Management.Automation.Host.ChoiceDescription[]] @("&Override", "&Cancel")
    [int]$defaultchoice = 1
    $opt = $host.UI.PromptForChoice($Title , $Info , $Options,$defaultchoice)
    switch($opt)
    {
    0 { Write-Host "Override msedgedriver.exe" -ForegroundColor Yellow
        # Get-MSEdgeDriver -Destination $Destination
        $overrideMSEdge = $true
    }
    1 { Write-Host "Cancel" -ForegroundColor Green
        $overrideMSEdge = $false
    }
    }
} else {
    $overrideMSEdge = $true
}

if ((Test-Path $Destination\webdriver.dll) -and !$Force) {
    $Title = "Get-WebDriver"
    $Info = "webdriver.dll is already there, override?"
    $options = [System.Management.Automation.Host.ChoiceDescription[]] @("&Override", "&Quit")
    [int]$defaultchoice = 1
    $opt = $host.UI.PromptForChoice($Title , $Info , $Options,$defaultchoice)
    switch($opt)
    {
    0 { Write-Host "Override webdriver.dll" -ForegroundColor Yellow
        # Get-MSEdgeDriver -Destination $Destination
        $overrideWebDriver = $true
    }
    1 { Write-Host "Quit" -ForegroundColor Green
        $overrideWebDriver = $false
    }
    }
} else {
    $overrideWebDriver = $true
}

function Get-MSEdgeDriver {
    param (
        [Parameter()]
        [string]$Destination
    )
    "Detect OS Architecture, .Net version and EDGE browser version"

    $OSArchitecture = (Get-CimInstance Win32_operatingsystem).OSArchitecture

    switch ($OSArchitecture) {
        # https://www.tenforums.com/tutorials/161325-how-find-version-microsoft-edge-chromium-installed.html
        # https://devblogs.microsoft.com/scripting/use-powershell-to-look-for-phone-numbers-in-text/
        # https://msedgewebdriverstorage.z22.web.core.windows.net/
        "64-bit" { 
            # https://stackoverflow.com/questions/46440429/get-microsoft-edge-browser-version-using-registry-or-command-line
            $msedgeVersion = (Get-Item "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe").VersionInfo | `
                                Select-Object -ExpandProperty FileVersion
            $msedgeDriver_Link = "https://msedgedriver.azureedge.net/$($msedgeVersion)/edgedriver_win64.zip"
            $msedgeDriver_Zip = "edgedriver_win64.zip"
        }
        "32-bit" { 
            $msedgeVersion = (Get-Item "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe").VersionInfo | `
                                Select-Object -ExpandProperty FileVersion
            $msedgeDriver_Link = "https://msedgedriver.azureedge.net/$($msedgeVersion)/edgedriver_win32.zip"
            $msedgeDriver_Zip = "edgedriver_win32.zip"
        }
        Default {}
    }

    $msedgeDriver_Link

    "Download edge webdriver"
    Start-BitsTransfer -Source $msedgeDriver_Link -Destination (Join-Path $Destination $msedgeDriver_Zip)

    "extract msedgedriver.exe"
    Invoke-Expression -Command "7z e (Join-Path $Destination $msedgeDriver_Zip) -o$Destination msedgedriver.exe -aoa -r"

}

function Get-WebDriver {
    param (
        [Parameter()]
        [string]$Destination
    )
    
    # https://stackoverflow.com/questions/3344855/which-net-version-is-my-powershell-script-using
    if ([System.Runtime.InteropServices.RuntimeInformation]::FrameworkDescription) {
        $DotNetVersion = [System.Runtime.InteropServices.RuntimeInformation]::FrameworkDescription
    }  else {
        $DotNetVersion = [System.Runtime.InteropServices.RuntimeInformation, mscorlib]::FrameworkDescription
    }
    
    "detect selenium web driver download link"
    $SeDriver_Site = "https://www.nuget.org/packages/Selenium.WebDriver/"
    $SeDriver_Link = (Invoke-WebRequest -Uri $SeDriver_Site -UseBasicParsing).Links.Href | Where-Object {$_ -match "nuget.org/api/v2"} | Select-Object -Unique
    $seSupport_Site = "https://www.nuget.org/packages/Selenium.Support/"
    $seSupport_Link = (Invoke-WebRequest -Uri $seSupport_Site -UseBasicParsing).Links.Href | Where-Object {$_ -match "nuget.org/api/v2"} | Select-Object -Unique

    "fetching file name"
    $SeDriver_LastIndexof = $SeDriver_Link.LastIndexOf("/")
    $SeDriver_LastSecondIndexof = $SeDriver_Link.Substring(0,$SeDriver_LastIndexof).LastIndexOf("/")
    $SeDriver_packageName = $SeDriver_Link.Substring($SeDriver_LastSecondIndexof+1,$SeDriver_LastIndexof-$SeDriver_LastSecondIndexof-1)
    $SeDriver_packageVersion = $SeDriver_Link.Substring($SeDriver_LastIndexof+1,$SeDriver_Link.Length-$SeDriver_LastIndexof-1)
    $SeDriver_nupkg = $SeDriver_packageName+"."+$SeDriver_packageVersion+".nupkg"

    $seSupport_LastIndexof = $seSupport_Link.LastIndexOf("/")
    $seSupport_LastSecondIndexof = $seSupport_Link.Substring(0,$seSupport_LastIndexof).LastIndexOf("/")
    $seSupport_packageName = $seSupport_Link.Substring($seSupport_LastSecondIndexof+1,$seSupport_LastIndexof-$seSupport_LastSecondIndexof-1)
    $seSupport_packageVersion = $seSupport_Link.Substring($seSupport_LastIndexof+1,$seSupport_Link.Length-$seSupport_LastIndexof-1)
    $seSupport_nupkg = $seSupport_packageName+"."+$seSupport_packageVersion+".nupkg"

    "selenium nupkg download link and file name"
    $SeDriver_Link
    $SeDriver_nupkg

    $seSupport_Link
    $seSupport_nupkg
    
    Invoke-WebRequest -Uri $SeDriver_Link -UseBasicParsing -OutFile (Join-Path $Destination $SeDriver_nupkg) -Verbose
    Invoke-WebRequest -Uri $seSupport_Link -UseBasicParsing -OutFile (Join-Path $Destination $seSupport_nupkg) -Verbose

    $targetDLL = "net" + ($DotNetVersion -replace "[^\d]", '').Substring(0,2)

    if ($targetDLL) {
        Invoke-Expression -Command "7z e (Join-Path $($Destination) $($SeDriver_nupkg)) -o$Destination lib\$($targetDll)\WebDriver.dll -aoa -r"
}
}

if ($overrideMSEdge) {
    Get-MSEdgeDriver -Destination $Destination
}

if ($overrideWebDriver) {
    Get-WebDriver -Destination $Destination
}