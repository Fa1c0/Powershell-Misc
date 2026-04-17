# Path to the text file containing patterns to match
$namesFile = "Strings.txt"

# Root folder to search
$rootPath = "C:\INSERT\DRIVE\LOCATION\HERE"

# CSV log file with timestamp
$logFile = "deletions_{0:yyyy-MM-dd_HH-mm-ss}.csv" -f (Get-Date)

# Create CSV header
"Timestamp,Pattern,FileName,FullPath" | Out-File -FilePath $logFile -Encoding UTF8

# Read patterns (trim + skip blanks)
$patterns = Get-Content -Path $namesFile |
            ForEach-Object { $_.Trim() } |
            Where-Object { $_ -ne "" }

foreach ($pattern in $patterns) {
    Write-Host "Searching for files containing: $pattern"

    $wildcard = "*$pattern*"

    # Find matching files
    $files = Get-ChildItem -Path $rootPath -Recurse -File -ErrorAction SilentlyContinue |
             Where-Object { $_.Name -like $wildcard }

    foreach ($file in $files) {
        Write-Host "Deleting: $($file.FullName)"

        # Log entry
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "$timestamp,$pattern,$($file.Name),$($file.FullName)" |
            Out-File -FilePath $logFile -Append -Encoding UTF8

        # Delete file
        Remove-Item -Path $file.FullName -Force
    }
}

Write-Host "Done. CSV log saved to: $logFile"
