<#
Author: Lex von Biedenfeld <github.com/avonbied>
.NOTES
	There are a few security/system risks
	associated with the automount WSL config.
	It is recommended to disable both automount
	and interop before using this script then
	re-enabling after.
#>
[CmdletBinding()]
param (
	[Parameter(Mandatory=$true,
		HelpMessage="Name of target WSL instance")]
	[ValidateNotNullOrEmpty()]
	[string]$WslName,
	[Parameter(HelpMessage="Target parent WSL directory")]
	[string]$ParentDirectory = '.',
	[Parameter(HelpMessage="Size of the target disk")]
	[Int64]$TargetDiskSize = 16GB
)

# Supported pkg managers #
$pkg_cli = @{
	apk = @('sudo apk update', 'sudo apk add --no-cache sudo rsync e2fsprogs')
	apt = @('sudo apt update', 'sudo apt-get install sudo rsync e2fsprogs')
	dnf = @('sudo dnf check-update', 'sudo dnf install -y sudo rsync e2fsprogs')
	pacman = @('sudo pacman -Syc sudo rsync e2fsprogs')
	yum = @('sudo yum check-update', 'sudo yum install -y sudo rsync e2fsprogs')
	zypper = @('sudo zypper install sudo rsync e2fsprogs')
}

function runAllInWsl($commands) {
	foreach($cmd in $commands) {
		wsl.exe -d $WslName $cmd.Split(' ');
	}
}
function runInWsl($cmd) {
	wsl.exe -d $WslName $cmd
}

$wslMask = $WslName.ToLower().Replace(' ','')
$tempDiskName = "$wslMask-temp.vhdx"
$targetDataPath = "$ParentDirectory\$wslMask"

function createTempDisk {
	if (-not (Test-Path "$targetDataPath\$tempDiskName")) {
		if (-not (Test-Path $targetDataPath)) {
			New-Item -ItemType Directory $targetDataPath
		}
		New-VHD -Dynamic -SizeBytes $TargetDiskSize -Path "$targetDataPath\$tempDiskName"
	} elseif (Test-Path "$targetDataPath\$tempDiskName") {
		Write-Error "ERROR: Temporary Disk ($tempDiskName) Already Exists. Please Remove and Retry."
		exit
	}
}

function installPackages {
	foreach($manager in $pkg_cli.Keys()) {
		if ((runInWsl @('command', '-v', $manager)).Length -gt 0) {
			runAllInWsl $pkg_cli[$manager]
			break
		}
		Write-Output "FAILED TO INSTALL PACKAGE: Package manager not found. You must manually install: "${packagesNeeded[@]}"">&2;
	}
}

function cloneDisk([string]$devName) {
	# "\\.\PhysicalDrive$((Mount-VHD -Path <pathToVHD> -PassThru | Get-Disk).Number)"
wsl.exe --mount --bare --vhd "$ParentDirectory\$wslDiskDir.vhdx"
wsl.exe -d $WslName @('dmesg', '|', 'grep', '-i', 'attached scsi disk') | Select-Object -Last 1


## Format as Partitionless Filesystem
mkfs -t ext4 /mnt/sdc
## Mount Clone Filesystem
mount /dev/sdc /media/clone
## Clone FileSystem with Rsync
rsync -aPHAXx --delete / /media/clone

}



# Use WSL import-in-place
wsl --import-in-place $ImageName .\ext4.vhdx