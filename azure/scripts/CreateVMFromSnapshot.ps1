[CmdletBinding()]
param (
	[Parameter(Mandatory = $true)]
	[ValidatePattern('\w{1,}\.\w{1,}\.?[\w.]*')]
	[String]$VmName,
	[ValidateSet('Standard_F2s')]
	[String]$VmSize,
	[bool]$Exportable,
	[ValidateSet('Microsoft RSA SChannel Cryptographic Provider', 'Microsoft Enhanced DSS and Diffie-Hellman Cryptographic Provider')]
	[string]$Encryption = 'Microsoft RSA SChannel Cryptographic Provider',
	[Parameter(Mandatory = $true)]
	[String]$Destination
)

$VmName = ""
$VmSize = ""

$vm = Get-AzVM -ResourceGroupName $TargetResourceGroup -Name $VmName -ErrorAction SilentlyContinue
if (!$vm) {
	$vmConfig = New-AzVMConfig -VMName $VmName -VMSize $VmSize
	
	
	$nic = "NIC-$VmName"
	
	$ip = Get-AzNetworkInterface -Name $nic -ResourceGroupName $TargetResourceGroup -ErrorAction SilentlyContinue
	if (!$ip) {
		$ip = New-AzNetworkInterface -Name $nic -Location $Location -ResourceGroupName $TargetResourceGroup -NetworkSecurityGroup $Nsg -Subnet $subnet
	}

}

#Provide the subscription Id
$subscriptionId = 'yourSubscriptionId'

#Provide the name of your resource group
$resourceGroupName ='yourResourceGroupName'

#Provide the name of the snapshot that will be used to create OS disk
$snapshotName = 'yourSnapshotName'

#Provide the name of the OS disk that will be created using the snapshot
$osDiskName = 'yourOSDiskName'

#Provide the name of an existing virtual network where virtual machine will be created
$virtualNetworkName = 'yourVNETName'

#Provide the name of the virtual machine
$virtualMachineName = 'yourVMName'

#Provide the size of the virtual machine
#e.g. Standard_DS3
#Get all the vm sizes in a region using below script:
#e.g. Get-AzVMSize -Location westus
$virtualMachineSize = 'Standard_DS3'

#Set the context to the subscription Id where Managed Disk will be created
Select-AzSubscription -SubscriptionId $SubscriptionId

$snapshot = Get-AzSnapshot -ResourceGroupName $resourceGroupName -SnapshotName $snapshotName

$diskConfig = New-AzDiskConfig -Location $snapshot.Location -SourceResourceId $snapshot.Id -CreateOption Copy

$disk = New-AzDisk -Disk $diskConfig -ResourceGroupName $resourceGroupName -DiskName $osDiskName

#Initialize virtual machine configuration
$VirtualMachine = New-AzVMConfig -VMName $virtualMachineName -VMSize $virtualMachineSize

#Use the Managed Disk Resource Id to attach it to the virtual machine. Please change the OS type to linux if OS disk has linux OS
$VirtualMachine = Set-AzVMOSDisk -VM $VirtualMachine -ManagedDiskId $disk.Id -CreateOption Attach -Windows

#Create a public IP for the VM
$publicIp = New-AzPublicIpAddress -Name ($VirtualMachineName.ToLower()+'_ip') -ResourceGroupName $resourceGroupName -Location $snapshot.Location -AllocationMethod Dynamic

#Get the virtual network where virtual machine will be hosted
$vnet = Get-AzVirtualNetwork -Name $virtualNetworkName -ResourceGroupName $resourceGroupName

$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $nic.Id

#Create the virtual machine with Managed Disk
New-AzVM -VM $VirtualMachine -ResourceGroupName $resourceGroupName -Location $snapshot.Location