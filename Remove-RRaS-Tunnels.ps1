<# 

.NOTES 
+---------------------------------------------------------------------------------------------+ 
| ORIGIN STORY                                                                                | 
+---------------------------------------------------------------------------------------------+ 
|   DATE        : 14/09/2021                                                                  |
|   AUTHOR      : Chris Hailes (cubesys)                                                      | 
|   VERSION     : 0.5                                                                         | 
+---------------------------------------------------------------------------------------------+ 

.SYNOPSIS 
 This Powershell script opens the rasphone profile and removes Tunnels based on their name,
 useful when trying to clean up previous deployments which don't remove themselves

#> 

& $Env:SystemRoot\System32\rasphone.exe -r "User Tunnel"
