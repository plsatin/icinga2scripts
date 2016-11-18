<#
icinga2scripts
Version 0.2
Description: Shutdown system.
Pavel Satin (c) 2016
pslater.ru@gmail.com
#>

$returnStateOK = 0
$returnStateWarning = 1
$returnStateCritical = 2
$returnStateUnknown = 3

#Проверка аргументов
if ( $args[0] -ne $Null) {
    $ComputerName = $args[0]
} else {
    $ComputerName = "localhost"
}


$result = Test-Connection -ComputerName $ComputerName -Count 2 -Quiet

if ($result)
{

Stop-Computer -computername $ComputerName -force
Write-Host "OK - Command send."
[System.Environment]::Exit($returnStateOK)

} #End if test-connection result
else {
    	Write-Host "Хост $ComputerName не доступен."
		[System.Environment]::Exit($returnStateUnknown)
}