#<powershell>
Install-WindowsFeature -name Web-Server -IncludeManagementTools

New-Item -Path C:\inetpub\wwwroot\index.html -ItemType File -Value "<img src=http://en.dnstools.ch/out/1.gif>" -Force

#</powershell>