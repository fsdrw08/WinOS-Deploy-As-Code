#

"# ipconfig"
ipconfig /registerdns

"# install language package"
Add-WindowsPackage -Online -PackagePath "$PSScriptRoot\Language\Microsoft-Windows-Client-Language-Pack_x64_zh-cn_20h2.cab"

"# Install Chocolatey"
& $PSScriptRoot\Scripts\ChocolateyInstall.ps1

"# Config WinRM"
& $PSScriptRoot\Scripts\ConfigureRemotingForAnsible.ps1

"# Install 7zip"
choco install 7zip.install --source="$PSScriptRoot\Software\" -y
#. MSIEXEC.EXE /i "D:\Install\7z1900-x64.msi" /qn /wait

# "#5. Install AdobeDC"
# Start-Process -FilePath msiexec -ArgumentList "/i `"D:\Resources\ReaderDC\AcroRead.msi`" TRANSFORMS=`"D:\Install\ReaderDC\AcroRead.mst`" /qn" -Wait
# #Start-Process -FilePath "D:\Install\AcroRdrDC1901020064_MUI.exe" -ArgumentList "/sAll /rs /rps /msi /norestart /quiet EULA_ACCEPT=YES" -Wait

"# Install o365"
Start-Process -FilePath "$PSScriptRoot\Software\MSOffice\setup.exe" -ArgumentList "/configure `"$PSScriptRoot\Software\MSOffice\configuration.xml`"" -Wait
# . "D:\Resources\O365_x64_CN\setup.exe" /configure "D:\Resources\O365_x64_CN\configuration.xml"

"#5.1 Install Citrix Workspace"
# . "$PSScriptRoot\Software\Citrix\CitrixWorkspaceApp.exe" /silent
Start-Process -FilePath "$PSScriptRoot\Software\Citrix\CitrixWorkspaceApp.exe" -ArgumentList  "/silent"


# "#6.1 Install EPSON Iprojection"
# Start-Process -FilePath msiexec -ArgumentList "/i `"D:\Resources\Epson iProjection Ver.3.00.msi`" /quiet" -Wait

# "#6.2 install MS TEAMS"
# Start-Process -FilePath msiexec -ArgumentList "/i `"D:\Resources\Teams_windows_x64.msi`" ALLUSERS=1 /quiet" -Wait

# "#7. Install Sogo"
# . "D:\Resources\sogou_yisheng_11a.exe" /S

"# change system region"
Set-WinSystemLocale -SystemLocale zh-CN

"# use unicode UFT-8 for system worldwide language support, 
ref: https://stackoverflow.com/questions/56419639/what-does-beta-use-unicode-utf-8-for-worldwide-language-support-actually-do"
@"
ACP
OEMCP
MACCP
"@ -split "`r`n" | ForEach-Object {
    Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage -Name $_ -Value "65001"
}

"#7.1. Rename Computer"
Rename-Computer -newname (Read-Host "PC new name")

# "#7.2. Join Domain"
# Add-Computer -domainname  -cred (get-credential domain\ServiceAccount) -Options JoinWithNewName -passthru -verbose

Start-Sleep 8

"#9. Work around logoncount 1 issue"
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoLogonCount /t REG_DWORD /d 0 /f

"# enable Hyper-V"
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All