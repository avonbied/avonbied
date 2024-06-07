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
	$App = New-Object -ComObject "$($appMap[$fileType]).application"
	$App.visible = $False
	Get-ChildItem -Path $SearchPath -File -Recurse | Where-Object { $_.Extension.TrimStart('.') -in $fileType } | ForEach-Object {
		$document = ""
		switch ($_.Extension.TrimStart('.')) {
			docx {
				$document = $App.Documents.Open($_.FullName)
			}
			pptx {
				$document = $App.Presentations.Open($_.FullName)
			}
			xlsx {
				$document = $App.Workbooks.Open($_.FullName)
			}
			Default {
				Write-Information "File: $($_.FullName) does not have a valid extension"
				continue;
			}
		}
		$document.Final = $true
		$document.Close($true)
	}
	$App.Quit()
}