<!--------------------------------------------------------------------------------------------
	ContributionDAO.cfc

	* $Revision: $
	* $Date: 4/20/2020 $
---------------------------------------------------------------------------------------------->

<cfcomponent displayname="ContributionDAO" output="false">

<!--- Local Variables --->
<cfset VARIABLES.dsn 		= REQUEST.DSN>

<!--------------------------------------------------------------------------------------------
	Init - Contribution Constructor

	Entry Conditions:
		DSN			- datasource name
---------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Contribution">
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
	GetContributionName - Get the name from  Contribution by ContributionID
	Modifications:
		2/7/2020 $ - created
---------------------------------------------------------------------------------------------->
	<cffunction Name="GetContributionName" Access="Public" Output="FALSE" returnType="String" DisplayName="GetContributionName">
		<cfargument Name="ContributionID"		 Type="Numeric"		Required="Yes"		Hint="ContributionID" >

		<cfset var qGetContributionName = "">
		<cfset var strContributionName = "">

		<cfquery name="qGetContributionName" datasource="#Request.DSN#">
			SELECT 	tblContribution.ContributionName
			FROM 	tblContribution
			WHERE 	ContributionID  = <CFQUERYPARAM Value="#ARGUMENTS.ContributionID#" CFSQLTYPE="CF_SQL_INTEGER">
		</cfquery>
		<cfif qGetContributionName.Recordcount GT 0>
			<cfset strContributionName = qGetContributionName.ContributionName>
		</cfif>
		<cfreturn strContributionName>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Pick - Contribution
	Modifications
		4/20/2020 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Pick" access="public" output="false" returntype="Query" DisplayName="Pick">
		<cfargument Name="AccountID"		Type="Numeric"  	Required="No" 	Hint="AccountID"			Default="#SESSION.AccountID#">
		<cfargument Name="SortBy"			Type="String"  		Required="No" 	Hint="SortBy" 				Default="AccountID">

		<cfset var qPick = "" />
		<cfquery name="qPick" datasource="#VARIABLES.dsn#">
			SELECT	tblContribution.ContributionID, tblContribution.AccountID
			FROM	tblContribution.tblContribution
			WHERE	1 = 1
				AND			tblContribution.AccountID = <CFQUERYPARAM Value="#ARGUMENTS.AccountID#" CFSQLTYPE="CF_SQL_INTEGER">
			<cfswitch expression="#ARGUMENTS.SortBy#">
				<cfcase value="AccountID">ORDER BY 	tblContribution.AccountID </cfcase>
			</cfswitch>
		</cfquery>
		<cfreturn qPick>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Lookup - Contribution
	Modifications
		4/20/2020  - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Lookup" access="public" output="false" returntype="Query" DisplayName="Lookup">
		<cfargument name="ContributionID"		Type="numeric"	Required="No"	Hint="ContributionID"			Default="0" />
		<cfargument Name="AccountID"			Type="Numeric"	Required="No"	Hint="AccountID"				Default="#SESSION.AccountID#">
		<cfargument Name="Filter"				Type="string"	Required="No"	Hint="Filter Value"			Default="">
		<cfargument Name="SortBy"				Type="String"	Required="No"	Hint="SortBy"				Default="AccountID">

		<cfset var qLookup = "" />
		<cfquery name="qLookup" datasource="#VARIABLES.dsn#">
			SELECT
				tblContribution.ContributionID,
				tblContribution.AccountID,
				tblContribution.ClubID,
				tblContribution.UserID,
				tblContribution.UserName,
				tblContribution.OrgYear,
				tblContribution.Amount,
				tblContribution.TranAmt,
				tblContribution.ConvFee,
				tblContribution.TranNo,
				tblContribution.TranType,
				tblContribution.Notes,
				tblContribution.bitSent,
				tblContribution.hm,
				tblContribution.HMName,
				tblContribution.HMAddress,
				tblContribution.Created_By,
				tblContribution.Created_Tmstmp,
				tblContribution.Modified_By,
				tblContribution.Modified_Tmstmp
				FROM	tblContribution
			WHERE 		1 = 1
			<cfif ARGUMENTS.ContributionID GT 0>
				AND		tblContribution.ContributionID 	= <CFQUERYPARAM Value="#ARGUMENTS.ContributionID#"	CFSQLTYPE="CF_SQL_INTEGER">
			<cfelse>
				AND		tblContribution.AccountID 	= <CFQUERYPARAM Value="#ARGUMENTS.AccountID#" CFSQLTYPE="CF_SQL_INTEGER">
				<cfif Len(ARGUMENTS.Filter) GT 0>
					AND		tblContribution.AccountID	LIKE <CFQUERYPARAM Value="#ARGUMENTS.Filter#%"		CFSQLTYPE="CF_SQL_VARCHAR">
				</cfif>
			</cfif>
			<cfswitch expression="#ARGUMENTS.SortBy#">
				<cfcase value="AccountID">ORDER BY 	tblContribution.AccountID </cfcase>
			</cfswitch>
		</cfquery>
		<cfreturn qLookup>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	ViewByClub -  Contribution
	Modifications
		10/31/2019 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="ViewByClub" access="public" output="true" returntype="Query" DisplayName="ViewByClub">
		<cfargument Name="AccountID"			Type="Numeric"	Required="No" 	Hint="AccountID"		Default="#SESSION.AccountID#">
		<cfargument Name="OrgYear"				Type="String"	Required="No" 	Hint="OrgYear"			Default="#SESSION.OrgYear#">
		<cfargument Name="Filter"				Type="String"	Required="No" 	Hint="Filter"			Default="">
		<cfargument Name="Override"				Type="string"	Required="No"	Hint="Override"			Default="N">
		<cfargument Name="SortBy"				Type="String"	Required="No" 	Hint="SortBy"			Default="ClubName">

		<cfset var qView = "" />
		<cfset var OrgYearM1 = Left(OrgYear,4)-1 & "-" & Right(OrgYear,2)-1>

		<cfquery name="qView" datasource="#VARIABLES.dsn#">
			SELECT
				tblClub.ClubID,
				tblClub.ClubName,
				tblClub.ClubNumber,
				tblClub.dFlag,
				tblClub.ClubSize As Size,
				tblClub.AccountID,
				tblAccount.AccountName,
				tblAccount.ZoneID,

				{ fn IFNULL(derivedContributionYTD.Amount, 0) } AS AmountYTD,
				{ fn IFNULL(derivedContributionMo.Amount, 0) } AS AmountMO,
				{ fn IFNULL(derivedContributionPriorYTD.Amount, 0) } AS AmountPriorYTD,
				{ fn IFNULL(derivedContributionPriorMo.Amount, 0) } AS AmountPriorMO,
				{ fn IFNULL(derivedGoal.Goal, 0) } AS Goal

			FROM		tblClub
			INNER JOIN	dbo.tblAccount ON dbo.tblClub.AccountID = dbo.tblAccount.AccountID

			LEFT OUTER JOIN	(
								SELECT	Sum(Amount) AS Amount, ClubID
								FROM	dbo.tblContribution
								WHERE	1 = 1
								AND		OrgYear = <CFQUERYPARAM Value="#ARGUMENTS.OrgYear#" CFSQLTYPE="CF_SQL_VARCHAR">
								GROUP BY ClubID
							) AS derivedContributionYTD ON dbo.tblClub.ClubID = derivedContributionYTD.ClubID

			LEFT OUTER JOIN	(
								SELECT	Sum(Amount) AS Amount, ClubID
								FROM	dbo.tblContribution
								WHERE	1 = 1
								AND		OrgYear = <CFQUERYPARAM Value="#OrgYearM1#" CFSQLTYPE="CF_SQL_VARCHAR">
								GROUP BY ClubID
							) AS derivedContributionPriorYTD ON dbo.tblClub.ClubID = derivedContributionPriorYTD.ClubID

			LEFT OUTER JOIN	(
								SELECT	Sum(Amount) AS Amount, ClubID
								FROM	dbo.tblContribution
								WHERE	1 = 1
								AND		OrgYear = <CFQUERYPARAM Value="#ARGUMENTS.OrgYear#" CFSQLTYPE="CF_SQL_VARCHAR">
								AND		MONTH(Created_Tmstmp) = MONTH(GetDate())
								GROUP BY ClubID
							) AS derivedContributionMo ON dbo.tblClub.ClubID = derivedContributionMo.ClubID

			LEFT OUTER JOIN	(
								SELECT	Sum(Amount) AS Amount, ClubID
								FROM	dbo.tblContribution
								WHERE	1 = 1
								AND		OrgYear = <CFQUERYPARAM Value="#OrgYearM1#" CFSQLTYPE="CF_SQL_VARCHAR">
								AND		MONTH(Created_Tmstmp) = MONTH(GetDate())
								GROUP BY ClubID
							) AS derivedContributionPriorMo ON dbo.tblClub.ClubID = derivedContributionPriorMo.ClubID

			LEFT OUTER JOIN	(
								SELECT	Sum(Goal) as Goal, ClubID
								FROM	dbo.tblGoal
								WHERE	1 = 1
								AND		OrgYear = <CFQUERYPARAM Value="#ARGUMENTS.OrgYear#" CFSQLTYPE="CF_SQL_VARCHAR">
								GROUP BY ClubID
							) AS derivedGoal ON dbo.tblClub.ClubID = derivedGoal.ClubID

			WHERE 		1 = 1
			<cfif ARGUMENTS.Override EQ "N">
				AND	 	tblClub.dFlag 			= 'N'
				AND	 	tblClub.IsActive 		= 'Y'
			</cfif>

			AND			tblClub.AccountID  				= <CFQUERYPARAM Value="#ARGUMENTS.AccountID#" CFSQLTYPE="CF_SQL_INTEGER">
			AND			tblClub.ClubTypeID 				IN (<CFQUERYPARAM Value="#SESSION.ClubType.IsActiveClub#" CFSQLTYPE="CF_SQL_INTEGER" list="Yes">)
			<cfif Len(ARGUMENTS.Filter) GT 0>
				<cfif IsNumeric(ARGUMENTS.Filter)>
					AND 	tblClub.ClubNumber			= <CFQUERYPARAM Value="#ARGUMENTS.Filter#" CFSQLTYPE="CF_SQL_INTEGER">
				<cfelse>
					AND 	tblClub.ClubName 			LIKE <cfqueryparam value="#ARGUMENTS.Filter#%">
				</cfif>
			</cfif>
			<cfswitch expression="#SESSION.RoleID#">
				<cfcase value="1,2,3,4">
					AND	 	tblClub.ClubID 	= <CFQUERYPARAM Value="#SESSION.ClubID#" CFSQLTYPE="CF_SQL_INTEGER">
				</cfcase>
			</cfswitch>

			<cfswitch expression="#ARGUMENTS.SortBy#">
				<cfcase value="ClubName">	ORDER BY dbo.tblClub.ClubName		</cfcase>
			</cfswitch>
		</cfquery>
		<cfreturn qView>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	ViewByDistrict -  Goal
	Modifications
		8/4/2019 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="ViewByDistrict" access="public" output="true" returntype="Query" DisplayName="ViewByDistrict">
		<cfargument Name="DomainID"				Type="Numeric"	Required="No" 	Hint="DomainID"			Default="0">
		<cfargument Name="AccountID"			Type="Numeric"	Required="No" 	Hint="AccountID"		Default="0">
		<cfargument Name="OrgYear"				Type="String"	Required="No" 	Hint="OrgYear"			Default="#SESSION.OrgYear#">
		<cfargument Name="Filter"				Type="String"	Required="No" 	Hint="Filter"			Default="">
		<cfargument Name="Override"				Type="string"	Required="No"	Hint="Override"			Default="N">
		<cfargument Name="SortBy"				Type="String"	Required="No" 	Hint="SortBy"			Default="ClubName">

		<cfset var qView = "" />
		<cfset var OrgYearM1 = Left(OrgYear,4)-1 & "-" & Right(OrgYear,2)-1>

		<cfquery name="qView" datasource="#VARIABLES.dsn#">
			SELECT
				tblAccount.AccountID,
				tblAccount.AccountName,
				tblAccount.ZoneID,
				( 	SELECT	IsNull(Sum(ClubSize),0) As CS
					FROM	dbo.tblClub
					WHERE	tblClub.AccountID = tblAccount.AccountID AND tblClub.dFlag = 'N' AND tblClub.IsActive = 'Y' AND tblClub.ClubTypeID = 0
				) AS Size,

				{ fn IFNULL(derivedContributionYTD.Amount, 0) } AS AmountYTD,
				{ fn IFNULL(derivedContributionMo.Amount, 0) } AS AmountMO,
				{ fn IFNULL(derivedContributionPriorYTD.Amount, 0) } AS AmountPriorYTD,
				{ fn IFNULL(derivedContributionPriorMo.Amount, 0) } AS AmountPriorMO,
				{ fn IFNULL(derivedGoal.Goal, 0) } AS Goal

			FROM		tblAccount
			LEFT OUTER JOIN	(
								SELECT	Sum(Amount) AS Amount, AccountID
								FROM	dbo.tblContribution
								WHERE	1 = 1
								AND		OrgYear = <CFQUERYPARAM Value="#ARGUMENTS.OrgYear#" CFSQLTYPE="CF_SQL_VARCHAR">
								GROUP BY AccountID
							) AS derivedContributionYTD ON dbo.tblAccount.AccountID = derivedContributionYTD.AccountID

			LEFT OUTER JOIN	(
								SELECT	Sum(Amount) AS Amount, AccountID
								FROM	dbo.tblContribution
								WHERE	1 = 1
								AND		OrgYear = <CFQUERYPARAM Value="#OrgYearM1#" CFSQLTYPE="CF_SQL_VARCHAR">
								GROUP BY AccountID
							) AS derivedContributionPriorYTD ON dbo.tblAccount.AccountID = derivedContributionPriorYTD.AccountID

			LEFT OUTER JOIN	(
								SELECT	Sum(Amount) AS Amount, AccountID
								FROM	dbo.tblContribution
								WHERE	1 = 1
								AND		OrgYear = <CFQUERYPARAM Value="#ARGUMENTS.OrgYear#" CFSQLTYPE="CF_SQL_VARCHAR">
								AND		MONTH(Created_Tmstmp) = MONTH(GetDate())
								GROUP BY AccountID
							) AS derivedContributionMo ON dbo.tblAccount.AccountID = derivedContributionMo.AccountID

			LEFT OUTER JOIN	(
								SELECT	Sum(Amount) AS Amount, AccountID
								FROM	dbo.tblContribution
								WHERE	1 = 1
								AND		OrgYear = <CFQUERYPARAM Value="#OrgYearM1#" CFSQLTYPE="CF_SQL_VARCHAR">
								AND		MONTH(Created_Tmstmp) = MONTH(GetDate())
								GROUP BY AccountID
							) AS derivedContributionPriorMo ON dbo.tblAccount.AccountID = derivedContributionPriorMo.AccountID

			LEFT OUTER JOIN	(
								SELECT	Sum(Goal) as Goal, AccountID
								FROM	dbo.tblGoal
								WHERE	1 = 1
								AND		OrgYear = <CFQUERYPARAM Value="#ARGUMENTS.OrgYear#" CFSQLTYPE="CF_SQL_VARCHAR">
								GROUP BY AccountID
							) AS derivedGoal ON dbo.tblAccount.AccountID = derivedGoal.AccountID

			WHERE 		1 = 1
			AND			tblAccount.AccountID 		> 0
			<cfif ARGUMENTS.Override EQ "N">
				AND	 	tblAccount.dFlag 			= 'N'
				AND	 	tblAccount.IsActive 		= 'Y'
			</cfif>
			<cfif ARGUMENTS.DomainID GT 0>
				AND			tblAccount.AccountID	IN 	(
														SELECT	AccountID
														FROM	tblDomainAccount
														WHERE	DomainID	= 	<CFQUERYPARAM Value="#ARGUMENTS.AccountID#" 	CFSQLTYPE="CF_SQL_INTEGER">
													)
			</cfif>
			<cfif ARGUMENTS.AccountID GT 0>
				AND			tblAccount.AccountID	= <CFQUERYPARAM Value="#ARGUMENTS.AccountID#" 	CFSQLTYPE="CF_SQL_INTEGER">
			</cfif>
			<cfif Len(ARGUMENTS.Filter) GT 0>
				AND		tblAccount.AccountName		LIKE <CFQUERYPARAM Value="#ARGUMENTS.Filter#%"		CFSQLTYPE="CF_SQL_VARCHAR">
			</cfif>
			<cfswitch expression="#ARGUMENTS.SortBy#">
				<cfcase value="AccountName">	ORDER BY dbo.tblAccount.ZoneID, dbo.tblAccount.AccountName		</cfcase>
			</cfswitch>
		</cfquery>
		<cfreturn qView>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	ViewByDomain -  Goal
	Modifications
		8/4/2019 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="ViewByDomain" access="public" output="true" returntype="Query" DisplayName="ViewByDomain">
		<cfargument Name="DomainID"				Type="Numeric"	Required="No" 	Hint="DomainID"			Default="0">
		<cfargument Name="OrgYear"				Type="String"	Required="No" 	Hint="OrgYear"			Default="#SESSION.OrgYear#">
		<cfargument Name="Filter"				Type="String"	Required="No" 	Hint="Filter"			Default="">
		<cfargument Name="Override"				Type="string"	Required="No"	Hint="Override"			Default="N">
		<cfargument Name="SortBy"				Type="String"	Required="No" 	Hint="SortBy"			Default="DomainID">

		<cfset var qView = "" />
		<cfset var OrgYearM1 = Left(OrgYear,4)-1 & "-" & Right(OrgYear,2)-1>

		<cfquery name="qView" datasource="#VARIABLES.dsn#">
			SELECT
				tblDomain.DomainID,
				tblDomain.DomainID As ZoneID,
				tblDomain.DomainName,
					(
						SELECT		ISNULL(SUM(dbo.tblClub.ClubSize), 0) AS Size
						FROM		dbo.tblClub
						INNER JOIN	dbo.tblDomainAccount ON dbo.tblClub.AccountID = dbo.tblDomainAccount.AccountID
						WHERE		dbo.tblDomainAccount.DomainID = tblDomain.DomainID
					) AS Size
				,{ fn IFNULL(derivedContributionYTD.Amount, 0) } AS AmountYTD
				,{ fn IFNULL(derivedContributionPriorYTD.Amount, 0) } AS AmountPriorYTD
				,{ fn IFNULL(derivedContributionMo.Amount, 0) } AS AmountMO
				,{ fn IFNULL(derivedContributionPriorMo.Amount, 0) } AS AmountPriorMO
				,{ fn IFNULL(derivedGoal.Goal, 0) } AS Goal

			FROM	tblDomain
			LEFT OUTER JOIN	(
								SELECT	Sum(dbo.tblContribution.Amount) AS Amount, dbo.tblDomainAccount.DomainID
								FROM	dbo.tblContribution
								INNER JOIN	dbo.tblDomainAccount ON dbo.tblContribution.AccountID = dbo.tblDomainAccount.AccountID
								WHERE	1 = 1
								AND		dbo.tblContribution.OrgYear = <CFQUERYPARAM Value="#ARGUMENTS.OrgYear#" CFSQLTYPE="CF_SQL_VARCHAR">
								GROUP BY dbo.tblDomainAccount.DomainID
							) AS derivedContributionYTD ON dbo.tblDomain.DomainID = derivedContributionYTD.DomainID

			LEFT OUTER JOIN	(
								SELECT	Sum(Amount) AS Amount,  dbo.tblDomainAccount.DomainID
								FROM	dbo.tblContribution
								INNER JOIN	dbo.tblDomainAccount ON dbo.tblContribution.AccountID = dbo.tblDomainAccount.AccountID
								WHERE	1 = 1
								AND		OrgYear = <CFQUERYPARAM Value="#OrgYearM1#" CFSQLTYPE="CF_SQL_VARCHAR">
								GROUP BY dbo.tblDomainAccount.DomainID
							) AS derivedContributionPriorYTD ON dbo.tblDomain.DomainID = derivedContributionPriorYTD.DomainID

			LEFT OUTER JOIN	(
								SELECT	Sum(Amount) AS Amount,  dbo.tblDomainAccount.DomainID
								FROM	dbo.tblContribution
								INNER JOIN	dbo.tblDomainAccount ON dbo.tblContribution.AccountID = dbo.tblDomainAccount.AccountID
								WHERE	1 = 1
								AND		OrgYear = <CFQUERYPARAM Value="#ARGUMENTS.OrgYear#" CFSQLTYPE="CF_SQL_VARCHAR">
								AND		MONTH(dbo.tblContribution.Created_Tmstmp) = MONTH(GetDate())
								GROUP BY dbo.tblDomainAccount.DomainID
							) AS derivedContributionMo ON dbo.tblDomain.DomainID = derivedContributionMo.DomainID

			LEFT OUTER JOIN	(
								SELECT	Sum(Amount) AS Amount,  dbo.tblDomainAccount.DomainID
								FROM	dbo.tblContribution
								INNER JOIN	dbo.tblDomainAccount ON dbo.tblContribution.AccountID = dbo.tblDomainAccount.AccountID
								WHERE	1 = 1
								AND		OrgYear = <CFQUERYPARAM Value="#OrgYearM1#" CFSQLTYPE="CF_SQL_VARCHAR">
								AND		MONTH(dbo.tblContribution.Created_Tmstmp) = MONTH(GetDate())
								GROUP BY dbo.tblDomainAccount.DomainID
							) AS derivedContributionPriorMo ON dbo.tblDomain.DomainID = derivedContributionPriorMo.DomainID

			LEFT OUTER JOIN	(
								SELECT	Sum(Goal) as Goal,  dbo.tblDomainAccount.DomainID
								FROM	dbo.tblGoal
								INNER JOIN	dbo.tblDomainAccount ON dbo.tblGoal.AccountID = dbo.tblDomainAccount.AccountID
								WHERE	1 = 1
								AND		OrgYear = <CFQUERYPARAM Value="#ARGUMENTS.OrgYear#" CFSQLTYPE="CF_SQL_VARCHAR">
								GROUP BY dbo.tblDomainAccount.DomainID
							) AS derivedGoal ON dbo.tblDomain.DomainID = derivedGoal.DomainID
			WHERE 		1 = 1
<!---
			AND			tblDomainAccount.AccountID	IN 	(<CFQUERYPARAM Value="#AccountIDs#" CFSQLTYPE="CF_SQL_INTEGER" List="Yes">)
 --->

			<cfswitch expression="#ARGUMENTS.SortBy#">
				<cfcase value="DomainID">	ORDER BY dbo.tblDomain.DomainID		</cfcase>
			</cfswitch>
		</cfquery>

		<cfreturn qView>

	</cffunction>


<!--- ----------------------------------------------------------------------------------------------------------------
	List -  Contribution
	Modifications
		2/7/2020 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="List" access="public" output="false" returntype="Query" DisplayName="List">
		<cfargument name="ContributionID"		Type="numeric"	Required="No"	Hint="ContributionID"	Default="0" />
		<cfargument Name="AccountID"			Type="Numeric"	Required="No"	Hint="AccountID"		Default="0">
		<cfargument Name="ClubID"				Type="Numeric"	Required="No"	Hint="ClubID"			Default="0">
		<cfargument Name="UserID"				Type="Numeric"	Required="No"	Hint="UserID"			Default="0">

		<cfargument Name="OrgYear"				Type="string"	Required="No"	Hint="OrgYear"			Default="">
		<cfargument Name="PeriodStart"			Type="string"	Required="No"	Hint="PeriodStart"		Default="">
		<cfargument Name="PeriodEnd"			Type="string"	Required="No"	Hint="PeriodEnd"		Default="">


		<cfargument Name="Filter"				Type="string"	Required="No"	Hint="Filter Value"		Default="">
		<cfargument Name="Scope"				Type="String"	Required="No"	Hint="Scope"			Default="C">		<!--- C|A|D --->
		<cfargument Name="SortBy"				Type="String"	Required="No"	Hint="SortBy"			Default="ID">

		<cfset var qView = "" />

		<cfquery name="qView" datasource="#VARIABLES.dsn#">
SELECT        dbo.tblContribution.ContributionID, dbo.tblContribution.AccountID, dbo.tblContribution.ClubID, dbo.tblClub.ClubName, dbo.tblClub.ClubNumber, dbo.tblContribution.UserID, dbo.tblContribution.UserName,
                         dbo.tblContribution.Amount,  dbo.tblContribution.TranAmt, dbo.tblContribution.TranNo, dbo.tblContribution.TranType, dbo.tblContribution.OrgYear, dbo.tblContribution.Notes, tblUser_1.UserName AS Created_By, dbo.tblContribution.Created_Tmstmp,
                         tblUser_2.UserName AS Modified_By, dbo.tblContribution.Modified_Tmstmp,
						CASE tblClub.ClubID WHEN 0 THEN 0 ELSE 1 END As SortGrp
FROM            dbo.tblContribution INNER JOIN
                         dbo.tblAccount ON dbo.tblContribution.AccountID = dbo.tblAccount.AccountID INNER JOIN
                         dbo.tblClub ON dbo.tblContribution.ClubID = dbo.tblClub.ClubID LEFT OUTER JOIN
                         dbo.tblUser AS tblUser_1 ON dbo.tblContribution.Created_By = tblUser_1.UserID LEFT OUTER JOIN
                         dbo.tblUser AS tblUser_2 ON dbo.tblContribution.Modified_By = tblUser_2.UserID

			WHERE 		1 = 1
			<cfif ARGUMENTS.ContributionID GT 0>
				AND		tblContribution.ContributionID 		= <CFQUERYPARAM Value="#ARGUMENTS.ContributionID#"	CFSQLTYPE="CF_SQL_INTEGER">
			<cfelse>
				<cfif Len(ARGUMENTS.OrgYear)>
					AND 	tblContribution.OrgYear			= <CFQUERYPARAM Value="#ARGUMENTS.OrgYear#"			CFSQLTYPE="CF_SQL_VARCHAR">
				</cfif>
				<cfif IsDate(ARGUMENTS.PeriodStart)>
					AND 	Convert(date, tblContribution.Created_Tmstmp)	>= #CreateODBCDate(ARGUMENTS.PeriodStart)#
				</cfif>
				<cfif IsDate(ARGUMENTS.PeriodEnd)>
					AND 	Convert(date, tblContribution.Created_Tmstmp)	<= #CreateODBCDate(ARGUMENTS.PeriodEnd)#
				</cfif>
				<cfif ARGUMENTS.AccountID GT 0>
					AND			tblContribution.AccountID 	= <CFQUERYPARAM Value="#ARGUMENTS.AccountID#" 		CFSQLTYPE="CF_SQL_INTEGER">
				</cfif>
				<cfif ARGUMENTS.ClubID GT 0>
					AND			tblContribution.ClubID 		= <CFQUERYPARAM Value="#ARGUMENTS.ClubID#" 			CFSQLTYPE="CF_SQL_INTEGER">
				</cfif>
				<cfif ARGUMENTS.UserID GT 0>
					AND			tblContribution.UserID 		= <CFQUERYPARAM Value="#ARGUMENTS.UserID#" 			CFSQLTYPE="CF_SQL_INTEGER">
				</cfif>
				<cfif Len(ARGUMENTS.Filter) GT 0>
					AND		(
								tblClub.ClubName				LIKE <CFQUERYPARAM Value="#ARGUMENTS.Filter#%"		CFSQLTYPE="CF_SQL_VARCHAR"> OR
								tblContribution.UserName		LIKE <CFQUERYPARAM Value="#ARGUMENTS.Filter#%"		CFSQLTYPE="CF_SQL_VARCHAR">
							)
				</cfif>
			</cfif>
			<cfswitch expression="#SESSION.RoleID#">
				<cfcase value="1,2,3,4">
					AND	 	tblClub.ClubID 		= <CFQUERYPARAM Value="#SESSION.ClubID#" CFSQLTYPE="CF_SQL_INTEGER">
				</cfcase>
				<cfcase value="5,6,7">
					AND	 	tblClub.AccountID 	IN (<CFQUERYPARAM Value="#SESSION.AccountIDs#" CFSQLTYPE="CF_SQL_INTEGER" List="Yes">)
				</cfcase>
			</cfswitch>

			<cfswitch expression="#ARGUMENTS.SortBy#">
				<cfcase value="AccountID">	ORDER BY dbo.tblContribution.AccountID,	SortGrp, dbo.tblClub.ClubName, dbo.tblContribution.Created_Tmstmp Desc								</cfcase>
				<cfcase value="ClubName">	ORDER BY SortGrp, dbo.tblClub.ClubName, dbo.tblContribution.Created_Tmstmp Desc	</cfcase>
				<cfcase value="ClubGrp">	ORDER BY SortGrp, dbo.tblClub.ClubName, dbo.tblContribution.Created_Tmstmp Desc	</cfcase>
				<cfcase value="Tmstmp">		ORDER BY dbo.tblContribution.Created_Tmstmp Desc						</cfcase>
				<cfcase value="ID">			ORDER BY dbo.tblContribution.ContributionID DESC						</cfcase>
			</cfswitch>
		</cfquery>
		<cfreturn qView>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	ListX -  Contribution
	Modifications
		10/31/2019 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="ListX" access="public" output="false" returntype="Query" DisplayName="ListX output to excel">
		<cfargument name="ContributionID"		Type="numeric"	Required="No"	Hint="ContributionID"	Default="0" />
		<cfargument Name="AccountID"			Type="Numeric"	Required="No"	Hint="AccountID"		Default="0">
		<cfargument Name="ClubID"				Type="Numeric"	Required="No"	Hint="ClubID"			Default="0">
		<cfargument Name="UserID"				Type="Numeric"	Required="No"	Hint="UserID"			Default="0">
		<cfargument Name="OrgYear"				Type="string"	Required="No"	Hint="OrgYear"			Default="#SESSION.OrgYear#">
		<cfargument Name="Filter"				Type="string"	Required="No"	Hint="Filter Value"		Default="">
		<cfargument Name="SortBy"				Type="String"	Required="No"	Hint="SortBy"			Default="ID">

		<cfset var qView = "" />

		<cfquery name="qView" datasource="#VARIABLES.dsn#">
SELECT        dbo.tblContribution.AccountID As DistrictID, dbo.tblClub.ClubName, dbo.tblClub.ClubNumber, dbo.tblContribution.UserName,
                         dbo.tblContribution.Amount, dbo.tblContribution.TranNo AS Tran_No, dbo.tblContribution.TranType AS Type, dbo.tblContribution.OrgYear, dbo.tblContribution.Notes
FROM            dbo.tblContribution INNER JOIN
                         dbo.tblAccount ON dbo.tblContribution.AccountID = dbo.tblAccount.AccountID INNER JOIN
                         dbo.tblClub ON dbo.tblContribution.ClubID = dbo.tblClub.ClubID LEFT OUTER JOIN
                         dbo.tblUser AS tblUser_1 ON dbo.tblContribution.Created_By = tblUser_1.UserID LEFT OUTER JOIN
                         dbo.tblUser AS tblUser_2 ON dbo.tblContribution.Modified_By = tblUser_2.UserID

			WHERE 		1 = 1
			<cfif ARGUMENTS.ContributionID GT 0>
				AND		tblContribution.ContributionID 		= <CFQUERYPARAM Value="#ARGUMENTS.ContributionID#"	CFSQLTYPE="CF_SQL_INTEGER">
			<cfelse>
				AND		tblContribution.OrgYear 			= <CFQUERYPARAM Value="#ARGUMENTS.OrgYear#"			CFSQLTYPE="CF_SQL_VARCHAR">
				<cfif ARGUMENTS.AccountID GT 0>
					AND			tblContribution.AccountID 	= <CFQUERYPARAM Value="#ARGUMENTS.AccountID#" 		CFSQLTYPE="CF_SQL_INTEGER">
				</cfif>
				<cfif ARGUMENTS.ClubID GT 0>
					AND			tblContribution.ClubID 		= <CFQUERYPARAM Value="#ARGUMENTS.ClubID#" 			CFSQLTYPE="CF_SQL_INTEGER">
				</cfif>
				<cfif ARGUMENTS.UserID GT 0>
					AND			tblContribution.UserID 		= <CFQUERYPARAM Value="#ARGUMENTS.UserID#" 			CFSQLTYPE="CF_SQL_INTEGER">
				</cfif>
				<cfif Len(ARGUMENTS.Filter) GT 0>
					AND		(
								tblClub.ClubName				LIKE <CFQUERYPARAM Value="#ARGUMENTS.Filter#%"		CFSQLTYPE="CF_SQL_VARCHAR"> OR
								tblContribution.UserName		LIKE <CFQUERYPARAM Value="#ARGUMENTS.Filter#%"		CFSQLTYPE="CF_SQL_VARCHAR">
							)
				</cfif>
			</cfif>
			<cfswitch expression="#ARGUMENTS.SortBy#">
				<cfcase value="AccountID">	ORDER BY dbo.tblContribution.AccountID									</cfcase>
				<cfcase value="ClubName">	ORDER BY dbo.tblClub.ClubName, dbo.tblContribution.Created_Tmstmp Desc	</cfcase>
				<cfcase value="Tmstmp">		ORDER BY dbo.tblContribution.Created_Tmstmp Desc						</cfcase>
				<cfcase value="ID">			ORDER BY dbo.tblContribution.ContributionID DESC						</cfcase>
			</cfswitch>
		</cfquery>
		<cfreturn qView>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Read -  Contribution
	Modifications
		4/20/2020 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Read" access="public" output="false" returntype="struct" DisplayName="Read Contribution">
		<cfargument name="Contribution"		type="Contribution"		required="Yes" />

		<cfset var qRead = "" />
		<cfset var strReturn = structNew() />

		<cfquery name="qRead" datasource="#VARIABLES.dsn#">
			SELECT
				tblContribution.ContributionID,
				tblContribution.AccountID,
				tblContribution.ClubID,
				tblContribution.UserID,
				tblContribution.UserName,
				tblContribution.OrgYear,
				tblContribution.Amount,
				tblContribution.TranAmt,
				tblContribution.ConvFee,
				tblContribution.TranNo,
				tblContribution.TranType,
				tblContribution.Notes,
				tblContribution.bitSent,
				tblContribution.hm,
				tblContribution.HMName,
				tblContribution.HMAddress,
				dbo.tblClub.ClubName,
				tblUser_1.UserName AS Created_By,
				tblContribution.Created_Tmstmp,
				tblUser_2.UserName AS Modified_By,
				tblContribution.Modified_Tmstmp
			FROM	tblContribution
			INNER JOIN	dbo.tblClub ON dbo.tblContribution.ClubID = dbo.tblClub.ClubID
			LEFT OUTER JOIN	tblUser AS tblUser_1 ON tblContribution.Created_By = tblUser_1.UserID
			LEFT OUTER JOIN tblUser AS tblUser_2 ON tblContribution.Modified_By = tblUser_2.UserID
			WHERE	1 = 1
			AND		tblContribution.ContributionID = <cfqueryparam value="#ARGUMENTS.Contribution.getContributionID()#" CFSQLType="cf_sql_integer" />
		</cfquery>
		<cfif qRead.recordCount>
			<cfset strReturn = queryRowToStruct(qRead)>
			<cfset ARGUMENTS.Contribution.init(argumentCollection=strReturn)>
		<cfelse>
			<cfset strReturn = Contribution.getMemento()>
		</cfif>
		<cfreturn strReturn>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Exists -  Contribution
	Modifications
		4/20/2020 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Exists" access="public" output="false" returntype="boolean" DisplayName="Exists Contribution">
		<cfargument name="Contribution"		type="Contribution"		required="Yes" />

		<cfset var qExists = "">
		<cfset var ContributionID = ARGUMENTS.Contribution.getContributionID()>

		<cfquery name="qExists" datasource="#variables.dsn#" maxrows="1">
			SELECT	count(1) as idexists
			FROM	tblContribution
			WHERE	1 = 1
			AND		ContributionID 	= <cfqueryparam value="#ARGUMENTS.Contribution.getContributionID()#" CFSQLType="cf_sql_integer" />

<!---
			<cfif ContributionID GT 0>
			<cfelse>
				AND		AccountID 	= <cfqueryparam value="#ARGUMENTS.Contribution.getAccountID()#" CFSQLType="cf_sql_integer" />
				AND		ClubID 		= <cfqueryparam value="#ARGUMENTS.Contribution.getClubID()#" 	CFSQLType="cf_sql_integer" />
				AND		UserID 		= 0
				AND		OrgYear		= <cfqueryparam value="#ARGUMENTS.Contribution.getOrgYear()#" 	CFSQLType="cf_sql_varchar" />
			</cfif>
 --->
		</cfquery>
		<cfif qExists.idexists>
			<cfreturn TRUE />
		<cfelse>
			<cfreturn FALSE />
		</cfif>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Save -  Contribution
	Modifications
		4/20/2020 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Save" access="public" output="false" returntype="numeric" DisplayName="Save Contribution Contribution">
		<cfargument name="Contribution"		type="Contribution"		required="Yes" />

		<cfset var pkID = 0 />		<!--- 0=false --->
		<cfif exists(arguments.Contribution)>
			<cfset pkID = update(arguments.Contribution) />
		<cfelse>
			<cfset pkID = create(arguments.Contribution) />
		</cfif>

		<cfreturn pkID />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	InsertRec -  Contribution
	Modifications
		2/7/2020 - created

	<cfinvoke component="\CFC\ContributionDAO" method="InsertRec" returnvariable="ContributionID">
		<cfinvokeargument name="AccountID"		Value="#AccountID#">
		<cfinvokeargument name="ClubID"		Value="#ClubID#">
		<cfinvokeargument name="UserID"		Value="#UserID#">
		<cfinvokeargument name="UserName"		Value="#UserName#">
		<cfinvokeargument name="OrgYear"		Value="#OrgYear#">
		<cfinvokeargument name="Amount"		Value="#Amount#">
		<cfinvokeargument name="TranAmt"		Value="#TranAmt#">
		<cfinvokeargument name="TranNo"		Value="#TranNo#">
		<cfinvokeargument name="TranType"		Value="#TranType#">
		<cfinvokeargument name="Notes"		Value="#Notes#">
		<cfinvokeargument name="hm"		Value="#hm#">
		<cfinvokeargument name="bitSent"		Value="#bitSent#">
		<cfinvokeargument name="HMName"		Value="#HMName#">
		<cfinvokeargument name="HMAddress"		Value="#HMAddress#">
	</cfinvoke>
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="InsertRec" access="public" output="false" returntype="numeric" DisplayName="InsertRec Contribution">
		<cfargument name="AccountID"				Type="numeric"		Required="No"		Default="#SESSION.AccountID#" />
		<cfargument name="ClubID"					Type="numeric"		Required="No"		Default="#SESSION.ClubID#" />
		<cfargument name="UserID"					Type="numeric"		Required="No"		Default="0" />
		<cfargument name="UserName"					Type="string"		Required="Yes"		Default="" />
		<cfargument name="OrgYear"					Type="string"		Required="No"		Default="" />
		<cfargument name="Amount"					Type="numeric"		Required="No"		Default="0.00" />
		<cfargument name="TranAmt"					Type="numeric"		Required="No"		Default="0.00" />
		<cfargument name="ConvFee"					Type="numeric"		Required="No"		Default="0.00" />
		<cfargument name="TranNo"					Type="string"		Required="Yes"		Default="" />
		<cfargument name="TranType"					Type="string"		Required="Yes"		Default="" />
		<cfargument name="Notes"					Type="string"		Required="Yes"		Default="" />
		<cfargument name="bitSent"					Type="boolean"		Required="No"		Default="0" />
		<cfargument name="hm"						Type="string"		Required="Yes"		Default="" />
		<cfargument name="HMName"					Type="string"		Required="Yes"		Default="" />
		<cfargument name="HMAddress"				Type="string"		Required="Yes"		Default="" />
		<cfargument name="OnErrorContinue"			Type="String"		Required="No"		Default="N" />

		<cfset var qInsert = "" />
		<cfset var R       = "" />

		<cftry>
			<cfquery name="qInsert" datasource="#VARIABLES.dsn#" Result="R">
				INSERT INTO tblContribution
					(
					tblContribution.AccountID,
					tblContribution.ClubID,
					tblContribution.UserID,
					tblContribution.UserName,
					tblContribution.OrgYear,
					tblContribution.Amount,
					tblContribution.TranAmt,
					tblContribution.ConvFee,
					tblContribution.TranNo,
					tblContribution.TranType,
					tblContribution.Notes,
					tblContribution.bitSent,
					tblContribution.hm,
					tblContribution.HMName,
					tblContribution.HMAddress,
					tblContribution.Created_By,
					tblContribution.Created_Tmstmp
					)
				VALUES
					(
					<cfqueryparam value="#ARGUMENTS.AccountID#"				CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#ARGUMENTS.ClubID#"					CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#ARGUMENTS.UserID#"					CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#Left(ARGUMENTS.UserName,80)#"					CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.UserName)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.OrgYear,7)#"					CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.OrgYear)#" />,
					<cfqueryparam value="#ARGUMENTS.Amount#"					CFSQLType="CF_SQL_MONEY" />,
					<cfqueryparam value="#ARGUMENTS.TranAmt#"					CFSQLType="CF_SQL_MONEY" />,
					<cfqueryparam value="#ARGUMENTS.ConvFee#"					CFSQLType="CF_SQL_MONEY" />,
					<cfqueryparam value="#Left(ARGUMENTS.TranNo,32)#"					CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.TranNo)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.TranType,2)#"					CFSQLType="CF_SQL_CHAR" 			null="#not len(ARGUMENTS.TranType)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.Notes,255)#"					CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.Notes)#" />,
					<cfqueryparam value="#ARGUMENTS.bitSent#"					CFSQLType="CF_SQL_BIT" />,
					<cfqueryparam value="#Left(ARGUMENTS.hm,1)#"						CFSQLType="CF_SQL_CHAR" 			null="#not len(ARGUMENTS.hm)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.HMName,50)#"					CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.HMName)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.HMAddress,255)#"				CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.HMAddress)#" />,
					<cfqueryparam value="#SESSION.UserID#"										CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#Now()#"											CFSQLType="CF_SQL_TIMESTAMP" />
					)
			</cfquery>
			<CF_XLogCart Table="Contribution" type="I" Value="#R.IDENTITYCOL#" Desc="Insert into Contribution">
			<cfcatch type="database">
				<cfif ARGUMENTS.OnErrorContinue EQ "N">
					<CF_XLogCart Table="Contribution" type="E" Value="0" Desc="Error inserting Contribution (#cfcatch.detail#)" >
				</cfif>
				<cfreturn 0 />
			</cfcatch>
		</cftry>
		<cfreturn R.IDENTITYCOL />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Create -  Contribution
	Modifications
		4/20/2020 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Create" access="public" output="false" returntype="numeric" DisplayName="Create Contribution">
		<cfargument name="Contribution"			Type="Contribution"	required="Yes" />
		<cfargument name="OnErrorContinue"  	Type="String"		required="No"	Default="N" />

		<cfset var qCreate = "" />
		<cfset var R       = "" />

		<cftry>
			<cfquery name="qCreate" datasource="#VARIABLES.dsn#" Result="R">
				INSERT INTO tblContribution
					(
					tblContribution.AccountID,
					tblContribution.ClubID,
					tblContribution.UserID,
					tblContribution.UserName,
					tblContribution.OrgYear,
					tblContribution.Amount,
					tblContribution.TranAmt,
					tblContribution.ConvFee,
					tblContribution.TranNo,
					tblContribution.TranType,
					tblContribution.Notes,
					tblContribution.bitSent,
					tblContribution.hm,
					tblContribution.HMName,
					tblContribution.HMAddress,
					tblContribution.Created_By,
					tblContribution.Created_Tmstmp
					)
				VALUES
					(
					<cfqueryparam value="#ARGUMENTS.Contribution.getAccountID()#"					CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#ARGUMENTS.Contribution.getClubID()#"						CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#ARGUMENTS.Contribution.getUserID()#"						CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#Left(ARGUMENTS.Contribution.getUserName(),80)#"				CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.Contribution.getUserName())#" />,
					<cfqueryparam value="#Left(ARGUMENTS.Contribution.getOrgYear(),7)#"				CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.Contribution.getOrgYear())#" />,
					<cfqueryparam value="#ARGUMENTS.Contribution.getAmount()#"						CFSQLType="CF_SQL_MONEY" />,
					<cfqueryparam value="#ARGUMENTS.Contribution.getTranAmt()#"						CFSQLType="CF_SQL_MONEY" />,
					<cfqueryparam value="#ARGUMENTS.Contribution.getConvFee()#"						CFSQLType="CF_SQL_MONEY" />,
					<cfqueryparam value="#Left(ARGUMENTS.Contribution.getTranNo(),32)#"					CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.Contribution.getTranNo())#" />,
					<cfqueryparam value="#Left(ARGUMENTS.Contribution.getTranType(),2)#"				CFSQLType="CF_SQL_CHAR"		null="#not len(ARGUMENTS.Contribution.getTranType())#" />,
					<cfqueryparam value="#Left(ARGUMENTS.Contribution.getNotes(),255)#"					CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.Contribution.getNotes())#" />,
					<cfqueryparam value="#ARGUMENTS.Contribution.getbitSent()#"						CFSQLType="CF_SQL_BIT" />,
					<cfqueryparam value="#Left(ARGUMENTS.Contribution.gethm(),1)#"						CFSQLType="CF_SQL_CHAR"		null="#not len(ARGUMENTS.Contribution.gethm())#" />,
					<cfqueryparam value="#Left(ARGUMENTS.Contribution.getHMName(),50)#"					CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.Contribution.getHMName())#" />,
					<cfqueryparam value="#Left(ARGUMENTS.Contribution.getHMAddress(),255)#"				CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.Contribution.getHMAddress())#" />,
					<cfqueryparam value="#SESSION.UserID#"											CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#Now()#"													CFSQLType="CF_SQL_TIMESTAMP" />
				)
			</cfquery>
			<CF_XLogCart Table="Contribution" type="I" Value="#R.IDENTITYCOL#" Desc="#ARGUMENTS.Contribution.getAccountID()# created">
			<cfcatch type="database">
				<cfif ARGUMENTS.OnErrorContinue EQ "N">
					<CF_XLogCart Table="Contribution" type="E" Value="0" Desc="Error inserting Contribution (#cfcatch.detail#)" >
				</cfif>
				<cfreturn 0 />
			</cfcatch>
		</cftry>
		<cfreturn R.IDENTITYCOL />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Update -  Contribution
	Modifications
		4/20/2020 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Update" access="public" output="false" returntype="numeric" DisplayName="Update Contribution">
		<cfargument name="Contribution"				Type="Contribution"	required="Yes" />
		<cfargument name="OnErrorContinue"		Type="String"			required="No"	Default="N" />

		<cfset var qUpdate = "" />

		<cftry>
			<cfquery name="qUpdate" datasource="#VARIABLES.dsn#">
				UPDATE tblContribution
				SET
					AccountID			= <cfqueryparam value="#ARGUMENTS.Contribution.getAccountID()#"					CFSQLType="CF_SQL_INTEGER" />,
					ClubID				= <cfqueryparam value="#ARGUMENTS.Contribution.getClubID()#"					CFSQLType="CF_SQL_INTEGER" />,
					UserID				= <cfqueryparam value="#ARGUMENTS.Contribution.getUserID()#"					CFSQLType="CF_SQL_INTEGER" />,
					UserName			= <cfqueryparam value="#Left(ARGUMENTS.Contribution.getUserName(),80)#"			CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.Contribution.getUserName())#" />,
					OrgYear				= <cfqueryparam value="#Left(ARGUMENTS.Contribution.getOrgYear(),7)#"			CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.Contribution.getOrgYear())#" />,
					Amount				= <cfqueryparam value="#ARGUMENTS.Contribution.getAmount()#"					CFSQLType="CF_SQL_MONEY" />,
					TranAmt					= <cfqueryparam value="#ARGUMENTS.Contribution.getTranAmt()#"				CFSQLType="CF_SQL_MONEY" />,
					ConvFee					= <cfqueryparam value="#ARGUMENTS.Contribution.getConvFee()#"				CFSQLType="CF_SQL_MONEY" />,
					TranNo				= <cfqueryparam value="#Left(ARGUMENTS.Contribution.getTranNo(),32)#"			CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.Contribution.getTranNo())#" />,
					TranType				= <cfqueryparam value="#Left(ARGUMENTS.Contribution.getTranType(),2)#"		CFSQLType="CF_SQL_CHAR" 			null="#not len(ARGUMENTS.Contribution.getTranType())#" />,
					Notes					= <cfqueryparam value="#Left(ARGUMENTS.Contribution.getNotes(),255)#"		CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.Contribution.getNotes())#" />,
					bitSent					= <cfqueryparam value="#ARGUMENTS.Contribution.getbitSent()#"				CFSQLType="CF_SQL_BIT" />,
					hm						= <cfqueryparam value="#Left(ARGUMENTS.Contribution.gethm(),1)#"			CFSQLType="CF_SQL_CHAR" 			null="#not len(ARGUMENTS.Contribution.gethm())#" />,
					HMName					= <cfqueryparam value="#Left(ARGUMENTS.Contribution.getHMName(),50)#"		CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.Contribution.getHMName())#" />,
					HMAddress			= <cfqueryparam value="#Left(ARGUMENTS.Contribution.getHMAddress(),255)#"		CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.Contribution.getHMAddress())#" />,
					Modified_By			= <cfqueryparam value="#SESSION.UserID#" 										CFSQLType="CF_SQL_INTEGER" />,
					Modified_Tmstmp		= <cfqueryparam value="#Now()#" 												CFSQLType="CF_SQL_TIMESTAMP" />
				WHERE	1 = 1
				AND		ContributionID	= <cfqueryparam value="#ARGUMENTS.Contribution.getContributionID()#"			CFSQLType="cf_sql_integer" />
			</cfquery>
			<CF_XLogCart Table="Contribution" type="U" Value="#ARGUMENTS.Contribution.getContributionID()#" Desc="Contribution #ARGUMENTS.Contribution.getAccountID()# Updated">
			<cfcatch type="database">
				<cfif ARGUMENTS.OnErrorContinue EQ "N">
					<CF_XLogCart Table="Contribution" type="E" Value="0" Desc="Error updating Contribution (#cfcatch.detail#)" >
				</cfif>
				<cfreturn 0 />
			</cfcatch>
		</cftry>
		<cfreturn ARGUMENTS.Contribution.getContributionID() />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	UpdateByContributionID -  Contribution
	Modifications
		8/4/2019 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="UpdateByContributionID" access="public" output="true" returntype="numeric" DisplayName="Update Contribution">
		<cfargument name="ContributionID"			Type="numeric"		Required="Yes" />
		<cfargument name="Amount"					Type="numeric"		Required="Yes" 		Default="0" />
		<cfargument name="TranAmt"					Type="numeric"		Required="Yes" 		Default="0" />
		<cfargument name="TranNo"					Type="string"		Required="Yes" />
		<cfargument name="Notes"					Type="string"		Required="Yes" />
		<cfargument name="OnErrorContinue"			Type="String"		Required="No"		Default="N" />

		<cfset var qUpdate = "" />

		<cftry>
			<cfquery name="qUpdate" datasource="#VARIABLES.dsn#">
				UPDATE tblContribution
				SET
					<!--- Amount				= <cfqueryparam value="#ARGUMENTS.Amount#"					CFSQLType="CF_SQL_MONEY" />, Set before going to CC Company--->
					TranAmt				= <cfqueryparam value="#ARGUMENTS.TranAmt#"					CFSQLType="CF_SQL_MONEY" />,
					TranNo				= <cfqueryparam value="#Left(ARGUMENTS.TranNo,32)#"			CFSQLType="CF_SQL_VARCHAR"  />,
					Notes				= <cfqueryparam value="#Left(ARGUMENTS.Notes,255)#"			CFSQLType="CF_SQL_VARCHAR"  />,
					Modified_By			= <cfqueryparam value="#SESSION.UserID#" 					CFSQLType="CF_SQL_INTEGER" />,
					Modified_Tmstmp		= <cfqueryparam value="#Now()#" 							CFSQLType="CF_SQL_TIMESTAMP" />
				WHERE	1 = 1
				AND		ContributionID	= <cfqueryparam value="#ARGUMENTS.ContributionID#"			CFSQLType="cf_sql_integer" />
			</cfquery>
			<CF_XLogCart Table="Contribution" type="U" Value="#ARGUMENTS.ContributionID#" Desc="Contribution Updated, #DollarFormat(ARGUMENTS.Amount)#/#DollarFormat(ARGUMENTS.TranAMt)#, #Left(ARGUMENTS.TranNo,32)# #ARGUMENTS.Notes#">
			<cfcatch type="database">
				<cfif ARGUMENTS.OnErrorContinue EQ "N">
					<CF_XLogCart Table="Contribution" type="E" Value="0" Desc="Error updating Contribution (#cfcatch.detail#)" >
				</cfif>
				<cfreturn 0 />
			</cfcatch>
		</cftry>
		<cfreturn ContributionID />

	</cffunction>
<!--- ----------------------------------------------------------------------------------------------------------------
	Delete -  Contribution
	Modifications
		4/20/2020 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Delete" access="public" output="false" returntype="boolean" DisplayName="Delete Contribution">
		<cfargument name="Contribution"			type="Contribution"	required="Yes" />
		<cfargument name="OnErrorContinue"  	Type="String"		required="No"	Default="N" />

		<cfset var qDelete = "" />
		<cfset var R       = "" />

		<cftry>
			<cfquery name="qDelete" datasource="#VARIABLES.dsn#" Result="R">
				DELETE FROM	tblContribution
				WHERE	1 = 1
				AND		ContributionID = <cfqueryparam value="#ARGUMENTS.Contribution.getContributionID()#" 		CFSQLType="cf_sql_integer" />
			</cfquery>
			<CF_XLogCart Table="Contribution" type="D" Value="#ARGUMENTS.Contribution.getContributionID()#" Desc="A=#ARGUMENTS.Contribution.getAccountID()# C=#ARGUMENTS.Contribution.getClubID()# U=#ARGUMENTS.Contribution.getUserID()# #ARGUMENTS.Contribution.getUserName()# $=#ARGUMENTS.Contribution.getAmount()# Deleted">
			<cfcatch type="database">
				<cfif ARGUMENTS.OnErrorContinue EQ "N">
					<CF_XLogCart Table="Contribution" type="D" Value="0" Desc="Error deleting Contribution (#cfcatch.detail#)" >
				</cfif>
				<cfreturn FALSE />
			</cfcatch>
		</cftry>
		<cfreturn TRUE />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	DeleteLogical -  Contribution
	Modifications
		4/20/2020 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="DeleteLogical" access="public" output="false" returntype="boolean" DisplayName="DeleteLogical Contribution">
		<cfargument name="Contribution"		type="Contribution"	required="true" />
		<cfargument name="OnErrorContinue"		type="String"		required="Yes" 	Default="Y"/>

		<cfset var qDelete = "" />
		<cfset var errMsg 	= "" />
		<cfset var ContributionID = ARGUMENTS.Contribution.getContributionID()>
		<cftry>
			<cfquery name="qDelete" datasource="#variables.DSN#">
				UPDATE  tblContribution
				SET
					dFlag				= 'Y',
					Modified_By 		= <cfqueryparam value="#SESSION.UserID#" 			CFSQLType="CF_SQL_INTEGER" />,
					Modified_Tmstmp 	= <cfqueryparam value="#Now()#" 					CFSQLType="CF_SQL_TIMESTAMP" />
				WHERE		ContributionID = <cfqueryparam value="#ContributionID#" 		CFSQLType="cf_sql_integer" />
			</cfquery>

			<CF_XLogCart Table="Contribution" type="D" Value="#ContributionID#" Desc="#ARGUMENTS.Contribution.getAccountID()# Logically Deleted">
			<cfcatch type="database">
				<cfif ARGUMENTS.OnErrorContinue EQ "N">
					<CF_XLogCart Table="Contribution" type="D" Value="0" Desc="Error deleting logical Contribution (#cfcatch.detail#)" >
				</cfif>
				<cfreturn FALSE />
			</cfcatch>
		</cftry>
		<cfreturn TRUE />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	DeleteByID -  Contribution
	Modifications
		4/20/2020 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="DeleteByID" access="public" output="false" returntype="boolean" DisplayName="DeleteByID Contribution">
		<cfargument name="ContributionID"			type="Numeric"	Required="true" />
		<cfargument name="OnErrorContinue"			type="String"		Required="Yes" 	Default="Y"/>

		<cfset var qDelete = "" />
		<cfset var R       = "" />

		<cftry>
			<cfquery name="qDelete" datasource="#VARIABLES.dsn#" Result="R">
				DELETE FROM	tblContribution
				WHERE	1 = 1
				AND		ContributionID = <cfqueryparam value="#ARGUMENTS.ContributionID#" 		CFSQLType="cf_sql_integer" />
			</cfquery>
			<CF_XLogCart Table="Contribution" type="D" Value="#ARGUMENTS.ContributionID#" Desc="Contribution Deleted">
			<cfcatch type="database">
				<cfif ARGUMENTS.OnErrorContinue EQ "N">
					<CF_XLogCart Table="Contribution" type="D" Value="#ARGUMENTS.ContributionID#" Desc="Error deleting Contribution (#cfcatch.detail#)" >
				</cfif>
				<cfreturn FALSE />
			</cfcatch>
		</cftry>
		<cfreturn TRUE />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	CheckDupPymt - Check Registration Payment for duplicate -- either the system calls us back or user hit back
	Modifications
		04/28/14 - Created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="CheckDupPymt" access="public" output="true" returntype="Boolean" DisplayName="Check for Duplicate Pymt">
		<cfargument Name="TranNo" 				Type="String"  	Required="No" 	Hint="TranNo" 					Default="">
		<cfargument Name="TranAmt"      		Type="String"  	Required="No" 	Hint="AmtPaid" 					Default="">

		<cfset var qCheckDupPymt = "" />

		<cfquery name="qCheckDupPymt" datasource="#variables.dsn#">
			SELECT
				tblContribution.ContributionID,
				tblContribution.UserID,
				tblContribution.UserName,
				tblContribution.TranAmt
			FROM		tblContribution
			WHERE 		1 = 1
			AND			tblContribution.TranNo 		= <CFQUERYPARAM Value="#ARGUMENTS.TranNo#" 			CFSQLTYPE="CF_SQL_VARCHAR">
			AND			tblContribution.TranAmt 	= <CFQUERYPARAM Value="#ARGUMENTS.TranAmt#" 		CFSQLTYPE="CF_SQL_VARCHAR">
		</cfquery>

		<cfif qCheckDupPymt.recordcount GT 0>
			<CF_XLogCart Table="tblContribution" type="A" Value="#qCheckDupPymt.ContributionID#" Desc="Dup Registration Payment [#qCheckDupPymt.UserName#] detected, AmtPaid=#DecimalFormat(ARGUMENTS.TranAmt)#, TranNo=#ARGUMENTS.TranNo#">
			<cfreturn TRUE>
		</cfif>
		<cfreturn FALSE>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Sum -  Sum Contribution BY OrgYear
	Modifications
		10/31/2019 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Sum" access="public" output="false" returntype="Query" DisplayName="Sum by OrgYear">
		<cfargument Name="AccountID"			Type="Numeric"	Required="No"	Hint="AccountID"		Default="#SESSION.AccountID#">
		<cfargument Name="ClubID"				Type="Numeric"	Required="No"	Hint="ClubID"			Default="0">
		<cfargument Name="OrgYears"				Type="String"	Required="No"	Hint="ClubID"			Default="#SESSION.PriorOrgYears#">
		<cfargument Name="SortBy"				Type="String"	Required="No"	Hint="SortBy"			Default="OrgYear">

		<cfset var qView = "" />

		<cfquery name="qView" datasource="#VARIABLES.dsn#">
			SELECT        TOP (100) PERCENT SUM(Amount) AS Amount, OrgYear
			FROM            dbo.tblContribution

			WHERE 		1 = 1
			AND			tblContribution.AccountID 	= <CFQUERYPARAM Value="#ARGUMENTS.AccountID#" 		CFSQLTYPE="CF_SQL_INTEGER">
			AND			tblContribution.ClubID 		= <CFQUERYPARAM Value="#ARGUMENTS.ClubID#" 			CFSQLTYPE="CF_SQL_INTEGER">
			AND			tblContribution.OrgYear 	IN (<CFQUERYPARAM Value="#ARGUMENTS.OrgYears#" 		CFSQLTYPE="CF_SQL_VARCHAR" List="Yes">)
			GROUP BY 	OrgYear
			<cfswitch expression="#ARGUMENTS.SortBy#">
				<cfcase value="OrgYear">	ORDER BY dbo.tblContribution.OrgYear								</cfcase>
			</cfswitch>
		</cfquery>
		<cfreturn qView>
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