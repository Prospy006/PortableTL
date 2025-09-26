@echo off

REM Removing the Cache Files
cd /d "%~dp0JavaPortableLauncher\Data\AppData\.tlauncher\cache\" >nul
rmdir "https_repo.tlauncher.org\update" >nul
cd /d "%~dp0" >nul

REM Running TL
start "" "JavaPortableLauncher\JavaPortableLauncher.exe" "TLauncher.jar" >nul