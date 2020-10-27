#region: Workaround for SelfSigned Cert an force TLS 1.2
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
[System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#endregion

function Connect-SOAppliance {
<#
    .SYNOPSIS
    Connect to a StoreOnce Appliance 
    
    .DESCRIPTION
    Connect to a StoreOnce Appliance and generate a connection object with Servername, Token etc.
    
    .PARAMETER Server
    StoreOnce Appliance to connect to

    .PARAMETER Username
    Username to connect with

    .PARAMETER Password
    Password to connect with

    .PARAMETER Credential
    Credential object to connect with

    .EXAMPLE
    Connect-SOAppliance -Server d2d01.lan.local -Username TenantAdmin01 -Password P@ssword

    .EXAMPLE
    Connect-SOAppliance -Server d2d01.lan.local -Credential (Get-Credential)

#Requires PS -Version 4.0
#>
[CmdletBinding(DefaultParametersetName="Username")][OutputType('System.Management.Automation.PSObject')]

    Param (

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]$Server,
    
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
  
        Test-IP -IP $Server

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

        if (!$Global:SOConnections) {
            $Global:SOConnections = @()
        }
        
        $SOConnection = [pscustomobject]@{                        
                        
            Server = $Server
            Username = $Username
            EncodedPassword = $EncodedPassword

        }

	if ($Global:SOConnections.server -notcontains $SOConnection.Server) {$Global:SOConnections += $SOConnection}

        $TESTCall = @{uri = "https://$($Global:SOConnections[-1].Server)/storeonceservices/";
                            Method = 'GET';
                            Headers = @{Authorization = 'Basic ' + $($Global:SOConnections[-1].EncodedPassword);
                                        Accept = 'text/xml'
                            } 
                        } 
                    
        $TESTResponse = Invoke-RestMethod @TESTCall
        $TESTCount = ($TESTResponse.document.list.item).count
            
        if ($TESTCount -lt 1) {throw "No valid API Response!"}

        Write-Output $Global:SOConnections

    }
    catch [Exception]{

        Remove-Variable -Name SOConnections -Scope Global -Force -ErrorAction SilentlyContinue
        throw $_.Exception.Message

    }

}
