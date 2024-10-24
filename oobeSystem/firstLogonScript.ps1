#
"Rename Computer"
# Rename-Computer -newname (Read-Host "PC new name")
$brand = Get-WmiObject win32_bios | Select-Object -ExpandProperty Manufacturer
$sn = Get-WmiObject win32_bios | Select-Object -ExpandProperty SerialNumber
if (("$brand-$sn".Length -le 15)) {
  Rename-Computer -newname "$brand-$sn"
  "Computer renamed to `"$brand-$sn`""
} else {
  "`$brand-`$sn too long, skip rename computer"
}
Start-Sleep -Seconds 3

# "Join Domain"
# Add-Computer -domainname  -cred (get-credential domain\ServiceAccount) -Options JoinWithNewName -passthru -verbose

"set current user password
ref: https://codeandkeep.com/Powershell-Read-Password/"

# function Set-LocalUserPassword {
#   $pass=Read-Host -Prompt 'Enter a Password' `
#     -AsSecureString 
#   $pass2=Read-Host -Prompt 'Re-type Password' `
#     -AsSecureString 
#   $bstr=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass)
#   $plain=[Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
#   [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
#   $bstr2=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass2)
#   $plain2=[Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr2)
#   [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr2)
#   [bool]$pValid=$true
#   $builder=New-Object -TypeName Text.StringBuilder
#   if ($plain -cne $plain2){
#     $pValid=$false
#     [void]$builder.Append('Passwords do not match, input again ')
#   }
#   if ($plain.Length -lt 1){
#       $pValid=$false
#       [void]$builder.Append('You input nothing. ')
#     }
#   if($pValid -eq $false){
#       Write-Warning -Message $builder.ToString()
#       Set-LocalUserPassword
#   }else{
#       Get-LocalUser $env:USERNAME | Set-LocalUser -Password $pass
#   }
# }
# Set-LocalUserPassword

function Set-CurrentUserPassword {
  param (
    [SecureString]$Password
  )
    if (!$Password -or $Password.Length -lt 1) {
      $pass=Read-Host -Prompt 'Enter a Password' -AsSecureString 
      $pass2=Read-Host -Prompt 'Re-type Password' -AsSecureString 
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
  } else {
    Get-LocalUser $env:USERNAME | Set-LocalUser -Password $Password
  }
}

Set-CurrentUserPassword -Password (ConvertTo-SecureString "root" -AsPlainText -Force)
Start-Sleep -Seconds 3

"ipconfig"
ipconfig /registerdns

$WorkingPath = $PSScriptRoot
# $WorkingPath = "E:\WinOS-Deploy-As-Code\oobeSystem"

# "# install language package"
[string]$OSVersion = [System.Environment]::OSVersion.Version.Build
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_switch?view=powershell-7.4#examples
# https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information
switch -Wildcard ($OSVersion) {
  "261*" {
      $LangpackPath = "$WorkingPath\Langpacks\Win11-24H2"
    }
  "226*" {
      $LangpackPath = "$WorkingPath\Langpacks\Win11-22H2"
    }
  "190*" {
      $LangpackPath = "$WorkingPath\Langpacks\Win10"
    }
}
$LangLabel = "zh-CN"
if (-not [bool](Get-WindowsPackage -Online | Where-Object {$_.PackageName -like "*languagepack*$LangLabel*"})) {
  if (Test-Path (Join-Path -Path $LangpackPath -ChildPath "Microsoft-Windows-Client-Language-Pack*$LangLabel*")) {
    Add-WindowsPackage -Online -PackagePath `"$LangpackPath\Microsoft-Windows-Client-Language-Pack_x64_$LangLabel.cab`"
  }
  else {
    "no such package in $(Join-Path -Path $LangpackPath -ChildPath "Microsoft-Windows-Client-Language-Pack*$LangLabel*")"
  }
} else {
  "language package `"Microsoft-Windows-Client-Language-Pack*$LangLabel*`" already installed"
}

"# change system region"
Set-WinSystemLocale -SystemLocale $LangLabel

"Install Chocolatey"
if (Test-Path -Path "$WorkingPath\Software\Chocolatey\chocolatey*nupkg") {
  & $WorkingPath\Software\Chocolatey\ChocolateyInstall.ps1
}

"Config WinRM"
& $WorkingPath\Config\ConfigureRemotingForAnsible.ps1

"Install git for windows"
$gitSetupExeWildCard="$WorkingPath\Software\Git\Git-*-bit.exe"
if (Test-Path -Path $gitSetupExeWildCard) {
  $gitSetupExe = (Get-Item -Path $gitSetupExeWildCard)[-1].FullName
  Start-Process -FilePath $gitSetupExe -ArgumentList "/SILENT" -Wait
}

"# Install 7zip"
$7zipSetupExeWildCard="$WorkingPath\Software\7-Zip\7z*.exe"
if (Test-Path -Path $7zipSetupExeWildCard) {
  $7zipSetupExe = (Get-Item -Path $7zipSetupExeWildCard)[-1].FullName
  # https://www.7-zip.org/faq.html
  Start-Process -FilePath $7zipSetupExe -ArgumentList "/S" -Wait
}

# "#5. Install AdobeDC"
# Start-Process -FilePath msiexec -ArgumentList "/i `"$WorkingPath\Software\ReaderDC\AcroRead.msi`" TRANSFORMS=`"D:\Install\ReaderDC\AcroRead.mst`" /qn" -Wait
# Start-Process -FilePath "$WorkingPath\Software\AcroRdrDC1901020064_MUI.exe" -ArgumentList "/sAll /rs /rps /msi /norestart /quiet EULA_ACCEPT=YES" -Wait

"Install o365"
if (Test-Path -Path "$WorkingPath\Software\MSOffice\setup.exe") {
  Start-Process -FilePath "$WorkingPath\Software\MSOffice\setup.exe" -ArgumentList "/configure `"$WorkingPath\Software\MSOffice\configuration.xml`"" -Wait
}
# . "D:\Resources\O365_x64_CN\setup.exe" /configure "D:\Resources\O365_x64_CN\configuration.xml"

# "Install MS TEAMS"
# Start-Process -FilePath msiexec -ArgumentList "/i `"D:\Resources\Teams_windows_x64.msi`" ALLUSERS=1 /quiet" -Wait

# "Install Citrix Workspace"
# . "$WorkingPath\Software\Citrix\CitrixWorkspaceApp.exe" /silent
# Start-Process -FilePath "$WorkingPath\Software\Citrix\CitrixWorkspaceApp.exe" -ArgumentList  "/silent"

# "Install EPSON Iprojection"
# Start-Process -FilePath msiexec -ArgumentList "/i `"$WorkingPath\Software\EPSON\Epson iProjection Ver.3.00.msi`" /quiet" -Wait

# "Install Sogo"
# . "$WorkingPath\Software\SOGO\sogou_yisheng_11a.exe" /S

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

"set PC turn off screen after 30 mins
ref: https://docs.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options"
powercfg -change monitor-timeout-ac 30

"# enable remote desktop"
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

"# enable Hyper-V"
# Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
# https://mikefrobbins.com/2018/06/21/use-powershell-to-install-windows-features-and-reboot/
$ProgPref = $ProgressPreference
$ProgressPreference = 'SilentlyContinue'
$results = Enable-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V -Online -All -NoRestart -WarningAction SilentlyContinue
$ProgressPreference = $ProgPref
if ($results.RestartNeeded -eq $true) {
  Start-Sleep -Seconds 5
  Restart-Computer -Force
}