### This script performs nslookup and ping on all DNS names or IP addresses you list in the text file referenced in $InputFile.
### (One per line.) (Names or IPs can be used!) Outputs to the screen - just copy & paste the screen into Excel to work with results.

$InputFile = 'IPs'
$addresses = get-content $InputFile
        foreach($address in $addresses) {
            try {
                [system.net.dns]::resolve($address) | Select HostName,AddressList
                }
                catch {
                    Write-host "$address was not found. $_" -ForegroundColor Green
                }
            }
