# Include hosts.txt file in the same directory as script is ran from.
# File should contain a list of resovlable hostsnames.
# Make sure to update the endpoint for API - LINE 53.

write-host "▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄"
write-host "██░▄▄▄█░██░▄▄▀█░▄▄█▄░▄██▄██▀▄▀████░██░█▀▄▄▀█░▄▄█▄░▄████░▄▄▀█░████░▄▄█▀▄▀█░█▀█░▄▄█░▄▄▀"
write-host "██░▄▄▄█░██░▀▀░█▄▄▀██░███░▄█░█▀████░▄▄░█░██░█▄▄▀██░█████░████░▄▄░█░▄▄█░█▀█░▄▀█░▄▄█░▀▀▄"
write-host "██░▀▀▀█▄▄█▄██▄█▄▄▄██▄██▄▄▄██▄█████░██░██▄▄██▄▄▄██▄█████░▀▀▄█▄██▄█▄▄▄██▄██▄█▄█▄▄▄█▄█▄▄"
write-host "▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀"

# Take creds fro API call.
$User = Read-host "Enter Username"
$Pass = Read-host "Enter Password"

# Delete and then create CSV for results.
try{
del .\results.csv
}
catch
{
}
New-item results.csv
Set-Content results.csv 'IP, State'
write-output ""

# Ingest hostnames from file.
$hosts = Get-content .\hosts.txt
$Total = $hosts.Count

# Resolve hostnames to IPs.
$ips = foreach ($i in $hosts)
{
try
{
(Resolve-DnsName $i).IPAddress
}
catch
{
}
}

# Loop through IPs, checking API for logs.
# Add results to CSV.
foreach ($x in $ips)
{
$query =  '{
  """query""": {
    """match""":{
      """host.ip""": """'+$x+'"""
  }
}
}'
try{
$response = curl.exe -u $User':'$Pass -X GET -s "https://<YOUR_ENDPOINT_HERE:9243/logs-*/_search" -H 'Content-Type: application/json' -d $query

$badresponse = '"max_score":null'

if ($response -match $badresponse)
{
#write-host $($x) "MISSING"
Add-content .\results.csv "$($x), MISSING"
}
else
{
#write-host $($x)"OK"
Add-content .\results.csv "$($x), OK"
}

}
catch
{
write-host 'API call failed.'
}
}

# Count results and output.
$Results = Import-csv .\results.csv
$Log_count = ($Results | findstr "OK").count
$Not_log_count = ($Results | findstr "MISSING").count
if ($($Not_log_count + $Log_count) -eq $Total)
{
write-host ""
write-host "Checksum OK"
write-host ""
write-host "$($Log_count) hosts logging"
write-host "$($Not_log_count) hosts not logging"
}
else
{
write-host "Checksum BAD"
}

Write-Output ""
Write-Output "Report generated in this directory as results.csv."
Write-Output ""
sleep 10
Exit
