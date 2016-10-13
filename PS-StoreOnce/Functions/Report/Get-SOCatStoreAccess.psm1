#region: Get-SOCatStoreAccess	
<# 
    .Synopsis
    Lists Clients with Access Permissions of a Catalyst Store..

    .Description
    Lists Clients with Access Permissions of a Catalyst Store..
    Outputs: Client,allowAccess
	
    .Parameter D2DIP
    IP Address of your StoreOnce system.
  
    .Parameter CatStore
    Name of your StoreOnce Store.

    .Example
    Get-SOCatStoreAccess -D2DIP 192.168.2.1 -CatStore YourStore

#Requires PS -Version 4.0
#>
function Get-SOCatStoreAccess {
	[CmdletBinding()]
	param (
		[parameter(Mandatory=$true, Position=0)]
			$D2DIP,
		[parameter(Mandatory=$true, Position=1)]
			[String]$CatStore
	)
	Process {
		if ($SOCred -eq $null) {Write-Error "No System Credential Set! Use 'Set-SOCredentials'." -Category ConnectionError; Return}
		if ($D2DIP.count -gt 1) {Write-Error "This Command only Supports one IP (D2D System)." -Category InvalidArgument; Return}
		$SOCatStoreAccess =  @()
		
        if (Test-IP -IP $D2DIP) {
            $myCatStore = Get-SOCatStores -D2DIPs $D2DIP | Where {$_.Name -eq $CatStore}
            if ($myCatStore -eq $null) {Write-Error "No Store named $CatStore found."; Return}
            $mySSID = ($myCatStore).SSID
            $myID = ($myCatStore).ID
            
            $StoreAcc = @{uri = "https://$D2DIP/storeonceservices/cluster/servicesets/$mySSID/services/cat/stores/$myID/permissions";
                        Method = 'GET';
                        Headers = @{Authorization = 'Basic ' + $SOCred;
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
