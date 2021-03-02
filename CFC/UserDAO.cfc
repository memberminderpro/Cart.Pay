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


</cfcomponent>