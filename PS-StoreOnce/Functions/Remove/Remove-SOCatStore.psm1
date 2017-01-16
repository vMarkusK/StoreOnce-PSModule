#region: Remove-SOCatStore
<# 
    .Synopsis
    Remove a single StoreOnce Catalyst store on your StoreOnce system.

    .Description
    Remove a single StoreOnce Catalyst store on a given Service Set on your StoreOnce system.
	
    .Parameter Server
    IP Address oder DNS Name of your StoreOnce system like defined via Connect-SOAppliance (check Get-SOConnections).

    .Parameter SSID
    Target Service Set for the Store on your StoreOnce system.

    .Parameter SOCatStoreName
    Name for the Store on your StoreOnce system.

    .Parameter Timeout
    Timeout for the Store deletion process (Default is 30 Seconds).

    .Example
    Remove-SOCatStore -Server 192.168.2.1 -SSID 1 -SOCatStoreName MyRemovedStore

#Requires PS -Version 4.0
#>
function Remove-SOCatStore {
	[CmdletBinding()]
	param (
		[parameter(Mandatory=$true, Position=0)]
			[String]$Server,
		[parameter(Mandatory=$true, Position=1)]
			[String]$SSID,
		[parameter(Mandatory=$true, Position=2)]
			[String]$SOCatStoreName,
		[parameter(Mandatory=$false, Position=4)]
			[Int]$Timeout = 30
			
	)
	Process {
		if (!$Global:SOConnections) {throw "No StoreOnce Appliance(s) connected! Use 'Connect-SOAppliance'"}
        if ($Server.count -gt 1) {throw "This Command only Supports one D2D System."}
        $Connection = $Global:SOConnections | Where {$_.Server -eq $Server}
		if (!$Connection) {throw "No D2D System found, check Get-SOConnections."}
        if ($Connection.count -gt 1) {throw "This Command only Supports one D2D System. Multiple Matches for $Server found..."}

        if (Test-IP -IP $($Connection.Server)) {
            if (!(Get-SOCatStores | where {$_.Name -eq $SOCatStoreName -and $_.System -eq $($Connection.Server)})) {throw "Store $SOCatStoreName does not exist."}
            $StoreCall = @{uri = "https://$($Connection.Server)/storeonceservices/cluster/servicesets/$SSID/services/cat/stores/$((Get-SOCatStores | where {$_.Name -eq $SOCatStoreName -and $_.System -eq $($Connection.Server)}).ID)";
                            Method = 'DELETE';
                            Headers = @{Authorization = 'Basic ' + $($Connection.EncodedPassword);
                                        Accept = 'text/xml';
                            } 
                        } 
            
            $StoreResponse = Invoke-RestMethod @StoreCall
            
            $i = 0
            while(!(Get-SOCatStores | where {$_.Name -eq $SOCatStoreName -and $_.System -eq $($SOConnections.Server) -and $_.Status -ne "Online"})){
                $i++
                Start-Sleep 1
            if($i -gt $Timeout) { Write-Error "Removing Store Failed."; break}
                Write-Progress -Activity "Deleting Store" -Status "Wait for Store be removed..."
            }
        }

		Return (Get-SOCatStores | where {$_.Name -eq $SOCatStoreName -and $_.System -eq $($SOConnections.Server)} | ft * -AutoSize)
	}
}
#endregion
