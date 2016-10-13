#region: Get-SOCatClients
<# 
	.Synopsis
	Lists all Catalyst Clients from your StoreOnce system(s).

	.Description
	Lists all Catalyst Clients from your StoreOnce system(s).
	Outputs: ArrayIP,SSID,Name,ID,Description,canCreateStores,canSetServerProperties,canManageClientPermissions
	
	.Parameter D2DIPs
	IP Address of your StoreOnce system(s).

	.Example
	Get-SOCatClients -D2DIPs 192.168.2.1, 192.168.2.2

#Requires PS -Version 4.0
#>
function Get-SOCatClients {
	[CmdletBinding()]
	param (
		[parameter(Mandatory=$true, Position=0)]
			$D2DIPs
	)
	Process {
		if ($SOCred -eq $null) {Write-Error "No System Credential Set! Use 'Set-SOCredentials'."; Return}
		$SOCatClients =  @()
		
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
                    $ClientReq = @{uri = "https://$D2DIP/storeonceservices/cluster/servicesets/$x/services/cat/configs/clients/";
                                Method = 'GET';
                                Headers = @{Authorization = 'Basic ' + $SOCred;
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
                            ArrayIP = $D2DIP
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
