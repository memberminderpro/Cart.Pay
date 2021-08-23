<!--------------------------------------------------------------------------------------------
	CCLogDAO.cfc

	* $Revision: $
	* $Date: 1/31/2021 $
---------------------------------------------------------------------------------------------->

<cfcomponent displayname="CCLogDAO" output="false">

<!--- Local Variables --->
<cfset VARIABLES.dsn 		= REQUEST.DSN>

<!--------------------------------------------------------------------------------------------
	Init - CCLog Constructor

	Entry Conditions:
		DSN			- datasource name
---------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="CCLog">
		<cfargument name="dsn" type="string" required="true">
		<cfset variables.dsn = ARGUMENTS.dsn>
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
	InsertRec -  CCLog
	Modifications
		1/31/2021 - created

	<cfinvoke component="\cfc\CCLogDAO" method="InsertRec" returnvariable="CClogID">
		<cfinvokeargument name="UserID"			Value="#FORM.UserID#">
		<cfinvokeargument name="LastName"		Value="#FORM.LastName#">
		<cfinvokeargument name="FirstName"		Value="#FORM.FirstName#">
		<cfinvokeargument name="MidName"		Value="#FORM.MidName#">
		<cfinvokeargument name="AccountID"		Value="#FORM.AccountID#">
		<cfinvokeargument name="ClubID"			Value="#FORM.ClubID#">
		<cfinvokeargument name="Email"			Value="#FORM.Email#">
		<cfinvokeargument name="Address1"		Value="#FORM.Address1#">
		<cfinvokeargument name="Address2"		Value="#FORM.Address2#">
		<cfinvokeargument name="Address3"		Value="#FORM.Address3#">
		<cfinvokeargument name="City"			Value="#FORM.City#">
		<cfinvokeargument name="StateCode"		Value="#FORM.StateCode#">
		<cfinvokeargument name="ProvOrOther"	Value="#FORM.ProvOrOther#">
		<cfinvokeargument name="PostalZip"		Value="#FORM.PostalZip#">
		<cfinvokeargument name="CountryCode"	Value="#FORM.CountryCode#">
		<cfinvokeargument name="PymtGW"			Value="#FORM.PymtGW#">
		<cfinvokeargument name="Type"			Value="#FORM.Type#">
		<cfinvokeargument name="ID"				Value="#FORM.ID#">
		<cfinvokeargument name="Venue"			Value="#FORM.Venue#">
		<cfinvokeargument name="Amount"			Value="#FORM.Amount#">
		<cfinvokeargument name="HandleFee"		Value="#FORM.HandleFee#">
		<cfinvokeargument name="Comment"		Value="#FORM.Comment#">
	</cfinvoke>

---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="InsertRec" access="public" output="true" returntype="numeric" DisplayName="InsertRec CCLog">
		<cfargument name="UserID"					Type="numeric"		Required="No"		Default="0" />
		<cfargument name="LastName"					Type="string"		Required="No"		Default="" />
		<cfargument name="FirstName"				Type="string"		Required="No"		Default="" />
		<cfargument name="MidName"					Type="string"		Required="Yes"		Default="" />
		<cfargument name="AccountID"				Type="numeric"		Required="No"		Default="0" />
		<cfargument name="ClubID"					Type="numeric"		Required="No"		Default="0" />
		<cfargument name="Email"					Type="string"		Required="No"		Default="" />
		<cfargument name="Address1"					Type="string"		Required="Yes"		Default="" />
		<cfargument name="Address2"					Type="string"		Required="Yes"		Default="" />
		<cfargument name="Address3"					Type="string"		Required="Yes"		Default="" />
		<cfargument name="City"						Type="string"		Required="Yes"		Default="" />
		<cfargument name="StateCode"				Type="string"		Required="Yes"		Default="" />
		<cfargument name="ProvOrOther"				Type="string"		Required="Yes"		Default="" />
		<cfargument name="PostalZip"				Type="string"		Required="Yes"		Default="" />
		<cfargument name="CountryCode"				Type="string"		Required="Yes"		Default="USA" />
		<cfargument name="PymtGW"					Type="string"		Required="No"		Default="" />
		<cfargument name="Type"						Type="string"		Required="No"		Default="" />
		<cfargument name="ID"						Type="numeric"		Required="No"		Default="0" />
		<cfargument name="Venue"					Type="string"		Required="Yes"		Default="" />
		<cfargument name="Amount"					Type="numeric"		Required="No"		Default="0.00" />
		<cfargument name="HandleFee"				Type="numeric"		Required="No"		Default="0.00" />
		<cfargument name="Comment"					Type="string"		Required="Yes"		Default="" />
		<cfargument name="OnErrorContinue"			Type="String"		Required="No"		Default="N" />

		<cfset var qInsert = "" />
		<cfset var R       = "" />

		<cftry>
			<cfquery name="qInsert" datasource="#VARIABLES.dsn#" Result="R">
				INSERT INTO tblCCLog
					(
					tblCCLog.UserID,
					tblCCLog.LastName,
					tblCCLog.FirstName,
					tblCCLog.MidName,
					tblCCLog.AccountID,
					tblCCLog.ClubID,
					tblCCLog.Email,
					tblCCLog.Address1,
					tblCCLog.Address2,
					tblCCLog.Address3,
					tblCCLog.City,
					tblCCLog.StateCode,
					tblCCLog.ProvOrOther,
					tblCCLog.PostalZip,
					tblCCLog.CountryCode,
					tblCCLog.PymtGW,
					tblCCLog.Type,
					tblCCLog.ID,
					tblCCLog.Venue,
					tblCCLog.Amount,
					tblCCLog.HandleFee,
					tblCCLog.Comment,
					tblCCLog.Created_By,
					tblCCLog.Created_Tmstmp
					)
				VALUES
					(
					<cfqueryparam value="#ARGUMENTS.UserID#"					CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#Left(ARGUMENTS.LastName,50)#"			CFSQLType="CF_SQL_VARCHAR" 		null="#not len(ARGUMENTS.LastName)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.FirstName,32)#"		CFSQLType="CF_SQL_VARCHAR" 		null="#not len(ARGUMENTS.FirstName)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.MidName,32)#"			CFSQLType="CF_SQL_VARCHAR" 		null="#not len(ARGUMENTS.MidName)#" />,
					<cfqueryparam value="#ARGUMENTS.AccountID#"					CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#ARGUMENTS.ClubID#"					CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#Left(ARGUMENTS.Email,80)#"			CFSQLType="CF_SQL_VARCHAR" 		null="#not len(ARGUMENTS.Email)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.Address1,50)#"			CFSQLType="CF_SQL_VARCHAR" 		null="#not len(ARGUMENTS.Address1)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.Address2,50)#"			CFSQLType="CF_SQL_VARCHAR" 		null="#not len(ARGUMENTS.Address2)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.Address3,50)#"			CFSQLType="CF_SQL_VARCHAR" 		null="#not len(ARGUMENTS.Address3)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.City,50)#"				CFSQLType="CF_SQL_VARCHAR" 		null="#not len(ARGUMENTS.City)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.StateCode,2)#"			CFSQLType="CF_SQL_CHAR" 		null="#not len(ARGUMENTS.StateCode)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.ProvOrOther,32)#"		CFSQLType="CF_SQL_VARCHAR" 		null="#not len(ARGUMENTS.ProvOrOther)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.PostalZip,12)#"		CFSQLType="CF_SQL_VARCHAR" 		null="#not len(ARGUMENTS.PostalZip)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.CountryCode,3)#"		CFSQLType="CF_SQL_CHAR" 		null="#not len(ARGUMENTS.CountryCode)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.PymtGW,2)#"			CFSQLType="CF_SQL_CHAR" 		null="#not len(ARGUMENTS.PymtGW)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.Type,1)#"				CFSQLType="CF_SQL_CHAR" 		null="#not len(ARGUMENTS.Type)#" />,
					<cfqueryparam value="#ARGUMENTS.ID#"						CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#Left(ARGUMENTS.Venue,255)#"			CFSQLType="CF_SQL_VARCHAR" 		null="#not len(ARGUMENTS.Venue)#" />,
					<cfqueryparam value="#ARGUMENTS.Amount#"					CFSQLType="CF_SQL_MONEY" />,
					<cfqueryparam value="#ARGUMENTS.HandleFee#"					CFSQLType="CF_SQL_MONEY" />,
					<cfqueryparam value="#Left(ARGUMENTS.Comment,255)#"			CFSQLType="CF_SQL_VARCHAR" 		null="#not len(ARGUMENTS.Comment)#" />,
					<cfqueryparam value="#SESSION.UserID#"						CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#Now()#"								CFSQLType="CF_SQL_TIMESTAMP" />
					)
			</cfquery>
			<CF_XLog Table="CCLog" type="I" Value="#R.IDENTITYCOL#" Desc="Insert into CCLog">
			<cfcatch type="database">
				<cfif ARGUMENTS.OnErrorContinue EQ "N">
					<CF_XLog Table="CCLog" type="E" Value="0" Desc="Error inserting CCLog (#cfcatch.detail#)" >
				</cfif>
				<cfreturn 0 />
			</cfcatch>
		</cftry>
		<cfreturn R.IDENTITYCOL />
	</cffunction>


</cfcomponent>