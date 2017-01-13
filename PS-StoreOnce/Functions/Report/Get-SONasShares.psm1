#region: Get-SONasShares
<# 
    .Synopsis
    Lists all NAS Stores from your StoreOnce system(s).

    .Description
    Lists all NAS Stores from your StoreOnce system(s).
    Outputs: ArrayIP,SSID,Name,ID,AccessProtocol,SizeOnDisk(GB),UserDataStored(GB),DedupeRatio

    .Example
    Get-SONasShares

#Requires PS -Version 4.0
#>
function Get-SONasShares {
	[CmdletBinding()]
	param (
	
	)
	Process {
		if (!$Global:SOConnections) {throw "No StoreOnce Appliance(s) connected! Use 'Connect-SOAppliance'"}
		$SONasShares =  @()
		
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
                    $ShareInf = @{uri = "https://$($SOConnection.Server)/storeonceservices/cluster/servicesets/$x/services/nas/shares/";
                                Method = 'GET';
                                Headers = @{Authorization = 'Basic ' + $($SOConnection.EncodedPassword);
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
                            System = $($SOConnection.Server)
						    SIDCount = [String] $SIDCount
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
