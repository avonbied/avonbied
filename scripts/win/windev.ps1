[CmdletBinding()]
param (
	[Parameter(HelpMessage="Install select options from list")]
	[ValidateSet("base", "dev", "iac")]
	[string[]]$InstallOptions = @("base"),
	[Parameter(HelpMessage="Installs all options")]
	[switch]$All
)

Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe

$configIds = if $All {
	@("base", "dev", "iac")
} else {
	$InstallOptions + "base" | Select-Object -Unique
}

foreach ($option in configIds) -or $All {
	winget.exe import -f ".\config\$option.dsc.yaml"
}