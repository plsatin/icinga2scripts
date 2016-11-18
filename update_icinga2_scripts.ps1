<#
icinga2scripts
Version 0.2
Description: Update powershell from remote host.
Pavel Satin (c) 2016
pslater.ru@gmail.com
#>

$returnStateOK = 0
$returnStateWarning = 1
$returnStateCritical = 2
$returnStateUnknown = 3

$localDir = "c:\Scripts\icinga2\"

$ScriptHost = "http://78.24.216.120"
$ScriptHostPath = $ScriptHost + "/icinga2scripts/"

Try
{
$HttpContent = Invoke-WebRequest -URI $ScriptHostPath -UseBasicParsing

$ArrLinks = $HttpContent.Links | Foreach {$_.href }

Foreach ($ArrStr in  $ArrLinks)
{
if ( $ArrStr.endsWith(".ps1") -OR $ArrStr.endsWith(".exe") -OR $ArrStr.endsWith(".dll"))
	{
		##Для Apache2
		$NewScriptHostPath = $ScriptHostPath + $ArrStr
		##Для IIS, он отдает ссылки с вместе с виртуальными каталогами
		#$NewScriptHostPath = $ScriptHost + $ArrStr

		$localFile = $localDir + $ArrStr
		Invoke-WebRequest -URI $NewScriptHostPath -UseBasicParsing -OutFile $localFile
		
		$script_count = $script_count + 1

	}
}

	$icinga2_status = "Update OK: Downloads " + $script_count + " scripts."
	
	Write-Host $icinga2_status
	[System.Environment]::Exit($returnStateOK)

}
Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
	
	Write-Host $ErrorMessage
	[System.Environment]::Exit($returnStateCritical)

}