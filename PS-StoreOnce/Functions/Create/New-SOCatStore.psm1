#region: New-SOCatStore
<# 
    .Synopsis
    Create a single StoreOnce Catalyst store on your StoreOnce system.

    .Description
    Create a single StoreOnce Catalyst store on a given Service Set on your StoreOnce system.
	
    .Parameter D2DIP
    IP Address of your StoreOnce system.

    .Parameter SSID
    Target Service Set for the new Store on your StoreOnce system.

    .Parameter SOCatStoreName
    Name for the new Store on your StoreOnce system.

    .Parameter SOCatStoreDesc
    Description for the new Store on your StoreOnce system.

    .Parameter Timeout
    Timeout for the Store creation process (Default is 30 Seconds).

    .Example
    New-SOCatStore -D2DIP 192.168.2.1 -SSID 1 -SOCatStoreName MyNewStore

#Requires PS -Version 4.0
#>
function New-SOCatStore {
	[CmdletBinding()]
	param (
		[parameter(Mandatory=$true, Position=0)]
			[String]$D2DIP,
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
		if ($SOCred -eq $null) {Write-Error "No System Credential Set! Use 'Set-SOCredentials'." -Category ConnectionError; Return}

        if (Test-IP -IP $D2DIP) {
            if (Get-SOCatStores -D2DIPs $D2DIP | where {$_.Name -eq $SOCatStoreName}) {Write-Error "Store $SOCatStoreName already Exists."; Return}
            $StoreCall = @{uri = "https://$D2DIP/storeonceservices/cluster/servicesets/$SSID/services/cat/stores/";
                            Method = 'POST';
                            Headers = @{Authorization = 'Basic ' + $SOCred;
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
            while(!(Get-SOCatStores -D2DIPs $D2DIP | where {$_.Name -eq $SOCatStoreName -and $_.Status -eq "Online"})){
                $i++
                Start-Sleep 1
            if($i -gt $Timeout) { Write-Error "Creating Store Failed."; break}
                Write-Progress -Activity "Creating Store" -Status "Wait for Store become Online..."
            }
        }

		Return (Get-SOCatStores -D2DIPs $D2DIP | where {$_.Name -eq $SOCatStoreName} | ft * -AutoSize)
	}
}
#endregion
