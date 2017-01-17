Connect Commands
=========================

This page contains details on **Connect** commands.

Connect-SOAppliance
-------------------------


NAME
    Connect-SOAppliance
    
ÜBERSICHT
    Connect to a StoreOnce Appliance
    
    
SYNTAX
    Connect-SOAppliance -Server <String> -Username <String> -Password <String> [-IgnoreCertRequirements] [<CommonParameters>]
    
    Connect-SOAppliance -Server <String> -Credential <PSCredential> [-IgnoreCertRequirements] [<CommonParameters>]
    
    
BESCHREIBUNG
    Connect to a StoreOnce Appliance and generate a connection object with Servername, Token etc.
    

PARAMETER
    -Server <String>
        StoreOnce Appliance to connect to
        
    -Username <String>
        Username to connect with
        
    -Password <String>
        Password to connect with
        
    -Credential <PSCredential>
        Credential object to connect with
        
    -IgnoreCertRequirements [<SwitchParameter>]
        
    <CommonParameters>
        Dieses Cmdlet unterstützt folgende allgemeine Parameter: "Verbose", "Debug",
        "ErrorAction", "ErrorVariable", "WarningAction", "WarningVariable",
        "OutBuffer", "PipelineVariable" und "OutVariable". Weitere Informationen finden Sie unter 
        "about_CommonParameters" (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- BEISPIEL 1 --------------------------
    
    PS C:\>Connect-SOAppliance -Server d2d01.lan.local -Username TenantAdmin01 -Password P@ssword
    
    
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>Connect-SOAppliance -Server d2d01.lan.local -Credential (Get-Credential)
    
    #Requires PS -Version 4.0
    
    
    
    
HINWEISE
    Zum Aufrufen der Beispiele geben Sie Folgendes ein: "get-help Connect-SOAppliance -examples".
    Weitere Informationen erhalten Sie mit folgendem Befehl: "get-help Connect-SOAppliance -detailed".
    Technische Informationen erhalten Sie mit folgendem Befehl: "get-help Connect-SOAppliance -full".




