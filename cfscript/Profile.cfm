<!--- ----------------------------------------------------------------------------------------------------------------
	SetProfile - Set Profile Value (equivalent function)
	Modifications
		06/3/12 - created
---------------------------------------------------------------------------------------------------------------------->

<cfparam name="bLoadProfile" 	default="TRUE">

<cfif bLoadProfile>
	<cfinclude template="Profile_Inc.cfm">
	<cfset bLoadProfile = FALSE>
</cfif>