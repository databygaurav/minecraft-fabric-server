@echo off
setlocal
powershell.exe -NoLogo -NoProfile -File "%~dp0start.ps1" %*
exit /b %errorlevel%
