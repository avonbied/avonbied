[CmdletBinding()]
param (
	[Parameter(Mandatory = $true)]
	[ValidatePattern('\w{1,}\.\w{1,}\.?[\w.]*')]
	[String]$FQDN,
	[ValidatePattern('[\w\.\s,]{1,}')]
	[String]$Aliases,
	[ValidateSet(1024, 2048, 4096)]
	[int]$KeyLength = 2048,
	[switch]$Exportable,
	[ValidateSet('Microsoft RSA SChannel Cryptographic Provider', 'Microsoft Enhanced DSS and Diffie-Hellman Cryptographic Provider')]
	[string]$Encryption = 'Microsoft RSA SChannel Cryptographic Provider',
	[Parameter(Mandatory = $true)]
	[String]$Destination
)

if (-not (Test-Path -Path $Destination)) {
	Write-Error "Path: '$Destination' does not exist."
	return 1
}

$aliasList = $Aliases -split ','
foreach ($alias in $aliasList) {
	$dnsAliases += "_continue_ = ""DNS='$alias&""`n"
}

$exportString = $Exportable.IsPresent.ToString()

$certificateINF = @"
[Version]
Signature = '`$Windows NT$'
[NewRequest]
Subject = "CN=${FQDN}, OU=Company Department, O=Company, L=Albany, S=AL, C=US"
KeySpec = 1
KeyLength = ${KeyLength}
Exportable = ${exportString}
MachineKeySet = TRUE
ProviderName = ${Encryption}
RequestType = PKCS10
KeyUsage = 0x0
[EnhancedKeyUsageExtension]
2.5.29.17 = "{text}"
_continue_ = "DNS=${FQDN}&"
${dnsAliases}
"@

$filename = "$Destination$($Destination.EndsWith('\') ? '' : '\')$FQDN.csr"
$certificateINF | Out-File ($tmpFile = [System.IO.Path]::GetTempFileName())
& certreq.exe -new $tmpFile $filename