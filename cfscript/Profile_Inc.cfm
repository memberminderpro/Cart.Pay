<!--- ----------------------------------------------------------------------------------------------------------------
	Profile_Inc. - rofile Value (equivalent function)
	Modifications
		06/3/2012 - created
		08/02/2016 - Updated to be an optional include
---------------------------------------------------------------------------------------------------------------------->

<cffunction name="SetProfile" returntype="numeric" output="No">
	<cfargument name="AccountID" 	required="yes" 		type="numeric"	Default="#SESSION.AccountID#">
	<cfargument name="ClubID" 		required="yes" 		type="numeric"	Default="#SESSION.ClubID#">
	<cfargument name="UserID" 		required="yes" 		type="numeric"	Default="0">
	<cfargument name="Section" 		required="yes" 		type="string">
	<cfargument name="Item" 		required="yes" 		type="string">
	<cfargument name="Value" 		required="yes" 		type="string">
	<cfargument name="Log" 			required="yes" 		type="boolean"	Default="TRUE">

	<cfset var rc = "">
	<cfset rc = createObject("component", "#APPLICATION.DIR#CFC\ConfigDAO").SetProfile(ARGUMENTS.AccountID, ARGUMENTS.ClubID, ARGUMENTS.UserID, ARGUMENTS.Section, ARGUMENTS.Item, ARGUMENTS.Value, ARGUMENTS.Log)>
	<cfreturn rc>
</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	GetProfile - Get Profile Value (equivalent function)
	Modifications
		06/3/12 - created
---------------------------------------------------------------------------------------------------------------------->
<cffunction name="GetProfile" returntype="String" output="No">
	<cfargument name="AccountID" 	required="yes" 		type="numeric"	Default="#SESSION.AccountID#">
	<cfargument name="ClubID" 		required="yes" 		type="numeric"	Default="#SESSION.ClubID#">
	<cfargument name="UserID" 		required="yes" 		type="numeric"	Default="0">
	<cfargument name="Section" 		required="yes" 		type="string">
	<cfargument name="Item" 		required="yes" 		type="string">

	<cfset var Value = "">
	<cfset Value = createObject("component", "#APPLICATION.DIR#CFC\ConfigDAO").GetProfile(ARGUMENTS.AccountID, ARGUMENTS.ClubID, ARGUMENTS.UserID, ARGUMENTS.Section, ARGUMENTS.Item)>
	<cfreturn Value>
</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	DeleteProfile - Delete Profile Value (equivalent function)
	Modifications
		06/3/12 - created
---------------------------------------------------------------------------------------------------------------------->
<cffunction name="DeleteProfile" returntype="String" output="No">
	<cfargument name="AccountID" 	required="yes" 		type="numeric"	Default="#SESSION.AccountID#">
	<cfargument name="ClubID" 		required="yes" 		type="numeric"	Default="#SESSION.ClubID#">
	<cfargument name="UserID" 		required="yes" 		type="numeric"	Default="0">
	<cfargument name="Section" 		required="yes" 		type="string">
	<cfargument name="Item" 		required="yes" 		type="string">

	<cfset Value = createObject("component", "#APPLICATION.DIR#CFC\ConfigDAO").DeleteProfile(ARGUMENTS.AccountID, ARGUMENTS.ClubID, ARGUMENTS.UserID, ARGUMENTS.Section, ARGUMENTS.Item)>

	<cfreturn Value>
</cffunction>
