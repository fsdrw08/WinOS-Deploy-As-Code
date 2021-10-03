@"
https://community.chocolatey.org/packages/chocolatey
https://community.chocolatey.org/packages/7zip.install/19.0
https://community.chocolatey.org/packages/chocolatey-core.extension
"@ -split "`r`n" | ForEach-Object {
    $downloadLink = (Invoke-WebRequest -Uri $_ -UseBasicParsing).Links.Href | Where-Object {$_ -match "v2/package"} | Select-Object -Unique
    $downloadLink

    $LastIndexof = $downloadLink.LastIndexOf("/")
    $LastSecondIndexof = $downloadLink.Substring(0,$LastIndexof).LastIndexOf("/")
    $packageName = $downloadLink.Substring($LastSecondIndexof+1,$LastIndexof-$LastSecondIndexof-1)
    $packageVersion = $downloadLink.Substring($LastIndexof+1,$downloadLink.Length-$LastIndexof-1)
    $fileName = $packageName+"."+$packageVersion+".nupkg"

    Invoke-WebRequest -Uri $downloadLink -UseBasicParsing -OutFile (Join-Path $PSScriptRoot $fileName)
}
