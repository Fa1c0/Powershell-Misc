# Simple script to create a list of Windows Servers and Desktops that have logged in the last hour.
# Endpoint URLs need amended before running.
# 2 Csv's are created in the dir where this is run listing hosts.

try { del .\Elastic_windows_servers.csv -ErrorAction SilentlyContinue}
catch { }
try { del .\Elastic_desktops.csv -ErrorAction SilentlyContinue}
catch { }

$User = Read-host "Enter Username"
$Pass = Read-host "Enter Password"

# Server search.
try{
$servers = curl.exe -u $User':'$Pass -X GET -s "<elastic_search_endpoint>:9243/<windows_system.security_index>/_search" -H 'Content-Type: application/json' -d'
{
  ""query"": {
    ""bool"": {
      ""filter"": {
        ""range"": {
          ""@timestamp"": {
            ""gte"": ""now-1h/h""
          }
        }
      }
    }
  },
  ""aggs"": {
    ""hostname"": {
      ""terms"": {
        ""field"": ""agent.name"",
        ""size"": 100
      }
    }
  },""size"": 0
}
'
}
catch
{
write-host 'Servers failed.'
}

$servers = $servers -replace "}"
$servers = $servers -replace '"'
$servers = $servers.Split("{")
$servers = $servers.Split(",") | findstr 'key'
$servers = $servers -replace "key:"
$servers >> Elastic_windows_servers.csv
Write-Output ""
Write-Output "$($servers.count) Windows Servers logging"

# Desktop search.
try{
$desktops = curl.exe -u $User':'$Pass -X GET -s "<elastic_search_endpoint>:9243/<windows_system.security_index>/_search" -H 'Content-Type: application/json' -d'
{
  ""query"": {
    ""bool"": {
      ""filter"": {
        ""range"": {
          ""@timestamp"": {
            ""gte"": ""now-1h/h""
          }
        }
      }
    }
  },
  ""aggs"": {
    ""hostname"": {
      ""terms"": {
        ""field"": ""agent.name"",
        ""size"": 100
      }
    }
  },""size"": 0
}
'
}
catch
{
write-host 'Desktops failed.'
}

$desktops = $desktops -replace "}"
$desktops = $desktops -replace '"'
$desktops = $desktops.Split("{") 
$desktops = $desktops.Split(",") | findstr 'key'
$desktops = $desktops -replace "key:"
$desktops >> Elastic_desktops.csv 

Write-Output "$($desktops.count) Desktops logging"
Write-Output ""
Write-Output "Reports generated."
Write-Output ""
sleep 3
Exit
