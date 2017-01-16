#
# Modulmanifest für das Modul "PSGet_PS-StoreOnce"
#
# Generiert von: Markus Kraus
#
# Generiert am: 16.01.2017
#

@{

# Die diesem Manifest zugeordnete Skript- oder Binärmoduldatei.
# RootModule = ''

# Die Versionsnummer dieses Moduls
ModuleVersion = '1.2.7'

# ID zur eindeutigen Kennzeichnung dieses Moduls
GUID = 'dfe6dfcc-5971-41b9-aa49-f2b5db87f3db'

# Autor dieses Moduls
Author = 'Markus Kraus'

# Unternehmen oder Hersteller dieses Moduls
CompanyName = 'mycloudrevolution.com'

# Urheberrechtserklärung für dieses Modul
Copyright = '(c) 2016 Markus Kraus. All rights reserved.'

# Beschreibung der von diesem Modul bereitgestellten Funktionen
Description = 'HPE StoreOnce PowerShell Module'

# Die für dieses Modul mindestens erforderliche Version des Windows PowerShell-Moduls
PowerShellVersion = '4.0'

# Der Name des für dieses Modul erforderlichen Windows PowerShell-Hosts
# PowerShellHostName = ''

# Die für dieses Modul mindestens erforderliche Version des Windows PowerShell-Hosts
# PowerShellHostVersion = ''

# Die für dieses Modul mindestens erforderliche Microsoft .NET Framework-Version
# DotNetFrameworkVersion = ''

# Die für dieses Modul mindestens erforderliche Version der CLR (Common Language Runtime)
# CLRVersion = ''

# Die für dieses Modul erforderliche Prozessorarchitektur ("Keine", "X86", "Amd64").
# ProcessorArchitecture = ''

# Die Module, die vor dem Importieren dieses Moduls in die globale Umgebung geladen werden müssen
# RequiredModules = @()

# Die Assemblys, die vor dem Importieren dieses Moduls geladen werden müssen
# RequiredAssemblies = @()

# Die Skriptdateien (PS1-Dateien), die vor dem Importieren dieses Moduls in der Umgebung des Aufrufers ausgeführt werden.
# ScriptsToProcess = @()

# Die Typdateien (.ps1xml), die beim Importieren dieses Moduls geladen werden sollen
# TypesToProcess = @()

# Die Formatdateien (.ps1xml), die beim Importieren dieses Moduls geladen werden sollen
# FormatsToProcess = @()

# Die Module, die als geschachtelte Module des in "RootModule/ModuleToProcess" angegebenen Moduls importiert werden sollen.
NestedModules = @('Functions\Connect-SOAppliance.psm1', 
               'Functions\Get-SOAppliance.psm1', 
               'Functions\Report\Get-SOCatClients.psm1', 
               'Functions\Report\Get-SOCatStoreAccess.psm1', 
               'Functions\Report\Get-SOCatStores.psm1', 
               'Functions\Report\Get-SONasShares.psm1', 
               'Functions\Report\Get-SOSIDs.psm1', 
               'Functions\Create\New-SOCatClient.psm1', 
               'Functions\Create\New-SOCatStore.psm1', 
               'Functions\Remove\Remove-SOCatClient.psm1', 
               'Functions\Remove\Remove-SOCatStore.psm1', 
               'Functions\Config\Set-SOCatStoreAccess.psm1', 
               'Functions\Test-IP.psm1')

# Aus diesem Modul zu exportierende Funktionen
FunctionsToExport = 'Connect-SOAppliance', 'Get-SOAppliance', 'Get-SOCatClients', 
               'Get-SOCatStoreAccess', 'Get-SOCatStores', 'Get-SONasShares', 
               'Get-SOSIDs', 'New-SOCatClient', 'New-SOCatStore', 'Remove-SOCatClient', 
               'Remove-SOCatStore', 'Set-SOCatStoreAccess', 'Test-IP'

# Aus diesem Modul zu exportierende Cmdlets
CmdletsToExport = '*'

# Die aus diesem Modul zu exportierenden Variablen
VariablesToExport = '*'

# Aus diesem Modul zu exportierende Aliase
AliasesToExport = '*'

# Aus diesem Modul zu exportierende DSC-Ressourcen
# DscResourcesToExport = @()

# Liste aller Module in diesem Modulpaket
# ModuleList = @()

# Liste aller Dateien in diesem Modulpaket
# FileList = @()

# Die privaten Daten, die an das in "RootModule/ModuleToProcess" angegebene Modul übergeben werden sollen. Diese können auch eine PSData-Hashtabelle mit zusätzlichen von PowerShell verwendeten Modulmetadaten enthalten.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'HPE','StoreOnce','REST'

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/mycloudrevolution/StoreOnce-PSModule/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'http://mycloudrevolution.com/projekte/storeonce-powershell-module/'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # External dependent modules of this module
        # ExternalModuleDependencies = ''

    } # End of PSData hashtable
    
 } # End of PrivateData hashtable

# HelpInfo-URI dieses Moduls
# HelpInfoURI = ''

# Standardpräfix für Befehle, die aus diesem Modul exportiert werden. Das Standardpräfix kann mit "Import-Module -Prefix" überschrieben werden.
# DefaultCommandPrefix = ''

}

