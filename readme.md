# ERAM

ERAM v2.30 is an Opensource RAM Disk made by Hideaki Okubo (okubo at msh.biglobe.ne.jp) with the source code comments translated by Katayama Hirofumi MZ (katayama.hirofumi.mz at gmail.com) and some modifications made by me thanks to help from a member of community.osr.com. It has a size limit of 4 GB that uses page/non-paged/external RAM. You can use it for storing temp files, browser cache, etc. in order to speed up the programs that use those files.

## Install Instructions

0. Download from the Releases section (available at https://github.com/Zero3K/ERAM/releases)

1. Extract the release archive so that `install.bat`, `uninstall.bat`, `eram.sys`, and `eram.cpl` are all in the same folder.
2. Right-click `install.bat` and select **Run as administrator**.
3. Follow the on-screen prompts and reboot when asked.

> **Note for 64-bit Windows:** Driver Signature Enforcement must be disabled for unsigned drivers. Run the following command in an elevated Command Prompt before installing, then reboot:
> ```
> bcdedit /set testsigning on
> ```

After installing, the RAM Disk will be available as drive **Z:** with a default size of **1 GB**, which can be changed by running the ERAM Control Panel applet (press <kbd>Win</kbd> + <kbd>R</kbd> and type `eramnt.cpl`).

## Uninstall Instructions

1. Right-click `uninstall.bat` and select **Run as administrator**.
2. Confirm the prompt and reboot when asked.

## Build Instructions -

1. Download WDK (Windows Driver Kit) 7.1.0 from https://www.microsoft.com/en-us/download/details.aspx?id=11800.
2. Extract the ISO using 7-Zip, etc. to a directory of your choosing.
3. Run the KitSetup.exe located in the directory it was extracted to.
4. Click Full Development Environment.
5. Click OK.
6. After the install has completed, you can find the Build Environments in the Start Menu in Windows Driver Kits\WDK 7600.16385.1\Build Environments.
7. Open the proper Environment depending on what OS and CPU architecture you are building for (Only the Checked Build Environment works for now).
8. Change the directory to the location of the source code (for example, cd C:\ERAM).
9. Type build and press Enter.

## Benchmarks -

![ERAM Benchmark done on Windows 7 64-bit](images/benchmark.png)
![ERAM Benchmark done on a Windows 7 64-bit Virtual Machine](images/benchmark_2.png)

## Screenshots -

![ERAM's RAM Disk Contents in a Windows 7 64-bit Virtual Machine](images/Empty_ERAM_Drive.png)
![ERAM's RAM Disk Properties in a Windows 7 64-bit Virtual Machine](images/ERAM_Drive_Properties.png)

![ERAM's Control Panel Applet in a Windows 7 64-bit Virtual Machine](images/ERAM_Options.png)

## Original Developer's Site -

http://www.vector.co.jp/authors/VA000363
