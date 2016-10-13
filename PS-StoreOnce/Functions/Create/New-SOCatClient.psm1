#region: New-SOCatClient
<# 
    .Synopsis
    Create a StoreOnce Catalyst Client on your StoreOnce system.

    .Description
    Create a StoreOnce Catalyst Client on all Service Sets on your StoreOnce system.
	
    .Parameter D2DIP
    IP Address of your StoreOnce system.

    .Parameter SOCatClientName
    Name for the new Client on your StoreOnce system.

    .Parameter SOCatClientDesc
    Description for the new Client on your StoreOnce system.

    .Parameter SOCatClientPass
    Password for the new Client on your StoreOnce system.

    .Parameter Timeout
    Timeout for the Client creation process (Default is 30 Seconds).

    .Example
    New-SOCatClient -D2DIP 192.168.2.1 -SOCatClientName MyNewClient

#Requires PS -Version 4.0
#>
function New-SOCatClient {
	[CmdletBinding()]
	param (
		[parameter(Mandatory=$true, Position=0)]
			[String]$D2DIP,
		[parameter(Mandatory=$true, Position=1)]
			[String]$SOCatClientName,
		[parameter(Mandatory=$false, Position=2)]
			[String]$SOCatClientDesc = $SOCatClientName,
		[parameter(Mandatory=$true, Position=3)]
			[SecureString]$SOCatClientPass,
		[parameter(Mandatory=$false, Position=4)]
			[Int]$Timeout = 30
			
	)
	Process {
		if ($SOCred -eq $null) {Write-Error "No System Credential Set! Use 'Set-SOCredentials'." -Category ConnectionError; Return}
	
        if (Test-IP -IP $D2DIP) {
            if (Get-SOCatClients -D2DIPs $D2DIP | where {$_.Name -eq $SOCatClientName}) {Write-Error "Client $SOCatClientName already Exists."; Return}
            [String]$SOCatClientPassClear =  [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($SOCatClientPass))
            [Array]$IDs = (Get-SOSIDs -D2DIP $D2DIP).SSID

            for ($i = 1; $i -le $IDs.Count; $i++ ){
                $ClientCall = @{uri = "https://$D2DIP/storeonceservices/cluster/servicesets/$i/services/cat/configs/clients/";
                                Method = 'POST';
                                Headers = @{Authorization = 'Basic ' + $SOCred;
                                            Accept = 'text/xml';
                                            'Content-Type' = 'application/x-www-form-urlencoded'
                                }
                                Body = @{name = $SOCatClientName;
                                        description = $SOCatClientDesc;
                                        password = $SOCatClientPassClear;
                                        canCreateStores = 'false';
                                        canSetServerProperties = 'false';
                                        canManageClientPermissions = 'false'
                                } 
                            }

                $ClientResponse = Invoke-RestMethod @ClientCall
            }
            
            $i = 0
            while(!(Get-SOCatClients -D2DIPs $D2DIP | where {$_.Name -eq $SOCatClientName})){
                $i++
                Start-Sleep 1
            if($i -gt $Timeout) { Write-Error "Creating Client Failed."; break}
                Write-Progress -Activity "Creating Client" -Status "Wait for Client..."
            }
        }
		Return (Get-SOCatClients -D2DIPs $D2DIP | where {$_.Name -eq $SOCatClientName} | ft * -AutoSize)
		
	}
}
#endregion
