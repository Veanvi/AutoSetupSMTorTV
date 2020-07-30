#requires -runasadministrator

# ---------- Функции ----------

function GetProxy () {
    Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' | Select-Object ProxyServer, ProxyEnable        
}

function SetProxy { 
    [CmdletBinding()]
    [Alias('proxy')]
    [OutputType([string])]
    Param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        $server,
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        $port    
    )
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyServer -Value "$($server):$($port)"
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyEnable -Value 1

    # Без этого изменения прокси не включается в Windows 7
    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections'
    $data = (Get-ItemProperty -Path $key -Name DefaultConnectionSettings).DefaultConnectionSettings
    $data[8] = 11
    Set-ItemProperty -Path $key -Name DefaultConnectionSettings -Value $data

    GetProxy 
}

function DisableProxy () {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyEnable -Value 0

    # Добавлено для совместимости с Windows 7
    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections'
    $data = (Get-ItemProperty -Path $key -Name DefaultConnectionSettings).DefaultConnectionSettings
    $data[8] = 9
    Set-ItemProperty -Path $key -Name DefaultConnectionSettings -Value $data
}

function ShowNotification([String]$msg) {
    # Чтобы в уведомлениях WinForms корректно отображалась кириллица кодировка скрипта должна быть UTF-16 LE
    Add-Type -AssemblyName System.Windows.Forms
    $global:balmsg = New-Object System.Windows.Forms.NotifyIcon
    $path = (Get-Process -id $pid).Path
    $balmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
    $balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning
    $balmsg.BalloonTipText = $msg
    $balmsg.BalloonTipTitle = "Внимание $Env:USERNAME"
    $balmsg.Visible = $true
    $balmsg.ShowBalloonTip(15000)
}

function EditPrivoxyConfigForConnectToTor() {
    $fileName = "C:\Program Files (x86)\Privoxy\config.txt"
    $fileOriginal = Get-Content $fileName
    [String[]]$fileModified = @()
    [String]$string = "forward-socks5t / 127.0.0.1:9050 ."

    $checkConfig = Select-String -InputObject $fileOriginal -SimpleMatch $string
    if ($checkConfig.Length -eq 0) {
        Foreach ($Line in $fileOriginal) {
            $fileModified += $Line
            if ($Line -match "#        forward-socks5t   /               127.0.0.1:9050 .") { $fileModified += $string }
        }
    }
    else {
        $fileModified = $fileOriginal
    }

    Set-Content $fileName $fileModified -Force

    # Удаление Privoxy из автозапуска
    $privoxyStartupInk = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\Privoxy.lnk" 
    if (Test-Path -Path  $privoxyStartupInk) {
        Remove-Item $privoxyStartupInk
    }
}

# ---------- Установка ПО ----------

Write-Host ""Запускается установка необходимого ПО для TorTV. Пожалуйста подождите."" -foreground Green
# Проверяет установлен ли Chocolatey.
$chocoVersion = choco
# Если не установлен вернется пустой объект, если установлен вернется объект с двумя свойствами
if ($chocoVersion.Length -ne 2) {
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Увеличение таймаута загрузки до двух часов, на случай медленного интернета
choco config set --name commandExecutionTimeoutSeconds --value 7200
# Устанавливается необходимое ПО
choco install tor privoxy potplayer -y
# Изменияется конфиг файл Privoxy для подключения к Tor
EditPrivoxyConfigForConnectToTor

# ---------- Запуск или остановка Tor-TV ----------

$currentProxy = GetProxy

# Если прокси выключено, то включается прокси и запускаются TorExpertBundle, Privoxy, PotPlayer со ссылкой на контент в Tor
if (-Not $currentProxy.ProxyEnable) {
    Start-Process -FilePath "C:\ProgramData\chocolatey\lib\tor\tools\Tor\tor.exe" -WindowStyle Hidden
    Set-Location -Path "C:\Program Files (x86)\Privoxy"
    Start-Process -FilePath "privoxy.exe" -WindowStyle Hidden

    ShowNotification("Настройки прокси вашей ОС изменены. Не забудьте запустить скрипт еще раз после завершения просмотра, чтобы отменить изменения.")

    SetProxy -server "127.0.0.1" -port 8118
    ."C:\Program Files\DAUM\PotPlayer\PotPlayerMini64.exe" "http://olegtitov3x4u2qz.onion/hls/" /urldlg
}
# Если прокси включено, то закрываются TorExpertBundle, Privoxy, PotPlayer и выключается прокси
else {
    ShowNotification("Изменения в настройках прокси вашей ОС отменены.")
    Stop-Process -ProcessName Privoxy, tor, PotPlayerMini64
    DisableProxy
}
