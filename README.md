# Windows standalone media deployment template
Everything in one code base to automatically deploy windows (10+) to a bare metal machine by standalone media (USB drive)

# The whole installation procedure:
1. PC boot from ventoy;
2. Under ventoy UI, select ISO file to launch, then select unattend xml file for auto install process;
3. According the config in unattend install file:
   1. windowsPE pass: 
      - Config winpe env language
      - Re-partition disk, install Windows system to target partition;
   2. offlineServicing pass: 
      - Install driver;
   3. specialize pass: 
      - Config time zone;
   4. oobeSystem pass:
      - Config language;
      - Skip oobe process;
      - Create local admin account;
      - Run first logon command -> triger the firstLogonScript.ps1:
        1. rename computer, naming pattern: `<board band>-<bios serial number>`
        2. set current user password (default password: root)
        3. ipconfig
        4. install language pack
        5. change system region
        6. install chocolatey
        7. config winrm
        8.  install o365
        9.  config system language encoding
        10. Work around logoncount 1 issue
        11. set PC sleep after 5 hours
        12. set PC turn off screen after 30 mins
        13. enable remote desktop
        14. enable Hyper-V
        15. restart PC
   
   
# Get started:
Prerequest: portable usb drive (at least 8G+, 32G is recommanded) with no data keep.  
1. Install ventoy by scoop 
   ```
   scoop install ventoy
   ```
   or chocolatey
   ```
   choco install ventoy -y
   ```
   or manually download and install from https://www.ventoy.net/en/download.html
2. Plugin the portable usb drive, launch ventoy2disk, partition and install ventoy to the the usb drive. BE CAREFUL! This step will delete ALL files in your usb drive.  
3. Clone this repo into root folder of the usb drive.
   ```
   git clone --recurse-submodules https://github.com/fsdrw08/WinOS-Deploy-As-Code.git
   ```  
4. Run script [.\Get-WinISO\Get-Win11ISO.bat](Get-WinISO/Get-Win11ISO.bat) to download the Windows 11 ISO to `<usb drive label>:\ISO\Windows`, you can also download Windows 10 ISO by running [.\Get-WinISO\Get-Win10ISO.bat](Get-WinISO/Get-Win10ISO.bat)
5.  According to the machine disk size, verify the disk partition config in .\unattendXML\unattend-UEFI-*G.xml, if there is no disk size match to you, create a new one by youself, then update [.\Copy-VentoyFiles\ventoy\ventoy.json](Copy-VentoyFiles/ventoy/ventoy.json) to add your new unattend xml file in template path.
6. Run script [.\Copy-VentoyFiles\Copy-VentoyFiles.bat](Copy-VentoyFiles/Copy-VentoyFiles.bat) to copy ventoy configuration json file to the usb drive root folder
7. (Optional), for PC driver deployment during offlineServicing pass, reference [.\Drivers\README.md](Drivers/README.md), prepare drivers for the target machine you need to install 
8. (Optional), for language pack offline deployment, reference [.\oobeSystem\Langpacks\README.md](oobesystem/Langpacks/README.md), download language package ISO and extra the target language cab file to related folder
9. (Optional), for chocolatey offline deployment, run script [.\oobeSystem\Software\Chocolatey\Get-ChocoPackages.bat](oobeSystem/Software/Chocolatey/Get-ChocoPackages.bat) to download chocolatey nupkg installation file
10. (Optional), for MS office offline deployment, run script [.\oobeSystem\Software\MSOffice\Download-Office.bat](oobeSystem/Software/MSOffice/Download-Office.bat) to download office installation files
11. Prepare done, plug in this USB drive to the target machine, boot from this USB drive, then Ventoy get load
12. Select the related Windows ISO, and related unattend xml file according to the disk size, then the installation process will start.


# Components reference in this project:
[Ventoy](https://github.com/ventoy/Ventoy): Ventoy is an open source tool to create bootable USB drive for ISO/WIM/IMG/VHD(x)/EFI files.  
[Unattended Windows Setup](https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/): Use to automate the configuration and the deployment of Windows.  
[Apply unattended answer file to Windows 10 install media](https://www.tenforums.com/tutorials/131765-apply-unattended-answer-file-windows-10-install-media.html): Tutorial to config a unattend xml file  
[Create media for automated unattended install of Windows 10](https://www.tenforums.com/tutorials/96683-create-media-automated-unattended-install-windows-10-a.html)

