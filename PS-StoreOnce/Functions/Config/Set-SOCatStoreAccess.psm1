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
	$True ore $False

	.Example
	Set-SOCatStoreAccess -Server 192.168.2.1 -SOCatClientName MyNewClient -SOCatStoreName MyNewStore -allowAccess:$true

#Requires PS -Version 4.0
#>
function Set-SOCatStoreAccess {
	[CmdletBinding()]
	param (
		[parameter(Mandatory=$true, Position=0)]
		[ValidateNotNullOrEmpty()]
			[String]$Server,
		[parameter(Mandatory=$true, Position=1)]
		[ValidateNotNullOrEmpty()]
			[String]$SOCatClientName,
		[parameter(Mandatory=$true, Position=2)]
		[ValidateNotNullOrEmpty()]
			[String]$SOCatStoreName,
		[parameter(Mandatory=$true, Position=3)]
		[ValidateNotNullOrEmpty()]
			[Boolean]$allowAccess
			
	)
	Process {
		if (!$Global:SOConnections) {throw "No StoreOnce Appliance(s) connected! Use 'Connect-SOAppliance'"}
        if ($Server.count -gt 1) {throw "This Command only Supports one D2D System."}
        $Connection = $Global:SOConnections | Where {$_.Server -eq $Server}
		if (!$Connection) {throw "No D2D System found, check Get-SOConnections."}
        if ($Connection.count -gt 1) {throw "This Command only Supports one D2D System. Multiple Matches for $Server found..."}

        if (Test-IP -IP $($Connection.Server)) {
            if (!($SOCaStore = (Get-SOCatStores | where {$_.Name -eq $SOCatStoreName -and $_.System -eq $($Connection.Server)}))) {throw "Store $SOCatStoreName does not exists."}
            if (!($SOCatClient = (Get-SOCatClients | where {$_.Name -eq $SOCatClientName -and $_.System -eq $($Connection.Server) -and $_.SSID -eq $($SOCaStore).SSID}))) {throw "Client $SOCatClientName does not exists."}
            
            $SSID = $($SOCaStore).SSID
            $StoreID = $($SOCaStore).ID
            $ClientID = $($SOCatClient).ID
            if ($allowAccess -eq $true) {$Access = "true"} else {$Access = "false"}
            $AccessCall = @{uri = "https://$($Connection.Server)/storeonceservices/cluster/servicesets/$SSID/services/cat/stores/$StoreID/permissions/$ClientID";
                            Method = 'PUT';
                            Headers = @{Authorization = 'Basic ' + $($Connection.EncodedPassword);
                                        Accept = 'text/xml';
                                        'Content-Type' = 'application/x-www-form-urlencoded'
                            }
                            Body = @{allowAccess = $Access						
                            } 
                        }

            $AccessResponse = Invoke-RestMethod @AccessCall
        }
		Return (Get-SOCatStoreAccess -Server $($Connection.Server) -CatStore $SOCaStore.Name | ft * -AutoSize)
		
	}
}
#endregion
