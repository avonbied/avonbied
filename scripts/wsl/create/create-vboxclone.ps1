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
	[Parameter(Mandatory=$true,
 		HelpMessage="Reference VirtualBox VM")]
	[string]$ReferenceVirtualBoxVM,
	[Parameter(HelpMessage="Target parent WSL directory")]
	[string]$ParentDirectory = "$env:USERPROFILE\wsl"
)

$basePath = "$ParentDirectory\$($WslName.ToLower())"
if (-not (Test-Path $basePath)) {
	New-Item -ItemType Directory $basePath
}

# Get VMInfo
function runInVm($cmd, $opts) {
	$optsList = ($opts -split ' ')
	return (VBoxManage.exe -q 'guestcontrol' $ReferenceVirtualBoxVM 'run' '--wait-stdout' '--username=root' '--password=root' "--exe=$cmd" '--' $optsList)
}
function getVmInfo() {
	# Get VMInfo
	## Get Config File
	$configFile = (VBoxManage.exe -q 'showvminfo' $ReferenceVirtualBoxVM | Select-String -SimpleMatch 'Config file:').Line.Replace('Config file:','').Trim()
	$vboxNms = @{ ns = 'http://www.virtualbox.org/' }
	## VMName
	## PrimaryDiskInfo (Name & Size)
	$vmDiskId = (Select-Xml -Path $configFile -Namespace $vboxNms -XPath '//ns:StorageControllers/ns:StorageController[@name="SATA"]/ns:AttachedDevice[@port="0"]/ns:Image/@uuid').Node.Value
	$vmDiskSize = (VBoxManage.exe -q 'showmediuminfo' 'disk' $vmDiskId | Select-String -SimpleMatch 'Capacity:').Line.Replace('Capacity:','').Replace('MBytes','').Trim()
	$vmDiskLocation = (VBoxManage.exe -q 'showmediuminfo' 'disk' $vmDiskId | Select-String -SimpleMatch 'Location:').Line.Replace('Location:','').Trim()
}

# Create & Attach Disk
## Size: PrimaryDiskInfo
function addDisk() {
	VBoxManage.exe createmedium disk --filename="$diskLocation\diskClone.vdi" --size=$vmDiskSize
 	VBoxManage.exe storageattach $ReferenceVirtualBoxVM --storagectl=$storageController --medium="$vmDiskLocation\diskClone.vdi" --port=$lastPort
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
 	VBoxManage.exe -q storageattach $ReferenceVirtualBoxVM --storagectl=$storageController --medium='none' --port=$lastPort
}

# Convert & Import Disk
function importDisk() {
	## Copy VDI Clone into VHD
	VBoxManage.exe -q clonemedium "$vmDiskLocation\diskClone.vdi" "$vmDiskLocation\diskClone.vhd" --format=VHD
	## Convert VHD to VHDX
	Convert-VHD "$vmDiskLocation\diskClone.vhd" "$basePath\ext4.vhdx"
	## Cleanup VDI & VHD
	VBoxManage.exe -q closemedium disk "$vmDiskLocation\diskClone.vdi" --delete
	VBoxManage.exe -q closemedium disk "$vmDiskLocation\diskClone.vhd" --delete
	# Use WSL import-in-place
	wsl --import-in-place $WslName "$basePath\ext4.vhdx"
}
