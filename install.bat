@echo off
setlocal EnableDelayedExpansion

:: ERAM RAM Disk - Install Script
:: Supports Windows 7 / 10 / 11 (32-bit and 64-bit)

echo ERAM RAM Disk - Installer
echo ==========================
echo.

:: Check for administrator privileges
net session >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: This script requires administrator privileges.
    echo Please right-click install.bat and select "Run as administrator".
    echo.
    pause
    exit /b 1
)

:: Detect processor architecture
set ARCH=x86
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" set ARCH=x64
if "%PROCESSOR_ARCHITECTURE%"=="ARM64" (
    echo ERROR: ARM64 is not supported by this driver.
    pause
    exit /b 1
)
:: Handle 32-bit process running on 64-bit Windows (WOW64)
if defined PROCESSOR_ARCHITEW6432 (
    if "%PROCESSOR_ARCHITEW6432%"=="AMD64" set ARCH=x64
)

echo Detected architecture: %ARCH%
echo.

:: Set paths
set SYSDIR=%SystemRoot%\System32
set DRVDIR=%SYSDIR%\drivers
set SCRIPTDIR=%~dp0

:: Verify that eram.sys exists
if not exist "%SCRIPTDIR%eram.sys" (
    echo ERROR: eram.sys not found in %SCRIPTDIR%
    echo Please ensure eram.sys is in the same directory as this script.
    echo.
    pause
    exit /b 1
)

:: Copy driver
echo Copying eram.sys to %DRVDIR%...
copy /Y "%SCRIPTDIR%eram.sys" "%DRVDIR%\eram.sys" >nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: Failed to copy eram.sys to %DRVDIR%.
    echo.
    pause
    exit /b 1
)
echo eram.sys copied successfully.

:: Copy and register control panel applet if it exists
if exist "%SCRIPTDIR%eram.cpl" (
    echo Copying eram.cpl to %SYSDIR%...
    copy /Y "%SCRIPTDIR%eram.cpl" "%SYSDIR%\eramnt.cpl" >nul
    if %ERRORLEVEL% neq 0 (
        echo WARNING: Failed to copy eram.cpl. Control panel applet may not be available.
    ) else (
        regsvr32 /s "%SYSDIR%\eramnt.cpl"
        echo eram.cpl installed as eramnt.cpl.
    )
)

:: Create or update the ERAM kernel driver service
echo Creating ERAM service...
sc query Eram >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo ERAM service already exists. Updating configuration...
    sc config Eram start= system binPath= "\SystemRoot\System32\drivers\eram.sys" >nul
) else (
    sc create Eram type= kernel start= system binPath= "\SystemRoot\System32\drivers\eram.sys" DisplayName= "ERAM" >nul
    if %ERRORLEVEL% neq 0 (
        echo ERROR: Failed to create ERAM service.
        echo.
        pause
        exit /b 1
    )
)
echo ERAM service created successfully.

:: Configure ERAM registry parameters
echo Configuring ERAM registry settings...

:: Default RAM disk size: 1 GB (262144 pages of 4 KB each)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Eram\Parameters" /v "Page"               /t REG_DWORD /d 262144 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Eram\Parameters" /v "DriveLetter"        /t REG_SZ    /d "Z:"    /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Eram\Parameters" /v "AllocUnit"          /t REG_DWORD /d 2       /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Eram\Parameters" /v "MediaId"            /t REG_DWORD /d 248     /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Eram\Parameters" /v "RootDirEntries"     /t REG_DWORD /d 128     /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Eram\Parameters" /v "NonPaged"           /t REG_DWORD /d 0       /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Eram\Parameters" /v "External"           /t REG_DWORD /d 0       /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Eram\Parameters" /v "SkipExternalCheck"  /t REG_DWORD /d 0       /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Eram\Parameters" /v "Swapable"           /t REG_DWORD /d 0       /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Eram\Parameters" /v "SkipReportUsage"    /t REG_DWORD /d 0       /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Eram\Parameters" /v "MakeTempDir"        /t REG_DWORD /d 0       /f >nul
echo Registry settings configured.

:: Register event log message source
echo Registering event log message source...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\EventLog\System\Eram" /v "EventMessageFile" /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\drivers\eram.sys" /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\EventLog\System\Eram" /v "TypesSupported"   /t REG_DWORD     /d 7                                          /f >nul

:: Copy uninstall.bat to a permanent location so the uninstall entry stays valid
echo Installing uninstaller...
if not exist "%ProgramFiles%\ERAM" mkdir "%ProgramFiles%\ERAM"
copy /Y "%SCRIPTDIR%uninstall.bat" "%ProgramFiles%\ERAM\uninstall.bat" >nul

:: Add uninstall entry to Programs and Features
echo Adding uninstall entry...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Eram" /v "DisplayName"     /t REG_SZ    /d "ERAM RAM Disk"                          /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Eram" /v "UninstallString" /t REG_SZ    /d "\"%ProgramFiles%\ERAM\uninstall.bat\""  /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Eram" /v "Publisher"       /t REG_SZ    /d "Error15 and Zero3K"                     /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Eram" /v "DisplayVersion"  /t REG_SZ    /d "2.30"                                   /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Eram" /v "NoModify"        /t REG_DWORD /d 1                                        /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Eram" /v "NoRepair"        /t REG_DWORD /d 1                                        /f >nul

echo.
echo ERAM has been installed successfully!
echo.
echo The RAM Disk will be available as drive Z: after reboot (default size: 1 GB).
echo You can change settings using the ERAM Control Panel applet (eramnt.cpl).
echo.
echo NOTE: On 64-bit Windows, Driver Signature Enforcement must be disabled for
echo unsigned drivers. You can do this by running the following command and
echo then rebooting:
echo   bcdedit /set testsigning on
echo.
echo A system reboot is required to complete the installation.
set /p REBOOT=Would you like to reboot now? (Y/N): 
if /i "%REBOOT%"=="Y" (
    shutdown /r /t 10 /c "Rebooting to complete ERAM installation."
) else (
    echo Please reboot your system manually to complete the installation.
)
echo.
pause
endlocal
