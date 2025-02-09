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
	[Parameter(HelpMessage="Reference VirtualBox VM")]
	[string]$ReferenceVirtualBoxVM,
	[Parameter(HelpMessage="Target parent WSL directory")]
	[string]$ParentDirectory = "$env:USERPROFILE\wsl"
)

$basePath = "$ParentDirectory\$($WslName.ToLower())"

if (-not (Test-Path $basePath)) {
	New-Item -ItemType Directory $basePath
}

# Get VMInfo
## Get Config File
$configFile = (VBoxManage.exe 'showvminfo' $ReferenceVirtualBoxVM | Select-String -SimpleMatch 'Config file:').Line.Replace('Config file:','').Trim()
$vboxNms = @{ ns = "http://www.virtualbox.org/" }
## VMName
## PrimaryDiskInfo (Name & Size)
$vmDiskId = (Select-Xml -Path $configFile -Namespace $vboxNms -XPath '//ns:StorageControllers/ns:StorageController[@name="SATA"]/ns:AttachedDevice[@port="0"]/ns:Image/@uuid').Node.Value
$vmDiskSize = (VBoxManage.exe 'showmediuminfo' 'disk' $vmDiskId | Select-String -SimpleMatch 'Capacity:').Line.Replace('Capacity:','').Replace('MBytes','').Trim()
## Location, Capacity
# Create & Attach Disk
## Size: PrimaryDiskInfo
function addDisk() {
	VBoxManage.exe createmedium disk --filename="$diskLocation\diskClone.vdi" --size=$vmDiskSize
	VBoxManage.exe storageattach $ReferenceVirtualBoxVM --storagectl=$storageController --medium="$diskLocation\diskClone.vdi" --port=$lastPort
}


# Copy Disk
## VMName: VMInfo
function copyDisk() {
	## Format as Partitionless Filesystem
	mkfs -t ext4 /dev/sdc
	## Mount Clone Filesystem
	mount /dev/sdc /media/clone
	## Clone FileSystem with Rsync
	rsync -aPHAXx --delete / /media/clone
	# Detach disk
	VBoxManage.exe storageattach $ReferenceVirtualBoxVM --storagectl=$storageController --medium='none' --port=$lastPort
}

# Convert & Import Disk
function importDisk() {
	## Copy VDI Clone into VHD
	VBoxManage.exe clonemedium "$diskLocation\diskClone.vdi" "$diskLocation\diskClone.vhd" --format=VHD
	## Convert VHD to VHDX
	Convert-VHD "$diskLocation\diskClone.vhd" "$basePath\ext4.vhdx"
	## Cleanup VDI & VHD
	VBoxManage.exe closemedium disk "$diskLocation\diskClone.vdi" --delete
	VBoxManage.exe closemedium disk "$diskLocation\diskClone.vhd" --delete
	# Use WSL import-in-place
	wsl --import-in-place $WslName "$basePath\ext4.vhdx"
}
