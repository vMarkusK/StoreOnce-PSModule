Connect Commands
=========================

This page contains details on **Connect** commands.

Connect-SOAppliance
-------------------------


NAME
    Connect-SOAppliance
    
SYNOPSIS
    Connect to a StoreOnce Appliance
    
    
SYNTAX
    Connect-SOAppliance -Server <String> -Username <String> -Password <String> [-IgnoreCertRequirements] [<CommonParameters>]
    
    Connect-SOAppliance -Server <String> -Credential <PSCredential> [-IgnoreCertRequirements] [<CommonParameters>]
    
    
DESCRIPTION
    Connect to a StoreOnce Appliance and generate a connection object with Servername, Token etc.
    

PARAMETERS
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
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Connect-SOAppliance -Server d2d01.lan.local -Username TenantAdmin01 -Password P@ssword
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Connect-SOAppliance -Server d2d01.lan.local -Credential (Get-Credential)
    
    #Requires PS -Version 4.0
    
    
    
    
REMARKS
    To see the examples, type: "get-help Connect-SOAppliance -examples".
    For more information, type: "get-help Connect-SOAppliance -detailed".
    For technical information, type: "get-help Connect-SOAppliance -full".




