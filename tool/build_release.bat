@echo off
set "PROGRAMFILES(X86)=C:\Program Files (x86)"
set "PROGRAMFILES=C:\Program Files"
set "LOCALAPPDATA=C:\Users\bala\AppData\Local"
set "APPDATA=C:\Users\bala\AppData\Roaming"
set "PROGRAMDATA=C:\ProgramData"
cd /d C:\Users\bala\omnitoolkit
call flutter build windows --release
exit /b %ERRORLEVEL%
