#
"Rename Computer"
Rename-Computer -newname (Read-Host "PC new name")


# "Join Domain"
# Add-Computer -domainname  -cred (get-credential domain\ServiceAccount) -Options JoinWithNewName -passthru -verbose

"set current user password
ref: https://codeandkeep.com/Powershell-Read-Password/"

function Set-LocalUserPassword {
  $pass=Read-Host -Prompt 'Enter a Password' `
    -AsSecureString 
  $pass2=Read-Host -Prompt 'Re-type Password' `
    -AsSecureString 
  $bstr=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass)
  $plain=[Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
  [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
  $bstr2=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass2)
  $plain2=[Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr2)
  [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr2)
  [bool]$pValid=$true
  $builder=New-Object -TypeName Text.StringBuilder
  if ($plain -cne $plain2){
    $pValid=$false
    [void]$builder.Append('Passwords do not match, input again ')
  }
  if ($plain.Length -lt 1){
      $pValid=$false
      [void]$builder.Append('You input nothing. ')
    }
  if($pValid -eq $false){
      Write-Warning -Message $builder.ToString()
      Set-LocalUserPassword
  }else{
      Get-LocalUser $env:USERNAME | Set-LocalUser -Password $pass
  }
}
Set-LocalUserPassword

"ipconfig"
ipconfig /registerdns

"# install language package"
$Windows11 = [System.Environment]::OSVersion.Version.Build -ge "22000"
switch ($Windows11) {
  "True" {
      $LangpackPath = "$PSScriptRoot\Langpacks\Win11"
    }
  "False" {
      $LangpackPath = "$PSScriptRoot\Langpacks\Win10"
    }
}
$LangLabel = "zh-CN"
if ((-not [bool](Get-WindowsPackage -Online | Where-Object {$_.PackageName -like "*languagepack*$LangLabel*"})) -and `
    (Test-Path (Join-Path -Path $LangpackPath -ChildPath "Microsoft-Windows-Client-Language-Pack*"))) {
  Add-WindowsPackage -Online -PackagePath "$PSScriptRoot\Langpacks\Microsoft-Windows-Client-Language-Pack_x64_$LangLabel.cab"
}

"# change system region"
Set-WinSystemLocale -SystemLocale $LangLabel

"Install Chocolatey"
if (Test-Path -Path "$PSScriptRoot\Software\Chocolatey\chocolatey*nupkg") {
  & $PSScriptRoot\Software\Chocolatey\ChocolateyInstall.ps1
}

"Config WinRM"
& $PSScriptRoot\Config\ConfigureRemotingForAnsible.ps1

# "# Install 7zip"
# choco install 7zip.install --source="$PSScriptRoot\Software\Chocolatey\" -y
#. MSIEXEC.EXE /i "D:\Install\7z1900-x64.msi" /qn /wait

# "#5. Install AdobeDC"
# Start-Process -FilePath msiexec -ArgumentList "/i `"$PSScriptRoot\Software\ReaderDC\AcroRead.msi`" TRANSFORMS=`"D:\Install\ReaderDC\AcroRead.mst`" /qn" -Wait
# Start-Process -FilePath "$PSScriptRoot\Software\AcroRdrDC1901020064_MUI.exe" -ArgumentList "/sAll /rs /rps /msi /norestart /quiet EULA_ACCEPT=YES" -Wait

"Install o365"
if (Test-Path -Path "$PSScriptRoot\Software\MSOffice\odt\setup.exe") {
  Start-Process -FilePath "$PSScriptRoot\Software\MSOffice\odt\setup.exe" -ArgumentList "/configure `"$PSScriptRoot\Software\MSOffice\configuration.xml`"" -Wait
}
# . "D:\Resources\O365_x64_CN\setup.exe" /configure "D:\Resources\O365_x64_CN\configuration.xml"

# "Install MS TEAMS"
# Start-Process -FilePath msiexec -ArgumentList "/i `"D:\Resources\Teams_windows_x64.msi`" ALLUSERS=1 /quiet" -Wait

# "Install Citrix Workspace"
# . "$PSScriptRoot\Software\Citrix\CitrixWorkspaceApp.exe" /silent
# Start-Process -FilePath "$PSScriptRoot\Software\Citrix\CitrixWorkspaceApp.exe" -ArgumentList  "/silent"

# "Install EPSON Iprojection"
# Start-Process -FilePath msiexec -ArgumentList "/i `"$PSScriptRoot\Software\EPSON\Epson iProjection Ver.3.00.msi`" /quiet" -Wait

# "Install Sogo"
# . "$PSScriptRoot\Software\SOGO\sogou_yisheng_11a.exe" /S

"# use unicode UFT-8 for system worldwide language support, 
ref: https://stackoverflow.com/questions/56419639/what-does-beta-use-unicode-utf-8-for-worldwide-language-support-actually-do"
@"
ACP
OEMCP
MACCP
"@ -split "`r`n" | ForEach-Object {
    Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage -Name $_ -Value "65001"
}

Start-Sleep 8

"#9. Work around logoncount 1 issue
ref: https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-shell-setup-autologon-logoncount"
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoLogonCount /t REG_DWORD /d 0 /f

"set PC sleep after 5 hours
ref: https://docs.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options"
powercfg -change -standby-timeout-ac 300

"set PC turn off screen after 5 hours
ref: https://docs.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options"
powercfg -change monitor-timeout-ac 30

"# enable Hyper-V"
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All