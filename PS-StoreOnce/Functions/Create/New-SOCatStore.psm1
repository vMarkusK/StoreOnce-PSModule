#region: New-SOCatStore
<# 
    .Synopsis
    Create a single StoreOnce Catalyst store on your StoreOnce system.

    .Description
    Create a single StoreOnce Catalyst store on a given Service Set on your StoreOnce system.
	
    .Parameter Server
    IP Address oder DNS Name of your StoreOnce system like defined via Connect-SOAppliance (check Get-SOConnections).

    .Parameter SSID
    Target Service Set for the new Store on your StoreOnce system.

    .Parameter SOCatStoreName
    Name for the new Store on your StoreOnce system.

    .Parameter SOCatStoreDesc
    Description for the new Store on your StoreOnce system.

    .Parameter Timeout
    Timeout for the Store creation process (Default is 30 Seconds).

    .Example
    New-SOCatStore -Server 192.168.2.1 -SSID 1 -SOCatStoreName MyNewStore

#Requires PS -Version 4.0
#>
function New-SOCatStore {
	[CmdletBinding()]
	param (
		[parameter(Mandatory=$true, Position=0)]
			[String]$Server,
		[parameter(Mandatory=$true, Position=1)]
			[String]$SSID,
		[parameter(Mandatory=$true, Position=2)]
			[String]$SOCatStoreName,
		[parameter(Mandatory=$false, Position=3)]
			[String]$SOCatStoreDesc = $SOCatStoreName,
		[parameter(Mandatory=$false, Position=4)]
			[Int]$Timeout = 30
			
	)
	Process {
		if (!$Global:SOConnections) {throw "No StoreOnce Appliance(s) connected! Use 'Connect-SOAppliance'"}
        if ($Server.count -gt 1) {throw "This Command only Supports one D2D System."}
        $Connection = $Global:SOConnections | Where {$_.Server -eq $Server}
		if (!$Connection) {throw "No D2D System found, check Get-SOConnections."}
        if ($Connection.count -gt 1) {throw "This Command only Supports one D2D System."}

        if (Test-IP -IP $($SOConnections.Server)) {
            if (Get-SOCatStores | where {$_.Name -eq $SOCatStoreName -and $_.System -eq $($SOConnections.Server)}) {throw "Store $SOCatStoreName already Exists."}
            $StoreCall = @{uri = "https://$($SOConnections.Server)/storeonceservices/cluster/servicesets/$SSID/services/cat/stores/";
                            Method = 'POST';
                            Headers = @{Authorization = 'Basic ' + $($SOConnections.EncodedPassword);
                                        Accept = 'text/xml';
                                        'Content-Type' = 'application/x-www-form-urlencoded'
                            }
                            Body = @{name = $SOCatStoreName;
                                    description = $SOCatStoreDesc;
                                    primaryTransferPolicy = '0';
                                    secondaryTransferPolicy = '1';
                                    userDataSizeLimitBytes = '0';
                                    dedupedDataSizeOnDiskLimitBytes = '0';
                                    dataJobRetentionDays = '90';
                                    inboundCopyJobRetentionDays = '90';
                                    outboundCopyJobRetentionDays = '90';
                                    encryption = 'false'
                            } 
                        } 
            
            $StoreResponse = Invoke-RestMethod @StoreCall
            
            $i = 0
            while(!(Get-SOCatStores | where {$_.Name -eq $SOCatStoreName -and $_.System -eq $($SOConnections.Server) -and $_.Status -eq "Online"})){
                $i++
                Start-Sleep 1
            if($i -gt $Timeout) { Write-Error "Creating Store Failed."; break}
                Write-Progress -Activity "Creating Store" -Status "Wait for Store become Online..."
            }
        }

		Return (Get-SOCatStores | where {$_.Name -eq $SOCatStoreName -and $_.System -eq $($SOConnections.Server)} | ft * -AutoSize)
	}
}
#endregion
