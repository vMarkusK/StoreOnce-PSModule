#region: Get-SOCatStores
<# 
    .Synopsis
    Lists all Catalyst Stores from your StoreOnce system(s).

    .Description
    Lists all Catalyst Stores from your StoreOnce system(s).
    Outputs: ArrayIP,SSID,Name,ID,SizeOnDisk(GB),UserDataStored(GB),DedupeRatio
	
    .Parameter D2DIPs
    IP Address of your StoreOnce system(s).

    .Example
    Get-SOCatStores -D2DIPs 192.168.2.1, 192.168.2.2

#Requires PS -Version 4.0
#>
function Get-SOCatStores {
	[CmdletBinding()]
	param (
		[parameter(Mandatory=$true, Position=0)]
			$D2DIPs
	)
	Process {
		if ($SOCred -eq $null) {Write-Error "No System Credential Set! Use 'Set-SOCredentials'." -Category ConnectionError; Return}
		$SOCatStores =  @()
		
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
                
                for ($x = 1; $x -le $SIDCount; $x++ ){
                    $StoreInf = @{uri = "https://$D2DIP/storeonceservices/cluster/servicesets/$x/services/cat/stores/";
                                Method = 'GET';
                                Headers = @{Authorization = 'Basic ' + $SOCred;
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
                            ArrayIP = $D2DIP
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
