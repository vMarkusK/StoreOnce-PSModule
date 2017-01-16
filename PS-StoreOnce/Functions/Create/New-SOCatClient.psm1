#region: New-SOCatClient
<# 
    .Synopsis
    Create a StoreOnce Catalyst Client on your StoreOnce system.

    .Description
    Create a StoreOnce Catalyst Client on all Service Sets on your StoreOnce system.
	
    .Parameter Server
    IP Address oder DNS Name of your StoreOnce system like defined via Connect-SOAppliance (check Get-SOConnections).

    .Parameter SOCatClientName
    Name for the new Client on your StoreOnce system.

    .Parameter SOCatClientPass
    Password for the new Client on your StoreOnce system.

    .Parameter SOCatClientCredential
    Name and Password per "Get-Credential" for the new Client on your StoreOnce system.

    .Parameter SOCatClientDesc
    Description for the new Client on your StoreOnce system.

    .Parameter Timeout
    Timeout for the Client creation process (Default is 30 Seconds).

    .Example
    New-SOCatClient -Server 192.168.2.1 -SOCatClientName MyNewClient -SOCatClientPass MyNewClientPass!!

    .Example
    New-SOCatClient -Server 192.168.2.1 -SOCatClientCredential (Get-Credential)

#Requires PS -Version 4.0
#>
function New-SOCatClient {
	[CmdletBinding(DefaultParametersetName="SOCatClientName")][OutputType('System.Management.Automation.PSObject')]
	param (
		[parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
			[String]$Server,
		[parameter(Mandatory=$true, Position=1, ParameterSetName="SOCatClientName")]
        [ValidateNotNullOrEmpty()]
			[String]$SOCatClientName,
        [parameter(Mandatory=$true, Position=2, ParameterSetName="SOCatClientName")]
        [ValidateNotNullOrEmpty()]
			[String]$SOCatClientPass,
        [Parameter(Mandatory=$true, Position=3, ParameterSetName="Credential")]
	    [ValidateNotNullOrEmpty()]
	        [Management.Automation.PSCredential]$SOCatClientCredential,
		[parameter(Mandatory=$false, Position=4)]
			[String]$SOCatClientDesc = $SOCatClientName,
		[parameter(Mandatory=$false, Position=5)]
			[Int]$Timeout = 30
			
	)
	Process {
		if (!$Global:SOConnections) {throw "No StoreOnce Appliance(s) connected! Use 'Connect-SOAppliance'"}
        if ($Server.count -gt 1) {throw "This Command only Supports one D2D System."}
        $Connection = $Global:SOConnections | Where {$_.Server -eq $Server}
		if (!$Connection) {throw "No D2D System found, check Get-SOConnections."}
        if ($Connection.count -gt 1) {throw "This Command only Supports one D2D System."}
        
        if ($PSBoundParameters.ContainsKey("SOCatClientCredential")){

            $SOCatClientName = $SOCatClientCredential.UserName
            $SOCatClientPass = $SOCatClientCredential.GetNetworkCredential().Password
        
        }  

        if (Test-IP -IP $($SOConnections.Server)) {
            if (Get-SOCatClients | where {$_.Name -eq $SOCatClientName -and $_.System -eq $($SOConnections.Server)}) {Throw "Client $SOCatClientName already Exists."}

            [Array]$IDs = (Get-SOSIDs | where {$_.System -eq $($SOConnections.Server)}).SSID

            for ($i = 1; $i -le $IDs.Count; $i++ ){
                $ClientCall = @{uri = "https://$($SOConnections.Server)/storeonceservices/cluster/servicesets/$i/services/cat/configs/clients/";
                                Method = 'POST';
                                Headers = @{Authorization = 'Basic ' + $($SOConnections.EncodedPassword);
                                            Accept = 'text/xml';
                                            'Content-Type' = 'application/x-www-form-urlencoded'
                                }
                                Body = @{name = $SOCatClientName;
                                        description = $SOCatClientDesc;
                                        password = $SOCatClientPass;
                                        canCreateStores = 'false';
                                        canSetServerProperties = 'false';
                                        canManageClientPermissions = 'false'
                                } 
                            }

                $ClientResponse = Invoke-RestMethod @ClientCall
            }
            
            $i = 0
            while(!(Get-SOCatClients | where {$_.Name -eq $SOCatClientName -and $_.System -eq $($SOConnections.Server)})){
                $i++
                Start-Sleep 1
            if($i -gt $Timeout) { Write-Error "Creating Client Failed."; break}
                Write-Progress -Activity "Creating Client" -Status "Wait for Client..."
            }
        }
		Return (Get-SOCatClients | where {$_.Name -eq $SOCatClientName -and $_.System -eq $($SOConnections.Server)} | ft * -AutoSize)
		
	}
}
#endregion
