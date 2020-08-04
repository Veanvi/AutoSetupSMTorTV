[![Github Total Downloads](https://img.shields.io/github/downloads/Veanvi/AutoSetupSMTorTV/total)]() [![Code size](https://img.shields.io/github/languages/code-size/veanvi/AutoSetupSMTorTV)]()

# AutoSetupSMTorTV

Скрипт авто настройки Tor-TV: 1D - Первый тёмный, Сергея Мохрова.

При первом запуске скрипт подготавливает вашу ОС к просмотру TorTV, устанавливая необходимое ПО и запускает воспроизведение тестового канала TorTV.

Этот скрипт при запуске TorTV изменяет прокси вашей ОС на 127.0.0.1:8118, для проксирования трафика в Tor, и запускает PotPlayer с воспроизведением потокового контента Сергея Мохрова. Когда вы закрываете PotPlayer прокси выключается, а открытые скриптом фоновые программы (TorExpertBundle, Privoxy) закрываются автоматически.

Ниже смотрите скринкасты с примерами использования, все записи длятся меньше минуты и очень подробные.

![WorkPreview](https://github.com/Veanvi/AutoSetupSMTorTV/blob/master/WorkPreview.png)

## Оглавление
- [Поддерживаемые ОС](#Поддерживаемые-ОС)
- [Требования к запуску](#Требования-к-запуску)
    - [Windows 10](#Windows-10)
    - [Windows 7](#Windows-7)
    - [Windows 8](#Windows-8)
- [ВНИМАНИЕ](#ВНИМАНИЕ)
- [Список доступных Tor-TV каналов](#Список-доступных-Tor-TV-каналов)
- [Как скачать скрипт с GitHub](#Как-скачать-скрипт-с-GitHub)
- [Как установить и использовать скрипт](#Как-установить-и-использовать-скрипт)
    - [Windows 10](#Windows-10)
    - [Windows 7](#Windows-7)
    - [Windows 8(8.1)](#Windows-8(8.1))

## Поддерживаемые ОС
- Windows 7 x86/x64
- Windows 8(8.1) x86/x64
- Windows 10 x86/x64

## Требования к запуску

### Windows 10
Нет требований. В этой ОС есть все необходимое.

### Windows 7
У вас должен быть установлен .NET 4.5.2 или новее. Установить его можно по [этой ссылке](https://www.microsoft.com/download/details.aspx?id=42642). Если вы действительно используете Win7 как основную ОС, скорее всего .NET вы уже когда-нибудь обновляли.

### Windows 8
Нет требований. В этой ОС есть все необходимое.

## ВНИМАНИЕ
1. Этот скрипт включает прокси в вашей операционной системе, это означает, что весь трафик, всех программ на вашем ПК, будет идти через Tor сеть, пока PotPlayer не будет закрыт. При закрытие PotPlayer прокси отключается, но если это по какой-то пречине не произошло запуститье скрипт повторно и он отключит proxy.
2. Этот скрипт запускает три процесса Tor, Privoxy и PotPlayer. Tor и Privoxy запускаются в скрытом режиме. Это важно знать на случай, если вы захотите вручную закрыть все дочерние процессы через диспетчер задач.
3. После запуска скрипта, пока PotPlayer не будет закрыт, все браузеры на вашем компьютере могут заходить на сайты .onion в Tor сети, если они не проксированы установленными в них расширениями.
4. Файл запуска Tor-TV, доступный в релизах, запускает скрипты powershell из ветки мастер данного репозитория. Т.е. при каждом запуске он скачивает самую свежую версию скриптов и запускает их. Если вы не хотите чтобы на ваш компьютер скачивались скрипты без вашей проверки, можите воспользоваться специальной версией запускающего батника, который не скачивает ps1 скрипты из GitHub. Нужный вам файл называется [AutoSetupSMTorTV-LocalRun.bat](https://github.com/Veanvi/AutoSetupSMTorTV/blob/master/AutoSetupSMTorTV-LocalRun.bat), он запускает скрипты из той директории, в которой нахгодится. Для Win10 вы должны положить в дирикторию откуда запускаете AutoSetupSMTorTV-LocalRun.bat файл SetupAndStartupTorTV.ps1, а если у вас Win7 или Win8, то в дирикторию к запускающему батнику нужно положить сразу два файла, SetupAndStartupTorTV.ps1 и SetupWmfOnWin7.ps1.

## Список доступных Tor-TV каналов
- Канал с тестовым вещянием (http://olegtitov3x4u2qz.onion/hls/)
- Канал 1D - Первый тёмный (http://olegtitov3x4u2qz.onion/1D)

## Как скачать скрипт с GitHub

<details><summary>Нажмите, чтобы развернуть</summary>

![First start SMTorTV on Windows 10 Demo](https://raw.githubusercontent.com/Veanvi/AutoSetupSMTorTV/master/ReadmeGIFs/Other/HowDownload.gif)
</details>

## Как установить и использовать скрипт

### Windows 10
<details><summary>Нажмите, чтобы развернуть</summary>

<details><summary>Первый запуск (установка) SMTorTV</summary>

![First start SMTorTV on Windows 10 Demo](https://raw.githubusercontent.com/Veanvi/AutoSetupSMTorTV/master/ReadmeGIFs/Win10/Win10InstallTorTV.gif)
</details>

<details><summary>Все последующие запуски SMTorTV после первого</summary>

![Standart start SMTorTV on Windows 10 Demo](https://raw.githubusercontent.com/Veanvi/AutoSetupSMTorTV/master/ReadmeGIFs/Win10/Win10StartTorTV.gif)
</details>

</details>

### Windows 7
<details><summary>Нажмите, чтобы развернуть</summary>

<details><summary>Первый запуск (установка) SMTorTV</summary>

![First start SMTorTV on Windows 7 Demo](https://github.com/Veanvi/AutoSetupSMTorTV/raw/master/ReadmeGIFs/Win7/Win7InstallSVTorTV.gif)
</details>

<details><summary>Все последующие запуски SMTorTV после первого</summary>

![Standart start SMTorTV on Windows 7 Demo](https://github.com/Veanvi/AutoSetupSMTorTV/raw/master/ReadmeGIFs/Win7/Win7StartTorTV.gif)
</details>

</details>

### Windows 8(8.1)
<details><summary>Нажмите, чтобы развернуть</summary>

<details><summary>Первый запуск (установка) SMTorTV</summary>

![First start SMTorTV on Windows 8 Demo](https://github.com/Veanvi/AutoSetupSMTorTV/raw/master/ReadmeGIFs/Win8/Win8InstallSVTorTV.gif)
</details>

<details><summary>Все последующие запуски SMTorTV после первого</summary>

Все запуски после первого ничем не отличается от Windows 10 и Windows 7, посмотрите скринкаст этих ОС.
</details>

</details>