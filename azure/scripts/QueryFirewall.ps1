$query = 'AzureDiagnostics
| where Category == "AzureFirewallNetworkRule"
| top 10 by TimeGenerated
| project TimeGenerated, SourceIP, TargetIP, Protocol, TargetPort, Action, msg_s'

$workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $resourceGroupName

Invoke-AzOperationalInsightsQuery -Query $query -Workspace $workspace | Select-Object -ExpandProperty Results
