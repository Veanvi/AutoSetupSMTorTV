@set @x=0; /*
@echo off
ver |>NUL find /v "5." && if "%~1"=="" cscript.exe //nologo //e:jscript "%~f0"& exit /b
:: Выше ничего не изменять! Это код для принудительного запуска с правами администратора

SetLocal EnableExtensions EnableDelayedExpansion

:: Отключение прокси на время загрузки скриптов
set "key=HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
for /f "tokens=2*" %%a in ('REG QUERY "%key%" /v ProxyEnable') do set "isProxyEnable=%%~b"

set "key=HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections"
for /f "tokens=2*" %%a in ('REG QUERY "%key%" /v DefaultConnectionSettings') do set "dcsArray=%%~b"

if !isProxyEnable! equ 1 (

  tasklist | Find /i "privoxy.exe"
  if !errorlevel! equ 0 goto skipChangeProxy

  REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f

  set dcsStartStr=%dcsArray:~0,17%
  set dcsEndStr=%dcsArray:~18%
  set "dcsResultStr=!dcsStartStr!9!dcsEndStr!"

  REG ADD "%key%" /v DefaultConnectionSettings /t REG_BINARY /d !dcsResultStr! /f
)

:skipChangeProxy

:: Определение версии операционной системы (Windows 7, Windows 8.1 или другие)
set "key=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
For /F "delims=" %%a in ('reg query "%key%" /v "ProductName" ^| find /i "ProductName"') do (
  set OSName=%%a
)

echo !OSName! |echo !OSName! |>NUL find /i "Windows 7" && call :W7 || echo !OSName! |>NUL find /i "Windows 8" && call :W7 || echo !OSName! |>NUL find /i "Windows 10" && call :W10
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
        powershell -ExecutionPolicy RemoteSigned -file "%~dp0SetupWmfOnWin7.ps1"
  ) else (
    powershell -ExecutionPolicy RemoteSigned -file "%~dp0SetupAndStartupTorTV.ps1"
  )
) else (
  :: В Windows 7 не получилось запустить скрипт на прямую из сети
  powershell -ExecutionPolicy RemoteSigned -file "%~dp0SetupWmfOnWin7.ps1"
)

exit /B

:: Выполняется если скрипт запущен не в Windows 7
:W10
powershell -ExecutionPolicy RemoteSigned -file "%~dp0SetupAndStartupTorTV.ps1"

exit /B

 
:: Эту строку не трогать. Ниже ничего не писать!!! Это код для принудительного запуска с правами администратора
*/new ActiveXObject('Shell.Application').ShellExecute (WScript.ScriptFullName,'Admin','','runas',1);