# Windows standalone media deployment template
Everything in one code base to automatically deploy windows (10+) to a bare metal machine by standalone media (USB drive)

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
4. Run script [.\Get-WinISO\Get-Win11ISO.bat](Get-WinISO/Get-Win11ISO.bat) to download the Windows 11 ISO, you can also download Windows 10 ISO by running [.\Get-WinISO\Get-Win10ISO.bat](Get-WinISO/Get-Win10ISO.bat)
5. Run script [.\Copy-VentoyFiles\Copy-VentoyFiles.bat](Copy-VentoyFiles/Copy-VentoyFiles.bat) to copy ventoy configuration json file to the usb drive root folder
6. (Optional), for PC driver deployment during offlineServicing pass, reference [.\Drivers\README.md](Drivers/README.md), prepare drivers for the target machine you need to install 
7. (Optional), for language pack offline deployment, reference [.\oobeSystem\Langpacks\README.md](oobesystem/Langpacks/README.md), download language package ISO and extra the target language cab file to related folder
8. (Optional), for chocolatey offline deployment, run script [.\oobeSystem\Software\Chocolatey\Get-ChocoPackages.bat](oobeSystem/Software/Chocolatey/Get-ChocoPackages.bat) to download chocolatey nupkg installation file
9. (Optional), for MS office offline deployment, run script [.\oobeSystem\Software\MSOffice\Download-Office.bat](oobeSystem/Software/MSOffice/Download-Office.bat) to download office installation files
10. According to the machine disk size, verify the disk partition config in .\unattendXML\unattend-UEFI-*G.xml, if there is no disk size match to you, create a new one by youself.
11. Prepare done, plug in this USB drive to the target machine, boot from this USB drive, then Ventoy get load
12. Select the related Windows ISO, and related unattend xml file according to the disk size, then the installation process will start.

# Components reference in this project:
[Ventoy](https://github.com/ventoy/Ventoy): Ventoy is an open source tool to create bootable USB drive for ISO/WIM/IMG/VHD(x)/EFI files.  
[Unattended Windows Setup](https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/): Use to automate the configuration and the deployment of Windows.  
[Apply unattended answer file to Windows 10 install media](https://www.tenforums.com/tutorials/131765-apply-unattended-answer-file-windows-10-install-media.html): Tutorial to config a unattend xml file  
[Create media for automated unattended install of Windows 10](https://www.tenforums.com/tutorials/96683-create-media-automated-unattended-install-windows-10-a.html)

