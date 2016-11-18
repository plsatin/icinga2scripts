<#
icinga2scripts
Version 0.2
Description: Скрипт для Icinga 2 - Информация об установленном ПО.
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

$array = @()


    #Define the variable to hold the location of Currently Installed Programs
    $UninstallKey = "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall" 

if ( $ComputerName -eq "localhost" ) {
    $reg = [microsoft.win32.registrykey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Default) 
} else {
    #Create an instance of the Registry Object and open the HKLM base key
    $reg = [microsoft.win32.registrykey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $ComputerName) 
}

    #Drill down into the Uninstall key using the OpenSubKey Method
    $regkey = $reg.OpenSubKey($UninstallKey) 

    #Retrieve an array of string that contain all the subkey names
    $subkeys = $regkey.GetSubKeyNames() 

    #Open each Subkey and use GetValue Method to return the required values for each

    foreach($key in $subkeys){

        $thisKey = $UninstallKey + "\\" + $key 

        $thisSubKey = $reg.OpenSubKey($thisKey) 

        $obj = New-Object PSObject
        #$obj | Add-Member -MemberType NoteProperty -Name "ComputerName" -Value $computername
        $obj | Add-Member -MemberType NoteProperty -Name "DisplayName" -Value $($thisSubKey.GetValue("DisplayName"))
        $obj | Add-Member -MemberType NoteProperty -Name "DisplayVersion" -Value $($thisSubKey.GetValue("DisplayVersion"))
        $obj | Add-Member -MemberType NoteProperty -Name "InstallLocation" -Value $($thisSubKey.GetValue("InstallLocation"))
        $obj | Add-Member -MemberType NoteProperty -Name "Publisher" -Value $($thisSubKey.GetValue("Publisher"))
        $obj | Add-Member -MemberType NoteProperty -Name "InstallDate" -Value $($thisSubKey.GetValue("InstallDate"))
        $array += $obj

    } 

$arraySort = $array | Sort-Object InstallDate –Descending

Write-Host "<b>Установленное ПО:</b>"
$arraySort | Where-Object { $_.DisplayName } | select DisplayName, InstallDate, Publisher | ConvertTo-Html -Fragment
[System.Environment]::Exit($returnStateOK)

} #End if test-connection result
else {
    	Write-Host "Хост $ComputerName не доступен."
		[System.Environment]::Exit($returnStateUnknown)
}
