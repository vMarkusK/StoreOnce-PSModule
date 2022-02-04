#region: Get-SOSIDs
<# 
	.Synopsis
	Lists all ServiceSets from your StoreOnce system(s).

	.Description
	Lists all ServiceSets from your StoreOnce system(s).
	
	.Example
	Get-SOSIDs

#Requires PS -Version 4.0
#>
function Get-SOSIDs {
	[CmdletBinding()]
	param (

	)
	Process {
		if (!$Global:SOConnections) {throw "No StoreOnce Appliance(s) connected! Use 'Connect-SOAppliance'"}
		$SOSIDs =  @()
		
		ForEach ($SOConnection in $($Global:SOConnections)) {
			if (Test-IP -IP $($SOConnection.Server)) {
				$SIDCall = @{uri = "https://$($SOConnection.Server)/storeonceservices/cluster/servicesets/";
							Method = 'GET';
							Headers = @{Authorization = 'Basic ' + $($SOConnection.EncodedPassword);
										Accept = 'text/xml'
							} 
						} 
					
				$SIDsResponse = Invoke-RestMethod @SIDCall
				$SIDCount = ($SIDsResponse.document.servicesets.serviceset).count
				if ($SIDCount -eq $null) {$SIDCount = 1}
				[Array] $SSID = $SIDsResponse.document.servicesets.serviceset.properties.ssid
				[Array] $Name = $SIDsResponse.document.servicesets.serviceset.properties.name
				[Array] $Alias = $SIDsResponse.document.servicesets.serviceset.properties.alias
				[Array] $OverallHealth = $SIDsResponse.document.servicesets.serviceset.properties.overallHealth
				[Array] $SerialNumber = $SIDsResponse.document.servicesets.serviceset.properties.serialNumber
				[Array] $CapacityBytes = $SIDsResponse.document.servicesets.serviceset.properties.localcapacityBytes
				[Array] $FreeBytes = $SIDsResponse.document.servicesets.serviceset.properties.localfreeBytes
				[Array] $UserBytes = $SIDsResponse.document.servicesets.serviceset.properties.localuserBytes
				[Array] $DiskBytes = $SIDsResponse.document.servicesets.serviceset.properties.localdiskBytes
				
				for ($i = 0; $i -lt $SIDCount; $i++ ){		
					$row = [PSCustomObject] @{
						System = $($SOConnection.Server)
						SIDCount = [String] $SIDCount
						SSID = $SSID[$i]
						Name = $Name[$i]
						Alias = $Alias[$i]
						OverallHealth = $OverallHealth[$i]
						SerialNumber = $SerialNumber[$i]
						"Capacity(GB)" = ([math]::Round(($CapacityBytes[$i] / 1073741824),2))
						"Free(GB)" = ([math]::Round(($FreeBytes[$i] / 1073741824),2))
						"UserData(GB)" = ([math]::Round(($UserBytes[$i] / 1073741824),2))
						"DiskData(GB)" = ([math]::Round(($DiskBytes[$i] / 1073741824),2))
					}
					$SOSIDs += $row
				} 
			}
		}

	Return $SOSIDs
	}
} 
#endregion
