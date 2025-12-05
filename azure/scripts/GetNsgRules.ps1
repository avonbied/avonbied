$subscriptions = (Get-AzSubscription | Out-GridView -Title 'Choose Subscriptions' -PassThru)
$output = @()

$count = 0

foreach ($s in $subscriptions) {
	[void](Select-AzSubscription -Subscription $s)
	$ruleGroups = Get-AzNetworkSecurityGroup
	foreach ($ruleGroup in $ruleGroups) {
		Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $ruleGroup | ForEach-Object {
			$output += ([PSCustomObject]@{
				Subscription = $s.Name
				Region = $ruleGroup.Location
				NSG = $ruleGroup.Name
				Priority = $_.Priority
				Direction = $_.Direction
				Access = $_.Access
				Name = $_.Name
				Source = $_.SourceAddressPrefix -join '; '
				Target = $_.DestinationAddressPrefix -join '; '
				Protocol = $_.Protocol
				Port = $_.DestinationPortRange -join '; '
			})
		}
		$count += 1
	}
}

$output[0..10] | Format-Table -AutoSize

$output | Export-Csv -Path "$PSScriptRoot\nsgs.csv"
