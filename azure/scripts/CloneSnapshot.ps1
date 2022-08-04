$ResourceGroupName = Read-Host -Prompt 'Resource Group: '
$VmName = Read-Host -Prompt 'VM Name: '
$TargetLocation = (Read-Host -Prompt 'Location ')

### Variables
$snapshotName = "$($VmName)_OSSnapshot-$(Get-Date -AsUTC -Format "yyyyMMdd_HHmmss")"
$vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName
[bool]$deployToSameRegion = $TargetLocation -eq $vm.Location

#We recommend you to store your snapshots in Standard storage to reduce cost. Please use Standard_ZRS in regions where zone redundant storage (ZRS) is available, otherwise use Standard_LRS
#Please check out the availability of ZRS here: https://docs.microsoft.com/en-us/Az.Storage/common/storage-redundancy-zrs#support-coverage-and-regional-availability
$snapshotConfig = New-AzSnapshotConfig -SourceUri $vm.StorageProfile.OsDisk.ManagedDisk.Id `
	-Location ($deployToSameRegion ? $vm.Location : $TargetLocation) `
	-CreateOption 'CopyStart' -SkuName 'Standard_LRS' -Incremental

if ($deployToSameRegion) {
	$tempSnapshot = New-AzSnapshot -SnapshotName "TEMP_$($VmName)-SNAPSHOT" -ResourceGroupName $ResourceGroupName -Snapshot $snapshotConfig
	#We recommend you to store your snapshots in Standard storage to reduce cost. Please use Standard_ZRS in regions where zone redundant storage (ZRS) is available, otherwise use Standard_LRS
	#Please check out the availability of ZRS here: https://docs.microsoft.com/en-us/Az.Storage/common/storage-redundancy-zrs#support-coverage-and-regional-availability
	$snapshotConfig = New-AzSnapshotConfig -SourceResourceId $tempSnapshot.Id -Location $TargetLocation `
		-CreateOption 'CopyStart' -SkuName 'Standard_LRS' -Incremental
}

$targetSnapshot.CompletionPercent

#Create a new snapshot in the target subscription and resource group
Return New-AzSnapshot -Snapshot $snapshotConfig -SnapshotName $snapshotName -ResourceGroupName $ResourceGroupName