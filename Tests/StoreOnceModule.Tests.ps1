<#
    .EXAMPLE
    Invoke-Pester -Script @{ Path = '.\Tests\StoreOnceModule.Tests.ps1'; Parameters = @{ SOAppliance="192.168.130.129"; SOUser="Admin"; SOPass="admin"} }
#>

$SOAppliance = $Parameters.Get_Item("SOAppliance")
$SOUser = $Parameters.Get_Item("SOUser")
$SOPass = $Parameters.Get_Item("SOPass")

Describe "Module Tests" {

    Remove-Module PS-StoreOnce -ErrorAction SilentlyContinue
    It "Importing PowerCLI Modules" {
        Import-Module ./PS-StoreOnce/PS-StoreOnce.psd1
	    Get-Module PS-StoreOnce | Should Be $true
    }
}

Describe "Connect-SOAppliance Tests" {

    Clear-Variable SOConnections -Scope Global -ErrorAction SilentlyContinue
    $connection = Connect-SOAppliance -Server $SOAppliance -Username $SOUser -Password $SOPass
    It "Connection exists" {
        ($Global:SOConnections).count | Should Be 1
    }

}

Describe "Get-SOAppliance Tests" {

    It "Variable is correct" {
        (Get-SOAppliance).Server | Should Be $SOAppliance
    }

}

Describe "Get-SOSIDs Tests" {

    It "System is correct" {
        (Get-SOSIDs).System | Should Be $SOAppliance
    }
    It "SIDCount is correct" {
        (Get-SOSIDs).SIDCount | Should BeGreaterThan 0 
    }

}

Describe "Get-SONasShares Tests" {

    It "System is correct" {
        (Get-SONasShares).System | Should Be $SOAppliance
    }
    It "SIDCount is correct" {
        (Get-SONasShares).SIDCount | Should BeGreaterThan 0 
    }

}

Describe "Get-SOCatStores Tests" {

    It "System is correct" {
        (Get-SOCatStores).System | Should Be $SOAppliance
    }
    It "SIDCount is correct" {
        (Get-SOCatStores).SIDCount | Should BeGreaterThan 0 
    }

}

Describe "Get-SOCatClients Tests" {

    It "System is correct" {
        (Get-SOCatClients).System | Should Be $SOAppliance
    }
    It "SIDCount is correct" {
        (Get-SOCatClients).SIDCount | Should BeGreaterThan 0 
    }

}

Describe "Get-SOCatStoreAccess Tests" {

    It "Client is correct" {
        (Get-SOCatStoreAccess -Server 192.168.130.129 -CatStore myNewStore).Client | Should Be "myNewClient"
    }
    It "allowAccess is correct" {
        (Get-SOCatStoreAccess -Server 192.168.130.129 -CatStore myNewStore).allowAccess | Should Be "true"
    }

}
