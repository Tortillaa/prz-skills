@echo off
REM Windows entry point for install.ps1.
REM A .ps1 file does not run when the execution policy is Restricted, the
REM default on many Windows 11 installs. This launcher bypasses that policy
REM for this process only. It does not change the user or machine setting.
setlocal EnableExtensions
set "PRZ_INSTALL_SCRIPT=%~dp0install.ps1"
set "PRZ_INSTALL_ARGS=%*"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference = 'Stop'; Invoke-Expression ('& ''' + ($env:PRZ_INSTALL_SCRIPT -replace '''', '''''') + ''' ' + $env:PRZ_INSTALL_ARGS)"
exit /b %ERRORLEVEL%
