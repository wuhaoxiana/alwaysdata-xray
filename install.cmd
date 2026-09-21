@echo off
rem Uploads start.sh and setup.sh to alwaysdata over SSH and runs setup.sh there (Windows).
rem
rem   install.cmd account@ssh-account.alwaysdata.net
if "%~1"=="" (
    echo Usage: install.cmd account@ssh-account.alwaysdata.net
    exit /b 1
)
cd /d "%~dp0"

tar -cf - start.sh setup.sh | ssh %1 "tar -xf - -C ~ --exclude='._*' --warning=no-unknown-keyword && bash ~/setup.sh"
