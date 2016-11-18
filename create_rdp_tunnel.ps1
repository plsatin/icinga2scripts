<#
icinga2scripts
Version 1.0
Description: Скрипт для Icinga 2 - Создание ssh туннеля с удаленным хостом
Pavel Satin (c) 2016
pslater.ru@gmail.com
#>
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$returnStateOK = 0
$returnStateWarning = 1
$returnStateCritical = 2
$returnStateUnknown = 3


$portnum = "338" + (Get-Random -minimum 10 -maximum 99).ToString()


$tunnelcmd = "c:\ProgramData\icinga2\Scripts\icinga2\plink.exe"
$tunnelarg = "-batch -P 2201 -N -C -v -R " + $portnum + ":localhost:3389 ssh_user@78.24.216.120 -pw password"


$regSSHkey = "HKCU:\Software\SimonTatham\PuTTY\SshHostKeys"
$regSSHname = "rsa2@2201:78.24.216.120"
$regSSHval = "0x10001,0x976400932c69affb57afa1c726b021bf5b60d96c3469de8bfa3718e31f769537ae9978328241a83a8d1aae8f05a947f582d19d32283dd0465825be5d31ff25f4f7876bc138ca3f40957191911f95607465100146dae7aa62444ec5e646af6e7147c81057661ac7e58c19944aa3ac6dafafe119ca34568dbf61c27e4b6c1a1559c2ab40583764f38eba5d2111bad543bf3c885f5d2ae2d0dc906b3f699d74ef41c36df6b318a253eee01e859650387adf2489ea072072bd0ff00b9ebceec01999499ebb9b6931f1a5d22db0d27e8755e2a380f0959bf10cc3b8680ba2b7bf3bae8678e7cf034f4e63dddc3f2d6d709fe146ade24b74744ae7e794ee09e3ba541f"

if (!(Test-Path $regSSHkey -PathType Any)) {
	New-Item -Path $regSSHkey -Force | Out-Null
	New-ItemProperty -Path $regSSHkey -Name $regSSHName -Value $regSSHval -PropertyType String -Force | Out-Null
} else {
	New-ItemProperty -Path $regSSHkey -Name $regSSHName -Value $regSSHval -PropertyType String -Force | Out-Null
}


$process = (start-process $tunnelcmd -argumentlist $tunnelarg -PassThru)

Start-Sleep -s 5

if ($process.HasExited) {
    Write-Host "Ошибка запуска plink. Процесс закрыт с кодом: " $process.ExitCode
    [System.Environment]::Exit($returnStateCritical)
} else {
    Write-Host "<b>OK</b> - Туннель создан. Номер порта: <b>$portnum</b>"
    Write-Host "Подключиться можно:"
    Write-Host "plink.exe -P 2201 -N -C -v -L 3379:localhost:$portnum ssh_user@78.24.216.120 -pw password"
    [System.Environment]::Exit($returnStateOK)
}
