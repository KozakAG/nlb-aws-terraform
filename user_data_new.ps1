$User = "Administrator"
$User
#
# Get public ip
#
$public_ip = (Get-Ec2Instance).Instances.PublicIpAddress
$public_ip[0]
$public_ip[1]
#
# Get instance id
#
$id =(Get-EC2Instance).Instances.InstanceID
$id[0]
$id[1]
#
# Get password
#
$pswd0 = aws ec2 get-password-data --instance-id  $id[0] --priv-launch-key C:\Users\Asgard\.aws\my_keypair
$pswd0[2] = $pswd0[2].Substring(21,32)
$pswd0[2]

$pswd1 = aws ec2 get-password-data --instance-id  $id[1] --priv-launch-key C:\Users\Asgard\.aws\my_keypair
$pswd1[2] = $pswd1[2].Substring(21,32)
$pswd1[2]
#
# connection to instances and their change 
#

$PWord = ConvertTo-SecureString -String $pswd0[2] -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
Enter-PSSession -ComputerName $public_ip[0] -Credential $Credential
New-Item -Path C:\inetpub\wwwroot\index.html -ItemType File -Value "<img src=http://en.dnstools.ch/out/1.gif>" -Force
exit

$PWord = ConvertTo-SecureString -String $pswd1[2] -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
Enter-PSSession -ComputerName $public_ip[1] -Credential $Credential
New-Item -Path C:\inetpub\wwwroot\index.html -ItemType File -Value "<img src=http://en.dnstools.ch/out/1.gif>" -Force
exit
