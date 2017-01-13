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

function Connect-SOAppliance {
<#
    .SYNOPSIS
    Connect to a StoreOnce Appliance 
    
    .DESCRIPTION
    Connect to a StoreOnce Appliance and generate a connection object with Servername, Token etc
    
    .PARAMETER Server
    StoreOnce Appliance to connect to

    .PARAMETER Port
    Optionally specify the Appliance port. Default is 443

    .PARAMETER Username
    Username to connect with

    .PARAMETER Password
    Password to connect with

    .PARAMETER Credential
    Credential object to connect with

    .INPUTS
    System.String
    Management.Automation.PSCredential
    Switch

    .OUTPUTS
    System.Management.Automation.PSObject.

    .EXAMPLE
    Connect-SOAppliance -Server d2d01.lan.local -Username TenantAdmin01 -Password P@ssword -IgnoreCertRequirements

    .EXAMPLE
    Connect-SOAppliance -Server d2d01.lan.local -Credential (Get-Credential)

    .EXAMPLE
    Connect-SOAppliance -Server d2d01.lan.local -Port 443 -Credential (Get-Credential)

#>
[CmdletBinding(DefaultParametersetName="Username")][OutputType('System.Management.Automation.PSObject')]

    Param (

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]$Server,

    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [Int]$Port = 443,    
    
    [Parameter(Mandatory=$true,ParameterSetName="Username")]
    [ValidateNotNullOrEmpty()]
    [String]$Username,

    [Parameter(Mandatory=$true,ParameterSetName="Username")]
    [ValidateNotNullOrEmpty()]
    [String]$Password,

    [Parameter(Mandatory=$true,ParameterSetName="Credential")]
	[ValidateNotNullOrEmpty()]
	[Management.Automation.PSCredential]$Credential,

    [Parameter(Mandatory=$false)]
    [Switch]$IgnoreCertRequirements

    )       

    try {
  
        Write-Verbose -Message "Testing connectivity to $($Server):$($Port)"
        Test-IP -IP $Server -Port $Port

    }
    catch [Exception] {

        throw "Could not connect to server $($Server) on port $($Port)"

    }

    if ($PSBoundParameters.ContainsKey("Credential")){

        $Username = $Credential.UserName
        $Password = $Credential.GetNetworkCredential().Password
        
    }          
       
    try {

        $Auth = $Username + ':' + $Password
        $Encoded = [System.Text.Encoding]::UTF8.GetBytes($Auth)
        $EncodedPassword = [System.Convert]::ToBase64String($Encoded)
            
        $Global:SOConnection = [pscustomobject]@{                        
                        
            Server = "$($Server):$($Port)"
            Username = $Username
            EncodedPassword = $EncodedPassword

        }

        # --- Update vROConnection with version information
        #$VersionInfo = Get-vROVersion
        #$Global:vROConnection.Version = $VersionInfo.Version
        #$Global:vROConnection.APIVersion = $VersionInfo.APIVersion

        $TESTCall = @{uri = "https://$($Global:SOConnection.Server)/storeonceservices/";
                            Method = 'GET';
                            Headers = @{Authorization = 'Basic ' + $($Global:SOConnection.EncodedPassword);
                                        Accept = 'text/xml'
                            } 
                        } 
                    
        $TESTResponse = Invoke-RestMethod @TESTCall
        $TESTCount = ($TESTResponse.document.list.item).count
            
        if ($TESTCount -lt 1) {Write-Error "Wrong Credentials!" -Category ConnectionError; throw "Could not log in with given credentials."}
        else {Write-Output "Credentials OK!"}


        Write-Output $Global:SOConnection


    }
    catch [Exception]{

        Remove-Variable -Name SOConnection -Scope Global -Force -ErrorAction SilentlyContinue
        throw $_.Exception.Message

    }

}