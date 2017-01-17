<a name="Title">
# Title

HPE StoreOnce PowerShell Module

|Navigation|
|-----------------|
|[About](#About)|
|[Contribute](#Contribute)|
|[Features](#Features)|
|[Enhancements](#Enhancements)|


<a name="About">
# About
[*Back to top*](#Title)

Project Owner: Markus Kraus [@vMarkus_K](https://twitter.com/vMarkus_K)

Project WebSite: [mycloudrevolution.com](http://mycloudrevolution.com/projekte/storeonce-powershell-module/)

Project Documentation: [Read the Docs](http://storeonce-psmodule.readthedocs.io/en/latest/index.html)

Project Details:

This module leverages the HPE StoreOnce REST API with PowerShell.
This first cmdlets will be for reporting purposes and after that some basic administrative cmdlets should be added.


+ Create Stores
+ Change Permissions
+ Delete Stores
+ etc.

<a name="Contribute">
# Contribute
[*Back to top*](#Title)

* Request access to the project Slack Channel (https://mycloudrevolution.slack.com/messages/storeonce-ps/)

Request form: http://mycloudrevolution.com/projekte/storeonce-powershell-module/
Or contact me via any other channel...

<a name="Features">
# Features
[*Back to top*](#Title)

## Connect-SOAppliance

Connect to a StoreOnce Appliance and generate a connection object with Servername, Token etc.

![Connect-SOAppliance](/Media/Connect-SOAppliance.png)

## Get-SOAppliance

Lists all connected StoreOnce Appliannce(s).

![Get-SOAppliance](/Media/Get-SOAppliance.png)

## Get-SOSIDs

Lists all ServiceSets from your StoreOnce system(s).

![Get-SOSIDs](/Media/Get-SOSIDs.png)

## Get-SOCatStores

Lists all Catalyst Stores from your StoreOnce system(s).

![Get-SOCatStores](/Media/Get-SOCatStores.png)

## Get-SONasShares

Lists all NAS Stores from your StoreOnce system(s).

![Get-SONasShares](/Media/Get-SONasShares.png)

## Get-SOCatClients

Lists all Catalyst Clients from your StoreOnce system(s).

![Get-SOCatClients](/Media/Get-SOCatClients.png)

## Get-SOCatStoreAccess

Lists Clients with Access Permissions of a Catalyst Store.

![Get-SOCatStoreAccess](/Media/Get-SOCatStoreAccess.png)

## New-SOCatStore

Creates a single StoreOnce Catalyst store with default options on a given Service Set on your StoreOnce system.

![New-SOCatStore](/Media/New-SOCatStore.png)

## New-SOCatClient

Creates a StoreOnce Catalyst Client on all Service Sets on your StoreOnce system.

![New-SOCatClient](/Media/New-SOCatClient.png)

## Set-SOCatStoreAccess

Permit or deny Client access to a StoreOnce Catalyst Store.

![Set-SOCatStoreAccess](/Media/Set-SOCatStoreAccess.png)

## Remove-SOCatStore

Remove a single StoreOnce Catalyst store on a given Service Set on your StoreOnce system.

![Remove-SOCatStore](/Media/Remove-SOCatStore.png)

## Remove-SOCatClient

Remove a single StoreOnce Catalyst store on a given Service Set on your StoreOnce system.

![Remove-SOCatClient](/Media/Remove-SOCatClient.png)

<a name="Enhancements">
# Enhancements
[*Back to top*](#Title)

Version 2.0
+ New: New Connection process
+ New: Remove-SOCatClient
+ New: Remove-SOCatStore

Version 1.1
+ New: IP Connection Test before REST Calls

Version 1.0
+ Enhanced: Module restructuring. Each Function has now its own psm1

Version 0.9
+ New: Permit or deny Client access to a StoreOnce Catalyst Store
+ Fix: Parameter Positions

Version 0.8
+ New: Creates a StoreOnce Catalyst client

Version 0.7
+ New: Creates a StoreOnce Catalyst store
+ Enhanced: More details for Get-SOCatStores

Version 0.6
+ Enhanced: Parameter Position declaration 
+ Enhanced: Output Reorganization

Version 0.5.2
+ Enhanced: New Cert Handling 
+ Enhanced: Cmdlet Set-SOCredentials rewritten

Version 0.5.1
+ Enhanced: Optional Credential verification for Set-SOCredentials Commandlet

Version 0.5
+ New: Get Clients (Users) with Access Permissions of a Catalyst Store

Version 0.4.1
+ Enhanced: Added ID not NAS and Catalyst

Version 0.4
+ New: Get StoreOnce Catalyst Clients (User)

Version 0.3
+ New: Get StoreOnce NAS Shares
+ Renamed StoreOnce Catalyst Stores Commandlet
+ Enhanced: Added Synopsis to Functions

Version 0.2.1
+ Fixed: Issue #4 - Secure Password Input

Version 0.2
+ New: Get StoreOnce Catalyst Stores

Version 0.1
+ New: Credential Handling for REST Calls
+ New: Get StoreOnce SIDs

