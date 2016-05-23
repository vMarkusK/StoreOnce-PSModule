<a name="Title">
# Title

HPE StoreOnce PS Module

|Navigation|
|-----------------|
|[About](#About)|
|[Features](#Features)|
|[Enhancements](#Enhancements)|


<a name="About">
# About
[*Back to top*](#Title)

Project Owner: Markus Kraus


<a name="Features">
# Features
[*Back to top*](#Title)

* Set-SOCredentials

Creates a Base64 hash for further requests against your StoreOnce system(s).
This should be the first Commandlet you use from this module.

* Get-SOSIDs

Lists all ServiceSets from your StoreOnce system(s).

Outputs: ArrayIP,SSID,Name,Alias,OverallHealth,SerialNumber,Capacity(GB).Free(GB),UserData(GB),DiskData(GB)

* Get-SOCatStores

Lists all Catalyst Stores from your StoreOnce system(s).

Outputs: ArrayIP,SSID,Name,ID,SizeOnDisk(GB),UserDataStored(GB),DedupeRatio

* Get-SONasShares

Lists all NAS Stores from your StoreOnce system(s).

Outputs: ArrayIP,SSID,Name,ID,AccessProtocol,SizeOnDisk(GB),UserDataStored(GB),DedupeRatio

* Get-SOCatClients

Lists all Catalyst Clients from your StoreOnce system(s).

Outputs: ArrayIP,SSID,Name,ID,Description,canCreateStores,canSetServerProperties,canManageClientPermissions

* Get-SOCatStoreAccess

Lists Clients with Access Permissions of a Catalyst Store.

Outputs: Client,allowAccess

<a name="Enhancements">
# Enhancements
[*Back to top*](#Title)

Version 0.5.1
+ Enhanced: Optional Credential verification for Set-SOCredentials Commandlet

Version 0.5
+ Get Clients (Users) with Access Permissions of a Catalyst Store

Version 0.4.1
+ Enhanced: Added ID not NAS and Catalyst

Version 0.4
+ Get StoreOnce Catalyst Clients (User)

Version 0.3
+ Get StoreOnce NAS Shares
+ Renamed StoreOnce Catalyst Stores Commandlet
+ Enhanced: Added Synopsis to Functions

Version 0.2.1
+ Fixed: Issue #4 - Secure Password Input

Version 0.2
+ Get StoreOnce Catalyst Stores

Version 0.1
+ Credential Handling for REST Calls
+ Get StoreOnce SIDs

