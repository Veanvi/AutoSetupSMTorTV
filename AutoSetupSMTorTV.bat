@set @x=0; /*
@echo off
ver |>NUL find /v "5." && if "%~1"=="" cscript.exe //nologo //e:jscript "%~f0"& exit /b
:: Выше ничего не изменять! Это код для принудительного запуска с правами администратора

:: Определение версии операционной системы (Windows 7 или другие)
SetLocal EnableExtensions EnableDelayedExpansion
set "key=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
For /F "delims=" %%a in ('reg query "%key%" /v "ProductName" ^| find /i "ProductName"') do (
  set OSName=%%a
)
echo !OSName! |echo !OSName! |>NUL find /i "Windows 7" && call :W7 || call :Other
exit /B

:: Выполняется если скрипт запущен в Windows 7
:W7
:: Определение версии Powershell
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine" >nul
:: Стирание ошибки, чтобы пользователь не закрыл окно увидев ошибку.
cls
if !errorlevel! equ 0 (
  for /f "tokens=2*" %%a in ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine" /v PowerShellVersion') do set "psVersion=%%~b"
  set psVersion=!psVersion:~0,3!
  :: Если установлена Powershell более ранней версии 5.1 начинается установка 5.1. Иначе запускается установка TorTV
  if !psVersion! neq 5.1 (
        powershell -ExecutionPolicy RemoteSigned -Command " iex ((New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/Veanvi/AutoSetupSMTorTV/master/SetupWmfOnWin7.ps1', '%TEMP%\SetupWmfOnWin7.ps1'))"
        cls
        powershell -ExecutionPolicy RemoteSigned -file "%TEMP%\SetupWmfOnWin7.ps1"
  ) else (
    powershell -NoProfile -InputFormat None -ExecutionPolicy RemoteSigned -Command " [System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Veanvi/AutoSetupSMTorTV/master/SetupAndStartupTorTV.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\SetupAndStartupTorTV"
  )
) else (
  :: В Windows 7 не получилось запустить скрипт на прямую из сети
  powershell -ExecutionPolicy RemoteSigned -Command " iex ((New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/Veanvi/AutoSetupSMTorTV/master/SetupWmfOnWin7.ps1', '%TEMP%\SetupWmfOnWin7.ps1'))"
  cls
  powershell -ExecutionPolicy RemoteSigned -file "%TEMP%\SetupWmfOnWin7.ps1"
)
exit /B

:: Выполняется если скрипт запущен не в Windows 7
:Other
powershell -NoProfile -InputFormat None -ExecutionPolicy RemoteSigned -Command " [System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Veanvi/AutoSetupSMTorTV/master/SetupAndStartupTorTV.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\SetupAndStartupTorTV"

exit /B
 
:: Эту строку не трогать. Ниже ничего не писать!!! Это код для принудительного запуска с правами администратора
*/new ActiveXObject('Shell.Application').ShellExecute (WScript.ScriptFullName,'Admin','','runas',1);