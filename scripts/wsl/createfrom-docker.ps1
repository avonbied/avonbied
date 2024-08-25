<#
Author: Lex von Biedenfeld <github.com/avonbied>
#>
[CmdletBinding()]
param (
	[Parameter(Mandatory=$true,
		HelpMessage="Name of target WSL instance")]
	[ValidateNotNullOrEmpty()]
	[string]$WslName,
	[Parameter(HelpMessage="Target parent WSL directory")]
	[string]$ParentDirectory = '.',
	[Parameter(HelpMessage="Reference Docker image")]
	[string]$ReferenceDockerImage = 'alpine:latest'
)

$wslMask = $WslName.ToLower().Replace(' ','')
$targetDataPath = "$ParentDirectory\$wslMask"

# Export Docker as tar
docker.exe pull $ReferenceDockerImage
docker.exe run -t --name 'wsl_export' $ReferenceDockerImage ls /
docker.exe export 'wsl_export' | Out-File 'wsl_export.tar'
docker.exe rm 'wsl_export'

# Import tar and cleanup
wsl.exe --import $WslName $targetDataPath 'wsl_export.tar'
Remove-Item 'wsl_export.tar'