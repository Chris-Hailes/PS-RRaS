<# 

.NOTES 
+---------------------------------------------------------------------------------------------+ 
| ORIGIN STORY                                                                                | 
+---------------------------------------------------------------------------------------------+ 
|   DATE        : 22/09/2021                                                                  |
|   AUTHOR      : Chris Hailes (cubesys)                                                      | 
|   VERSION     : 1.0                                                                         | 
+---------------------------------------------------------------------------------------------+ 

.SYNOPSIS 
 This PowerShell script is used to inspect Windows10 Machines for a build version and apply a interface
 metric fix for Always On VPN interfaces

 Windows 10 1809 and earlier doesn't honour the split tunnel configuration properly. This was identified in a recent customer project.

 This script stops the RRaS tunnel from using automatic interface metrics for the device and user tunnel in this example
 we force Windows 10 1809 or lower to use a interface metric of 4 to force all traffic down the tunnel rather than Windows 10 1903 and higher
 will use an interface metric of 85 as they honour the profile XML and are able to split tunnel traffic correctly

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

If ($winbuild -le "17763"){
    Write-Host 'Checking User RRaS Phone Book for IpInterfaceMetric Entries' -ForegroundColor Green
    (Get-Content $usrrasphone | Select-String -Pattern "IpInterfaceMetric=" -SimpleMatch)
        #User tunnel static metric
        (Get-Content $usrrasphone) -replace 'IpInterfaceMetric=81', $rollbackmetric | Set-Content $usrrasphone
        (Get-Content $usrrasphone) -replace 'IpInterfaceMetric=82', $rollbackmetric | Set-Content $usrrasphone
        (Get-Content $usrrasphone) -replace 'IpInterfaceMetric=80', $rollbackmetric | Set-Content $usrrasphone
        (Get-Content $usrrasphone) -replace 'IpInterfaceMetric=0', $rollbackmetric | Set-Content $usrrasphone
    Write-Host 'Checking User RRaS Phone Book for IpInterfaceMetric Entries post update' -ForegroundColor Green
    (Get-Content $usrrasphone | Select-String -Pattern "IpInterfaceMetric=" -SimpleMatch)

    Write-Host 'Checking System RRaS Phone Book for IpInterfaceMetric Entries' -ForegroundColor Green
    (Get-Content $sysrasphone | Select-String -Pattern "IpInterfaceMetric=" -SimpleMatch)
        #Device tunnel static metric
        (Get-Content $sysrasphone) -replace 'IpInterfaceMetric=81', $rollbackmetric | Set-Content $sysrasphone 
        (Get-Content $sysrasphone) -replace 'IpInterfaceMetric=82', $rollbackmetric | Set-Content $sysrasphone
        (Get-Content $sysrasphone) -replace 'IpInterfaceMetric=80', $rollbackmetric | Set-Content $sysrasphone
        (Get-Content $sysrasphone) -replace 'IpInterfaceMetric=0', $rollbackmetric | Set-Content $sysrasphone
    Write-Host 'Checking System RRaS Phone Book for IpInterfaceMetric Entries post update' -ForegroundColor Green
    (Get-Content $sysrasphone | Select-String -Pattern "IpInterfaceMetric=" -SimpleMatch)
   
} Else {
    Write-Host 'Checking User RRaS Phone Book for IpInterfaceMetric Entries' -ForegroundColor Green
    (Get-Content $usrrasphone | Select-String -Pattern "IpInterfaceMetric=" -SimpleMatch)
        #User tunnel static metric
        (Get-Content $usrrasphone) -replace 'IpInterfaceMetric=4', $rollforwardmetric | Set-Content $usrrasphone
        (Get-Content $usrrasphone) -replace 'IpInterfaceMetric=81', $rollforwardmetric | Set-Content $usrrasphone
        (Get-Content $usrrasphone) -replace 'IpInterfaceMetric=82', $rollforwardmetric | Set-Content $usrrasphone           
        (Get-Content $usrrasphone) -replace 'IpInterfaceMetric=80', $rollforwardmetric | Set-Content $usrrasphone
        (Get-Content $usrrasphone) -replace 'IpInterfaceMetric=0', $rollforwardmetric | Set-Content $usrrasphone
    Write-Host 'Checking User RRaS Phone Book for IpInterfaceMetric Entries post update' -ForegroundColor Green
    (Get-Content $usrrasphone | Select-String -Pattern "IpInterfaceMetric=" -SimpleMatch)

    Write-Host 'Checking System RRaS Phone Book for IpInterfaceMetric Entries' -ForegroundColor Green
    (Get-Content $usrrasphone | Select-String -Pattern "IpInterfaceMetric=" -SimpleMatch)
        #Device tunnel static metric
        (Get-Content $sysrasphone) -replace 'IpInterfaceMetric=4', $rollforwardmetric | Set-Content $sysrasphone 
        (Get-Content $sysrasphone) -replace 'IpInterfaceMetric=81', $rollforwardmetric | Set-Content $sysrasphone 
        (Get-Content $sysrasphone) -replace 'IpInterfaceMetric=82', $rollforwardmetric | Set-Content $sysrasphone            
        (Get-Content $sysrasphone) -replace 'IpInterfaceMetric=80', $rollforwardmetric | Set-Content $sysrasphone
        (Get-Content $sysrasphone) -replace 'IpInterfaceMetric=0', $rollforwardmetric | Set-Content $sysrasphone
    Write-Host 'Checking System RRaS Phone Book for IpInterfaceMetric Entries post update' -ForegroundColor Green
    (Get-Content $usrrasphone | Select-String -Pattern "IpInterfaceMetric=" -SimpleMatch)
}
