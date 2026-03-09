@echo off
setlocal EnableDelayedExpansion

:: ERAM RAM Disk - Uninstall Script
:: Supports Windows 7 / 10 / 11 (32-bit and 64-bit)

echo ERAM RAM Disk - Uninstaller
echo ============================
echo.

:: Check for administrator privileges
net session >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: This script requires administrator privileges.
    echo Please right-click uninstall.bat and select "Run as administrator".
    echo.
    pause
    exit /b 1
)

echo This will remove the ERAM RAM Disk driver from your system.
set /p CONFIRM=Are you sure you want to continue? (Y/N): 
if /i not "%CONFIRM%"=="Y" (
    echo Uninstall cancelled.
    pause
    exit /b 0
)

:: Set paths
set SYSDIR=%SystemRoot%\System32
set DRVDIR=%SYSDIR%\drivers

:: Stop the ERAM service if running
echo Stopping ERAM service...
sc stop Eram >nul 2>&1
timeout /t 3 /nobreak >nul

:: Disable and delete the ERAM service
echo Removing ERAM service...
sc config Eram start= disabled >nul 2>&1
sc delete Eram >nul 2>&1

:: Remove the driver file
echo Removing eram.sys...
if exist "%DRVDIR%\eram.sys" (
    del /f /q "%DRVDIR%\eram.sys" >nul 2>&1
    if exist "%DRVDIR%\eram.sys" (
        echo WARNING: eram.sys is currently in use and cannot be deleted now.
        echo It will need to be deleted manually after reboot:
        echo   %DRVDIR%\eram.sys
    ) else (
        echo eram.sys removed.
    )
)

:: Unregister and remove control panel applet
echo Removing control panel applet...
if exist "%SYSDIR%\eram.cpl" (
    del /f /q "%SYSDIR%\eram.cpl" >nul 2>&1
    if exist "%SYSDIR%\eram.cpl" (
        echo WARNING: eram.cpl could not be deleted now.
        echo It will need to be deleted manually after reboot:
        echo   %SYSDIR%\eram.cpl
    ) else (
        echo eram.cpl removed.
    )
)

:: Remove registry entries
echo Removing registry entries...
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Eram"                               /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\EventLog\System\Eram"              /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Eram"            /f >nul 2>&1
echo Registry entries removed.

:: Remove the ERAM program files folder
if exist "%ProgramFiles%\ERAM" (
    rmdir /s /q "%ProgramFiles%\ERAM" >nul 2>&1
)

echo.
echo ERAM has been uninstalled successfully!
echo.
echo A system reboot is required to complete the uninstallation.
set /p REBOOT=Would you like to reboot now? (Y/N): 
if /i "%REBOOT%"=="Y" (
    shutdown /r /t 10 /c "Rebooting to complete ERAM uninstallation."
) else (
    echo Please reboot your system manually to complete the uninstallation.
)
echo.
pause
endlocal
