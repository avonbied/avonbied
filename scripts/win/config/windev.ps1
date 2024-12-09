[CmdletBinding()]
param (
	# Specifies a path to one or more locations. Wildcards are permitted.
	[Parameter(Mandatory=$true,
		ValueFromPipeline=$true,
		HelpMessage="Path to one or more locations.")]
	[ValidateNotNullOrEmpty()]
	[string]$SearchPath,
	[Parameter(Mandatory=$true, HelpMessage="Microsoft365 file types (ex. docx, pptx)")]
	[string[]]$FileTypes = @("pptx","docx","xlsx"),
	[Parameter(Mandatory=$true, HelpMessage="The number of days of logs history")]
	[ValidateRange(1, 365)]
	[Int32]$LogDuration = 7
)
Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
winget import 