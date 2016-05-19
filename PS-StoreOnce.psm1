###### ignore invalid SSL Certs ##########
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

###### Set-SOCredentials ##########
function Set-SOCredentials {
	
	[String]$SOUser = (Read-Host 'D2D username?')
	$SOPassword = (Read-Host 'D2D password?' -AsSecureString)
	[String]$SOPasswordClear =  [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($SOPassword))
  	$global:SOCred = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($SOUser):$($SOPasswordClear)"))
	if ($SOCred -eq $null) {Write-Error "No Credential Set"; return}
	
	} # end function

###### Get-SOSIDs ##########
function Get-SOSIDs {
	param ($D2DIPs)
	
	if ($SOCred -eq $null) {Write-Error "No Credential Set! Use 'set-SOCredentials'"; return}
	$global:SOSIDs =  New-Object System.Collections.ArrayList
	
	foreach ($D2DIP in $D2DIPs) {
		$SIDCall = @{uri = "https://$D2DIP/storeonceservices/cluster/servicesets/";
					Method = 'GET'; #(or POST, or whatever)
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
				
			$row = New-object PSObject
			$row  | Add-Member -Name ArrayIP -Value $D2DIP -Membertype NoteProperty
			$row  | Add-Member -Name SSID -Value $SSID[$i]-Membertype NoteProperty
			$row  | Add-Member -Name Name -Value $Name[$i] -Membertype NoteProperty
			$row  | Add-Member -Name Alias -Value $Alias[$i] -Membertype NoteProperty
			$row  | Add-Member -Name OverallHealth -Value $OverallHealth[$i] -Membertype NoteProperty
			$row  | Add-Member -Name SerialNumber -Value $SerialNumber[$i] -Membertype NoteProperty
			$row  | Add-Member -Name "Capacity(GB)" -Value ([math]::Round(($CapacityBytes[$i] / 1073741824),2))  -Membertype NoteProperty
			$row  | Add-Member -Name "Free(GB)" -Value ([math]::Round(($FreeBytes[$i] / 1073741824),2))  -Membertype NoteProperty
			$row  | Add-Member -Name "UserData(GB)" -Value ([math]::Round(($UserBytes[$i] / 1073741824),2))  -Membertype NoteProperty
			$row  | Add-Member -Name "DiskData(GB)" -Value ([math]::Round(($DiskBytes[$i] / 1073741824),2))  -Membertype NoteProperty
			$SOSIDs += $row
			
			} 
		}
	
	Return $SOSIDs
	
	} # end function

###### Get-SOStores ##########
function Get-SOStores {
	param ($D2DIPs)
	
	if ($SOCred -eq $null) {Write-Error "No System Credential Set! Use 'Set-SOCredentials'."; return}
	$global:SOStores =  New-Object System.Collections.ArrayList
	
	foreach ($D2DIP in $D2DIPs) {
		$SIDCall = @{uri = "https://$D2DIP/storeonceservices/cluster/servicesets/";
					Method = 'GET'; #(or POST, or whatever)
						Headers = @{Authorization = 'Basic ' + $SOCred;
									Accept = 'text/xml'
				} 
			} 
		
		$SIDsResponse = Invoke-RestMethod @SIDCall
		$SIDCount = ($SIDsResponse.document.servicesets.serviceset).count
		if ($SIDCount -eq $null) {$SIDCount = 1}
		
		for ($x = 1; $x -le $SIDCount; $x++ ){
			$StoreInf = @{uri = "https://$D2DIP/storeonceservices/cluster/servicesets/$x/services/cat/stores/";
						Method = 'GET'; #(or POST, or whatever)
							Headers = @{Authorization = 'Basic ' + $SOCred;
										Accept = 'text/xml'
					} 
				} 
			$StoreInfResponse = Invoke-RestMethod @StoreInf
		
			[Array] $Name = $StoreInfResponse.document.stores.store.properties.name
			[Array] $SSID = $StoreInfResponse.document.stores.store.properties.ssid
			[Array] $UserDataStored = $StoreInfResponse.document.stores.store.properties.userdatastored
			[Array] $SizeOnDisk = $StoreInfResponse.document.stores.store.properties.sizeondisk
			[Array] $DDRate = $StoreInfResponse.document.stores.store.properties.deduperatio
			$StoresCount = ($Name).count
		
			$DDRate = $DDRate | foreach {$i=1} {if ($i++ %2){$_}}
		
			for ($i = 0; $i -lt $StoresCount; $i++ ){
						
				$row = New-object PSObject
				$row  | Add-Member -Name ArrayIP -Value $D2DIP -Membertype NoteProperty
				$row  | Add-Member -Name SSID -Value $SSID[$i] -Membertype NoteProperty
				$row  | Add-Member -Name Name -Value $Name[$i] -Membertype NoteProperty
				$row  | Add-Member -Name "SizeOnDisk(GB)" -Value ([math]::Round(($SizeOnDisk[$i]),2)) -Membertype NoteProperty
				$row  | Add-Member -Name "UserDataStored(GB)" -Value ([math]::Round(($UserDataStored[$i]),2)) -Membertype NoteProperty
				$row  | Add-Member -Name DedupeRatio -Value $DDRate[$i] -Membertype NoteProperty
				$SOStores += $row
			
		
				}
			}
	
		} 
		
	Return $SOStores
	
	}# end function
