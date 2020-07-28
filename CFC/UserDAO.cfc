<!--------------------------------------------------------------------------------------------
	UserDAO.cfc

	* $Revision: $
	* $Date: 1/4/2020 $

	Notes:
		1-4, 69205+ is in use by DACdb
		so 1000 - < 69205 can be used here for CART only Users
---------------------------------------------------------------------------------------------->

<cfcomponent displayname="UserDAO" output="false">

<!--- Local Variables --->
<cfset VARIABLES.dsn 		= REQUEST.DSN>
<cfset CacheTime 			= CreateTimeSpan(0, 0, 0, 10)>

<!--------------------------------------------------------------------------------------------
	Init - User Constructor

	Entry Conditions:
		DSN			- datasource name
---------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="User">
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

<!--------------------------------------------------------------------------------------------
	GetUserName - Get the name from  User by UserID
	Modifications:
		1/4/2020 $ - created
---------------------------------------------------------------------------------------------->
	<cffunction Name="GetUserName" Access="Public" Output="FALSE" returnType="String" DisplayName="GetUserName">
		<cfargument Name="UserID"		 Type="Numeric"		Required="Yes"		Hint="UserID" >

		<cfset var qGetUserName = "">
		<cfset var strUserName = "">

		<cfquery name="qGetUserName" datasource="#VARIABLES.DSN#">
			SELECT 	UserName
			FROM 	tblUser
			WHERE 	UserID  = <CFQUERYPARAM Value="#ARGUMENTS.UserID#" CFSQLTYPE="CF_SQL_INTEGER">
		</cfquery>
		<cfif qGetUserName.Recordcount GT 0>
			<cfset strUserName = qGetUserName.UserName>
		</cfif>
		<cfreturn strUserName>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Pick - User
	Modifications
		12/18/2019 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Pick" access="public" output="false" returntype="Query" DisplayName="Pick">
		<cfargument Name="AccountID"		Type="Numeric"  	Required="No" 	Hint="AccountID"			Default="#SESSION.AccountID#">
		<cfargument Name="ClubID"			Type="Numeric"  	Required="No" 	Hint="AccountID"			Default="#SESSION.ClubID#">
		<cfargument Name="UserID"			Type="Numeric"  	Required="No" 	Hint="AccountID"			Default="0">
		<cfargument Name="Override"			Type="String"  		Required="No" 	Hint="Override" 			Default="N">
		<cfargument Name="SortBy"			Type="String"  		Required="No" 	Hint="SortBy" 				Default="UserName">

		<cfset var qPick = "" />
		<cfquery name="qPick" datasource="#VARIABLES.dsn#">
			SELECT		dbo.tblUser.UserID, dbo.tblUser.UserName, dbo.tblUser.AccountID, dbo.tblUser.ClubID, dbo.tblClub.ClubName
			FROM		dbo.tblUser
			LEFT OUTER JOIN	dbo.tblClub ON dbo.tblUser.ClubID = dbo.tblClub.ClubID
			WHERE		(1 = 1)
			<cfif ARGUMENTS.AccountID GT 0>
				AND		tblUser.AccountID 	= <CFQUERYPARAM Value="#ARGUMENTS.AccountID#" CFSQLTYPE="CF_SQL_INTEGER">
			</cfif>
			<cfif ARGUMENTS.ClubID GT 0>
				AND		tblUser.ClubID 		= <CFQUERYPARAM Value="#ARGUMENTS.ClubID#" CFSQLTYPE="CF_SQL_INTEGER">
			</cfif>
			<cfif ARGUMENTS.UserID GT 0>
				OR		tblUser.UserID 		= <CFQUERYPARAM Value="#ARGUMENTS.UserID#" CFSQLTYPE="CF_SQL_INTEGER">
			</cfif>
			<cfif ARGUMENTS.Override EQ "N">
				AND		tblUser.dFlag 		= 'N'
			</cfif>
			<cfswitch expression="#ARGUMENTS.SortBy#">
				<cfcase value="UserName">ORDER BY 	tblUser.UserName </cfcase>
			</cfswitch>
		</cfquery>
		<cfreturn qPick>
	</cffunction>


<!--- ----------------------------------------------------------------------------------------------------------------
	Lookup - User
	Modifications
		8/16/2019  - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Lookup" access="public" output="false" returntype="Query" DisplayName="Lookup">
		<cfargument name="UserID"				Type="numeric"	Required="No"	Hint="UserID"			Default="0" />
		<cfargument Name="AccountID"			Type="Numeric"	Required="No"	Hint="AccountID"		Default="#SESSION.AccountID#">
		<cfargument Name="Override"				Type="String"	Required="No" 	Hint="Override"			Default="N">
		<cfargument Name="Filter"				Type="string"	Required="No"	Hint="Filter Value"		Default="">
		<cfargument Name="SortBy"				Type="String"	Required="No"	Hint="SortBy"			Default="UserName">

		<cfset var qLookup = "" />
		<cfquery name="qLookup" datasource="#VARIABLES.DSN#">
			SELECT
				tblUser.UserID,
				tblUser.UserName,
				tblUser.MemberID,
				tblUser.IsRotarian,
				tblUser.dFlag,
				tblUser.AccountID,
				tblUser.ClubID,
				tblUser.LastName,
				tblUser.FirstName,
				tblUser.MidName,
				tblUser.Prefix,
				tblUser.NameSfx,
				tblUser.NickName,
				tblUser.MemberName,
				tblUser.FName,
				tblUser.Private,
				tblUser.PhoneNumber,
				tblUser.Email,
				tblUser.Address1,
				tblUser.Address2,
				tblUser.City,
				tblUser.StateCode,
				tblUser.ProvOrOther,
				tblUser.PostalZip,
				tblUser.CountryCode,
				tblUser.ClubPositionID,
				tblUser.DistrictPositionID,
				tblUser.Notes,
				tblUser.UUID,
				tblUser.IAgree,
				tblUser.Source,
				tblUser.Created_By,
				tblUser.Created_Tmstmp,
				tblUser.Modified_By,
				tblUser.Modified_Tmstmp
				FROM	tblUser
			WHERE 		1 = 1
			<cfif ARGUMENTS.UserID GT 0>
				AND		tblUser.UserID 	= <CFQUERYPARAM Value="#ARGUMENTS.UserID#"	CFSQLTYPE="CF_SQL_INTEGER">
			<cfelse>
				AND		tblUser.AccountID 	= <CFQUERYPARAM Value="#ARGUMENTS.AccountID#" CFSQLTYPE="CF_SQL_INTEGER">
				<cfif ARGUMENTS.Override EQ "N">
					AND	 	tblUser.dFlag 		= 'N'
				</cfif>
				<cfif Len(ARGUMENTS.Filter) GT 0>
					AND		tblUser.UserName	LIKE <CFQUERYPARAM Value="#ARGUMENTS.Filter#%"		CFSQLTYPE="CF_SQL_VARCHAR">
				</cfif>
			</cfif>
			<cfswitch expression="#ARGUMENTS.SortBy#">
				<cfcase value="UserName">ORDER BY 	tblUser.UserName </cfcase>
			</cfswitch>
		</cfquery>
		<cfreturn qLookup>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	LookupRotary - User
	Modifications
		8/16/2019  - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="LookupRotary" access="public" output="false" returntype="Query" DisplayName="LookupRotary">
		<cfargument name="UserID"				Type="numeric"	Required="No"	Hint="UserID"			Default="0" />

		<cfset var qLookup = "" />
		<cfquery name="qLookup" datasource="Rotary">
			SELECT			dbo.tblUser.UserID, dbo.tblUser.UserName, dbo.tblUser.MemberID, dbo.tblUser.dFlag, dbo.tblUser.AccountID, dbo.tblUser.ClubID, dbo.tblUser.LastName, dbo.tblUser.FirstName, dbo.tblUser.MidName, dbo.tblUser.Prefix,
							dbo.tblUser.NameSfx, dbo.tblUser.NickName, dbo.tblUser.MemberName, dbo.tblUser.FName, dbo.tblUser.HomePhone as PhoneNumber, dbo.tblUser.Notes, dbo.tblUser.UUID, dbo.tblUser.Created_By, dbo.tblUser.Created_Tmstmp,
							dbo.tblUser.Modified_By, dbo.tblUser.Modified_Tmstmp, dbo.tblMemberEmail.Email, dbo.tblMemberAddress.Address1, dbo.tblMemberAddress.Address2, dbo.tblMemberAddress.City, dbo.tblMemberAddress.StateCode,
							dbo.tblMemberAddress.ProvOrOther, dbo.tblMemberAddress.PostalZip, dbo.tblMemberAddress.CountryCode
			FROM			dbo.tblUser
			LEFT OUTER JOIN	dbo.tblMemberAddress ON dbo.tblUser.AddressID = dbo.tblMemberAddress.AddressID
			LEFT OUTER JOIN	dbo.tblMemberEmail ON dbo.tblUser.PMailID = dbo.tblMemberEmail.MemberEmailID

			WHERE 	1 = 1
			AND		tblUser.UserID 	= <CFQUERYPARAM Value="#ARGUMENTS.UserID#"	CFSQLTYPE="CF_SQL_INTEGER">
		</cfquery>
		<cfreturn qLookup>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	View -  User
	Modifications
		8/16/2019 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="View" access="public" output="false" returntype="Query" DisplayName="View">
		<cfargument name="UserID"				Type="numeric"	Required="No"	Hint="UserID"			Default="0" />
		<cfargument Name="Override"				Type="String"	Required="No"	Hint="Override"			Default="N">
		<cfargument Name="Filter"				Type="string"	Required="No"	Hint="Filter Value"		Default="">
		<cfargument Name="SortBy"				Type="String"	Required="No"	Hint="SortBy"			Default="UserName">

		<cfset var qView = "" />
		<cfquery name="qView" datasource="#VARIABLES.dsn#">
WITH CTE_User AS (
		SELECT        dbo.tblUser.UserID, dbo.tblUser.UserName, dbo.tblUser.MemberID, dbo.tblUser.IsRotarian, dbo.tblUser.dFlag, dbo.tblUser.AccountID, dbo.tblUser.ClubID, dbo.tblUser.LastName, dbo.tblUser.FirstName, dbo.tblUser.MidName,
		                         dbo.tblUser.Prefix, dbo.tblUser.NameSfx, dbo.tblUser.NickName, dbo.tblUser.MemberName, dbo.tblUser.FName, dbo.tblUser.Private, dbo.tblUser.PhoneNumber, dbo.tblUser.Email, dbo.tblUser.Address1, dbo.tblUser.Address2,
		                         dbo.tblUser.City, dbo.tblUser.StateCode, dbo.tblUser.ProvOrOther, dbo.tblUser.PostalZip, dbo.tblUser.CountryCode, dbo.tblUser.ClubPositionID, dbo.tblUser.DistrictPositionID, dbo.tblUser.Notes, dbo.tblUser.UUID,
		                         dbo.tblUser.IAgree, tblUser_1.UserName AS Created_By, dbo.tblUser.Created_Tmstmp, tblUser_2.UserName AS Modified_By, dbo.tblUser.Modified_Tmstmp, dbo.tblAccount.AccountName, dbo.tblAccount.ZoneID,
		                         dbo.tblClub.ClubName, dbo.tblClub.dFlag AS dFlagClub, dbo.tblClub.ClubNumber, dbo.tblClubPosition.ClubPosition, dbo.tblDistrictPosition.DistrictPosition
		FROM            dbo.tblUser LEFT OUTER JOIN
		                         dbo.tblAccount ON dbo.tblUser.AccountID = dbo.tblAccount.AccountID LEFT OUTER JOIN
		                         dbo.tblClub ON dbo.tblUser.ClubID = dbo.tblClub.ClubID LEFT OUTER JOIN
		                         dbo.tblDistrictPosition ON dbo.tblUser.DistrictPositionID = dbo.tblDistrictPosition.DistrictPositionID LEFT OUTER JOIN
		                         dbo.tblClubPosition ON dbo.tblUser.ClubPositionID = dbo.tblClubPosition.ClubPositionID LEFT OUTER JOIN
		                         dbo.tblUser AS tblUser_1 ON dbo.tblUser.Created_By = tblUser_1.UserID LEFT OUTER JOIN
		                         dbo.tblUser AS tblUser_2 ON dbo.tblUser.Modified_By = tblUser_2.UserID
		WHERE 		1 = 1
		AND		tblUser.UserID 	= <CFQUERYPARAM Value="#ARGUMENTS.UserID#"	CFSQLTYPE="CF_SQL_INTEGER">
		AND		tblUser.Source  = 0

UNION ALL
		SELECT        dbo.tblUser.UserID, dbo.tblUser.UserName, dbo.tblUser.MemberID, dbo.tblUser.IsRotarian, dbo.tblUser.dFlag, dbo.tblUser.AccountID, dbo.tblUser.ClubID, dbo.tblUser.LastName, dbo.tblUser.FirstName, dbo.tblUser.MidName,
		                         dbo.tblUser.Prefix, dbo.tblUser.NameSfx, dbo.tblUser.NickName, dbo.tblUser.MemberName, dbo.tblUser.FName, dbo.tblUser.Private, dbo.tblUser.PhoneNumber, dbo.tblUser.Email,
		                         Rotary.dbo.tblMemberAddress.Address1, Rotary.dbo.tblMemberAddress.Address2, Rotary.dbo.tblMemberAddress.City, Rotary.dbo.tblMemberAddress.StateCode, Rotary.dbo.tblMemberAddress.ProvOrOther, Rotary.dbo.tblMemberAddress.PostalZip, Rotary.dbo.tblMemberAddress.CountryCode,
		                         dbo.tblUser.ClubPositionID, dbo.tblUser.DistrictPositionID, dbo.tblUser.Notes, dbo.tblUser.UUID,
		                         dbo.tblUser.IAgree, tblUser_1.UserName AS Created_By, dbo.tblUser.Created_Tmstmp, tblUser_2.UserName AS Modified_By, dbo.tblUser.Modified_Tmstmp, dbo.tblAccount.AccountName, dbo.tblAccount.ZoneID,
		                         dbo.tblClub.ClubName, dbo.tblClub.dFlag AS dFlagClub, dbo.tblClub.ClubNumber, dbo.tblClubPosition.ClubPosition, dbo.tblDistrictPosition.DistrictPosition
		FROM            dbo.tblUser LEFT OUTER JOIN
		                         Rotary.dbo.tblMemberAddress ON dbo.tblUser.UserID = Rotary.dbo.tblMemberAddress.UserID LEFT OUTER JOIN
		                         dbo.tblAccount ON dbo.tblUser.AccountID = dbo.tblAccount.AccountID LEFT OUTER JOIN
		                         dbo.tblClub ON dbo.tblUser.ClubID = dbo.tblClub.ClubID LEFT OUTER JOIN
		                         dbo.tblDistrictPosition ON dbo.tblUser.DistrictPositionID = dbo.tblDistrictPosition.DistrictPositionID LEFT OUTER JOIN
		                         dbo.tblClubPosition ON dbo.tblUser.ClubPositionID = dbo.tblClubPosition.ClubPositionID LEFT OUTER JOIN
		                         dbo.tblUser AS tblUser_1 ON dbo.tblUser.Created_By = tblUser_1.UserID LEFT OUTER JOIN
		                         dbo.tblUser AS tblUser_2 ON dbo.tblUser.Modified_By = tblUser_2.UserID
		WHERE 		1 = 1
		AND		tblUser.UserID 	= <CFQUERYPARAM Value="#ARGUMENTS.UserID#"	CFSQLTYPE="CF_SQL_INTEGER">
		AND		tblUser.Source  = 1
)
SELECT * FROM CTE_User
			<cfswitch expression="#ARGUMENTS.SortBy#">
				<cfcase value="UserName">	ORDER BY UserName		</cfcase>
			</cfswitch>
		</cfquery>
		<cfreturn qView>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	List -  User Admin -- Return based on RoleID
	Modifications
		8/16/2019 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="List" access="public" output="false" returntype="Query" DisplayName="List">
		<cfargument name="UserID"				Type="numeric"	Required="No"	Hint="UserID"			Default="0" />
		<cfargument Name="Override"				Type="String"	Required="No" 	Hint="Override"			Default="N">
		<cfargument Name="Filter"				Type="String"	Required="No" 	Hint="Filter"			Default="">
		<cfargument Name="SortBy"				Type="String"	Required="No" 	Hint="SortBy"			Default="UserName">

		<cfset var qList = "" />

		<cfquery name="qList" datasource="#VARIABLES.dsn#">
WITH CTE_User AS (
	SELECT        dbo.tblUser.UserID, dbo.tblUser.UserName, dbo.tblUser.MemberID, dbo.tblUser.IsRotarian, dbo.tblUser.dFlag, dbo.tblUser.AccountID, dbo.tblUser.ClubID, dbo.tblUser.LastName, dbo.tblUser.FirstName, dbo.tblUser.MidName,
                   dbo.tblUser.Prefix, dbo.tblUser.NameSfx, dbo.tblUser.NickName, dbo.tblUser.MemberName, dbo.tblUser.FName, dbo.tblUser.Private, dbo.tblUser.PhoneNumber, dbo.tblUser.Email,
                   dbo.tblUser.Address1, dbo.tblUser.Address2, dbo.tblUser.City, dbo.tblUser.StateCode, dbo.tblUser.ProvOrOther, dbo.tblUser.PostalZip, dbo.tblUser.CountryCode,
                   dbo.tblUser.ClubPositionID, dbo.tblUser.DistrictPositionID, dbo.tblUser.Notes, dbo.tblUser.UUID,
                   tblUser_1.UserName AS Created_By, dbo.tblUser.Created_Tmstmp, tblUser_2.UserName AS Modified_By, dbo.tblUser.Modified_Tmstmp, dbo.tblClubPosition.ClubPosition, dbo.tblDistrictPosition.DistrictPosition,
                   dbo.tblClub.ClubName, dbo.tblClub.ClubNumber, ISNULL(dbo.tblUserAccount.UserRoleID, 0) AS RoleID
	FROM            dbo.tblUser
	LEFT OUTER JOIN dbo.tblUserAccount ON dbo.tblUser.UserID = dbo.tblUserAccount.UserID AND dbo.tblUser.AccountID = dbo.tblUserAccount.AccountID
	LEFT OUTER JOIN dbo.tblClub ON dbo.tblUser.ClubID = dbo.tblClub.ClubID
	LEFT OUTER JOIN dbo.tblDistrictPosition ON dbo.tblUser.DistrictPositionID = dbo.tblDistrictPosition.DistrictPositionID
	LEFT OUTER JOIN dbo.tblClubPosition ON dbo.tblUser.ClubPositionID = dbo.tblClubPosition.ClubPositionID
	LEFT OUTER JOIN dbo.tblUser AS tblUser_1 ON dbo.tblUser.Created_By = tblUser_1.UserID
	LEFT OUTER JOIN dbo.tblUser AS tblUser_2 ON dbo.tblUser.Modified_By = tblUser_2.UserID
			WHERE 		1 = 1
			AND		tblUser.Source  = 0
			<cfswitch expression="#SESSION.RoleID#">
				<cfcase value="1,2,3,4">
					AND		tblUser.ClubID 		= <CFQUERYPARAM Value="#SESSION.ClubID#"	CFSQLTYPE="CF_SQL_INTEGER">
				</cfcase>
				<cfcase value="5,6,7">
					AND		tblUser.AccountID 	= <CFQUERYPARAM Value="#SESSION.AccountID#"	CFSQLTYPE="CF_SQL_INTEGER">
				</cfcase>
			</cfswitch>
			<cfif ARGUMENTS.Override EQ "N">
				AND	 	tblUser.dFlag 		= 'N'
			</cfif>
			<cfif Len(ARGUMENTS.Filter) GT 0>
				AND 	tblUser.UserName 			LIKE <cfqueryparam value="#ARGUMENTS.Filter#%">
			</cfif>

UNION ALL
	SELECT        dbo.tblUser.UserID, dbo.tblUser.UserName, dbo.tblUser.MemberID, dbo.tblUser.IsRotarian, dbo.tblUser.dFlag, dbo.tblUser.AccountID, dbo.tblUser.ClubID, dbo.tblUser.LastName, dbo.tblUser.FirstName, dbo.tblUser.MidName,
                  dbo.tblUser.Prefix, dbo.tblUser.NameSfx, dbo.tblUser.NickName, dbo.tblUser.MemberName, dbo.tblUser.FName, dbo.tblUser.Private, dbo.tblUser.PhoneNumber, dbo.tblUser.Email,
                  Rotary.dbo.tblMemberAddress.Address1, Rotary.dbo.tblMemberAddress.Address2, Rotary.dbo.tblMemberAddress.City, Rotary.dbo.tblMemberAddress.StateCode, Rotary.dbo.tblMemberAddress.ProvOrOther, Rotary.dbo.tblMemberAddress.PostalZip, Rotary.dbo.tblMemberAddress.CountryCode,
                  dbo.tblUser.ClubPositionID, dbo.tblUser.DistrictPositionID, dbo.tblUser.Notes, dbo.tblUser.UUID,
                  tblUser_1.UserName AS Created_By, dbo.tblUser.Created_Tmstmp, tblUser_2.UserName AS Modified_By, dbo.tblUser.Modified_Tmstmp, dbo.tblClubPosition.ClubPosition, dbo.tblDistrictPosition.DistrictPosition,
                  dbo.tblClub.ClubName, dbo.tblClub.ClubNumber, ISNULL(dbo.tblUserAccount.UserRoleID, 0) AS RoleID
	FROM            dbo.tblUser
	LEFT OUTER JOIN Rotary.dbo.tblMemberAddress ON dbo.tblUser.UserID = Rotary.dbo.tblMemberAddress.UserID
	LEFT OUTER JOIN dbo.tblUserAccount ON dbo.tblUser.UserID = dbo.tblUserAccount.UserID AND dbo.tblUser.AccountID = dbo.tblUserAccount.AccountID
	LEFT OUTER JOIN dbo.tblClub ON dbo.tblUser.ClubID = dbo.tblClub.ClubID
	LEFT OUTER JOIN dbo.tblDistrictPosition ON dbo.tblUser.DistrictPositionID = dbo.tblDistrictPosition.DistrictPositionID
	LEFT OUTER JOIN dbo.tblClubPosition ON dbo.tblUser.ClubPositionID = dbo.tblClubPosition.ClubPositionID
	LEFT OUTER JOIN dbo.tblUser AS tblUser_1 ON dbo.tblUser.Created_By = tblUser_1.UserID
	LEFT OUTER JOIN dbo.tblUser AS tblUser_2 ON dbo.tblUser.Modified_By = tblUser_2.UserID
			WHERE 		1 = 1
			AND		tblUser.Source  = 1
			<cfswitch expression="#SESSION.RoleID#">
				<cfcase value="1,2,3,4">
					AND		tblUser.ClubID 		= <CFQUERYPARAM Value="#SESSION.ClubID#"	CFSQLTYPE="CF_SQL_INTEGER">
				</cfcase>
				<cfcase value="5,6,7">
					AND		tblUser.AccountID 	= <CFQUERYPARAM Value="#SESSION.AccountID#"	CFSQLTYPE="CF_SQL_INTEGER">
				</cfcase>
			</cfswitch>
			<cfif ARGUMENTS.Override EQ "N">
				AND	 	tblUser.dFlag 		= 'N'
			</cfif>
			<cfif Len(ARGUMENTS.Filter) GT 0>
				AND 	tblUser.UserName 			LIKE <cfqueryparam value="#ARGUMENTS.Filter#%">
			</cfif>
)
SELECT * FROM CTE_User

			<cfswitch expression="#ARGUMENTS.SortBy#">
				<cfcase value="UserName">	ORDER BY UserName		</cfcase>
			</cfswitch>
		</cfquery>
		<cfreturn qList>

	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Read -  User
	Modifications
		8/16/2019 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Read" access="public" output="false" returntype="struct" DisplayName="Read User">
		<cfargument name="User"		type="User"		required="Yes" />

		<cfset var qRead = "" />
		<cfset var strReturn = structNew() />

		<cfquery name="qRead" datasource="#VARIABLES.dsn#">

SELECT        dbo.tblUser.UserID, dbo.tblUser.UserName, dbo.tblUser.MemberID, dbo.tblUser.IsRotarian, dbo.tblUser.dFlag, dbo.tblUser.AccountID, dbo.tblUser.ClubID, dbo.tblUser.LastName, dbo.tblUser.FirstName, dbo.tblUser.MidName,
                         dbo.tblUser.Prefix, dbo.tblUser.NameSfx, dbo.tblUser.NickName, dbo.tblUser.MemberName, dbo.tblUser.FName, dbo.tblUser.Private, dbo.tblUser.PhoneNumber, dbo.tblUser.Email, dbo.tblUser.Address1, dbo.tblUser.Address2,
                         dbo.tblUser.City, dbo.tblUser.StateCode, dbo.tblUser.ProvOrOther, dbo.tblUser.PostalZip, dbo.tblUser.CountryCode, dbo.tblUser.ClubPositionID, dbo.tblUser.DistrictPositionID, dbo.tblUser.Notes, dbo.tblUser.UUID, dbo.tblUser.Source,
                         dbo.tblUser.IAgree, tblUser_1.UserName AS Created_By, dbo.tblUser.Created_Tmstmp, tblUser_2.UserName AS Modified_By, dbo.tblUser.Modified_Tmstmp, dbo.tblClub.ClubName, dbo.tblDistrictPosition.DistrictPosition,
                         dbo.tblClubPosition.ClubPosition, dbo.tblAccount.AccountName
FROM            dbo.tblUser LEFT OUTER JOIN
                         dbo.tblAccount ON dbo.tblUser.AccountID = dbo.tblAccount.AccountID LEFT OUTER JOIN
                         dbo.tblClub ON dbo.tblUser.ClubID = dbo.tblClub.ClubID LEFT OUTER JOIN
                         dbo.tblDistrictPosition ON dbo.tblUser.DistrictPositionID = dbo.tblDistrictPosition.DistrictPositionID LEFT OUTER JOIN
                         dbo.tblClubPosition ON dbo.tblUser.ClubPositionID = dbo.tblClubPosition.ClubPositionID LEFT OUTER JOIN
                         dbo.tblUser AS tblUser_1 ON dbo.tblUser.Created_By = tblUser_1.UserID LEFT OUTER JOIN
                         dbo.tblUser AS tblUser_2 ON dbo.tblUser.Modified_By = tblUser_2.UserID

			WHERE	1 = 1
			AND		tblUser.UserID = <cfqueryparam value="#ARGUMENTS.User.getUserID()#" CFSQLType="cf_sql_integer" />
		</cfquery>
		<cfif qRead.recordCount>
			<cfset strReturn = queryRowToStruct(qRead)>
			<cfset ARGUMENTS.User.init(argumentCollection=strReturn)>
		<cfelse>
			<cfset strReturn = User.getMemento()>
		</cfif>
		<cfreturn strReturn>

	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Exists -  User
	Modifications
		1/4/2020 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Exists" access="public" output="false" returntype="boolean" DisplayName="Exists User">
		<cfargument name="User"		type="User"		required="Yes" />

		<cfset var qExists = "">

		<cfquery name="qExists" datasource="#variables.dsn#" maxrows="1">
			SELECT count(1) as idexists
			FROM	tblUser
			WHERE	UserID = <cfqueryparam value="#ARGUMENTS.User.getUserID()#" CFSQLType="cf_sql_integer" />
		</cfquery>
		<cfif qExists.idexists>
			<cfreturn TRUE />
		<cfelse>
			<cfreturn FALSE />
		</cfif>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Save -  User
	Modifications
		1/4/2020 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Save" access="public" output="false" returntype="numeric" DisplayName="Save User User">
		<cfargument name="User"		type="User"		required="Yes" />
		<cfargument name="fDebug" 	Type="boolean"	required="No"		Default="FALSE" />

		<cfset var pkID = 0 />		<!--- 0=false --->
		<cfif exists(arguments.User)>
			<cfif fDebug>update User</cfif>
			<cfset pkID = update(arguments.User) />
		<cfelse>
			<cfif fDebug>create User</cfif>
			<cfset pkID = create(arguments.User) />
		</cfif>

		<cfreturn pkID />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	InsertRec -  User
	Modifications
		1/4/2020 - created

	<cfinvoke component="\CFC\UserDAO" method="InsertRec" returnvariable="UserID">
		<cfinvokeargument name="UserID"			Value="#UserID#">
		<cfinvokeargument name="MemberID"		Value="#MemberID#">
		<cfinvokeargument name="IsRotarian"		Value="#IsRotarian#">
		<cfinvokeargument name="dFlag"			Value="#dFlag#">
		<cfinvokeargument name="AccountID"		Value="#AccountID#">
		<cfinvokeargument name="ClubID"			Value="#ClubID#">
		<cfinvokeargument name="LastName"		Value="#LastName#">
		<cfinvokeargument name="FirstName"		Value="#FirstName#">
		<cfinvokeargument name="MidName"		Value="#MidName#">
		<cfinvokeargument name="Prefix"			Value="#Prefix#">
		<cfinvokeargument name="NameSfx"		Value="#NameSfx#">
		<cfinvokeargument name="NickName"		Value="#NickName#">
		<cfinvokeargument name="Private"		Value="#Private#">
		<cfinvokeargument name="PhoneNumber"		Value="#PhoneNumber#">
		<cfinvokeargument name="Email"			Value="#Email#">
		<cfinvokeargument name="Address1"		Value="#Address1#">
		<cfinvokeargument name="Address2"		Value="#Address2#">
		<cfinvokeargument name="City"			Value="#City#">
		<cfinvokeargument name="StateCode"		Value="#StateCode#">
		<cfinvokeargument name="ProvOrOther"		Value="#ProvOrOther#">
		<cfinvokeargument name="PostalZip"		Value="#PostalZip#">
		<cfinvokeargument name="CountryCode"		Value="#CountryCode#">
		<cfinvokeargument name="ClubPositionID"		Value="#ClubPositionID#">
		<cfinvokeargument name="DistrictPositionID"		Value="#DistrictPositionID#">
		<cfinvokeargument name="Notes"			Value="#Notes#">
		<cfinvokeargument name="UUID"			Value="#UUID#">
		<cfinvokeargument name="IAgree"			Value="#IAgree#">
		<cfinvokeargument name="Source"		Value="#Source#">
	</cfinvoke>
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="InsertRec" access="public" output="false" returntype="numeric" DisplayName="InsertRec User">
		<cfargument name="UserID"					Type="numeric"		Required="No"		Default="0" />
		<cfargument name="MemberID"					Type="numeric"		Required="No"		Default="0" />
		<cfargument name="IsRotarian"				Type="string"		Required="No"		Default="N" />
		<cfargument name="dFlag"					Type="string"		Required="No"		Default="N" />
		<cfargument name="AccountID"				Type="numeric"		Required="No"		Default="#SESSION.AccountID#" />
		<cfargument name="ClubID"					Type="numeric"		Required="No"		Default="#SESSION.ClubID#" />
		<cfargument name="LastName"					Type="string"		Required="No"		Default="" />
		<cfargument name="FirstName"				Type="string"		Required="No"		Default="" />
		<cfargument name="MidName"					Type="string"		Required="Yes"		Default="" />
		<cfargument name="Prefix"					Type="string"		Required="Yes"		Default="" />
		<cfargument name="NameSfx"					Type="string"		Required="Yes"		Default="" />
		<cfargument name="NickName"					Type="string"		Required="Yes"		Default="" />
		<cfargument name="Private"					Type="string"		Required="No"		Default="N" />
		<cfargument name="PhoneNumber"				Type="string"		Required="Yes"		Default="" />
		<cfargument name="Email"					Type="string"		Required="Yes"		Default="" />
		<cfargument name="Address1"					Type="string"		Required="Yes"		Default="" />
		<cfargument name="Address2"					Type="string"		Required="Yes"		Default="" />
		<cfargument name="City"						Type="string"		Required="Yes"		Default="" />
		<cfargument name="StateCode"				Type="string"		Required="Yes"		Default="" />
		<cfargument name="ProvOrOther"				Type="string"		Required="Yes"		Default="" />
		<cfargument name="PostalZip"				Type="string"		Required="Yes"		Default="" />
		<cfargument name="CountryCode"				Type="string"		Required="Yes"		Default="USA" />
		<cfargument name="ClubPositionID"			Type="numeric"		Required="No"		Default="0" />
		<cfargument name="DistrictPositionID"		Type="numeric"		Required="No"		Default="0" />
		<cfargument name="Notes"					Type="string"		Required="Yes"		Default="" />
		<cfargument name="IAgree"					Type="string"		Required="Yes"		Default="" />
		<cfargument name="Source"					Type="numeric"		Required="No"		Default="0" />
		<cfargument name="OnErrorContinue"			Type="String"		Required="No"		Default="N" />

		<cfset var qInsert	= "" />
		<cfset var R		= "" />
		<cfset var MaxID 	= "0" />

		<cflock timeout="5" scope="SESSION" type="EXCLUSIVE">
			<cfif ARGUMENTS.UserID EQ 0>  <!--- In CARTS, if we are creating a user here it should take the DACdb ID. If not avail, then 1,000 to 62000. --->
				<cfquery name="M" datasource="#VARIABLES.dsn#">
					SELECT 	Max(UserID) AS MaxID
					FROM 	tblUser
					WHERE	UserID > 4 and UserID < 62000>
				</cfquery>
				<cfif NOT IsNumeric(M.MaxID)>
					<CFSET MaxID = 1000>
				<cfelse>
					<CFSET MaxID = M.MaxID + 1>
				</cfif>
			<cfelse>
					<CFSET MaxID = ARGUMENTS.UserID>
			</cfif>

			<cftry>
				<cfquery name="qInsert" datasource="#VARIABLES.dsn#" Result="R">
					INSERT INTO tblUser
						(
						UserID,
						MemberID,
						IsRotarian,
						dFlag,
						AccountID,
						ClubID,
						LastName,
						FirstName,
						MidName,
						Prefix,
						NameSfx,
						NickName,
						Private,
						PhoneNumber,
						Email,
						Address1,
						Address2,
						City,
						StateCode,
						ProvOrOther,
						PostalZip,
						CountryCode,
						ClubPositionID,
						DistrictPositionID,
						Notes,
						IAgree,
						Source,
						Created_By,
						Created_Tmstmp
						)
					VALUES
						(
						<cfqueryparam value="#MaxID#"								CFSQLType="CF_SQL_INTEGER" />,
						<cfqueryparam value="#ARGUMENTS.MemberID#"					CFSQLType="CF_SQL_INTEGER" />,
						<cfqueryparam value="#Left(ARGUMENTS.IsRotarian,1)#"		CFSQLType="CF_SQL_CHAR" 			null="#not len(ARGUMENTS.IsRotarian)#" />,
						<cfqueryparam value="#Left(ARGUMENTS.dFlag,1)#"				CFSQLType="CF_SQL_CHAR" 			null="#not len(ARGUMENTS.dFlag)#" />,
						<cfqueryparam value="#ARGUMENTS.AccountID#"					CFSQLType="CF_SQL_INTEGER" />,
						<cfqueryparam value="#ARGUMENTS.ClubID#"					CFSQLType="CF_SQL_INTEGER" />,
						<cfqueryparam value="#Left(ARGUMENTS.LastName,50)#"			CFSQLType="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#Left(ARGUMENTS.FirstName,32)#"		CFSQLType="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#Left(ARGUMENTS.MidName,32)#"			CFSQLType="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#Left(ARGUMENTS.Prefix,12)#"			CFSQLType="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#Left(ARGUMENTS.NameSfx,20)#"			CFSQLType="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#Left(ARGUMENTS.NickName,20)#"			CFSQLType="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#Left(ARGUMENTS.Private,1)#"			CFSQLType="CF_SQL_CHAR" 			null="#not len(ARGUMENTS.Private)#" />,
						<cfqueryparam value="#Left(ARGUMENTS.PhoneNumber,20)#"		CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.PhoneNumber)#" />,
						<cfqueryparam value="#Left(ARGUMENTS.Email,80)#"			CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.Email)#" />,
						<cfqueryparam value="#Left(ARGUMENTS.Address1,50)#"			CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.Address1)#" />,
						<cfqueryparam value="#Left(ARGUMENTS.Address2,50)#"			CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.Address2)#" />,
						<cfqueryparam value="#Left(ARGUMENTS.City,50)#"				CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.City)#" />,
						<cfqueryparam value="#Left(ARGUMENTS.StateCode,2)#"			CFSQLType="CF_SQL_CHAR" 			null="#not len(ARGUMENTS.StateCode)#" />,
						<cfqueryparam value="#Left(ARGUMENTS.ProvOrOther,32)#"		CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.ProvOrOther)#" />,
						<cfqueryparam value="#Left(ARGUMENTS.PostalZip,12)#"		CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.PostalZip)#" />,
						<cfqueryparam value="#Left(ARGUMENTS.CountryCode,3)#"		CFSQLType="CF_SQL_CHAR" 			null="#not len(ARGUMENTS.CountryCode)#" />,
						<cfqueryparam value="#ARGUMENTS.ClubPositionID#"			CFSQLType="CF_SQL_INTEGER" />,
						<cfqueryparam value="#ARGUMENTS.DistrictPositionID#"		CFSQLType="CF_SQL_INTEGER" />,
						<cfqueryparam value="#ARGUMENTS.Notes#"						CFSQLType="CF_SQL_VARCHAR"			null="#not len(ARGUMENTS.Notes)#" />,
						<cfqueryparam value="#Left(ARGUMENTS.IAgree,1)#"			CFSQLType="CF_SQL_CHAR" 			null="#not len(ARGUMENTS.IAgree)#" />,
						<cfqueryparam value="#ARGUMENTS.Source#"					CFSQLType="CF_SQL_INTEGER" />,
						<cfqueryparam value="#SESSION.UserID#"						CFSQLType="CF_SQL_INTEGER" />,
						<cfqueryparam value="#Now()#"								CFSQLType="CF_SQL_TIMESTAMP" />
						)
				</cfquery>
				<CF_XLogCart Table="User" type="I" Value="#MaxID#" Desc="Insert into User">
				<cfcatch type="database">
					<cfif ARGUMENTS.OnErrorContinue EQ "N">
						<CF_XLogCart Table="User" type="E" Value="0" Desc="Error inserting User (#cfcatch.detail#)" >
					</cfif>
					<cfreturn 0 />
				</cfcatch>
			</cftry>
		</cflock>
		<cfreturn MaxID />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Create -  User
	Modifications
		8/16/2019 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Create" access="public" output="false" returntype="numeric" DisplayName="Create User">
		<cfargument name="User"					Type="User"			required="Yes" />
		<cfargument name="OnErrorContinue"  	Type="String"		required="No"	Default="N" />

		<cfset var qCreate = "" />
		<cfset var R       = "" />
		<cfset var MaxID 	= "0" />
		<cfset var UserID 	= ARGUMENTS.User.getUserID()>

		<cflock timeout="5" scope="SESSION" type="EXCLUSIVE">

			<cfif UserID EQ 0>  <!--- In CARTS, if we are creating a user here it should take the DACdb ID. If not avail, then 1,000 to 62000. --->
				<cfquery name="M" datasource="#VARIABLES.dsn#">
					SELECT 	Max(UserID) AS MaxID
					FROM 	tblUser
					WHERE	UserID > 4 and UserID < 62000
				</cfquery>
				<cfif NOT IsNumeric(M.MaxID)>
					<CFSET MaxID = 1000>
				<cfelse>
					<CFSET MaxID = M.MaxID + 1>
				</cfif>
			<cfelse>
					<CFSET MaxID = UserID>
			</cfif>

			<cftry>
				<cfquery name="qCreate" datasource="#VARIABLES.dsn#" Result="R">
					INSERT INTO tblUser
						(
						UserID,
						MemberID,
						IsRotarian,
						dFlag,
						AccountID,
						ClubID,
						LastName,
						FirstName,
						MidName,
						Prefix,
						NameSfx,
						NickName,
						<!--- Private, --->
						PhoneNumber,
						Email,
						Address1,
						Address2,
						City,
						StateCode,
						ProvOrOther,
						PostalZip,
						CountryCode,
						ClubPositionID,
						DistrictPositionID,
						Notes,
						IAgree,
						Source,
						Created_By,
						Created_Tmstmp
						)
					VALUES
						(
						<cfqueryparam value="#MaxID#"											CFSQLType="CF_SQL_INTEGER" />,
						<cfqueryparam value="#ARGUMENTS.User.getMemberID()#"					CFSQLType="CF_SQL_INTEGER" />,
						<cfqueryparam value="#Left(ARGUMENTS.User.getIsRotarian(),1)#"			CFSQLType="CF_SQL_CHAR"		null="#not len(ARGUMENTS.User.getIsRotarian())#" />,
						<cfqueryparam value="#Left(ARGUMENTS.User.getdFlag(),1)#"				CFSQLType="CF_SQL_CHAR"		null="#not len(ARGUMENTS.User.getdFlag())#" />,
						<cfqueryparam value="#ARGUMENTS.User.getAccountID()#"					CFSQLType="CF_SQL_INTEGER" />,
						<cfqueryparam value="#ARGUMENTS.User.getClubID()#"						CFSQLType="CF_SQL_INTEGER" />,
						<cfqueryparam value="#Left(ARGUMENTS.User.getLastName(),50)#"			CFSQLType="CF_SQL_VARCHAR"	/>,
						<cfqueryparam value="#Left(ARGUMENTS.User.getFirstName(),32)#"			CFSQLType="CF_SQL_VARCHAR"	/>,
						<cfqueryparam value="#Left(ARGUMENTS.User.getMidName(),32)#"			CFSQLType="CF_SQL_VARCHAR"	/>,
						<cfqueryparam value="#Left(ARGUMENTS.User.getPrefix(),12)#"				CFSQLType="CF_SQL_VARCHAR"	/>,
						<cfqueryparam value="#Left(ARGUMENTS.User.getNameSfx(),20)#"			CFSQLType="CF_SQL_VARCHAR"	/>,
						<cfqueryparam value="#Left(ARGUMENTS.User.getNickName(),20)#"			CFSQLType="CF_SQL_VARCHAR"	/>,
						<!--- <cfqueryparam value="#Left(ARGUMENTS.User.getPrivate(),1)#"				CFSQLType="CF_SQL_CHAR"		null="#not len(ARGUMENTS.User.getPrivate())#" />, --->
						<cfqueryparam value="#Left(ARGUMENTS.User.getPhoneNumber(),20)#"		CFSQLType="CF_SQL_VARCHAR"	null="#not len(ARGUMENTS.User.getPhoneNumber())#" />,
						<cfqueryparam value="#Left(ARGUMENTS.User.getEmail(),80)#"				CFSQLType="CF_SQL_VARCHAR"	null="#not len(ARGUMENTS.User.getEmail())#" />,
						<cfqueryparam value="#Left(ARGUMENTS.User.getAddress1(),50)#"			CFSQLType="CF_SQL_VARCHAR"	null="#not len(ARGUMENTS.User.getAddress1())#" />,
						<cfqueryparam value="#Left(ARGUMENTS.User.getAddress2(),50)#"			CFSQLType="CF_SQL_VARCHAR"	null="#not len(ARGUMENTS.User.getAddress2())#" />,
						<cfqueryparam value="#Left(ARGUMENTS.User.getCity(),50)#"				CFSQLType="CF_SQL_VARCHAR"	null="#not len(ARGUMENTS.User.getCity())#" />,
						<cfqueryparam value="#Left(ARGUMENTS.User.getStateCode(),2)#"			CFSQLType="CF_SQL_CHAR"		null="#not len(ARGUMENTS.User.getStateCode())#" />,
						<cfqueryparam value="#Left(ARGUMENTS.User.getProvOrOther(),32)#"		CFSQLType="CF_SQL_VARCHAR"	null="#not len(ARGUMENTS.User.getProvOrOther())#" />,
						<cfqueryparam value="#Left(ARGUMENTS.User.getPostalZip(),12)#"			CFSQLType="CF_SQL_VARCHAR"	null="#not len(ARGUMENTS.User.getPostalZip())#" />,
						<cfqueryparam value="#Left(ARGUMENTS.User.getCountryCode(),3)#"			CFSQLType="CF_SQL_CHAR"		null="#not len(ARGUMENTS.User.getCountryCode())#" />,
						<cfqueryparam value="#ARGUMENTS.User.getClubPositionID()#"				CFSQLType="CF_SQL_INTEGER" />,
						<cfqueryparam value="#ARGUMENTS.User.getDistrictPositionID()#"			CFSQLType="CF_SQL_INTEGER" />,
						<cfqueryparam value="#ARGUMENTS.User.getNotes()#"						CFSQLType="CF_SQL_VARCHAR"	null="#not len(ARGUMENTS.User.getNotes())#" />,
						<cfqueryparam value="#Left(ARGUMENTS.User.getIAgree(),1)#"				CFSQLType="CF_SQL_CHAR"		null="#not len(ARGUMENTS.User.getIAgree())#" />,
						<cfqueryparam value="#ARGUMENTS.User.getSource()#"						CFSQLType="CF_SQL_INTEGER" />,
						<cfqueryparam value="#SESSION.UserID#"									CFSQLType="CF_SQL_INTEGER" />,
						<cfqueryparam value="#Now()#"											CFSQLType="CF_SQL_TIMESTAMP" />
					)
				</cfquery>

				<CF_XLogCart Table="User" type="I" Value="#MaxID#" Desc="#ARGUMENTS.User.getUserName()# created">
				<cfcatch type="database">
					<cfif ARGUMENTS.OnErrorContinue EQ "N">
						<CF_XLogCart Table="User" type="E" Value="0" Desc="Error inserting User (#cfcatch.detail#)" >
					</cfif>
					<cfreturn 0 />
				</cfcatch>
			</cftry>
		</cflock>
		<cfreturn MaxID />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Update -  User
	Modifications
		8/16/2019 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Update" access="public" output="true" returntype="numeric" DisplayName="Update User">
		<cfargument name="User"					Type="User"	required="Yes" />
		<cfargument name="OnErrorContinue"		Type="String"			required="No"	Default="N" />

		<cfset var qUpdate = "" />

			<cfquery name="qUpdate" datasource="#VARIABLES.dsn#">
				UPDATE tblUser
				SET
					MemberID			= <cfqueryparam value="#ARGUMENTS.User.getMemberID()#"					CFSQLType="CF_SQL_INTEGER" />,
					IsRotarian			= <cfqueryparam value="#Left(ARGUMENTS.User.getIsRotarian(),1)#"		CFSQLType="CF_SQL_CHAR" 			null="#not len(ARGUMENTS.User.getIsRotarian())#" />,
					dFlag				= <cfqueryparam value="#Left(ARGUMENTS.User.getdFlag(),1)#"				CFSQLType="CF_SQL_CHAR" 			null="#not len(ARGUMENTS.User.getdFlag())#" />,
					AccountID			= <cfqueryparam value="#ARGUMENTS.User.getAccountID()#"					CFSQLType="CF_SQL_INTEGER" />,
					ClubID				= <cfqueryparam value="#ARGUMENTS.User.getClubID()#"					CFSQLType="CF_SQL_INTEGER" />,
					LastName			= <cfqueryparam value="#Left(ARGUMENTS.User.getLastName(),50)#"			CFSQLType="CF_SQL_VARCHAR" />,
					FirstName			= <cfqueryparam value="#Left(ARGUMENTS.User.getFirstName(),32)#"		CFSQLType="CF_SQL_VARCHAR" />,
					MidName				= <cfqueryparam value="#Left(ARGUMENTS.User.getMidName(),32)#"			CFSQLType="CF_SQL_VARCHAR" />,
					Prefix				= <cfqueryparam value="#Left(ARGUMENTS.User.getPrefix(),12)#"			CFSQLType="CF_SQL_VARCHAR" />,
					NameSfx				= <cfqueryparam value="#Left(ARGUMENTS.User.getNameSfx(),20)#"			CFSQLType="CF_SQL_VARCHAR" />,
					NickName			= <cfqueryparam value="#Left(ARGUMENTS.User.getNickName(),20)#"			CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.User.getNickName())#" />,
					<!--- Private				= <cfqueryparam value="#Left(ARGUMENTS.User.getPrivate(),1)#"			CFSQLType="CF_SQL_CHAR" 			null="#not len(ARGUMENTS.User.getPrivate())#" />, --->
					PhoneNumber			= <cfqueryparam value="#Left(ARGUMENTS.User.getPhoneNumber(),20)#"		CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.User.getPhoneNumber())#" />,
					Email				= <cfqueryparam value="#Left(ARGUMENTS.User.getEmail(),80)#"			CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.User.getEmail())#" />,
					Address1			= <cfqueryparam value="#Left(ARGUMENTS.User.getAddress1(),50)#"			CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.User.getAddress1())#" />,
					Address2			= <cfqueryparam value="#Left(ARGUMENTS.User.getAddress2(),50)#"			CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.User.getAddress2())#" />,
					City				= <cfqueryparam value="#Left(ARGUMENTS.User.getCity(),50)#"				CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.User.getCity())#" />,
					StateCode			= <cfqueryparam value="#Left(ARGUMENTS.User.getStateCode(),2)#"			CFSQLType="CF_SQL_CHAR" 			null="#not len(ARGUMENTS.User.getStateCode())#" />,
					ProvOrOther			= <cfqueryparam value="#Left(ARGUMENTS.User.getProvOrOther(),32)#"		CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.User.getProvOrOther())#" />,
					PostalZip			= <cfqueryparam value="#Left(ARGUMENTS.User.getPostalZip(),12)#"		CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.User.getPostalZip())#" />,
					CountryCode			= <cfqueryparam value="#Left(ARGUMENTS.User.getCountryCode(),3)#"		CFSQLType="CF_SQL_CHAR" 			null="#not len(ARGUMENTS.User.getCountryCode())#" />,
					ClubPositionID		= <cfqueryparam value="#ARGUMENTS.User.getClubPositionID()#"			CFSQLType="CF_SQL_INTEGER" />,
					DistrictPositionID	= <cfqueryparam value="#ARGUMENTS.User.getDistrictPositionID()#"		CFSQLType="CF_SQL_INTEGER" />,
					Notes				= <cfqueryparam value="#ARGUMENTS.User.getNotes()#"						CFSQLType="CF_SQL_VARCHAR"			null="#not len(ARGUMENTS.User.getNotes())#" />,
					IAgree					= <cfqueryparam value="#Left(ARGUMENTS.User.getIAgree(),1)#"		CFSQLType="CF_SQL_CHAR" 			null="#not len(ARGUMENTS.User.getIAgree())#" />,
					Source					= <cfqueryparam value="#ARGUMENTS.User.getSource()#"				CFSQLType="CF_SQL_INTEGER" />,
					Modified_By			= <cfqueryparam value="#SESSION.UserID#" 								CFSQLType="CF_SQL_INTEGER" />,
					Modified_Tmstmp		= <cfqueryparam value="#Now()#" 										CFSQLType="CF_SQL_TIMESTAMP" />
				WHERE	1 = 1
				AND		UserID			= <cfqueryparam value="#ARGUMENTS.User.getUserID()#"					CFSQLType="cf_sql_integer" />
			</cfquery>
		<cftry>
			<CF_XLogCart Table="User" type="U" Value="#ARGUMENTS.User.getUserID()#" Desc="User #ARGUMENTS.User.getUserName()# Updated">
			<cfcatch type="database">
				<cfif ARGUMENTS.OnErrorContinue EQ "N">
					<CF_XLogCart Table="User" type="E" Value="0" Desc="Error updating User (#cfcatch.detail#)" >
				</cfif>
				<cfreturn 0 />
			</cfcatch>
		</cftry>
		<cfreturn ARGUMENTS.User.getUserID() />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Delete -  User
	Modifications
		8/16/2019 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Delete" access="public" output="false" returntype="boolean" DisplayName="Delete User">
		<cfargument name="User"	type="User"	required="Yes" />
		<cfargument name="OnErrorContinue"  	Type="String"		required="No"	Default="N" />

		<cfset var qDelete = "" />
		<cfset var R       = "" />
		<cftry>
			<cfquery name="qDelete" datasource="#VARIABLES.dsn#" Result="R">
				DELETE FROM	tblUser
				WHERE	1 = 1
				AND		UserID = <cfqueryparam value="#ARGUMENTS.User.getUserID()#" 					CFSQLType="cf_sql_integer" />
			</cfquery>
			<CF_XLogCart Table="User" type="D" Value="#ARGUMENTS.User.getUserID()#" Desc="#ARGUMENTS.User.getUserName()# Physically Deleted">
			<cfcatch type="database">
				<cfif ARGUMENTS.OnErrorContinue EQ "N">
					<CF_XLogCart Table="User" type="D" Value="0" Desc="Error deleting User (#cfcatch.detail#)" >
				</cfif>
				<cfreturn FALSE />
			</cfcatch>
		</cftry>
		<cfreturn TRUE />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	DeleteLogical -  User
	Modifications
		8/16/2019 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="DeleteLogical" access="public" output="false" returntype="boolean" DisplayName="DeleteLogical User">
		<cfargument name="User"		type="User"	required="true" />
		<cfargument name="OnErrorContinue"		type="String"		required="Yes" 	Default="Y"/>

		<cfset var qDelete = "" />
		<cfset var errMsg 	= "" />
		<cfset var UserID = ARGUMENTS.User.getUserID()>
		<cftry>
			<cfquery name="qDelete" datasource="#variables.DSN#">
				UPDATE  tblUser
				SET
					dFlag				= 'Y',
					Modified_By 		= <cfqueryparam value="#SESSION.UserID#" 		CFSQLType="CF_SQL_INTEGER" />,
					Modified_Tmstmp 	= <cfqueryparam value="#Now()#" 				CFSQLType="CF_SQL_TIMESTAMP" />
				WHERE		UserID = <cfqueryparam value="#UserID#" 					CFSQLType="cf_sql_integer" />
			</cfquery>

			<CF_XLogCart Table="User" type="D" Value="#UserID#" Desc="#ARGUMENTS.User.getUserName()# Logically Deleted">
			<cfcatch type="database">
				<cfif ARGUMENTS.OnErrorContinue EQ "N">
					<CF_XLogCart Table="User" type="D" Value="0" Desc="Error deleting logical User (#cfcatch.detail#)" >
				</cfif>
				<cfreturn FALSE />
			</cfcatch>
		</cftry>
		<cfreturn TRUE />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	DeleteByID -  User
	Modifications
		8/16/2019 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="DeleteByID" access="public" output="false" returntype="boolean" DisplayName="DeleteByID User">
		<cfargument name="UserID"		type="Numeric"	Required="true" />
		<cfargument name="OnErrorContinue"			type="String"		Required="Yes" 	Default="Y"/>

		<cfset var qDelete = "" />
		<cfset var R       = "" />

		<cftry>
			<cfquery name="qDelete" datasource="#VARIABLES.dsn#" Result="R">
				DELETE FROM	tblUser
				WHERE	1 = 1
				AND		UserID = <cfqueryparam value="#ARGUMENTS.UserID#" 					CFSQLType="cf_sql_integer" />
			</cfquery>
			<CF_XLogCart Table="User" type="D" Value="#ARGUMENTS.UserID#" Desc="User Deleted">
			<cfcatch type="database">
				<cfif ARGUMENTS.OnErrorContinue EQ "N">
					<CF_XLogCart Table="User" type="D" Value="#ARGUMENTS.UserID#" Desc="Error deleting User (#cfcatch.detail#)" >
				</cfif>
				<cfreturn FALSE />
			</cfcatch>
		</cftry>
		<cfreturn TRUE />
	</cffunction>


<!---------------------------------------------------------------------------------------------------------
	FindUserByEMail - Return a query with the basic UserName
	Don't limit to account here -- need global search for login across all names
----------------------------------------------------------------------------------------------------------->
	<cffunction Name="FindUserByEMail" Access="Public" Output="FALSE" returnType="Query" DisplayName="FindUserByEMail">
		<cfargument Name="UserID"             	 Type="Numeric"  	Required="Yes" 	Hint="UserID">
		<cfargument Name="DSN"  	           	 Type="String"  	Required="No" 	Hint="DSN" 		default="#VARIABLES.DSN#">

		<cfset var qLookup = QueryNew("UserID,UserName,AccountID,EMail","Integer,varchar,integer,varchar")>

		<cfswitch expression="#ARGUMENTS.DSN#">
			<cfcase value="Cart">
				<cfquery name="qLookup" datasource="#ARGUMENTS.DSN#">
					SELECT			dbo.tblUser.UserID, dbo.tblUser.UserName, dbo.tblUser.FName, dbo.tblUser.AccountID,  dbo.tblUser.Email
					FROM			dbo.tblUser
					WHERE 			tblUser.UserID	= <CFQUERYPARAM Value="#ARGUMENTS.UserID#" CFSQLTYPE="CF_SQL_INTEGER">
				</cfquery>
			</cfcase>
			<cfdefaultcase>
				<cfquery name="qLookup" datasource="#ARGUMENTS.DSN#">
					SELECT			dbo.tblUser.UserID, dbo.tblUser.UserName, dbo.tblUser.FName,  dbo.tblUser.AccountID,  dbo.tblMemberEmail.Email
					FROM			dbo.tblUser
					LEFT OUTER JOIN	dbo.tblMemberEmail ON dbo.tblUser.PMailID = dbo.tblMemberEmail.MemberEmailID
					WHERE 			tblUser.UserID	= <CFQUERYPARAM Value="#ARGUMENTS.UserID#" CFSQLTYPE="CF_SQL_INTEGER">
				</cfquery>
			</cfdefaultcase>
		</cfswitch>
		<cfreturn qLookup>
	</cffunction>

<!--------------------------------------------------------------------------------------------
	GetUserNameList - Return a list of UserNames basied on the UserIDs passed in
			The badge report uses this when there is a subset of users to print
	Modifications:
		08/25/010- Created
---------------------------------------------------------------------------------------------->
	<cffunction Name="GetUserNameList" Access="Public" Output="FALSE" returnType="String" DisplayName="GetUserName">
		<cfargument Name="UserIDs"        	 Type="String"  	Required="Yes" 	Hint="UserIDs" >

		<cfset var userList  = "">
		<cfset var qList	= "">

		<cfquery name="qList" datasource="#Request.DSN#">
			SELECT 	RTRIM(tblUser.UserName) As UserName
			FROM 	tblUser
			WHERE 	1 = 1
			<cfif ListLen(ARGUMENTS.UserIDs) GT 0>
				AND		UserID  IN (<CFQUERYPARAM Value="#ARGUMENTS.UserIDs#" CFSQLTYPE="CF_SQL_INTEGER" list="Yes">)
			<cfelse>
				AND		UserID  = 0
			</cfif>
		</cfquery>
		<cfif qList.Recordcount GT 0>
			<cfset userList = ValueList(qList.UserName,";&nbsp;")>
		</cfif>
		<cfreturn userList>

	</cffunction>
<!--- ----------------------------------------------------------------------------------------------------------------
	queryRowToStruct
	Modifications
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="queryRowToStruct" access="private" output="false" returntype="struct">
		<cfargument name="qry" type="query" required="true">

		<cfscript>
			/**
			 * Makes a row of a query into a structure.
			 *
			 * @param query 	 The query to work with.
			 * @param row 	 Row number to check. Defaults to row 1.
			 * @return Returns a structure.
			 * @author Nathan Dintenfass (nathan@changemedia.com)
			 * @version 1, December 11, 2001
			 */
			//by Default, do this to the first row of the query
			var row = 1;
			//a var for looping
			var ii = 1;
			//the cols to loop over
			var cols = listToArray(qry.columnList);
			//the struct to return
			var stReturn = structnew();
			//if there is a second argument, use that for the row number
			if(arrayLen(arguments) GT 1)
				row = arguments[2];
			//loop over the cols and build the struct from the query row
			for(ii = 1; ii lte arraylen(cols); ii = ii + 1){
				stReturn[cols[ii]] = qry[cols[ii]][row];
			}
			//return the struct
			return stReturn;
		</cfscript>
	</cffunction>

</cfcomponent>