<cfcomponent displayname="ConfigDAO" hint="table ID column = ">

<!--- Local Variables --->
<cfset VARIABLES.dsn 		= REQUEST.DSN>
<cfset CacheTime 			= CreateTimeSpan(0, 0, 0, 1)>

<!--------------------------------------------------------------------------------------------
	Init - Config Constructor

	Entry Conditions:
		DSN			- datasource name
---------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="ConfigDAO">
		<cfargument name="dsn" type="string" required="true">
		<cfset variables.dsn = arguments.dsn>
		<cfreturn this>
	</cffunction>

<!--------------------------------------------------------------------------------------------
	getVariablesScope - Return variable Scope

	Entry Conditions:
		None
---------------------------------------------------------------------------------------------->
	<cffunction name="getVariablesScope" access="public" output="false" returntype="struct">
      <cfreturn variables />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	SetProfile - Set Profile Value (equivalent function)
	Modifications
		06/3/12 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="SetProfile" returntype="Numeric" output="True">
		<cfargument name="AccountID" 		type="numeric"		required="yes" 			Default="#SESSION.AccountID#">
		<cfargument name="ClubID" 			type="numeric"		required="yes" 			Default="#SESSION.ClubID#">
		<cfargument name="UserID" 			type="numeric"		required="yes" 			Default="#SESSION.UserID#">

		<cfargument name="Section" 			type="string"		required="yes">
		<cfargument name="Item" 			type="string"		required="yes">
		<cfargument name="Value" 			type="string"		required="yes">
		<cfargument name="Log" 				type="string"		required="yes"			Default="TRUE">

		<cfset var qSet = "" />

		<cfif exists(ARGUMENTS.AccountID, ARGUMENTS.ClubID, ARGUMENTS.UserID,ARGUMENTS.Section, ARGUMENTS.Item, ARGUMENTS.Value, ARGUMENTS.AccountID)>
			<cfset pkID = update(ARGUMENTS.AccountID, ARGUMENTS.ClubID, ARGUMENTS.UserID, ARGUMENTS.Section, ARGUMENTS.Item, ARGUMENTS.Value, ARGUMENTS.Log) />
		<cfelse>
			<cfset pkID = create(ARGUMENTS.AccountID, ARGUMENTS.ClubID, ARGUMENTS.UserID, ARGUMENTS.Section, ARGUMENTS.Item, ARGUMENTS.Value, ARGUMENTS.Log) />
		</cfif>

		<cfreturn pkID>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	GetProfile - Get Profile Value (equivalent function)
	Modifications
		06/3/12 - created

	Notes:   ClubID | EventID, Order of Lookup:
		AccountID, ClubID, UserID
		AccountID, 	    0, UserID
		AccountID, ClubID,      0
				0, ClubID, UserID
		AccountID,      0,      0
		        0,      0,      0

---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="GetProfile" returntype="String" output="No">
		<cfargument name="AccountID" 		type="numeric"		required="yes" 			Default="#SESSION.AccountID#">
		<cfargument name="ClubID" 			type="numeric"		required="yes" 			Default="#SESSION.ClubID#">
		<cfargument name="UserID" 			type="numeric"		required="yes" 			Default="#SESSION.UserID#">

		<cfargument name="Section" 			type="string"		required="yes">
		<cfargument name="Item" 			type="string"		required="yes">

		<cfset var qGet 	= "" />
		<cfset var Valaue 	= "" />

		<!---
			User config - try first with the ClubID
		 --->
		<cfif ARGUMENTS.UserID GT 0>
			<cfquery name="qGet" datasource="#variables.dsn#" maxrows="1">
				SELECT 		Value
				FROM		tblConfig
				WHERE		1 = 1
				AND			tblConfig.AccountID 	= <CFQUERYPARAM Value="#ARGUMENTS.AccountID#" 	CFSQLTYPE="CF_SQL_INTEGER">
				AND			tblConfig.ClubID	 	= <CFQUERYPARAM Value="#ARGUMENTS.ClubID#" 		CFSQLTYPE="CF_SQL_INTEGER">
				AND			tblConfig.UserID 		= <CFQUERYPARAM Value="#ARGUMENTS.UserID#" 		CFSQLTYPE="CF_SQL_INTEGER">
				AND			tblConfig.Section 		= <CFQUERYPARAM Value="#ARGUMENTS.Section#" 	CFSQLTYPE="CF_SQL_VARCHAR">
				AND			tblConfig.Item 			= <CFQUERYPARAM Value="#ARGUMENTS.Item#" 		CFSQLTYPE="CF_SQL_VARCHAR">
			</cfquery>
			<cfif QGet.Recordcount EQ 1>
				<cfreturn Duplicate(qGet.Value)>
			</cfif>

			<!---
				Account-level with User-Specific config - try now without the ClubID
			 --->
			<cfquery name="qGet" datasource="#variables.dsn#" maxrows="1">
				SELECT 		Value
				FROM		tblConfig
				WHERE		1 = 1
				AND			tblConfig.AccountID 	= <CFQUERYPARAM Value="#ARGUMENTS.AccountID#" 	CFSQLTYPE="CF_SQL_INTEGER">
				AND			tblConfig.ClubID	 	= 0
				AND			tblConfig.UserID 		= <CFQUERYPARAM Value="#ARGUMENTS.UserID#" 		CFSQLTYPE="CF_SQL_INTEGER">
				AND			tblConfig.Section 		= <CFQUERYPARAM Value="#ARGUMENTS.Section#" 	CFSQLTYPE="CF_SQL_VARCHAR">
				AND			tblConfig.Item 			= <CFQUERYPARAM Value="#ARGUMENTS.Item#" 		CFSQLTYPE="CF_SQL_VARCHAR">
			</cfquery>
			<cfif QGet.Recordcount EQ 1>
				<cfreturn Duplicate(qGet.Value)>
			</cfif>
		</cfif>

		<!---
			Club/Event config?  Events use the ClubID parameter
		 --->
		<cfif ARGUMENTS.ClubID GT 0>
			<cfquery name="qGet" datasource="#variables.dsn#" maxrows="1">

				SELECT 		Value
				FROM		tblConfig
				WHERE		1 = 1
				AND			tblConfig.AccountID 	= <CFQUERYPARAM Value="#ARGUMENTS.AccountID#" 	CFSQLTYPE="CF_SQL_INTEGER">
				AND			tblConfig.ClubID	 	= <CFQUERYPARAM Value="#ARGUMENTS.ClubID#" 		CFSQLTYPE="CF_SQL_INTEGER">
				AND			tblConfig.UserID 		= 0
				AND			tblConfig.Section 		= <CFQUERYPARAM Value="#ARGUMENTS.Section#" 	CFSQLTYPE="CF_SQL_VARCHAR">
				AND			tblConfig.Item 			= <CFQUERYPARAM Value="#ARGUMENTS.Item#" 		CFSQLTYPE="CF_SQL_VARCHAR">
			</cfquery>
			<cfif QGet.Recordcount EQ 1>
				<cfreturn Duplicate(qGet.Value)>
			</cfif>

				<!--- Check the Event Configuration --->
			<cfquery name="qGet" datasource="#variables.dsn#" maxrows="1">
				SELECT 		Value
				FROM		tblConfig
				WHERE		1 = 1
				AND			tblConfig.AccountID 	= 0
				AND			tblConfig.ClubID	 	= <CFQUERYPARAM Value="#ARGUMENTS.ClubID#" 		CFSQLTYPE="CF_SQL_INTEGER">
				AND			tblConfig.UserID 		= <CFQUERYPARAM Value="#ARGUMENTS.UserID#" 		CFSQLTYPE="CF_SQL_INTEGER">
				AND			tblConfig.Section 		= <CFQUERYPARAM Value="#ARGUMENTS.Section#" 	CFSQLTYPE="CF_SQL_VARCHAR">
				AND			tblConfig.Item 			= <CFQUERYPARAM Value="#ARGUMENTS.Item#" 		CFSQLTYPE="CF_SQL_VARCHAR">
			</cfquery>
			<cfif QGet.Recordcount EQ 1>
				<cfreturn Duplicate(qGet.Value)>
			</cfif>
			<!---
				See if there is a match default value for the Profile/Section/Item (e.g, ClubID could be a specific "section", so check for club
			<cfquery name="qGet" datasource="#variables.dsn#" maxrows="1">
				SELECT 		DefaultValue
				FROM		tblConfigMaster
				WHERE		1 = 1
				AND			tblConfigMaster.AccountID 	= <CFQUERYPARAM Value="#ARGUMENTS.AccountID#" 	CFSQLTYPE="CF_SQL_INTEGER">
				AND			tblConfigMaster.ClubID	 	= <CFQUERYPARAM Value="#ARGUMENTS.ClubID#" 		CFSQLTYPE="CF_SQL_INTEGER">
				AND			tblConfigMaster.Section 	= <CFQUERYPARAM Value="#ARGUMENTS.Section#" 	CFSQLTYPE="CF_SQL_VARCHAR">
				AND			tblConfigMaster.Item 		= <CFQUERYPARAM Value="#ARGUMENTS.Item#" 		CFSQLTYPE="CF_SQL_VARCHAR">
			</cfquery>
			<cfif QGet.Recordcount EQ 1>
				<cfreturn Duplicate(qGet.DefaultValue)>
			</cfif>
			 --->
		</cfif>

		<!---
			Account config?
		 --->
		<cfif ARGUMENTS.AccountID GT 0>
			<cfquery name="qGet" datasource="#variables.dsn#" maxrows="1">
				SELECT 		Value
				FROM		tblConfig
				WHERE		1 = 1
				AND			tblConfig.AccountID 	= <CFQUERYPARAM Value="#ARGUMENTS.AccountID#" 	CFSQLTYPE="CF_SQL_INTEGER">
				AND			tblConfig.ClubID	 	= 0
				AND			tblConfig.UserID 		= 0
				AND			tblConfig.Section 		= <CFQUERYPARAM Value="#ARGUMENTS.Section#" 	CFSQLTYPE="CF_SQL_VARCHAR">
				AND			tblConfig.Item 			= <CFQUERYPARAM Value="#ARGUMENTS.Item#" 		CFSQLTYPE="CF_SQL_VARCHAR">
			</cfquery>
			<cfif QGet.Recordcount EQ 1>
				<cfreturn Duplicate(qGet.Value)>
			</cfif>
		</cfif>

		<!---
			See if there is a match default match for 0,0,0,
		 --->
		<cfquery name="qGet" datasource="#variables.dsn#" maxrows="1">
			SELECT 		Value
			FROM		tblConfig
			WHERE		1 = 1
			AND			tblConfig.AccountID 	= 0
			AND			tblConfig.ClubID	 	= 0
			AND			tblConfig.UserID 		= 0
			AND			tblConfig.Section 		= <CFQUERYPARAM Value="#ARGUMENTS.Section#" 	CFSQLTYPE="CF_SQL_VARCHAR">
			AND			tblConfig.Item 			= <CFQUERYPARAM Value="#ARGUMENTS.Item#" 		CFSQLTYPE="CF_SQL_VARCHAR">
		</cfquery>
		<cfreturn Duplicate(qGet.Value)>

<!--- Removed 9/17/14
		<!---
			Otherwise try the Master File (should depreciate this use)
		 --->
		<cfquery name="qGet" datasource="#variables.dsn#" maxrows="1">
			SELECT 		DefaultValue
			FROM		tblConfigMaster
			WHERE		1 = 1
			AND			tblConfigMaster.AccountID 	= <CFQUERYPARAM Value="#ARGUMENTS.AccountID#" 	CFSQLTYPE="CF_SQL_INTEGER">
			AND			tblConfigMaster.ClubID	 	= 0
			AND			tblConfigMaster.Section 	= <CFQUERYPARAM Value="#ARGUMENTS.Section#" 	CFSQLTYPE="CF_SQL_VARCHAR">
			AND			tblConfigMaster.Item 		= <CFQUERYPARAM Value="#ARGUMENTS.Item#" 		CFSQLTYPE="CF_SQL_VARCHAR">
		</cfquery>
		<cfif QGet.Recordcount EQ 1>
			<cfreturn Duplicate(qGet.DefaultValue)>
		</cfif>

		<!---
			See if there is a match "generic" default value for ALL Accounts
		 --->
		<cfquery name="qGet" datasource="#variables.dsn#" maxrows="1">
			SELECT 		DefaultValue
			FROM		tblConfigMaster
			WHERE		1 = 1
			AND			tblConfigMaster.AccountID 	= 0
			AND			tblConfigMaster.Section 	= <CFQUERYPARAM Value="#ARGUMENTS.Section#" 	CFSQLTYPE="CF_SQL_VARCHAR">
			AND			tblConfigMaster.Item 		= <CFQUERYPARAM Value="#ARGUMENTS.Item#" 		CFSQLTYPE="CF_SQL_VARCHAR">
		</cfquery>
		<cfreturn Duplicate(qGet.DefaultValue)>		<!--- Return blank if no match at this point --->
 --->
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Lookup - Config
	Modifications
		6/3/2012 - created, used by clone
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Lookup" access="public" output="false" returntype="Query" DisplayName="Lookup Config">
		<cfargument name="ConfigItemID"				Type="numeric" 		Required="Yes"	Hint="ConfigItemID">

		<cfset var qLookup = "" />
		<cfquery name="qLookup" datasource="#variables.dsn#">
			SELECT
				tblConfig.ConfigItemID,
				tblConfig.AccountID,
				tblConfig.ClubID,
				tblConfig.UserID,
				tblConfig.Section,
				tblConfig.Item,
				tblConfig.Value,
				tblConfig.Created_By,
				tblConfig.Created_Tmstmp,
				tblConfig.Modified_By,
				tblConfig.Modified_Tmstmp

			FROM		tblConfig
			WHERE 		1 = 1
			AND			tblConfig.ConfigItemID = <CFQUERYPARAM Value="#ARGUMENTS.ConfigItemID#" CFSQLTYPE="CF_SQL_INTEGER">

			<cfswitch expression="#ARGUMENTS.SortBy#">
				<cfcase value="AccountID">ORDER BY 	tblConfig.AccountID </cfcase>
			</cfswitch>

		</cfquery>
		<cfreturn qLookup>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	View - Config
	Modifications
		6/3/2012 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="View" access="public" output="false" returntype="Query" DisplayName="View Config">
		<cfargument name="AccountID" 		type="numeric"		required="yes" 			Default="#SESSION.AccountID#">
		<cfargument name="ClubID" 			type="numeric"		required="yes" 			Default="#SESSION.ClubID#">
		<cfargument name="UserID" 			type="numeric"		required="yes" 			Default="#SESSION.UserID#">
		<cfargument Name="SortBy" 	   		type="String"  		required="No" 			Default="AccountID">

		<cfset var qView = "" />
		<cfquery name="qView" datasource="#variables.dsn#">
			SELECT
				tblConfig.ConfigItemID,
				tblConfig.AccountID,
				tblConfig.ClubID,
				tblConfig.UserID,
				tblConfig.Section,
				tblConfig.Item,
				tblConfig.Value,
				tblUser_1.UserName AS Created_By,
					tblConfig.Created_Tmstmp,
				tblUser_2.UserName AS Modified_By,
					tblConfig.Modified_Tmstmp

			FROM	tblConfig
			LEFT OUTER JOIN	tblUser AS tblUser_1 ON tblConfig.Created_By = tblUser_1.UserID
			LEFT OUTER JOIN tblUser AS tblUser_2 ON tblConfig.Modified_By = tblUser_2.UserID

			WHERE 		1 = 1
			AND		tblConfig.AccountID = <CFQUERYPARAM Value="#ARGUMENTS.AccountID#" CFSQLTYPE="CF_SQL_INTEGER">

			<cfswitch expression="#ARGUMENTS.SortBy#">
				<cfcase value="AccountID">ORDER BY 	tblConfig.AccountID </cfcase>
			</cfswitch>

		</cfquery>
		<cfreturn qView>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	List - Config
	Modifications
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="List" access="public" output="false" returntype="Query" DisplayName="List Config">
		<cfargument name="ConfigItemID"		Type="numeric" 		Required="No"			Default="0">
		<cfargument name="AccountID" 		type="numeric"		required="yes" 			Default="#SESSION.AccountID#">
		<cfargument name="ClubID" 			type="numeric"		required="yes" 			Default="#SESSION.ClubID#">
		<cfargument name="UserID" 			type="numeric"		required="yes" 			Default="#SESSION.UserID#">
		<cfargument Name="SortBy" 	   		type="String"  		required="No" 			Default="AccountID">

		<cfset var qList = "" />
		<cfquery name="qList" datasource="#variables.dsn#">
			SELECT
				tblConfig.ConfigItemID,
				tblConfig.AccountID,
				tblConfig.ClubID,
				tblConfig.UserID,
				tblConfig.Section,
				tblConfig.Item,
				tblConfig.Value,
				tblConfig.Created_By,
				tblConfig.Created_Tmstmp,
				tblConfig.Modified_By,
				tblConfig.Modified_Tmstmp

			FROM	tblConfig
			WHERE 	1 = 1
			AND		tblConfig.AccountID = <CFQUERYPARAM Value="#ARGUMENTS.AccountID#" CFSQLTYPE="CF_SQL_INTEGER">

			<cfif ARGUMENTS.ConfigItemID GT 0>
				AND 	tblConfig.ConfigItemID = <CFQUERYPARAM Value="#ARGUMENTS.ConfigItemID#" CFSQLTYPE="cf_sql_integer">
			</cfif>

			<cfswitch expression="#ARGUMENTS.SortBy#">
				<cfcase value="AccountID">ORDER BY 	tblConfig.AccountID </cfcase>
			</cfswitch>

		</cfquery>
		<cfreturn qList>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Save - Config
	Modifications
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Save" access="public" output="false" returntype="numeric" DisplayName="Save Config">
		<cfargument name="Config" type="Config" required="true" />

		<cfset var pkID = 0 />		<!--- 0=false --->
		<cfif exists(arguments.Config)>
			<cfset pkID = update(arguments.Config) />
		<cfelse>
			<cfset pkID = create(arguments.Config) />
		</cfif>

		<cfreturn Duplicate(pkID) />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Exists - Config Item Exist?
	Modifications
		6/3/2012 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Exists" access="public" output="false" returntype="boolean" DisplayName="Exists Config">
		<cfargument name="AccountID" 		type="numeric"		required="yes" 			Default="#SESSION.AccountID#">
		<cfargument name="ClubID" 			type="numeric"		required="yes" 			Default="#SESSION.ClubID#">
		<cfargument name="UserID" 			type="numeric"		required="yes" 			Default="#SESSION.UserID#">

		<cfargument name="Section" 			type="string"		required="yes">
		<cfargument name="Item" 			type="string"		required="yes">

		<cfset var qExists = "">
		<cfquery name="qExists" datasource="#variables.dsn#" maxrows="1">
			SELECT 		count(1) as idexists
			FROM		tblConfig
			WHERE		1 = 1
			AND			tblConfig.AccountID 	= <CFQUERYPARAM Value="#ARGUMENTS.AccountID#" 	CFSQLTYPE="CF_SQL_INTEGER">
			AND			tblConfig.ClubID	 	= <CFQUERYPARAM Value="#ARGUMENTS.ClubID#" 		CFSQLTYPE="CF_SQL_INTEGER">
			AND			tblConfig.UserID	 	= <CFQUERYPARAM Value="#ARGUMENTS.UserID#" 		CFSQLTYPE="CF_SQL_INTEGER">
			AND			tblConfig.Section 		= <CFQUERYPARAM Value="#ARGUMENTS.Section#" 	CFSQLTYPE="CF_SQL_VARCHAR">
			AND			tblConfig.Item 			= <CFQUERYPARAM Value="#ARGUMENTS.Item#" 		CFSQLTYPE="CF_SQL_VARCHAR">
		</cfquery>

		<cfif qExists.idexists>
			<cfreturn TRUE />
		<cfelse>
			<cfreturn FALSE />
		</cfif>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Create - Config
	Modifications
		6/3/2012 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Create" access="public" output="false" returntype="numeric" DisplayName="Create Config">
		<cfargument name="AccountID" 		type="numeric"		required="yes" 			Default="#SESSION.AccountID#">
		<cfargument name="ClubID" 			type="numeric"		required="yes" 			Default="#SESSION.ClubID#">
		<cfargument name="UserID" 			type="numeric"		required="yes" 			Default="#SESSION.UserID#">

		<cfargument name="Section" 			type="string"		required="yes">
		<cfargument name="Item" 			type="string"		required="yes">
		<cfargument name="Value" 			type="string"		required="yes">
		<cfargument name="Log" 				type="string"		required="yes"			Default="TRUE">

		<cfset var qCreate = "" />
		<cfset var errMsg 	= "" />

			<cfquery name="qCreate" datasource="#VARIABLES.dsn#" Result="R">
				INSERT INTO tblConfig
					(
					AccountID,
					ClubID,
					UserID,
					Section,
					Item,
					Value,
					Created_By,
					Created_Tmstmp
					)
				VALUES
					(
					<cfqueryparam value="#ARGUMENTS.AccountID#" 			CFSQLType="cf_sql_integer" />,
					<cfqueryparam value="#ARGUMENTS.ClubID#" 				CFSQLType="cf_sql_integer" />,
					<cfqueryparam value="#ARGUMENTS.UserID#" 				CFSQLType="cf_sql_integer" />,
					<cfqueryparam value="#Left(ARGUMENTS.Section,32)#" 		CFSQLType="cf_sql_varchar"  />,
					<cfqueryparam value="#Left(ARGUMENTS.Item,32)#" 		CFSQLType="cf_sql_varchar"  />,
					<cfqueryparam value="#ARGUMENTS.Value#" 				CFSQLType="cf_sql_varchar"  />,
					<cfqueryparam value="#SESSION.UserID#" 					CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#Now()#" 							CFSQLType="CF_SQL_TIMESTAMP" />
					)
			</cfquery>

		<cftry>
			<cfif Log>
				<CF_XLogCart Table="Config" type="I" Value="#ARGUMENTS.AccountID#" Desc="A=#ARGUMENTS.AccountID# C=#ARGUMENTS.ClubID# U=#ARGUMENTS.UserID# #ARGUMENTS.Section# #ARGUMENTS.Item#=[#ARGUMENTS.Value#] created">
			</cfif>
			<cfcatch type="database">
				<CF_XLogCart Table="Config" type="I" Value="0" Desc="Error inserting A=#ARGUMENTS.AccountID# C=#ARGUMENTS.ClubID# U=#ARGUMENTS.UserID# #ARGUMENTS.Section# #ARGUMENTS.Item#=[#ARGUMENTS.Value#](#cfcatch.message#)" >
				<cfreturn 0 />
			</cfcatch>

			</cftry>
		<cfreturn R.IDENTITYCOL />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Update - Config
	Modifications
		6/3/2012 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Update" access="public" output="false" returntype="numeric" DisplayName="Update Config">
		<cfargument name="AccountID" 		type="numeric"		required="yes" 			Default="#SESSION.AccountID#">
		<cfargument name="ClubID" 			type="numeric"		required="yes" 			Default="#SESSION.ClubID#">
		<cfargument name="UserID" 			type="numeric"		required="yes" 			Default="#SESSION.UserID#">

		<cfargument name="Section" 			type="string"		required="yes">
		<cfargument name="Item" 			type="string"		required="yes">
		<cfargument name="Value" 			type="string"		required="yes">
		<cfargument name="Log" 				type="string"		required="yes"			Default="TRUE">

		<cfset var qUpdate   = "" />
		<cfset var errMsg 	= "" />

		<cftry>
			<cfquery name="qUpdate" datasource="#variables.dsn#">
				UPDATE	tblConfig
				SET
					Value 			= <cfqueryparam value="#ARGUMENTS.Value#" 				CFSQLType="cf_sql_varchar"	 />,
					Modified_By 	= <cfqueryparam value="#SESSION.UserID#" 				CFSQLType="cf_sql_integer" />,
					Modified_Tmstmp = <cfqueryparam value="#Now()#" 						CFSQLType="cf_sql_timestamp" />
				WHERE		1 = 1
				AND			tblConfig.AccountID 	= <CFQUERYPARAM Value="#ARGUMENTS.AccountID#" 	CFSQLTYPE="CF_SQL_INTEGER">
				AND			tblConfig.ClubID	 	= <CFQUERYPARAM Value="#ARGUMENTS.ClubID#" 		CFSQLTYPE="CF_SQL_INTEGER">
				AND			tblConfig.UserID	 	= <CFQUERYPARAM Value="#ARGUMENTS.UserID#" 		CFSQLTYPE="CF_SQL_INTEGER">
				AND			tblConfig.Section 		= <CFQUERYPARAM Value="#ARGUMENTS.Section#" 	CFSQLTYPE="CF_SQL_VARCHAR">
				AND			tblConfig.Item 			= <CFQUERYPARAM Value="#ARGUMENTS.Item#" 		CFSQLTYPE="CF_SQL_VARCHAR">
			</cfquery>

			<cfif Log>
				<CF_XLogCart Table="Config" type="U" Value="#ARGUMENTS.AccountID#" Desc="A=#ARGUMENTS.AccountID# C=#ARGUMENTS.ClubID# U=#ARGUMENTS.UserID# #ARGUMENTS.Section#/#ARGUMENTS.Item#=[#ARGUMENTS.Value#] updated">
			</cfif>
			<cfcatch type="database">
				<CF_XLogCart Table="Config" type="U" Value="#ARGUMENTS.AccountID#" Desc="Error updating A=#ARGUMENTS.AccountID# C=#ARGUMENTS.ClubID# U=#ARGUMENTS.UserID# #ARGUMENTS.Section#/#ARGUMENTS.Item#=[#ARGUMENTS.Value#] (#cfcatch.message#)" >
				<cfset errMsg = "Message=#cfcatch.message#<BR>Details=#cfcatch.detail#" />
				<cfreturn 0 />
			</cfcatch>
		</cftry>
		<cfreturn 1 />

	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Delete - Config
	Modifications
		6/3/2012 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Delete" access="public" output="false" returntype="boolean" DisplayName="Delete Config">
		<cfargument name="ConfigItemID" 	required="yes" 		type="numeric">

		<cfset var qDelete = "">
		<cfset var errMsg 	= "" />

		<cftry>
			<cfquery name="qDelete" datasource="#variables.dsn#">
				DELETE
				FROM		tblConfig
				WHERE		tblConfig.ConfigItemID 	= <CFQUERYPARAM Value="#ARGUMENTS.ConfigItemID#" CFSQLTYPE="CF_SQL_INTEGER">
			</cfquery>

			<CF_XLogCart Table="Config" type="D" Value="#ARGUMENTS.ConfigItemID#" Desc="Config Item deleted">
			<cfcatch type="database">
				<CF_XLogCart Table="Config" type="D" Value="#ARGUMENTS.ConfigItemID#" Desc="Error deleting Config Item (#cfcatch.message#)" >
				<cfset errMsg = "Message=#cfcatch.message#<BR>Details=#cfcatch.detail#" />
				<cfreturn FALSE />
			</cfcatch>

		</cftry>
		<cfreturn TRUE />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	DeleteProfile - Config
	Modifications
		6/3/2012 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="DeleteProfile" access="public" output="false" returntype="boolean" DisplayName="Delete Config Profile">
		<cfargument name="AccountID" 		type="numeric"		required="yes" 			Default="#SESSION.AccountID#">
		<cfargument name="ClubID" 			type="numeric"		required="yes" 			Default="#SESSION.ClubID#">
		<cfargument name="UserID" 			type="numeric"		required="yes" 			Default="#SESSION.UserID#">
		<cfargument name="Section" 			type="string"		required="yes">
		<cfargument name="Item" 			type="string"		required="yes">

		<cfset var qDelete = "">
		<cfset var errMsg 	= "" />

		<cftry>
			<cfquery name="qDelete" datasource="#variables.dsn#">
				DELETE
				FROM		tblConfig
				WHERE		1 = 1
				AND			tblConfig.AccountID 	= <CFQUERYPARAM Value="#ARGUMENTS.AccountID#" 	CFSQLTYPE="CF_SQL_INTEGER">
				AND			tblConfig.ClubID	 	= <CFQUERYPARAM Value="#ARGUMENTS.ClubID#" 		CFSQLTYPE="CF_SQL_INTEGER">
				AND			tblConfig.UserID	 	= <CFQUERYPARAM Value="#ARGUMENTS.UserID#" 		CFSQLTYPE="CF_SQL_INTEGER">
				AND			tblConfig.Section 		= <CFQUERYPARAM Value="#ARGUMENTS.Section#" 	CFSQLTYPE="CF_SQL_VARCHAR">
				AND			tblConfig.Item 			= <CFQUERYPARAM Value="#ARGUMENTS.Item#" 		CFSQLTYPE="CF_SQL_VARCHAR">
			</cfquery>

			<CF_XLogCart Table="Config" type="D" Value="#ARGUMENTS.Section#" Desc="Config Item deleted (#ARGUMENTS.AccountID#,#ARGUMENTS.ClubID#,#ARGUMENTS.UserID#) [#ARGUMENTS.Item#]">
			<cfcatch type="database">
				<CF_XLogCart Table="Config" type="D" Value="#ARGUMENTS.ConfigItemID#" Desc="Error deleting Config Item (#cfcatch.message#)" >
				<cfset errMsg = "Message=#cfcatch.message#<BR>Details=#cfcatch.detail#" />
				<cfreturn FALSE />
			</cfcatch>

		</cftry>
		<cfreturn TRUE />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Clone - Config
	Modifications
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Clone" access="public" output="true" returntype="numeric" DisplayName="Clone Config">
		<cfargument name="Config" type="Config" required="true" />

		<cfset var Q 		= "" />
		<cfset var ConfigObj  = "" />

		<cfset Q = Lookup( ConfigID=ARGUMENTS.Config, UseCustom="N"  ) />
		<cfinvoke component="Config" method="init" returnvariable="ConfigObj">
			<cfinvokeargument name="ConfigItemID"			Value="#Q.ConfigItemID#" />
			<cfinvokeargument name="AccountID"				Value="#Q.AccountID#" />
			<cfinvokeargument name="ClubID"					Value="#Q.ClubID#" />
			<cfinvokeargument name="UserID"					Value="#Q.UserID#" />
			<cfinvokeargument name="Section"				Value="#Q.Section#" />
			<cfinvokeargument name="Item"					Value="#Q.Item#" />
			<cfinvokeargument name="Value"					Value="#Q.Value#" />
		</cfinvoke>
		<cfset CloneID = Create( ConfigObj, "Y" ) />

		<cfreturn Duplicate(CloneID) />
	</cffunction>

</cfcomponent>
