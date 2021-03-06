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

function StartPlayerCloseHandler () {
    $scriptBlock = { 
        function DisableProxy () {
            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyEnable -Value 0
        
            # Добавлено для совместимости с Windows 7
            $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections'
            $data = (Get-ItemProperty -Path $key -Name DefaultConnectionSettings).DefaultConnectionSettings
            $data[8] = 9
            Set-ItemProperty -Path $key -Name DefaultConnectionSettings -Value $data
        }

        function ShowNotification() {
            Add-Type -AssemblyName System.Windows.Forms 
            $global:balloon = New-Object System.Windows.Forms.NotifyIcon
            $path = (Get-Process -id $pid).Path
            $balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 
            $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning 
            $balloon.BalloonTipText = 'Tor proxy выключено'
            $balloon.BalloonTipTitle = 'Внимание ' + $Env:USERNAME
            $balloon.Visible = $true 
            $balloon.ShowBalloonTip(5000)
        }
        
        $potPlayerProc = Get-Process -Name PotPlayer*
        Write-Host $potPlayerProc
        
        if($potPlayerProc) {
            $potPlayerProc.WaitForExit()
            Stop-Process -ProcessName Privoxy, tor, PotPlayerMini*
            DisableProxy
            ShowNotification
        }                                       
    }  
     
    Start-Process powershell -ArgumentList @("-WindowStyle Hidden", "-NoLogo", $scriptBlock)
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
    $balmsg.ShowBalloonTip(5000)
}

function EditPrivoxyConfigForConnectToTor() {
    $fileName = ""

    $winArch = (Get-WmiObject Win32_OperatingSystem | Select-Object OSArchitecture).OSArchitecture
    if($winArch[0] -eq "6"){
        $fileName = "C:\Program Files (x86)\Privoxy\config.txt"
    }else {
        $fileName = "C:\Program Files\Privoxy\config.txt"
    }

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

Write-Host "Запускается установка необходимого ПО для TorTV. Пожалуйста, подождите." -foreground Green
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
choco install axel tor privoxy -y

# Проверка установлен ли пакет, если установлен у объекта будет 3 свойства, если нет то 2
if(Test-Path -Path "$env:TEMP\chocolatey\potplayer"){
    Remove-Item -Path "$env:TEMP\chocolatey\potplayer" -Recurse
}
# Таймаут в команде установки установлен для прерывания опирации установки
# Это нужно, чтобы создать набор папок текущей версии PotPlayer, а загрузка будет осуществляться в ручную
$isPotPlayInstalled = choco search potplayer --local-only
if($isPotPlayInstalled.Length -eq 2){
    choco install potplayer -y --timeout 20
}
if($isPotPlayInstalled.Length -eq 3) {
    choco upgrade potplayer -y --timeout 20
}
# Ручная загрузка PotPlayer, с помощью Axel Download Accelerator
# Если папка $env:TEMP\chocolatey\potplayer существует, значит нужно переустанвоить PotPlayer
$isPotPlayerNeedToReinstall = Test-Path -Path "$env:TEMP\chocolatey\potplayer"
if($isPotPlayerNeedToReinstall){
    $serchResult = Get-ChildItem -Path "$env:TEMP\chocolatey\" -Include "PotPlayerSetup*.exe" -Recurse -Force -ErrorAction SilentlyContinue | Get-ChildItem
    if($serchResult.Exists){
        $winArch = (Get-WmiObject Win32_OperatingSystem | Select-Object OSArchitecture).OSArchitecture
        $progFilesPath = If ($winArch[0] -eq "6") {"PotPlayerSetup64.exe"} Else {"PotPlayerSetup.exe"}

        $url = "https://t1.daumcdn.net/potplayer/PotPlayer/Version/Latest/$progFilesPath"
        Write-Host "Загружается PotPlayer. Пожалуйста, подождите." -foreground Green
        Remove-Item $serchResult.FullName -Force
        # -n колличесвто потоков загрузки, -a альтернативный лог загрузки, -o каталог в который идет загрузка
        axel -n 10 -a -o $serchResult.DirectoryName $url

        if ($isPotPlayInstalled.Length -eq 2) {
            choco install potplayer -y --ignore-checksum
        }else {
            choco upgrade potplayer -y --ignore-checksum
        }
    }
}
# Изменияется конфиг файл Privoxy для подключения к Tor
EditPrivoxyConfigForConnectToTor

# ---------- Запуск или остановка Tor-TV ----------

$currentProxy = GetProxy

# Если прокси выключено, то включается прокси и запускаются TorExpertBundle, Privoxy, PotPlayer со ссылкой на контент в Tor
if (-Not $currentProxy.ProxyEnable) {

    $winArch = (Get-WmiObject Win32_OperatingSystem | Select-Object OSArchitecture).OSArchitecture
    $progFilesPath = If ($winArch[0] -eq "6") {"C:\Program Files (x86)"} Else {"C:\Program Files"}

    Start-Process -FilePath "C:\ProgramData\chocolatey\lib\tor\tools\Tor\tor.exe" -WindowStyle Hidden
    Set-Location -Path "$progFilesPath\Privoxy"
    Start-Process -FilePath "privoxy.exe" -WindowStyle Hidden

    ShowNotification("Настройки прокси вашей ОС изменены.")

    SetProxy -server "127.0.0.1" -port 8118
    $potPlayerExeName = If ($winArch[0] -eq "6") {"PotPlayerMini64.exe"} Else {"PotPlayerMini.exe"}

    $potPlayerPath = "C:\Program Files\DAUM\PotPlayer\$potPlayerExeName"

    $playListUriArray = @(
        "http://olegtitov3x4u2qz.onion/hls/1",
        "http://olegtitov3x4u2qz.onion/hls/2",
        "http://olegtitov3x4u2qz.onion/hls/3",
        "http://olegtitov3x4u2qz.onion/hls/"
    )

    Stop-Process -ProcessName PotPlayerMini*
    $potPlayerProc = Start-Process -FilePath $potPlayerPath -PassThru
    $potPlayerProc.WaitForInputIdle()

    # Открытие нового, скрытого окна консоли, которое следит за завершением работы PotPlayer
    # Если плеер закрывается, скрипт закрывает torExpertBundle с Privoxy и выключает proxy
    StartPlayerCloseHandler

    # Ссылка, которая должна воспроизводиться автоматически, должна быть последней в $playListUriArray
    if($playListUriArray.Count -gt 1){
        for ($i = 0; $i -lt $playListUriArray.Count; $i++) {
            Start-Process -FilePath $potPlayerPath -ArgumentList @($playListUriArray[$i], "/add", "/current")
        }
    }
    Start-Sleep -s 1
    # Start-Process -FilePath $potPlayerPath -ArgumentList "/autoplay /current"
    }
# Если прокси включено, то закрываются TorExpertBundle, Privoxy, PotPlayer и выключается прокси
else {
    ShowNotification("Tor proxy выключено")
    Stop-Process -ProcessName Privoxy, tor, PotPlayerMini*
    DisableProxy
}
