#region: Get-SOCatClients
<# 
	.Synopsis
	Lists all Catalyst Clients from your StoreOnce system(s).

	.Description
	Lists all Catalyst Clients from your StoreOnce system(s).
	Outputs: ArrayIP,SSID,Name,ID,Description,canCreateStores,canSetServerProperties,canManageClientPermissions

	.Example
	Get-SOCatClients

#Requires PS -Version 4.0
#>
function Get-SOCatClients {
	[CmdletBinding()]
	param (

	)
	Process {
		if (!$Global:SOConnections) {throw "No StoreOnce Appliance(s) connected! Use 'Connect-SOAppliance'"}
		$SOCatClients =  @()
		
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
                    $ClientReq = @{uri = "https://$($SOConnection.Server)/storeonceservices/cluster/servicesets/$x/services/cat/configs/clients/";
                                Method = 'GET';
                                Headers = @{Authorization = 'Basic ' + $($SOConnection.EncodedPassword);
                                            Accept = 'text/xml'
                                } 
                            } 
                    $ClientResponse = Invoke-RestMethod @ClientReq
                
                    [Array] $Name = $ClientResponse.document.clients.client.properties.name
                    [Array] $ID = $ClientResponse.document.clients.client.properties.id
                    [Array] $Description = $ClientResponse.document.clients.client.properties.description
                    [Array] $canCreateStores = $ClientResponse.document.clients.client.properties.canCreateStores
                    [Array] $canSetServerProperties = $ClientResponse.document.clients.client.properties.canSetServerProperties
                    [Array] $canManageClientPermissions = $ClientResponse.document.clients.client.properties.canManageClientPermissions
                    $ClientCount = ($Name).count
                            
                    for ($i = 0; $i -lt $ClientCount; $i++ ){
                                
                        $row = [PSCustomObject] @{
                            System = $($SOConnection.Server)
						    SIDCount = [String] $SIDCount
                            SSID = $x
                            Name = $Name[$i]
                            ID = $ID[$i]
                            Description = $Description[$i]
                            canCreateStores = $canCreateStores[$i]
                            canSetServerProperties = $canSetServerProperties[$i]
                            canManageClientPermissions = $canManageClientPermissions[$i]
                        }
                        $SOCatClients += $row
                
                    }
                }
            
            }
        } 
			
	Return $SOCatClients
	}
}
#endregion
