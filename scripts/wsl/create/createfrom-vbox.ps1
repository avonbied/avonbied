<#
Author: Lex von Biedenfeld <github.com/avonbied>
.NOTES
	This requires VirtualBox executable (VBoxManage.exe) to be on the $PATH
#>
[CmdletBinding()]
param (
	[Parameter(Mandatory=$true,
		HelpMessage="Name of target WSL instance")]
	[ValidatePattern("^[a-zA-Z][\w\.\-]*$")]
	[string]$WslName,
	[Parameter(HelpMessage="Reference VirtualBox disk path")]
	[string]$ReferenceVirtualBoxDisk,
	[Parameter(HelpMessage="Target parent WSL directory")]
	[string]$ParentDirectory = "$env:USERPROFILE\wsl"
)

$basePath = "$ParentDirectory\$($WslName.ToLower())"

if (-not (Test-Path $basePath)) {
	New-Item -ItemType Directory $basePath
}

# Get disk info
# VBoxManage.exe list hdds | select "$ReferenceVirtualBoxDisk.vdi"

## Clone VDI into VHDX
VBoxManage.exe clonemedium "$ReferenceVirtualBoxDisk" "$basePath\$WslName.vhd" --format=VHD
Convert-VHD "$ReferenceVirtualBoxDisk.vhd" "$basePath\ext4.vhdx"

# Import disk and cleanup
wsl --import-in-place $WslName "$basePath\ext4.vhdx"
VBoxManage.exe closemedium disk "$basePath\$WslName.vhd" --delete