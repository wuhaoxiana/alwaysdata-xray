@echo off
rem Uploads start.sh and setup.sh to ~/xray on alwaysdata over SSH and runs setup.sh there (Windows).
rem
rem   install.cmd account@ssh-account.alwaysdata.net
if "%~1"=="" (
    echo Usage: install.cmd account@ssh-account.alwaysdata.net
    exit /b 1
)
cd /d "%~dp0"

tar -cf - start.sh setup.sh | ssh %1 "cd ~ && { [ ! -f xray ] || mv xray xray.old; } && mkdir -p xray && tar -xf - -C xray --exclude='._*' --warning=no-unknown-keyword && bash xray/setup.sh"
