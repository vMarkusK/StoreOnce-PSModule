#region: Get-SONasShares
<# 
    .Synopsis
    Lists all NAS Stores from your StoreOnce system(s).

    .Description
    Lists all NAS Stores from your StoreOnce system(s).
    Outputs: ArrayIP,SSID,Name,ID,AccessProtocol,SizeOnDisk(GB),UserDataStored(GB),DedupeRatio
	
    .Parameter D2DIPs
    IP Address of your StoreOnce system(s).

    .Example
    Get-SONasShares -D2DIPs 192.168.2.1, 192.168.2.2

#Requires PS -Version 4.0
#>
function Get-SONasShares {
	[CmdletBinding()]
	param (
		[parameter(Mandatory=$true, Position=0)]
			$D2DIPs
	)
	Process {
		if ($SOCred -eq $null) {Write-Error "No System Credential Set! Use 'Set-SOCredentials'." -Category ConnectionError; Return}
		$SONasShares =  @()
		
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
                    $ShareInf = @{uri = "https://$D2DIP/storeonceservices/cluster/servicesets/$x/services/nas/shares/";
                                Method = 'GET';
                                Headers = @{Authorization = 'Basic ' + $SOCred;
                                            Accept = 'text/xml'
                                } 
                            } 
                    
                    $ShareInfResponse = Invoke-RestMethod @ShareInf
                    [Array] $Name = $ShareInfResponse.document.shares.share.properties.name
                    [Array] $ID = $ShareInfResponse.document.shares.share.properties.id
                    [Array] $AccessProtocol = $ShareInfResponse.document.shares.share.properties.accessProtocol
                    [Array] $SSID = $ShareInfResponse.document.shares.share.properties.ssid
                    [Array] $UserDataStored = $ShareInfResponse.document.shares.share.properties.userdatastored
                    [Array] $SizeOnDisk = $ShareInfResponse.document.shares.share.properties.sizeondisk
                    [Array] $DDRate = $ShareInfResponse.document.shares.share.properties.deduperatio
                    $ShareCount = ($Name).count
                
                    for ($i = 0; $i -lt $ShareCount; $i++ ){		
                        $row = [PSCustomObject] @{
                            ArrayIP = $D2DIP
                            SSID = $SSID[$i]
                            Name = $Name[$i]
                            ID = $ID[$i]
                            AccessProtocol = $AccessProtocol[$i]
                            "SizeOnDisk(GB)" = ([math]::Round(($SizeOnDisk[$i]),2))
                            "UserDataStored(GB)" = ([math]::Round(($UserDataStored[$i]),2))
                            DedupeRatio = $DDRate[$i]
                        }
                        $SONasShares += $row
                    }
                }
            }
        } 
			
	Return $SONasShares
	}
}
#endregion
