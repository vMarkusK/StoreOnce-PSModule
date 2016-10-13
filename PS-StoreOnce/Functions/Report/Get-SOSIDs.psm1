#region: Get-SOSIDs
<# 
	.Synopsis
	Lists all ServiceSets from your StoreOnce system(s).

	.Description
	Lists all ServiceSets from your StoreOnce system(s).
	Outputs: ArrayIP,SSID,Name,Alias,OverallHealth,SerialNumber,Capacity(GB).Free(GB),UserData(GB),DiskData(GB)
	
	.Parameter D2DIPs
	IP Address of your StoreOnce system(s).

	.Example
	Get-SOSIDs -D2DIPs 192.168.2.1, 192.168.2.2

#Requires PS -Version 4.0
#>
function Get-SOSIDs {
	[CmdletBinding()]
	param (
		[parameter(Mandatory=$true, Position=0)]
			$D2DIPs
	)
	Process {
		if ($SOCred -eq $null) {Write-Error "No Credential Set! Use 'set-SOCredentials'" -Category ConnectionError; Return}
		$SOSIDs =  @()
		
		ForEach ($D2DIP in $D2DIPs) {
			if (Test-IP -IP $D2DIP) {
				$SIDCall = @{uri = "https://$D2DIP/storeonceservices/cluster/servicesets/";
							Method = 'GET';
							Headers = @{Authorization = 'Basic ' + $SOCred;
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
				[Array] $CapacityBytes = $SIDsResponse.document.servicesets.serviceset.properties.capacityBytes
				[Array] $FreeBytes = $SIDsResponse.document.servicesets.serviceset.properties.freeBytes
				[Array] $UserBytes = $SIDsResponse.document.servicesets.serviceset.properties.userBytes
				[Array] $DiskBytes = $SIDsResponse.document.servicesets.serviceset.properties.diskBytes
				
				for ($i = 0; $i -lt $SIDCount; $i++ ){		
					$row = [PSCustomObject] @{
						ArrayIP = $D2DIP
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
