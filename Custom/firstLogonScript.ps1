#

"#1 ipconfig"
ipconfig /registerdns

"#2. install language package"
Add-WindowsPackage -Online -PackagePath "$PSScriptRoot\Language\Microsoft-Windows-Client-Language-Pack_x64_zh-cn_20h2.cab"

"#3. Install Chocolatey"
& $PSScriptRoot\Scripts\ChocolateyInstall.ps1

"#4. Config WinRM"
& $PSScriptRoot\Scripts\ConfigureRemotingForAnsible.ps1

"#5.2 Install 7zip"
choco install 7zip.install --source="$PSScriptRoot\Software\"
#. MSIEXEC.EXE /i "D:\Install\7z1900-x64.msi" /qn /wait

# "#5. Install AdobeDC"
# Start-Process -FilePath msiexec -ArgumentList "/i `"D:\Resources\ReaderDC\AcroRead.msi`" TRANSFORMS=`"D:\Install\ReaderDC\AcroRead.mst`" /qn" -Wait
# #Start-Process -FilePath "D:\Install\AcroRdrDC1901020064_MUI.exe" -ArgumentList "/sAll /rs /rps /msi /norestart /quiet EULA_ACCEPT=YES" -Wait

"#6. Install o365"
Start-Process -FilePath "$PSScriptRoot\Software\MSOffice\setup.exe" -ArgumentList "/configure 'D:\Install\O365_x64_CN\configuration.xml'" -Wait
# . "D:\Resources\O365_x64_CN\setup.exe" /configure "D:\Resources\O365_x64_CN\configuration.xml"

# "#6.1 Install EPSON Iprojection"
# Start-Process -FilePath msiexec -ArgumentList "/i `"D:\Resources\Epson iProjection Ver.3.00.msi`" /quiet" -Wait

# "#6.2 install MS TEAMS"
# Start-Process -FilePath msiexec -ArgumentList "/i `"D:\Resources\Teams_windows_x64.msi`" ALLUSERS=1 /quiet" -Wait

# "#7. Install Sogo"
# . "D:\Resources\sogou_yisheng_11a.exe" /S

"#7.1. Rename Computer"
Rename-Computer -newname (Read-Host "PC new name")

# "#7.2. Join Domain"
# Add-Computer -domainname  -cred (get-credential work.local\svcfuodomjon) -Options JoinWithNewName -passthru -verbose

"#5.1 Install Citrix Workspace"
. "$PSScriptRoot\Software\Citrix\CitrixWorkspaceApp.exe" /silent


Start-Sleep 8

"#9. Work around logoncount 1 issue"
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoLogonCount /t REG_DWORD /d 0 /f

"#10. start-sleep"
Start-Sleep -Seconds 2100
shutdown -r -t 00