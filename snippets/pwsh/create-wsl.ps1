$ImageName = "Test-VM"
$IsoFile = "test.iso"
$TargetVHDSize = 64GB

$bootDrive = "$ImageName-bootswap.vdi"
$rootDrive = "$ImageName-root.vdi"
$cloneDrive = "$ImageName-clone.vdi"
$cloneVHD = "$ImageName-clone.vhd"

# Install & Setup Distro on VBox
## Create VM
VBoxManage.exe createvm $ImageName --register --default --ostype=Linux_64
## Create & Attach Disks
VBoxManage.exe createmedium disk --filename=$bootDrive --size=1536
VBoxManage.exe storageattach $ImageName --storagectl=$bootDrive
VBoxManage.exe createmedium disk --filename=$rootDrive --size=($TargetVHDSize / 1MB)
VBoxManage.exe storageattach $ImageName --storagectl=$rootDrive
## Unattended install
VBoxManage.exe unattended install $ImageName --iso=$IsoFile

## Validate Output
VBoxManage.exe showvminfo $ImageName

# Make Clone
## Create & Attach Disks
VBoxManage.exe createmedium disk --filename=$cloneDrive --size=($TargetVHDSize / 1MB)
VBoxManage.exe storageattach $ImageName --storagectl=$cloneDrive
## Format as Partitionless Filesystem
mkfs -t ext4 /dev/sdc
## Mount Clone Filesystem
mount /dev/sdc /media/clone
## Clone FileSystem with Rsync
rsync -aPHAXx --delete / /media/clone
## Copy VDI Clone into VHD
VBoxManage.exe clonemedium $cloneDrive $cloneVHD disk --format=VHD
## Convert VHD to VHDX
Convert-VHD $cloneVHD .\ext4.vhdx


# Use WSL import-in-place
wsl --import-in-place $ImageName .\ext4.vhdx