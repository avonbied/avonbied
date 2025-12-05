<#
Author: Lex von Biedenfeld <github.com/avonbied>
#>
[CmdletBinding()]
param (
	[Parameter(Mandatory=$true,
		HelpMessage="Name of target WSL instance")]
	[ValidatePattern("^[a-zA-Z][\w\.\-]*$")]
	[string]$WslName,
	[Parameter(HelpMessage="Reference Docker image")]
	[string]$ReferenceDockerImage = 'alpine:latest',
	[Parameter(HelpMessage="Target parent WSL directory")]
	[string]$ParentDirectory = "$env:USERPROFILE\wsl"
)

$basePath = "$ParentDirectory\$($WslName.ToLower())"

if (-not (Test-Path $basePath)) {
	New-Item -ItemType Directory $basePath
}

# Export Docker as tar
docker.exe pull $ReferenceDockerImage
docker.exe run -t --name 'wsl_export' $ReferenceDockerImage ls /
docker.exe export 'wsl_export' | Out-File 
docker.exe rm 'wsl_export'

# Import tar and cleanup
wsl.exe --import $WslName $basePath "$basePath\wsl_export.tar"
Remove-Item "$basePath\wsl_export.tar"