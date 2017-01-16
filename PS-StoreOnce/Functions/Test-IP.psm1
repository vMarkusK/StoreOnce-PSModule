#region: Test-IP
<# 
	.Synopsis
	Tests IP Connectivity on given port

	.Description
    Tests IP Connectivity on given port.
    Test returns $True or throws an error.
	
	.Parameter IP
    IP Address of your system to Test
  
    .Parameter Port
    Port to Test
  
	.Example
	Test-IP -IP 192.168.2.1 -Port 8443
   
	.Example
	Test-IP -IP 192.168.2.1

#Requires PS -Version 4.0
#>
function Test-IP {
	param (
		[parameter(Mandatory=$true, Position=0)]
			[String]$IP,
		[parameter(Mandatory=$false, Position=1)]
			[Int]$Port = 443

	)
	Process {
        try {
            Write-Verbose "Testing connectivity to $($IP) on port $($Port)"
            $TCPClient = New-Object Net.Sockets.TcpClient
            $TCPClient.Connect($IP, $Port)
            $TCPClient.Close()
            return $true
        }
        catch [Exception] {

            throw "Could not connect to $($IP) on port $($Port)"

        }
    }
}