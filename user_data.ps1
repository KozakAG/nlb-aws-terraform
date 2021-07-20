#<powershell>
Install-WindowsFeature -name Web-Server -IncludeManagementTools
Set-NetFirewallRule -Name “WINRM-HTTP-In-TCP-PUBLIC” -RemoteAddress “Any”
Enable-PSRemoting –force
Start-Service -Name Winrm
#</powershell>