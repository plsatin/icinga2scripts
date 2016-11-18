<#
icinga2scripts
Version 1.0
Description: Скрипт для Icinga 2 - Запуск RemoteDesktop через туннель
Pavel Satin (c) 2016
pslater.ru@gmail.com
#>


$returnStateOK = 0
$returnStateWarning = 1
$returnStateCritical = 2
$returnStateUnknown = 3

#Windows Balloon
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
$objNotifyIcon = New-Object System.Windows.Forms.NotifyIcon 



if ($args[0] -eq $null) {

    $objNotifyIcon.Icon = "C:\Scripts\images\icinga.ico"
    $objNotifyIcon.BalloonTipIcon = "Error" 
    $objNotifyIcon.BalloonTipText = "Параметр с именем хоста не передан! Работа скрипта завершена."
    $objNotifyIcon.BalloonTipTitle = "Подключение через туннель"
 
    $objNotifyIcon.Visible = $True 
    $objNotifyIcon.ShowBalloonTip(30000)

    Start-Sleep -s 10
    $objNotifyIcon.Visible = $false
    $script:objNotifyIcon.Dispose()
    #Remove–Variable –Scope script –Name objNotifyIcon

    exit
}

$rdpHost = $args[0]

$plinkPath = "C:\Scripts\bin\"


add-type -TypeDefinition  @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
            public bool CheckValidationResult(
                ServicePoint srvPoint, X509Certificate certificate,
                WebRequest request, int certificateProblem) {
                return true;
            }
        }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

$user = "icinga"
$pass = "password"
$secpasswd = ConvertTo-SecureString $pass -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($user, $secpasswd)
$apiurl = "https://78.24.216.120:5665/v1/objects/services/" + $rdpHost + "!create-rdp-tunnel?attrs=last_check_result"
#$headers = @{}
#$headers["Accept"] = "application/json"

#Write-Host $apiurl

$apireq = Invoke-WebRequest -Credential $credential -Uri $apiurl -Method Get -UseBasicParsing -ContentType "text/plain; charset=Windows-1251"

$outputresult = $apireq | ConvertFrom-Json | Select -expand Results | Select -expand attrs | Select -expand last_check_result 
$strOutput = $outputresult.output
$indxPlink = $strOutput.IndexOf("plink")

$portnum = "339" + (Get-Random -minimum 10 -maximum 99).ToString()

$strOutput2 = $strOutput.Substring($indxPlink, $strOutput.Length - $indxPlink)



$cmdArgs = "/C " + $strOutput2.Replace("3379", $portnum)
$mstscArgs = "/v localhost:$portnum"


#Запуск процессов
Start-Process cmd.exe $cmdArgs
Start-Process mstsc.exe $mstscArgs



$objNotifyIcon.Icon = "C:\Scripts\images\icinga.ico"
$objNotifyIcon.BalloonTipIcon = "Info" 
$objNotifyIcon.BalloonTipText = "Устанавливаем подключение к $rdpHost"
$objNotifyIcon.BalloonTipTitle = "Подключение через туннель"
 
$objNotifyIcon.Visible = $True 
$objNotifyIcon.ShowBalloonTip(30000)

Start-Sleep -s 30
$objNotifyIcon.Visible = $false
$script:objNotifyIcon.Dispose()
#Remove–Variable –Scope script –Name objNotifyIcon
