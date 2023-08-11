# Remove blank lines in file
Get-Content $file | Where-Object { $_.Trim() -ne '' } | Set-Content $file

# Output all installed applications (use Get-CimInstance over Get-WmiObject) into a CSV
Get-CimInstance Win32_Product | Sort-Object Name | Export-Csv -Path "$env:COMPUTERNAME.csv"

# Find string in file
Select-String -Path $file -Pattern $pattern

# Output all running/stopped services
Get-Service | Select-Object -Property Name, DisplayName, Status, CanPauseAndContinue, CanShutdown, CanStop, ServiceType, @{l='DependentServices';e={[string]::join(';',($_.MemberOf))}}, @{l='ServicesDependedOn';e={[string]::join(';',($_.MemberOf))}} | -Path "$env:COMPUTERNAME.csv"
