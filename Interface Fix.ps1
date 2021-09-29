<# 

.NOTES 
+---------------------------------------------------------------------------------------------+ 
| ORIGIN STORY                                                                                | 
+---------------------------------------------------------------------------------------------+ 
|   DATE        : 24/09/2021                                                                  |
|   AUTHOR      : Chris Hailes (cubesys)                                                      | 
|   VERSION     : 1.1                                                                         | 
+---------------------------------------------------------------------------------------------+ 

.SYNOPSIS 
 This PowerShell script is used to inspect Windows10 Machines for a build version and apply a interface
 metric fix for Always On VPN interfaces

 Windows 10 1809 and earlier doesn't honour the split tunnel configuration as expected. This was identified in a recent customer project.

 This script stops the RRaS tunnel from using automatic interface metrics for the device and user tunnel in this example
 we force Windows 10 1809 or lower to use a interface metric of 4 to force all traffic down the tunnel rather than Windows 10 1903 and higher
 will use an interface metric of 85 as they honour the profile XML and are able to split tunnel traffic as expected


.v1.1
 Added an eventlog entry to place the Write-Host content into an event log for remote validation purposes

#> 

#Parameters
# Get Local Username
$username = $((gwmi win32_Computersystem -Property UserName -Impersonation Impersonate).Username).Split("\")[1]
#Build User based Rasphone Location (User Tunnel)
If (Test-Path -Path "C:\Users\$($username)\Appdata\Roaming\Microsoft\Network\Connections\Pbk\rasphone.pbk"){
    $usrrasphone = ('C:\Users\' + $username + '\Appdata\Roaming\Microsoft\Network\Connections\Pbk\rasphone.pbk')
} Else {
    $usrrasphone = ('C:\Users\' + $username + '\Appdata\Roaming\Microsoft\Network\Connections\Pbk\_hiddenpBk\rasphone.pbk')
}
#System based Rasphone Location (Device Tunnel)
$sysrasphone = "C:\ProgramData\Microsoft\Network\Connections\Pbk\rasphone.pbk"
#Set interface metric value
$rollbackmetric = 'IpInterfaceMetric=4'
$rollforwardmetric = 'IpInterfaceMetric=85'
#Get Windows Build Number
$winbuild = (Get-WmiObject -class Win32_OperatingSystem).BuildNumber
#Create New Event Log Source
New-EventLog -Source AOVPN -LogName Application -ErrorAction SilentlyContinue

If ($winbuild -le "17763"){
        #User tunnel static metric
        (Get-Content $usrrasphone) -replace 'IpInterfaceMetric=81', $rollbackmetric | Set-Content $usrrasphone
        (Get-Content $usrrasphone) -replace 'IpInterfaceMetric=82', $rollbackmetric | Set-Content $usrrasphone
        (Get-Content $usrrasphone) -replace 'IpInterfaceMetric=80', $rollbackmetric | Set-Content $usrrasphone
        (Get-Content $usrrasphone) -replace 'IpInterfaceMetric=0', $rollbackmetric | Set-Content $usrrasphone

        #Log the Outcome of script execution
        $logmetric = (Get-Content $usrrasphone) | Select-String -Pattern "IpInterfaceMetric=" -SimpleMatch
            
        if ($logmetric -like '*IpInterfaceMetric=0*'){
        Write-EventLog -LogName "Application" -Source "AOVPN" -EventID 3015 -EntryType Error -Message "$usrrasphone `n`n AOVPN Interface Metric Fix PowerShell script has been executed`n $(foreach ($entry in $logmetric){"`n$($entry)"})" -Category 1 -RawData 10,20
        } Else {
        Write-EventLog -LogName "Application" -Source "AOVPN" -EventID 3010 -EntryType Information -Message "$usrrasphone `n`n AOVPN Interface Metric Fix PowerShell script has been executed`n $(foreach ($entry in $logmetric){"`n$($entry)"})" -Category 1 -RawData 10,20
        }

        #Device tunnel static metric
        (Get-Content $sysrasphone) -replace 'IpInterfaceMetric=81', $rollbackmetric | Set-Content $sysrasphone 
        (Get-Content $sysrasphone) -replace 'IpInterfaceMetric=82', $rollbackmetric | Set-Content $sysrasphone
        (Get-Content $sysrasphone) -replace 'IpInterfaceMetric=80', $rollbackmetric | Set-Content $sysrasphone
        (Get-Content $sysrasphone) -replace 'IpInterfaceMetric=0', $rollbackmetric | Set-Content $sysrasphone

        #Log the Outcome of script execution
        $logmetric = (Get-Content $sysrasphone) | Select-String -Pattern "IpInterfaceMetric=" -SimpleMatch

        if ($logmetric -like '*IpInterfaceMetric=0*'){
        Write-EventLog -LogName "Application" -Source "AOVPN" -EventID 3015 -EntryType Error -Message "$sysrasphone `n`n Interface Metric Fix PowerShell script has been executed`n $(foreach ($entry in $logmetric){"`n$($entry)"})" -Category 1 -RawData 10,20
        } Else {
        Write-EventLog -LogName "Application" -Source "AOVPN" -EventID 3010 -EntryType Information -Message "$sysrasphone `n`n Interface Metric Fix PowerShell script has been executed`n $(foreach ($entry in $logmetric){"`n$($entry)"})" -Category 1 -RawData 10,20
        }
   
} Else {
        #User tunnel static metric
        (Get-Content $usrrasphone) -replace 'IpInterfaceMetric=4', $rollforwardmetric | Set-Content $usrrasphone
        (Get-Content $usrrasphone) -replace 'IpInterfaceMetric=81', $rollforwardmetric | Set-Content $usrrasphone
        (Get-Content $usrrasphone) -replace 'IpInterfaceMetric=82', $rollforwardmetric | Set-Content $usrrasphone           
        (Get-Content $usrrasphone) -replace 'IpInterfaceMetric=80', $rollforwardmetric | Set-Content $usrrasphone
        (Get-Content $usrrasphone) -replace 'IpInterfaceMetric=0', $rollforwardmetric | Set-Content $usrrasphone

        #Log the Outcome of script execution
        $logmetric = (Get-Content $usrrasphone) | Select-String -Pattern "IpInterfaceMetric=" -SimpleMatch

        if ($logmetric -like '*IpInterfaceMetric=0*'){
        Write-EventLog -LogName "Application" -Source "AOVPN" -EventID 3015 -EntryType Error -Message "$sysrasphone `n`n Interface Metric Fix PowerShell script has been executed`n $(foreach ($entry in $logmetric){"`n$($entry)"})" -Category 1 -RawData 10,20
        } Else {
        Write-EventLog -LogName "Application" -Source "AOVPN" -EventID 3010 -EntryType Information -Message "$sysrasphone `n`n Interface Metric Fix PowerShell script has been executed`n $(foreach ($entry in $logmetric){"`n$($entry)"})" -Category 1 -RawData 10,20
        }
   
        #Device tunnel static metric
        (Get-Content $sysrasphone) -replace 'IpInterfaceMetric=4', $rollforwardmetric | Set-Content $sysrasphone 
        (Get-Content $sysrasphone) -replace 'IpInterfaceMetric=81', $rollforwardmetric | Set-Content $sysrasphone 
        (Get-Content $sysrasphone) -replace 'IpInterfaceMetric=82', $rollforwardmetric | Set-Content $sysrasphone            
        (Get-Content $sysrasphone) -replace 'IpInterfaceMetric=80', $rollforwardmetric | Set-Content $sysrasphone
        (Get-Content $sysrasphone) -replace 'IpInterfaceMetric=0', $rollforwardmetric | Set-Content $sysrasphone

        #Log the Outcome of script execution
        $logmetric = (Get-Content $sysrasphone) | Select-String -Pattern "IpInterfaceMetric=" -SimpleMatch

        if ($logmetric -like '*IpInterfaceMetric=0*'){
        Write-EventLog -LogName "Application" -Source "AOVPN" -EventID 3015 -EntryType Error -Message "$sysrasphone `n`n Interface Metric Fix PowerShell script has been executed`n $(foreach ($entry in $logmetric){"`n$($entry)"})" -Category 1 -RawData 10,20
        } Else {
        Write-EventLog -LogName "Application" -Source "AOVPN" -EventID 3010 -EntryType Information -Message "$sysrasphone `n`n Interface Metric Fix PowerShell script has been executed`n $(foreach ($entry in $logmetric){"`n$($entry)"})" -Category 1 -RawData 10,20
        }
   }
