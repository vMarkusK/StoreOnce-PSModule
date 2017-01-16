#region: Get-SOCatStores
<# 
    .Synopsis
    Lists all Catalyst Stores from your StoreOnce system(s).

    .Description
    Lists all Catalyst Stores from your StoreOnce system(s).

    .Example
    Get-SOCatStores

#Requires PS -Version 4.0
#>
function Get-SOCatStores {
	[CmdletBinding()]
	param (

	)
	Process {
		if (!$Global:SOConnections) {throw "No StoreOnce Appliance(s) connected! Use 'Connect-SOAppliance'"}
		$SOCatStores =  @()
		
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
                
                for ($x = 1; $x -le $SIDCount; $x++ ){
                    $StoreInf = @{uri = "https://$($SOConnection.Server)/storeonceservices/cluster/servicesets/$x/services/cat/stores/";
                                Method = 'GET';
                                Headers = @{Authorization = 'Basic ' + $($SOConnection.EncodedPassword);
                                            Accept = 'text/xml'
                                } 
                            } 
                    
                    $StoreInfResponse = Invoke-RestMethod @StoreInf
                    [Array] $SSID = $StoreInfResponse.document.stores.store.properties.ssid
                    [Array] $Name = $StoreInfResponse.document.stores.store.properties.name
                    [Array] $ID = $StoreInfResponse.document.stores.store.properties.id
                    [Array] $Status = $StoreInfResponse.document.stores.store.properties.status
                    [Array] $Health = $StoreInfResponse.document.stores.store.properties.health
                    [Array] $UserDataStored = $StoreInfResponse.document.stores.store.properties.userdatastored
                    [Array] $SizeOnDisk = $StoreInfResponse.document.stores.store.properties.sizeondisk
                    [Array] $DDRate = $StoreInfResponse.document.stores.store.properties.deduperatio
                    $StoresCount = ($Name).count
                
                    $DDRate = $DDRate | ForEach {$i=1} {if ($i++ %2){$_}}
                
                    for ($i = 0; $i -lt $StoresCount; $i++ ){	
                        $row = [PSCustomObject] @{
                            System = $($SOConnection.Server)
						    SIDCount = [String] $SIDCount
                            SSID = $SSID[$i]
                            Name = $Name[$i]
                            ID = $ID[$i]
                            Status = $Status[$i]
                            Health = $Health[$i]
                            "SizeOnDisk(GB)" = ([math]::Round(($SizeOnDisk[$i]),2))
                            "UserDataStored(GB)" = ([math]::Round(($UserDataStored[$i]),2))
                            DedupeRatio = $DDRate[$i]
                        }
                        $SOCatStores += $row
                    }
                }
            }
        } 
		
	Return $SOCatStores
	}
}
#endregion
