# AutoSetupSMTorTV
Скрипт авто настройки Sergey Mokhrov TorTV. При первом запуске скрипт подготавливает вашу ОС к просмотру TorTV, устанавливая необходимое ПО. При последующих запусках скрипт изменяет прокси вашей ОС на 127.0.0.1:8118, для проксирования трафика в Tor, и запускает PotPlayer с воспроизведением потокового контента Сергея Мохрова. Ниже смотрите скринкасты с примерами использования, все записи длятся меньше минуты и очень подробные.

## Оглавление
- [Требования к запуску](#Требования-к-запуску)
    - [Windows 10](#Windows-10)
    - [Windows 7](#Windows-7)
- [ВНИМАНИЕ](#ВНИМАНИЕ)
- [Как скачать скрипт с GitHub](#Как-скачать-скрипт-с-GitHub)
- [Как установить и использовать скрипт](#Как-установить-и-использовать-скрипт)
    - [Windows 10](#Windows-10)
    - [Windows 7](#Windows-7)

## Требования к запуску

### Windows 10
Нет требований. В этой ОС есть все необходимое.

### Windows 7
У вас должен быть установлен .NET 4.5.2 или новее. Установить его можно по [этой ссылке](https://www.microsoft.com/download/details.aspx?id=42642). Если вы действительно используете Win7 как основную ОС, скорее всего .NET вы уже когда-нибудь обновляли.

## ВНИМАНИЕ
1. Этот скрипт включает прокси в вашей операционной системе, это означает, что весь трафик, всех программ на вашем ПК, будет идти через Tor сеть. После того, как вы закончите просмотр трансляции Сергея Мохрова вам обязательно нужно либо запустить скрипт повторно, чтобы он закрыл запущенные в фоне программы и отключил прокси, либо в ручную отключить прокси в настройках сети в Windows. Если вы этого не сделаете, многие сайты будут требовать ввод капчи при посещении, а сайты платежных систем и банков скорее всего не дадут доступ вообще.
2. Этот скрипт запускает три процесса Tor, Privoxy и PotPlayer. Tor и Privoxy запускаются в скрытом режиме. Это важно знать на случай, если вы захотите вручную закрыть все дочерние процессы через диспетчер задач.
3. В состав необходимого ПО, которое устанавливает скрипт автоматически, входит PotPlayer. Ресурс который распространяет этот плеер не вполне стабилен и иногда загрузка плеера обрывается. Шансы того, что это произойдет с вами при первом запуске довольно низкие, но все же существуют, если это произошло нужно запустить скрипт еще дважды, первый раз для отключения Tor прокси, второй для повторной попытки скачать PotPlayer.

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

<details><summary>Закрытие SMTorTV по завершению просмотра</summary>

![Stop SMTorTV on Windows 10 Demo](https://raw.githubusercontent.com/Veanvi/AutoSetupSMTorTV/master/ReadmeGIFs/Win10/Win10StopTorTV.gif)
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

<details><summary>Закрытие SMTorTV по завершению просмотра</summary>

![Stop SMTorTV on Windows 7 Demo](https://github.com/Veanvi/AutoSetupSMTorTV/raw/master/ReadmeGIFs/Win7/Win7StopTorTV.gif)
</details>

</details>