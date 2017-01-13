<# 
	.Synopsis
	Lists all connected StoreOnce Appliannce(s).

	.Description
	Lists all connected StoreOnce Appliannce(s).
	
	.Example
	Get-SOSIDs

#Requires PS -Version 4.0
#>
function Get-SOAppliance {
	[CmdletBinding()]
	param (

	)
	Process {
		if (!$Global:SOConnections) {throw "No StoreOnce Appliance(s) connected! Use 'Connect-SOAppliance'"}
		
		
	Return $Global:SOConnections
	}
} 