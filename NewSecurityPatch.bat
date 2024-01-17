@echo off
:: ### START UAC SCRIPT ###

if "%2"=="firstrun" exit
cmd /c "%0" null firstrun

if "%1"=="skipuac" goto skipuacstart

:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (shift & goto gotPrivileges)

setlocal DisableDelayedExpansion
set "batchPath=%~0"
setlocal EnableDelayedExpansion
ECHO Set UAC = CreateObject^("Shell.Application"^) > "%temp%\OEgetPrivileges.vbs"
ECHO UAC.ShellExecute "!batchPath!", "ELEV", "", "runas", 1 >> "%temp%\OEgetPrivileges.vbs"
"%temp%\OEgetPrivileges.vbs"
exit /B

:gotPrivileges

setlocal & pushd .

cd /d %~dp0
cmd /c "%0" skipuac firstrun
cd /d %~dp0

:skipuacstart

if "%2"=="firstrun" exit

:: ### END UAC SCRIPT ###

:: ### START OF YOUR OWN BATCH SCRIPT BELOW THIS LINE ###

echo Blocking all Ports

REG ADD HKLM\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices /v Deny_All /t REG_DWORD /d 1 /f
REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Msi.Package\DefaultIcon /v (Default) /t REG_SZ /d C:\Windows\System32\msiexec.exe,1 /f
echo Done..!

echo Creating New User
set /p NAME=Enter New Username :
set /p PWD=Enter Password :  
net user %NAME% %PWD% /add
echo Done..!

echo Setting Password Expire Age
wmic useraccount where "Name='%NAME%'" set PasswordExpires=true
net accounts /maxpwage:90
echo Done..!

echo Installing Chrome Thunderbird Winrar Skype Anydesk
set /p ANAME=Enter Admin Username : 
cd C:\Users\%ANAME%\Downloads
curl "https://drive.usercontent.google.com/download?id=1y4y2RVCz9utoddJOyHvsFgmF_8EEa0JP&export=download&authuser=0&confirm=t&uuid=e13d0ff5-b493-49a4-b48e-6ac1b4f8b773&at=APZUnTXZf6TtHcwMH3Kf0uotti8T:1692279971973" -O
Installer.exe
curl "https://download.anydesk.com/AnyDesk.exe" -O  
AnyDesk.exe
echo Done..!

echo Now system is going to restart
pause
shutdown -r -t 0
del %0