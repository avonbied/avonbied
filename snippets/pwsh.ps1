# Remove blank lines in file
Get-Content $file | Where-Object { $_.Trim() -ne '' } | Set-Content $file

# Output all installed applications (use Get-CimInstance over Get-WmiObject) into a CSV
Get-CimInstance Win32_Product | Sort-Object Name | Export-Csv -Path "$env:COMPUTERNAME.csv"

# Find string in file
Select-String -Path $file -Pattern $pattern

# Output all running/stopped services
Get-Service | Select-Object -Property Name, DisplayName, Status, ServiceType, @{l='DependentServices';e={[string]::join(';',($_.DependentServices.Name))}}, @{l='ServicesDependedOn';e={[string]::join(';',($_.ServicesDependedOn.Name))}} | -Path "$env:COMPUTERNAME.csv"

# Resolve DNS records for list of Hostnames (objects with a 'Hostname' property)
$hostnames | ForEach-Object {
	$initial = Resolve-DnsName $_.Hostname
	Add-Member -InputObject $_ -MemberType NoteProperty -Name MappedCNames -Value (($initial | Where-Object { $_.Type -eq 'CNAME' }).NameHost -join '; ')
	Add-Member -InputObject $_ -MemberType NoteProperty -Name IPs -Value (($initial | Where-Object { $_.Type -ne 'CNAME' }).IPAddress -join '; ') -PassThru
}
