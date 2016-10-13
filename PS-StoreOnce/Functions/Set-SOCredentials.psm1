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

#Requires PS -Version 4.0
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
		[parameter(Mandatory=$false, Position=3)]
			[Boolean]$ShowHash
	)
	Process {
		if ($TESTIP.count -gt 1) {Write-Error "This Command only Supports one IP (D2D System)." -Category InvalidArgument; Return}
		
		if ($PSCmdlet.ShouldProcess( $SOUser,"Creating Base64String String with given Password.")) {
			[String]$SOPasswordClear =  [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($SOPassword))
			$global:SOCred = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($SOUser):$($SOPasswordClear)"))
			}
		if ($SOCred -eq $null) {Write-Error "No Credential Set" -Category InvalidArgument; Return}
		
		If ($TESTIP) {

            if (Test-IP -IP $TESTIP) {

                Write-Verbose "Testing Basic REST Call to $($TESTIP)"
                $TESTCall = @{uri = "https://$TESTIP/storeonceservices/";
                            Method = 'GET';
                            Headers = @{Authorization = 'Basic ' + $SOCred;
                                        Accept = 'text/xml'
                            } 
                        } 
                    
                $TESTResponse = Invoke-RestMethod @TESTCall
                $TESTCount = ($TESTResponse.document.list.item).count
            
                if ($TESTCount -lt 1) {Write-Error "Wrong Credentials!" -Category ConnectionError; Return}
                else {Write-Output "Credentials OK!"}
            }
		}
	if ($ShowHash -eq $true) {Return $SOCred}
	}	
}
#endregion