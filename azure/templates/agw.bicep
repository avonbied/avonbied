targetScope = 'resourceGroup'

param location string = resourceGroup().location

param virtualNetwork string
param subnet string
@allowed(['1.0','1.1','1.2','1.3'])
param tlsVersion string

param isHttp2 bool = true

param appGatewayName string

var tls = replace(tlsVersion, '.', '_')

resource appGateway 'Microsoft.Network/applicationGateways@2022-01-01' = {
  name: 'AGW-${appGatewayName}'
	location: location
	properties: {
		enableHttp2: isHttp2
		firewallPolicy: wafSettings
		sslPolicy: {
			minProtocolVersion: 'TLSv${tls}'
		}
		sku: {
			name: 'WAF_v2'
			tier: 'WAF_v2'
			capacity: 3
		}
		gatewayIPConfigurations: [{
			name: 'appGatewayIpConfig'
			properties: {
				subnet: subnet
			}
		}]
		frontendIPConfigurations: [{
			name: 'appGwPrivateFrontendIp'
			properties: {
				privateIPAllocationMethod: 'Dynamic'
				subnet: subnet
			}
		}]
		frontendPorts: [{
			name: 'port_80'
			properties: {
				port: 80
			}
		}]
		backendAddressPools: [{
			name: 'BEP-default'
			properties: {}
		}]
		backendHttpSettingsCollection: [{
			name: 'BE-default-80'
			properties: {
				port: 80
				protocol: 'Http'
				cookieBasedAffinity: 'Disabled'
				requestTimeout: 120
			}
		}]
		httpListeners: [{
			name: 'default-http'
			properties: {
				frontendIPConfiguration: { id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGatewayName, 'appGwPrivateFrontendIp') }
				frontendPort: { id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGatewayName, 'port_80') }
				protocol: 'Http'
			}
		}]
		requestRoutingRules: [{
			name: 'RR-default-http'
		}]
	}
}

resource wafSettings 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2022-01-01' = {
	name: '${appGatewayName}-WAF'
	location: location	
	properties: {
		managedRules: {
			managedRuleSets: [{
				ruleSetType: 'OWASP'
				ruleSetVersion: '3.0'
			}]
		}
		policySettings: {
			mode: 'Detection'
			state: 'Enabled'
			requestBodyCheck: true
			fileUploadLimitInMb: 100
			maxRequestBodySizeInKb: 128
		}
	}
}
