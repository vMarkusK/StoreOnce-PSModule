#region: Workaround for SelfSigned Cert
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
#endregion

#region: Set-SOCredentials
<# 
	.Synopsis
	Creates a Base64 hash for further requests against your StoreOnce system(s).

	.Description
	Creates a Base64 hash for further requests against your StoreOnce system(s). 
	This should be the first Commandlet you use from this module.
	
	.Parameter SOPassword
	User Password as SecureString of your StoreOnce system.

	.Parameter SOUser
	User Name of your StoreOnce system.

	.Parameter TESTIP
	IP Address of your StoreOnce system to Test the Credentials.
  
	.Parameter ShowHash
	It set to True, Hash will be displayed.
  
	.Example
	Set-SOCredentials
   
	.Example
	Set-SOCredentials -TESTIP 192.168.2.1 -ShowHash $true
   
	.Example  
	Set-SOCredentials -SOUser Admin -SOPassword $("admin" | ConvertTo-SecureString -AsPlainText -Force) -ShowHash $true
   
	.Example  
	Set-SOCredentials -SOUser Admin -ShowHash $true

#Requires PS -Version 2.0
#>
function Set-SOCredentials {
	[CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Low')]
	param (
		[parameter(Mandatory=$true, Position=0)]
			[String]$SOUser,
		[parameter(Mandatory=$true, Position=1)]
			[SecureString]$SOPassword,
		[parameter(Mandatory=$false, Position=2)]
			[String]$TESTIP,
		[parameter(Mandatory=$false, Position=1)]
			[Boolean]$ShowHash
	)
	Process {
		if ($TESTIP.count -gt 1) {Write-Error "This Command only Supports one IP (D2D System)." -Category InvalidArgument; Return}
		
		if ($PSCmdlet.ShouldProcess( $SOUser,"Creating Base64String String with given Password.")) {
			[String]$SOPasswordClear =  [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($SOPassword))
			$global:SOCred = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($SOUser):$($SOPasswordClear)"))
			if ($ShowHash -eq $true) {Return $SOCred}
			}
		if ($SOCred -eq $null) {Write-Error "No Credential Set" -Category InvalidArgument; Return}
		
		If ($TESTIP) {
			$TESTCall = @{uri = "https://$TESTIP/storeonceservices/";
						Method = 'GET';
							Headers = @{Authorization = 'Basic ' + $SOCred;
										Accept = 'text/xml'
					} 
				} 
				
			$TESTResponse = Invoke-RestMethod @TESTCall
			$TESTCount = ($TESTResponse.document.list.item).count
		
			if ($TESTCount -lt 1) {Write-Error "Wrong Credentials!" -Category ConnectionError; Return}
			else {Write-Information "Credentials OK!"}
		}
	
	}	
}
#endregion

#region: Get-SOSIDs
<# 
	.Synopsis
	Lists all ServiceSets from your StoreOnce system(s).

	.Description
	Lists all ServiceSets from your StoreOnce system(s).
	Outputs: ArrayIP,SSID,Name,Alias,OverallHealth,SerialNumber,Capacity(GB).Free(GB),UserData(GB),DiskData(GB)
	
	.Parameter D2DIPs
	IP Address of your StoreOnce system(s).

	.Example
	Get-SOSIDs -D2DIPs 192.168.2.1, 192.168.2.2

#Requires PS -Version 2.0
#>
function Get-SOSIDs {
	[CmdletBinding()]
	param (
		[parameter(Mandatory=$true, Position=0)]
			$D2DIPs
	)
	Process {
		if ($SOCred -eq $null) {Write-Error "No Credential Set! Use 'set-SOCredentials'" -Category ConnectionError; Return}
		$SOSIDs =  @()
		
		ForEach ($D2DIP in $D2DIPs) {
			$SIDCall = @{uri = "https://$D2DIP/storeonceservices/cluster/servicesets/";
						Method = 'GET';
							Headers = @{Authorization = 'Basic ' + $SOCred;
										Accept = 'text/xml'
					} 
				} 
				
			$SIDsResponse = Invoke-RestMethod @SIDCall
			$SIDCount = ($SIDsResponse.document.servicesets.serviceset).count
			if ($SIDCount -eq $null) {$SIDCount = 1}
			[Array] $SSID = $SIDsResponse.document.servicesets.serviceset.properties.ssid
			[Array] $Name = $SIDsResponse.document.servicesets.serviceset.properties.name
			[Array] $Alias = $SIDsResponse.document.servicesets.serviceset.properties.alias
			[Array] $OverallHealth = $SIDsResponse.document.servicesets.serviceset.properties.overallHealth
			[Array] $SerialNumber = $SIDsResponse.document.servicesets.serviceset.properties.serialNumber
			[Array] $CapacityBytes = $SIDsResponse.document.servicesets.serviceset.properties.capacityBytes
			[Array] $FreeBytes = $SIDsResponse.document.servicesets.serviceset.properties.freeBytes
			[Array] $UserBytes = $SIDsResponse.document.servicesets.serviceset.properties.userBytes
			[Array] $DiskBytes = $SIDsResponse.document.servicesets.serviceset.properties.diskBytes
			
			for ($i = 0; $i -lt $SIDCount; $i++ ){		
				$row = [PSCustomObject] @{
					ArrayIP = $D2DIP
					SSID = $SSID[$i]
					Name = $Name[$i]
					Alias = $Alias[$i]
					OverallHealth = $OverallHealth[$i]
					SerialNumber = $SerialNumber[$i]
					"Capacity(GB)" = ([math]::Round(($CapacityBytes[$i] / 1073741824),2))
					"Free(GB)" = ([math]::Round(($FreeBytes[$i] / 1073741824),2))
					"UserData(GB)" = ([math]::Round(($UserBytes[$i] / 1073741824),2))
					"DiskData(GB)" = ([math]::Round(($DiskBytes[$i] / 1073741824),2))
				}
				$SOSIDs += $row
			} 
		}

	Return $SOSIDs
	}
} 
#endregion

#region: Get-SOCatStores
<# 
	.Synopsis
	Lists all Catalyst Stores from your StoreOnce system(s).

	.Description
	Lists all Catalyst Stores from your StoreOnce system(s).
	Outputs: ArrayIP,SSID,Name,ID,SizeOnDisk(GB),UserDataStored(GB),DedupeRatio
	
	.Parameter D2DIPs
	IP Address of your StoreOnce system(s).

	.Example
	Get-SOCatStores -D2DIPs 192.168.2.1, 192.168.2.2

#Requires PS -Version 2.0
#>
function Get-SOCatStores {
	[CmdletBinding()]
	param (
		[parameter(Mandatory=$true, Position=0)]
			$D2DIPs
	)
	Process {
		if ($SOCred -eq $null) {Write-Error "No System Credential Set! Use 'Set-SOCredentials'." -Category ConnectionError; Return}
		$SOCatStores =  @()
		
		ForEach ($D2DIP in $D2DIPs) {
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
				$StoreInf = @{uri = "https://$D2DIP/storeonceservices/cluster/servicesets/$x/services/cat/stores/";
							Method = 'GET';
								Headers = @{Authorization = 'Basic ' + $SOCred;
											Accept = 'text/xml'
						} 
					} 
				
				$StoreInfResponse = Invoke-RestMethod @StoreInf
				[Array] $SSID = $StoreInfResponse.document.stores.store.properties.ssid
				[Array] $Name = $StoreInfResponse.document.stores.store.properties.name
				[Array] $ID = $StoreInfResponse.document.stores.store.properties.id
				[Array] $UserDataStored = $StoreInfResponse.document.stores.store.properties.userdatastored
				[Array] $SizeOnDisk = $StoreInfResponse.document.stores.store.properties.sizeondisk
				[Array] $DDRate = $StoreInfResponse.document.stores.store.properties.deduperatio
				$StoresCount = ($Name).count
			
				$DDRate = $DDRate | ForEach {$i=1} {if ($i++ %2){$_}}
			
				for ($i = 0; $i -lt $StoresCount; $i++ ){	
					$row = [PSCustomObject] @{
						ArrayIP = $D2DIP
						SSID = $SSID[$i]
						Name = $Name[$i]
						ID = $ID[$i]
						"SizeOnDisk(GB)" = ([math]::Round(($SizeOnDisk[$i]),2))
						"UserDataStored(GB)" = ([math]::Round(($UserDataStored[$i]),2))
						DedupeRatio = $DDRate[$i]
					}
					$SOCatStores += $row
				}
			}
		} 
		
	Return $SOCatStores
	}
}
#endregion

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

#Requires PS -Version 2.0
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
			
	Return $SONasShares
	}
}
#endregion

#region: Get-SOCatClients
<# 
	.Synopsis
	Lists all Catalyst Clients from your StoreOnce system(s).

	.Description
	Lists all Catalyst Clients from your StoreOnce system(s).
	Outputs: ArrayIP,SSID,Name,ID,Description,canCreateStores,canSetServerProperties,canManageClientPermissions
	
	.Parameter D2DIPs
	IP Address of your StoreOnce system(s).

	.Example
	Get-SOCatClients -D2DIPs 192.168.2.1, 192.168.2.2

#Requires PS -Version 2.0
#>
function Get-SOCatClients {
	[CmdletBinding()]
	param (
		[parameter(Mandatory=$true, Position=0)]
			$D2DIPs
	)
	Process {
		if ($SOCred -eq $null) {Write-Error "No System Credential Set! Use 'Set-SOCredentials'."; Return}
		$SOCatClients =  @()
		
		ForEach ($D2DIP in $D2DIPs) {
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
				$ClientReq = @{uri = "https://$D2DIP/storeonceservices/cluster/servicesets/$x/services/cat/configs/clients/";
							Method = 'GET';
								Headers = @{Authorization = 'Basic ' + $SOCred;
											Accept = 'text/xml'
						} 
					} 
				$ClientResponse = Invoke-RestMethod @ClientReq
			
				[Array] $Name = $ClientResponse.document.clients.client.properties.name
				[Array] $ID = $ClientResponse.document.clients.client.properties.id
				[Array] $Description = $ClientResponse.document.clients.client.properties.description
				[Array] $canCreateStores = $ClientResponse.document.clients.client.properties.canCreateStores
				[Array] $canSetServerProperties = $ClientResponse.document.clients.client.properties.canSetServerProperties
				[Array] $canManageClientPermissions = $ClientResponse.document.clients.client.properties.canManageClientPermissions
				$ClientCount = ($Name).count
						
				for ($i = 0; $i -lt $ClientCount; $i++ ){
							
					$row = [PSCustomObject] @{
						ArrayIP = $D2DIP
						SSID = $x
						Name = $Name[$i]
						ID = $ID[$i]
						Description = $Description[$i]
						canCreateStores = $canCreateStores[$i]
						canSetServerProperties = $canSetServerProperties[$i]
						canManageClientPermissions = $canManageClientPermissions[$i]
					}
					$SOCatClients += $row
			
				}
			}
		
		} 
			
	Return $SOCatClients
	}
}
#endregion

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

#Requires PS -Version 2.0
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
	
	Return $SOCatStoreAccess | Where {$_.allowAccess -eq "true"}
	}
}
#endregion