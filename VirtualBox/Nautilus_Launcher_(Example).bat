@echo off
tasklist /FI "IMAGENAME eq Xming.exe" 2>NUL | find /I /N "Xming.exe" >NUL
if "%ERRORLEVEL%"=="1" start "" "%ProgramFiles(x86)%\Xming\Xming.exe" :0 -clipboard -multiwindow
set xmingdisplay=192.168.56.1:0.0
set runcmd=nautilus --no-desktop ~/Desktop/
set username=demon
set keyfile=C:\Users\Samuel\Documents\SSHKeys\FedoraVM.ppk
set vmnetwork=192.168.56.101
"%ProgramFiles(x86)%\PuTTY\plink.exe" -X -l "%username%" -i "%keyfile%" -ssh "%vmnetwork%" "export DISPLAY=%xmingdisplay%; %runcmd% > /dev/null 2>&1 & exit"
exit
