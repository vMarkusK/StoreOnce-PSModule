#region: Set-SOCatStoreAccess
<# 
	.Synopsis
	Permits or denys Client access to a StoreOnce Catalyst Store.

	.Description
	Permits or denys Client access to a StoreOnce Catalyst Store.
	
	.Parameter D2DIP
	IP Address of your StoreOnce system.

	.Parameter SOCatClientName
	Name for the Client on your StoreOnce system.

	.Parameter SOCatStoreName
	Name for the Store on your StoreOnce system.

	.Parameter allowAccess
	True ore False

	.Example
	Set-SOCatStoreAccess -D2DIP 192.168.2.1 -SOCatClientName MyNewClient -SOCatStoreName MyNewStore -allowAccess:$true

#Requires PS -Version 4.0
#>
function Set-SOCatStoreAccess {
	[CmdletBinding()]
	param (
		[parameter(Mandatory=$true, Position=0)]
			[String]$D2DIP,
		[parameter(Mandatory=$true, Position=1)]
			[String]$SOCatClientName,
		[parameter(Mandatory=$true, Position=2)]
			[String]$SOCatStoreName,
		[parameter(Mandatory=$true, Position=3)]
			[Boolean]$allowAccess
			
	)
	Process {
		if ($SOCred -eq $null) {Write-Error "No System Credential Set! Use 'Set-SOCredentials'." -Category ConnectionError; Return}

        if (Test-IP -IP $D2DIP) {
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
