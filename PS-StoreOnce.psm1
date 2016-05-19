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
	$global:SOCred = ""
	$SOUser = (Read-Host 'D2D username?')
	$SOPassword = (Read-Host 'D2D password?')
  	$global:SOCred = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($SOUser):$($SOPassword)"))
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
			$row  | Add-Member -Name D2D-IP -Value $D2DIP -Membertype NoteProperty
			$row  | Add-Member -Name SSID -Value $SSID[$i]-Membertype NoteProperty
			$row  | Add-Member -Name Name -Value $Name[$i] -Membertype NoteProperty
			$row  | Add-Member -Name Alias -Value $Alias[$i] -Membertype NoteProperty
			$row  | Add-Member -Name OverallHealth -Value $OverallHealth[$i] -Membertype NoteProperty
			$row  | Add-Member -Name SerialNumber -Value $SerialNumber[$i] -Membertype NoteProperty
			$row  | Add-Member -Name CapacityGBytes -Value ([math]::Round(($CapacityBytes[$i] / 1073741824),2))  -Membertype NoteProperty
			$row  | Add-Member -Name FreeGBytes -Value ([math]::Round(($FreeBytes[$i] / 1073741824),2))  -Membertype NoteProperty
			$row  | Add-Member -Name UserGBytes -Value ([math]::Round(($UserBytes[$i] / 1073741824),2))  -Membertype NoteProperty
			$row  | Add-Member -Name DiskGBytes -Value ([math]::Round(($DiskBytes[$i] / 1073741824),2))  -Membertype NoteProperty
			
			$SOSIDs += $row
			
			} 
		}
	
	Return $SOSIDs
	
	} # end function