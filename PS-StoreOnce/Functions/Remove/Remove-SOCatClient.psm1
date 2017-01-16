#region: Remove-SOCatClient
<# 
    .Synopsis
    Remove a single StoreOnce Catalyst store on your StoreOnce system.

    .Description
    Remove a single StoreOnce Catalyst store on a given Service Set on your StoreOnce system.
	
    .Parameter Server
    IP Address oder DNS Name of your StoreOnce system like defined via Connect-SOAppliance (check Get-SOConnections).

    .Parameter SOCatClientName
    Name for the Client on your StoreOnce system.

    .Parameter Timeout
    Timeout for the Client deletion process (Default is 30 Seconds).

    .Example
    Remove-SOCatClient -Server 192.168.2.1 -SOCatClientName MyRemovedClient

#Requires PS -Version 4.0
#>
function Remove-SOCatClient {
	[CmdletBinding()]
	param (
		[parameter(Mandatory=$true, Position=0)]
			[String]$Server,
		[parameter(Mandatory=$true, Position=2)]
			[String]$SOCatClientName,
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
            if (!(Get-SOCatClients | where {$_.Name -eq $SOCatClientName -and $_.System -eq $($Connection.Server)})) {throw "Client $SOCatClientName does not exist."}

            [Array]$IDs = (Get-SOSIDs | where {$_.System -eq $($Connection.Server)}).SSID

            for ($i = 1; $i -le $IDs.Count; $i++ ){
                $ClientCall = @{uri = "https://$($Connection.Server)/storeonceservices/cluster/servicesets/$i/services/cat/configs/clients/$((Get-SOCatClients | where {$_.Name -eq $SOCatClientName -and $_.System -eq $($Connection.Server) -and $_.SSID -eq $i}).ID)";
                                Method = 'DELETE';
                                Headers = @{Authorization = 'Basic ' + $($SOConnections.EncodedPassword);
                                            Accept = 'text/xml';
                                } 
                            } 
                
                $ClientResponse = Invoke-RestMethod @ClientCall

            }
            
            $i = 0
            while((Get-SOCatClients | where {$_.Name -eq $SOCatClientName -and $_.System -eq $($SOConnections.Server)})){
                $i++
                Start-Sleep 1
            if($i -gt $Timeout) { Write-Error "Removing Client Failed."; break}
                Write-Progress -Activity "Deleting Client" -Status "Wait for Client be removed..."
            }
        }

		Return (Get-SOCatClients | where {$_.System -eq $($SOConnections.Server)} | ft * -AutoSize)
	}
}
#endregion
