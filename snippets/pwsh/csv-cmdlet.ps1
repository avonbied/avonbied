[CmdletBinding()]
param (
	# Specifies a path to one or more locations. Wildcards are permitted.
	[Parameter(Mandatory=$true,
		ValueFromPipeline=$true,
		HelpMessage="Path to one or more locations.")]
	[ValidateNotNullOrEmpty()]
	[string]$inputCsv,
	[Parameter(Mandatory=$false, HelpMessage="Output filename")]
	[string]$outputCsv,
	[switch]$NoHeaders = $false
)

# Replace this if the CSV has $NoHeaders
$CustomHeaders = 'ID,Header1'

#######
$Headers = @($CustomHeaders -split ',')

$csvData = if ($NoHeaders) {
	Import-Csv -Path $inputCsv -Delimiter ',' -Header $Headers
} else {
	Import-Csv -Path $inputCsv -Delimiter ','
}

if ($NoHeaders) {
	$Headers = $csvData[0].psobject.properties.name
}
Write-Host "CSV file: $inputCsv import completed"
########

<# Insert Code Here #>

########
Write-Host 'Exporting results to CSV file...'

$CSVName = if ($outputCsv -eq '') { "output-$(Get-Date -Format 'yyyyMMdd')" } else { $outputCsv }
$ExportPath = "$CSVName.csv"

try {
	$csvData | Export-Csv -Path $ExportPath -NoTypeInformation
}
catch {
	Write-Host "Error during CSV export.`nError: $($_.Exception.Message)" -ForegroundColor Red
	break
}

Write-Host "CSV file has been exported successfully to file: $ExportPath" -ForegroundColor Green