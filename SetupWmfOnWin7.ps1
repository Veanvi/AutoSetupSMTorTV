function DownloadFile([String]$uri) {
    $osVersion = (get-itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName
    $temp = $env:TEMP
    $localPath = If ($osVersion.Contains("Windows 7")) {$temp + "\Win7WMF.zip"} Else {$temp + "\Win8WMF.msu"}
    $webClient = New-Object System.Net.webClient
    $webClient.DownloadFile($uri, $localPath)
}

function UnpackDownloadedWmfFile() {
    $temp = $env:TEMP
    $shellApp = new-object -com shell.application
    $localPath = $temp + "\Win7WMF.zip"
    $zipFile = $shellApp.namespace($localPath)
    $destinationPath = $temp + "\WMF5"
    if (Test-Path -Path  $destinationPath) {
        Remove-Item $destinationPath -Force
    }
    New-Item -Path $destinationPath -ItemType Directory
    $destination = $shellApp.namespace($destinationPath)
    $destination.Copyhere($zipFile.items())
    Remove-Item $localPath -Force
}

# Проверка установлена ли Powershell 5.1. Если установлена выполнение прекращается
$powershellVerison = $PSVersionTable.PSVersion.Major + $PSVersionTable.PSVersion.Minor
if ($powershellVerison -eq 6) {
    Exit
}

$osArch = Get-WmiObject Win32_OperatingSystem | Select-Object OSArchitecture
Write-Host "Архитектура - " $osArch.OSArchitecture
$osVersion = (get-itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName

if($osVersion.Contains("Windows 7")) {
    # Проверка битности ОС. Если 64-bit выполняется блок if, иначе else
    if ($osArch.OSArchitecture[0] -eq "6") {
        Write-Host "Идет загрузка WMF 5.1 (65 мб), пожалуйста подождите." -foreground Green
        DownloadFile("https://go.microsoft.com/fwlink/?linkid=839523")
        Write-Host "Установочный файл загружен"
    }
    else {
        Write-Host "Идет загрузка WMF 5.1 (43 мб), пожалуйста подождите." -foreground Green
        DownloadFile("https://go.microsoft.com/fwlink/?linkid=839522")
        Write-Host "Установочный файл загружен"
    }

    UnpackDownloadedWmfFile

    Write-Host "Запускается установка WMF, пожалуйста следуйте инструкции" -foreground Green
    $wmfPath = $env:TEMP + "\WMF5"
    Set-Location -Path $wmfPath
    .\Install-WMF5.1.ps1
    Write-Host "Установка WMF 5.1 завершена" -foreground Green
} elseif ($osVersion.Contains("Windows 8")) {
    # Проверка битности ОС. Если 64-bit выполняется блок if, иначе else
    if ($osArch.OSArchitecture[0] -eq "6") {
        Write-Host "Идет загрузка WMF 5.1 (19 мб), пожалуйста подождите." -foreground Green
        DownloadFile("https://go.microsoft.com/fwlink/?linkid=839516")
        Write-Host "Установочный файл загружен"
    }
    else {
        Write-Host "Идет загрузка WMF 5.1 (15 мб), пожалуйста подождите." -foreground Green
        DownloadFile("https://go.microsoft.com/fwlink/?linkid=839521")
        Write-Host "Установочный файл загружен"
    }

    Write-Host "Запускается установка WMF, пожалуйста следуйте инструкции" -foreground Green
    $wmfPath = $env:TEMP + "\Win8WMF.msu"
    Start-Process -FilePath $wmfPath
    Write-Host "Установка WMF 5.1 завершена" -foreground Green
}
