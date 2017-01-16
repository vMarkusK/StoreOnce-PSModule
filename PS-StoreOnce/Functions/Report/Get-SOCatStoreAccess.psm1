#region: Get-SOCatStoreAccess	
<# 
    .Synopsis
    Lists Clients with Access Permissions of a Catalyst Store..

    .Description
    Lists Clients with Access Permissions of a Catalyst Store..
    Outputs: Client,allowAccess
	
    .Parameter Server
    IP Address oder DNS Name of your StoreOnce system like defined via Connect-SOAppliance (check Get-SOConnections).
  
    .Parameter CatStore
    Name of your StoreOnce Store.

    .Example
    Get-SOCatStoreAccess -Server 192.168.2.1 -CatStore YourStore

#Requires PS -Version 4.0
#>
function Get-SOCatStoreAccess {
	[CmdletBinding()]
	param (
		[parameter(Mandatory=$true, Position=0)]
			$Server,
		[parameter(Mandatory=$true, Position=1)]
			[String]$CatStore
	)
	Process {
		if (!$Global:SOConnections) {throw "No StoreOnce Appliance(s) connected! Use 'Connect-SOAppliance'"}
        if ($Server.count -gt 1) {throw "This Command only Supports one D2D System."}
        $Connection = $Global:SOConnections | Where {$_.Server -eq $Server}
		if (!$Connection) {throw "No D2D System found, check Get-SOConnections."}
        if ($Connection.count -gt 1) {throw "This Command only Supports one D2D System. Multiple Matches for $Server found..."}
		$SOCatStoreAccess =  @() 
		
        if (Test-IP -IP $($SOConnections.Server)) {
            $myCatStore = Get-SOCatStores | Where {$_.Name -eq $CatStore -and $_.System -eq $($SOConnections.Server)}
            if ($myCatStore -eq $null) {Write-Error "No Store named $CatStore found."; Return}
            $mySSID = ($myCatStore).SSID
            $myID = ($myCatStore).ID
            
            $StoreAcc = @{uri = "https://$($SOConnections.Server)/storeonceservices/cluster/servicesets/$mySSID/services/cat/stores/$myID/permissions";
                        Method = 'GET';
                        Headers = @{Authorization = 'Basic ' + $($SOConnections.EncodedPassword);
                                    Accept = 'text/xml'
                        } 
                    } 
                    
            $StoreAccResponse = Invoke-RestMethod @StoreAcc	
            [Array] $Name = $StoreAccResponse.document.permittedClients.permittedClient.properties.name
            [Array] $allowAccess = $StoreAccResponse.document.permittedClients.permittedClient.properties.allowAccess
            $ClientCount = ($Name).count
                    
            for ($i = 0; $i -lt $ClientCount; $i++ ){				
                $row = [PSCustomObject] @{
                    Client = $Name[$i]
                    allowAccess = $allowAccess[$i]
                }
                $SOCatStoreAccess += $row
            }
        }
	
	Return $SOCatStoreAccess | Where {$_.allowAccess -eq "true"}
	}
}
#endregion
