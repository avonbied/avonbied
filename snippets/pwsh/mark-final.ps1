[CmdletBinding()]
param (
	# Specifies a path to one or more locations. Wildcards are permitted.
	[Parameter(Mandatory=$true,
		ValueFromPipeline=$true,
		HelpMessage="Path to one or more locations.")]
	[ValidateNotNullOrEmpty()]
	[string]$SearchPath,
	[Parameter(Mandatory=$true, HelpMessage="Microsoft365 file types (ex. docx, pptx)")]
	[string[]]$FileTypes = @("pptx","docx","xlsx")
)

$appMap = @{
	"pptx"="powerpoint";
	"docx"="word";
	"xlsx"="excel";
}

foreach ($fileType in $FileTypes) {
	$app = New-Object -ComObject "$($appMap[$fileType]).application"
	$app.visible = $False
	Get-ChildItem -Path $SearchPath -File -Recurse | Where-Object { $_.Extension.TrimStart('.') -in $fileType } | ForEach-Object {
		$filename = $_.FullName
		$document = switch ($_.Extension.TrimStart('.')) {
			docx {
				$app.Documents.Open($filename)
			}
			pptx {
				$app.Presentations.Open($filename)
			}
			xlsx {
				$app.Workbooks.Open($filename)
			}
			Default {
				Write-Information "File: $($filename) does not have a valid extension"
				continue;
			}
		}
		$document.Final = $true
		$document.Close($true)
	}
	$app.Quit()
}