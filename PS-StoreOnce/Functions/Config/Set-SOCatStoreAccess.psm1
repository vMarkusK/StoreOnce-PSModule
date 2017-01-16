#region: Set-SOCatStoreAccess
<# 
	.Synopsis
	Permits or denys Client access to a StoreOnce Catalyst Store.

	.Description
	Permits or denys Client access to a StoreOnce Catalyst Store.
	
	.Parameter Server
    IP Address oder DNS Name of your StoreOnce system like defined via Connect-SOAppliance (check Get-SOConnections).

	.Parameter SOCatClientName
	Name for the Client on your StoreOnce system.

	.Parameter SOCatStoreName
	Name for the Store on your StoreOnce system.

	.Parameter allowAccess
	True ore False

	.Example
	Set-SOCatStoreAccess -Server 192.168.2.1 -SOCatClientName MyNewClient -SOCatStoreName MyNewStore -allowAccess:$true

#Requires PS -Version 4.0
#>
function Set-SOCatStoreAccess {
	[CmdletBinding()]
	param (
		[parameter(Mandatory=$true, Position=0)]
			[String]$Server,
		[parameter(Mandatory=$true, Position=1)]
			[String]$SOCatClientName,
		[parameter(Mandatory=$true, Position=2)]
			[String]$SOCatStoreName,
		[parameter(Mandatory=$true, Position=3)]
			[Boolean]$allowAccess
			
	)
	Process {
		if (!$Global:SOConnections) {throw "No StoreOnce Appliance(s) connected! Use 'Connect-SOAppliance'"}
        if ($Server.count -gt 1) {throw "This Command only Supports one D2D System."}
        $Connection = $Global:SOConnections | Where {$_.Server -eq $Server}
		if (!$Connection) {throw "No D2D System found, check Get-SOConnections."}
        if ($Connection.count -gt 1) {throw "This Command only Supports one D2D System. Multiple Matches for $Server found..."}

        if (Test-IP -IP $($Connection.Server)) {
            if (!($SOCaStore = (Get-SOCatStores -D2DIPs $D2DIP | where {$_.Name -eq $SOCatStoreName}))) {Write-Error "Store $SOCatStoreName does not exists."; Return}
            if (!($SOCatClient = (Get-SOCatClients -D2DIPs $D2DIP | where {$_.Name -eq $SOCatClientName -and $_.SSID -eq $($SOCaStore).SSID}))) {Write-Error "Client $SOCatClientName does not exists."; Return}
            
            $SSID = $($SOCaStore).SSID
            $StoreID = $($SOCaStore).ID
            $ClientID = $($SOCatClient).ID
            if ($allowAccess -eq $true) {$Access = "true"} else {$Access = "false"}
            $AccessCall = @{uri = "https://$D2DIP/storeonceservices/cluster/servicesets/$SSID/services/cat/stores/$StoreID/permissions/$ClientID";
                            Method = 'PUT';
                            Headers = @{Authorization = 'Basic ' + $SOCred;
                                        Accept = 'text/xml';
                                        'Content-Type' = 'application/x-www-form-urlencoded'
                            }
                            Body = @{allowAccess = $Access						
                            } 
                        }

            $AccessResponse = Invoke-RestMethod @AccessCall
        }
		Return (Get-SOCatStoreAccess -D2DIP $D2DIP -CatStore $SOCaStore.Name | ft * -AutoSize)
		
	}
}
#endregion
