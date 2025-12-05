[CmdletBinding()]
param (
	# Specifies a path to one or more locations. Wildcards are permitted.
	[Parameter(Mandatory=$true,
		ValueFromPipeline=$true,
		HelpMessage="Path to one or more locations.")]
	[ValidateNotNullOrEmpty()]
	[string]$SearchPath,
	[Parameter(Mandatory=$true, HelpMessage="Microsoft365 file types (ex. docx, pptx)")]
	[string[]]$FileTypes = @("pptx","docx","xlsx"),
	[Parameter(Mandatory=$true, HelpMessage="The number of days of logs history")]
	[ValidateRange(1, 365)]
	[Int32]$LogDuration = 7
)

# Hardware Providers
# 'Microsoft-Windows-Kernel-PnP', 'Microsoft-Windows-Kernel-WHEA', 'Microsoft-Windows-DriverFrameworks-UserMode', 'Microsoft-Windows-DriverFrameworks-KernelMode'

# OS Providers
# 'Microsoft-Windows-Kernel-General', 'Microsoft-Windows-Kernel-Power', 'Microsoft-Windows-Kernel-Boot',

# EventTypes
# 0	Administrative
# 1	Operational
# 2	Analytical
# 3	Debug

# LogLevel
# 0	LogAlways
# 1	Critical
# 2	Error
# 3	Warning
# 4	Informational
# 5	Verbose

# LogName
# Application
# Security
# System
# Setup
# Forwarded Events

$endTime = (Get-Date)
$startTime = ($endTime).AddDays(-$LogDuration)

$providers = @{
	Hardware = @('Microsoft-Windows-Kernel-PnP', 'Microsoft-Windows-Kernel-WHEA', 'Microsoft-Windows-DriverFrameworks-UserMode', 'Microsoft-Windows-DriverFrameworks-KernelMode')
}

$filterMap = @{
	LogName = 'System'
	LogLevel = (1..3)
	# Id = (1..20)
	ProviderName = $providers['Hardware']
	StartTime = $startTime
	EndTime = $endTime
}

function Get-DiskHealth {
	Get-WmiObject -Namespace 'root\wmi' -Class MSStorageDriver_FailurePredictStatus
	| Select-Object InstanceName, PredictFailure, Reason
}

function Get-MemoryHealth {
	Get-WmiObject -Class Win32_PhysicalMemory
	| Select-Object Manufacturer, Capacity, Speed, Status
}

function Get-CPUHealth {
	Get-WmiObject -Class Win32_Processor
	| Select-Object Name, Manufacturer, MaxClockSpeed, Status
}

