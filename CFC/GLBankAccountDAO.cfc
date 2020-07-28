<!--------------------------------------------------------------------------------------------
	GLBankAccountDAO.cfc

	* $Revision: $
	* $Date: 11/4/2019 $
---------------------------------------------------------------------------------------------->

<cfcomponent displayname="GLBankAccountDAO" output="false">

<!--- Local Variables --->
<cfset VARIABLES.dsn 		= REQUEST.DSN>

<!--------------------------------------------------------------------------------------------
	Init - GLBankAccount Constructor

	Entry Conditions:
		DSN			- datasource name
---------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="GLBankAccount">
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
	GetGLBankAccountName - LOOKUP a GLBankAccount by GLBankAccountID, across all Accounts
	Modifications:
		11/4/2019 $ - created
---------------------------------------------------------------------------------------------->
	<cffunction Name="GetGLBankAccountName" Access="Public" Output="false" returnType="String" DisplayName="GetGLBankAccountName">
		<cfargument Name="GLBankAccountID"        	 Type="Numeric"  	Required="Yes" 	Hint="GLBankAccountID" >

		<cfset var qGetGLBankAccountName = "">
		<cfset var strGLBankAccountName = "">

		<cfquery name="qGetGLBankAccountName" datasource="#Request.DSN#">
			SELECT 	GLBankAccount.GLBankAccountName
			FROM 	GLBankAccount
			WHERE 	GLBankAccountID  = <CFQUERYPARAM Value="#ARGUMENTS.GLBankAccountID#" CFSQLTYPE="CF_SQL_INTEGER">
		</cfquery>

		<cfif qGetGLBankAccountName.Recordcount GT 0>
			<cfset strGLBankAccountName = qGetGLBankAccountName.GLBankAccountName>
		</cfif>
		<cfreturn strGLBankAccountName>

	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	InvoiceIDtoGLBankAccountID - Invoice - Returns a list of Invoices Associated with an InvoiceGrp
	Modifications
		2/7/2017 - Created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="InvoiceIDtoGLBankAccountID" access="public" output="false" returntype="Query" DisplayName="InvoiceIDtoGLBankAccountID">
		<cfargument Name="InvoiceID"         Type="Numeric"  	Required="Yes" 	Hint="InvoiceID"		Default="0">

		<cfset var qPick = "" />
		<cfquery name="qPick" datasource="#Request.DSN#">
			SELECT		dbo.GL_InvoiceGrp.GLBankAccountID, dbo.GL_Invoice.UserID, dbo.GL_Invoice.Amount, dbo.GLBankAccount.AccountID, dbo.GLBankAccount.ClubID, dbo.GLBankAccount.GLBankAccountName
			FROM		dbo.GL_Invoice
			INNER JOIN	dbo.GL_InvoiceGrp ON dbo.GL_Invoice.InvoiceGrpID = dbo.GL_InvoiceGrp.InvoiceGrpID
			INNER JOIN	dbo.GLBankAccount ON dbo.GL_InvoiceGrp.GLBankAccountID = dbo.GLBankAccount.GLBankAccountID
			WHERE 		1 = 1
			AND 		GL_Invoice.InvoiceID 	= <CFQUERYPARAM Value="#ARGUMENTS.InvoiceID#" CFSQLTYPE="CF_SQL_INTEGER">
		</cfquery>
		<cfreturn qPick>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	UserIDtoGLBankAccountID - Invoice - Returns a list of Invoices Associated with an InvoiceGrp
	Modifications
		2/7/2017 - Created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="UserIDtoGLBankAccountID" access="public" output="false" returntype="Query" DisplayName="UserIDtoGLBankAccountID ">
		<cfargument Name="UserID"         Type="Numeric"  	Required="Yes" 	Hint="InvoiceID"		Default="0">

		<cfset var qPick = "" />
		<cfquery name="qPick" datasource="#Request.DSN#">
			SELECT		dbo.GL_InvoiceGrp.GLBankAccountID, dbo.GL_Invoice.UserID, dbo.GL_Invoice.Amount, dbo.GL_Invoice.InvoiceID, dbo.GLBankAccount.AccountID, dbo.GLBankAccount.ClubID
			FROM		dbo.GL_Invoice
			INNER JOIN	dbo.GL_InvoiceGrp ON dbo.GL_Invoice.InvoiceGrpID = dbo.GL_InvoiceGrp.InvoiceGrpID
			INNER JOIN	dbo.GLBankAccount ON dbo.GL_InvoiceGrp.GLBankAccountID = dbo.GLBankAccount.GLBankAccountID
			WHERE 		1 = 1
			AND 		GL_Invoice.UserID 	= <CFQUERYPARAM Value="#ARGUMENTS.UserID#" CFSQLTYPE="CF_SQL_INTEGER">
			ORDER BY	GL_Invoice.Created_Tmstmp DESC
		</cfquery>
		<cfreturn qPick>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Pick - GLBankAccount
	Modifications
		8/28/2019 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Pick" access="public" output="false" returntype="Query" DisplayName="Pick">
		<cfargument Name="GLBankAccountID"		Type="Numeric"  	Required="No" 	Hint="GLBankAccountID"		Default="0">
		<cfargument Name="GL_AccountTypeIDs" 	Type="String"  		Required="No" 	Hint="GL_AccountTypeIDs" 	Default="">
		<cfargument Name="Override"				Type="String"  		Required="No" 	Hint="Override" 			Default="N">
		<cfargument Name="SortBy"				Type="String"  		Required="No" 	Hint="SortBy" 				Default="GLBankAccountName">

		<cfset var qPick = "" />

		<cfquery name="qPick" datasource="#VARIABLES.dsn#">
			SELECT		dbo.GLBankAccount.GLBankAccountID, dbo.GLBankAccount.GLBankAccountName, dbo.GLBankAccount.GLBankAccountTypeID, dbo.GLBankAccount.AccountID, dbo.GLBankAccount.ClubID,
						dbo.GLBankAccount.ReceivableAccountID, dbo.GLBankAccountType.IsClub
			FROM		dbo.GLBankAccount
			INNER JOIN	dbo.GLBankAccountType ON dbo.GLBankAccount.GLBankAccountTypeID = dbo.GLBankAccountType.GLBankAccountTypeID

			WHERE 		1 = 1
			AND		GLBankAccount.GLBankAccountID 		= <CFQUERYPARAM Value="#ARGUMENTS.GLBankAccountID#" CFSQLTYPE="CF_SQL_INTEGER">
			<cfif Len(ARGUMENTS.GL_AccountTypeIDs) GT 0>
				AND	 	GL_Account.GL_AccountTypeID 	IN (<CFQUERYPARAM Value="#ARGUMENTS.GL_AccountTypeIDs#" CFSQLTYPE="CF_SQL_INTEGER" list="Yes">)
			</cfif>
			<cfif ARGUMENTS.Override EQ "N">
				AND	 	GLBankAccount.dFlag 			= 'N'
			</cfif>
		</cfquery>
		<cfreturn qPick>

	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	FindAccounts - Find What Accounts the User or Club is Using
	Modifications
		02/06/2017- created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="FindAccounts" access="public" output="false" returntype="Query" DisplayName="FindAccounts">
		<cfargument Name="ClubID"			Type="Numeric"  	Required="No" 	Hint="ClubID"			Default="0">
		<cfargument Name="UserID"			Type="Numeric"  	Required="No" 	Hint="UserID"			Default="0">
		<cfargument Name="Override"			Type="String"  		Required="No" 	Hint="Override" 		Default="N">
		<cfargument Name="SortBy"			Type="String"  		Required="No" 	Hint="SortBy" 			Default="AccountType">

		<cfset var qFind = "" />

		<cfquery name="qFind" datasource="#VARIABLES.dsn#">
SELECT dbo.GLBankAccount.GLBankAccountID, dbo.GLBankAccount.GLBankAccountName, dbo.GLBankAccount.ClubID
FROM     dbo.GLBankAccount
INNER JOIN	dbo.tblUser ON dbo.GLBankAccount.ClubID = dbo.tblUser.ClubID
			WHERE 		1 = 1
			<cfif ARGUMENTS.UserID GT 0>
				AND			tblUser.UserID  					= <CFQUERYPARAM Value="#ARGUMENTS.UserID#"	CFSQLTYPE="CF_SQL_INTEGER">
			<cfelse>
				AND			tblUser.ClubID  					= <CFQUERYPARAM Value="#ARGUMENTS.ClubID#"	CFSQLTYPE="CF_SQL_INTEGER">
				ANd			GLBankAccount.GLBankAccountTypeID	= 1
			</cfif>
		</cfquery>
		<cfreturn qFind>

	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	MyAccounts - Find My GLBankAccount I have Access to
	Modifications
		11/07/2016- created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="MyAccounts" access="public" output="false" returntype="Query" DisplayName="MyAccounts">
		<cfargument Name="AccountID"		Type="Numeric"  	Required="No" 	Hint="AccountID"		Default="#SESSION.AccountID#">
		<cfargument Name="ClubID"			Type="Numeric"  	Required="No" 	Hint="ClubID"			Default="0">
		<cfargument Name="UserID"			Type="Numeric"  	Required="No" 	Hint="UserID"			Default="#SESSION.UserID#">
		<cfargument Name="Override"			Type="String"  		Required="No" 	Hint="Override" 		Default="N">
		<cfargument Name="SortBy"			Type="String"  		Required="No" 	Hint="SortBy" 			Default="AccountType">

		<cfset var qFind = "" />
		<cfquery name="qFind" datasource="#VARIABLES.dsn#">
SELECT dbo.GLBankAccount.GLBankAccountID, dbo.GLBankAccount.GLBankAccountName, dbo.GLBankAccount.dFlag, dbo.GLBankAccount.ClubID, dbo.GLBankAccountUsers.UserID, dbo.GLBankAccountUsers.bitReadOnly, dbo.GLBankAccountType.GLBankAccountType,
                  dbo.GLBankAccount.IsCashBasis, dbo.GLBankAccount.BankAccountID, dbo.GLBankAccount.UpgradedOn, dbo.GLBankAccount.ExpiresOn, dbo.GLBankAccount.Notes,
                  dbo.GLBankAccount.Created_Tmstmp, dbo.GLBankAccount.Modified_Tmstmp, tblUser_1.UserName AS Created_By, tblUser_2.UserName AS Modified_By
FROM     dbo.GLBankAccount INNER JOIN
                  dbo.GLBankAccountUsers ON dbo.GLBankAccount.GLBankAccountID = dbo.GLBankAccountUsers.GLBankAccountID INNER JOIN
                  dbo.GLBankAccountType ON dbo.GLBankAccount.GLBankAccountTypeID = dbo.GLBankAccountType.GLBankAccountTypeID LEFT OUTER JOIN
                  dbo.tblUser AS tblUser_1 ON dbo.GLBankAccount.Created_By = tblUser_1.UserID LEFT OUTER JOIN
                  dbo.tblUser AS tblUser_2 ON dbo.GLBankAccount.Modified_By = tblUser_2.UserID

			WHERE 		1 = 1
			AND			GLBankAccount.AccountID 	= <CFQUERYPARAM Value="#ARGUMENTS.AccountID#"	CFSQLTYPE="CF_SQL_INTEGER">
			<cfif ARGUMENTS.UserID GT 0>
				AND		GLBankAccountUsers.UserID 	= <CFQUERYPARAM Value="#ARGUMENTS.UserID#" 		CFSQLTYPE="CF_SQL_INTEGER">
			</cfif>
			<cfif ARGUMENTS.ClubID GT 0>
				AND		dbo.GLBankAccount.ClubID 	= <CFQUERYPARAM Value="#ARGUMENTS.ClubID#" 		CFSQLTYPE="CF_SQL_INTEGER">
			</cfif>
			<cfif ARGUMENTS.Override EQ "N">
				AND	 	GLBankAccount.dFlag 		= 'N'
			</cfif>
			<cfswitch expression="#ARGUMENTS.SortBy#">
				<cfcase value="GLBankAccountName">	ORDER BY 	GLBankAccount.GLBankAccountName </cfcase>
				<cfcase value="AccountType">		ORDER BY 	GLBankAccountType.SortPosition, GLBankAccount.GLBankAccountName </cfcase>
			</cfswitch>
		</cfquery>
		<cfreturn qFind>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	MyBankAccounts - Unique Bank Accounts I have Access to
	Modifications
		11/07/2016- created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="MyBankAccounts" access="public" output="false" returntype="Query" DisplayName="MyBankAccounts">
		<cfargument Name="AccountID"		Type="Numeric"  	Required="No" 	Hint="AccountID"		Default="#SESSION.AccountID#">
		<cfargument Name="ClubID"			Type="Numeric"  	Required="No" 	Hint="ClubID"			Default="0">
		<cfargument Name="UserID"			Type="Numeric"  	Required="No" 	Hint="UserID"			Default="#SESSION.UserID#">
		<cfargument Name="NeedReceivable"	Type="String"  		Required="No" 	Hint="NeedReceivable" 	Default="N">
		<cfargument Name="Override"			Type="String"  		Required="No" 	Hint="Override" 		Default="N">
		<cfargument Name="SortBy"			Type="String"  		Required="No" 	Hint="SortBy" 			Default="GLBankAccountName">

		<cfset var qFind = "" />
		<cfquery name="qFind" datasource="#VARIABLES.dsn#">
SELECT        GLBankAccountID, GLBankAccountName
FROM          dbo.GLBankAccount

			WHERE 		1 = 1
			AND			GLBankAccount.AccountID 	= <CFQUERYPARAM Value="#ARGUMENTS.AccountID#"	CFSQLTYPE="CF_SQL_INTEGER">
			<cfif ARGUMENTS.ClubID GT 0>
				AND		GLBankAccount.ClubID 		= <CFQUERYPARAM Value="#ARGUMENTS.ClubID#"		CFSQLTYPE="CF_SQL_INTEGER">
			</cfif>
			<cfif ARGUMENTS.NeedReceivable EQ "Y">
				AND	 	GLBankAccount.ReceivableAccountID 		<> 0
			</cfif>
			<cfif ARGUMENTS.Override EQ "N">
				AND	 	GLBankAccount.dFlag 		= 'N'
			</cfif>
			<cfswitch expression="#ARGUMENTS.SortBy#">
				<cfcase value="GLBankAccountName">	ORDER BY 	GLBankAccount.GLBankAccountName </cfcase>
			</cfswitch>
		</cfquery>
		<cfreturn qFind>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	FindClubAccount - Find the Club Account -- old one or new one for paying dues
	Modifications
		04/15/2018- created, this is going to ignore the dues epired date for now
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="FindClubAccount" access="public" output="false" returntype="Query" DisplayName="FindClubAccount">
		<cfargument Name="ClubID"			Type="Numeric"  	Required="No" 	Hint="ClubID"			Default="#SESSION.ClubID#">
		<cfargument Name="Override"			Type="String"  		Required="No" 	Hint="Override" 		Default="N">
		<cfargument Name="SortBy"			Type="String"  		Required="No" 	Hint="SortBy" 			Default="GLBankAccountName">

		<cfset var qFind = "" />
		<cfquery name="qFind" datasource="#VARIABLES.dsn#">
			SELECT		dbo.GLBankAccount.GLBankAccountID, dbo.GLBankAccount.GLBankAccountName
			FROM 		dbo.GLBankAccount
			WHERE 		1 = 1
			AND			GLBankAccount.ClubID 				= <CFQUERYPARAM Value="#ARGUMENTS.ClubID#" CFSQLTYPE="CF_SQL_INTEGER">
			AND			GLBankAccount.GLBankAccountTypeID 	= 1
			<cfif ARGUMENTS.Override EQ "N">
				AND	 	GLBankAccount.dFlag 				= 'N'
			</cfif>
			<cfswitch expression="#ARGUMENTS.SortBy#">
				<cfcase value="GLBankAccountName">	ORDER BY 	GLBankAccount.GLBankAccountName </cfcase>
			</cfswitch>
		</cfquery>
		<cfreturn qFind>

	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	DistrictAccounts - Find My GLBankAccount a Level-9 has access to in the District
	Modifications
		11/07/2016- created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="DistrictAccounts" access="public" output="false" returntype="Query" DisplayName="DistrictAccounts">
		<cfargument Name="AccountID"		Type="Numeric"  	Required="No" 	Hint="AccountID"		Default="#SESSION.AccountID#">
		<cfargument Name="Override"			Type="String"  		Required="No" 	Hint="Override" 		Default="N">
		<cfargument Name="SortBy"			Type="String"  		Required="No" 	Hint="SortBy" 			Default="GLBankAccountName">

		<cfset var qFind = "" />
		<cfquery name="qFind" datasource="#VARIABLES.dsn#">
SELECT        dbo.GLBankAccount.GLBankAccountID, dbo.GLBankAccount.GLBankAccountName, dbo.GLBankAccount.dFlag, dbo.tblClub.ClubName, dbo.GLBankAccount.ClubID, dbo.GLBankAccount.AccountID,
                         dbo.GLBankAccount.GLBankAccountTypeID, dbo.GLBankAccount.IsCashBasis, dbo.GLBankAccount.BankAccountID, dbo.GLBankAccount.UpgradedOn, dbo.GLBankAccount.ExpiresOn, dbo.GLBankAccount.Created_Tmstmp,
                         dbo.GLBankAccount.Modified_Tmstmp, tblUser_1.UserName AS Created_By, tblUser_2.UserName AS Modified_By, dbo.tblAccount.AccountName, dbo.GLBankAccountType.GLBankAccountType,
                         CASE GLBankAccount.ClubID WHEN 0 THEN 1 ELSE 0 END AS Type, dbo.tblMemberEmail.Email
FROM            dbo.GLBankAccount INNER JOIN
                         dbo.GLBankAccountType ON dbo.GLBankAccount.GLBankAccountTypeID = dbo.GLBankAccountType.GLBankAccountTypeID INNER JOIN
                         dbo.tblClub ON dbo.GLBankAccount.ClubID = dbo.tblClub.ClubID INNER JOIN
                         dbo.tblAccount ON dbo.GLBankAccount.AccountID = dbo.tblAccount.AccountID LEFT OUTER JOIN
                         dbo.tblUser AS tblUser_1 ON dbo.GLBankAccount.Created_By = tblUser_1.UserID LEFT OUTER JOIN
                         dbo.tblUser AS tblUser_2 ON dbo.GLBankAccount.Modified_By = tblUser_2.UserID LEFT OUTER JOIN
                         dbo.tblMemberEmail ON tblUser_2.PMailID = dbo.tblMemberEmail.MemberEmailID

			WHERE 		1 = 1
			AND			GLBankAccount.AccountID 	= <CFQUERYPARAM Value="#ARGUMENTS.AccountID#" CFSQLTYPE="CF_SQL_INTEGER">
			<cfif ARGUMENTS.Override EQ "N">
				AND	 	GLBankAccount.dFlag 		= 'N'
			</cfif>
			<cfswitch expression="#ARGUMENTS.SortBy#">
				<cfcase value="GLBankAccountName">	ORDER BY 	GLBankAccount.GLBankAccountName </cfcase>
				<cfcase value="Account">			ORDER BY 	GLBankAccount.ClubID, dbo.tblClub.ClubName, GLBankAccount.GLBankAccountName </cfcase>
				<cfcase value="ClubName">			ORDER BY 	GLBankAccountTypeID, dbo.tblClub.ClubName, GLBankAccount.GLBankAccountName </cfcase>
			</cfswitch>
		</cfquery>
		<cfreturn qFind>

	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Lookup - GLBankAccount Lookup
	Modifications
		8/22/2016  - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Lookup" access="public" output="false" returntype="Query" DisplayName="Lookup">
		<cfargument Name="GLBankAccountID"		Type="numeric"		Required="No" 	Hint="SortBy"				Default="0">
		<cfargument Name="Override"				Type="String"		Required="No" 	Hint="Override" 			Default="N">
		<cfargument Name="SortBy"				Type="String"		Required="No" 	Hint="SortBy" 				Default="GLBankAccountName">

		<cfset var qLookup = "" />

		<cfquery name="qLookup" datasource="#VARIABLES.dsn#">
			SELECT
				GLBankAccount.GLBankAccountID,
				GLBankAccount.GLBankAccountName,
				GLBankAccount.dFlag,
				GLBankAccount.AccountID,
				GLBankAccount.ClubID,
				GLBankAccount.GLBankAccountTypeID,
				GLBankAccount.IsCashBasis,
				GLBankAccount.BankAccountID,
				GLBankAccount.ReceivableAccountID,
				GLBankAccount.IncomeAccountID,
				GLBankAccount.CCAccountID,
				GLBankAccount.BankFeeAccountID,
				GLBankAccount.UpgradedOn,
				GLBankAccount.ExpiresOn,
				GLBankAccount.BillingContact,
				GLBankAccount.BillingCompany,
				GLBankAccount.BillingAddress1,
				GLBankAccount.BillingAddress2,
				GLBankAccount.BillingAddress3,
				GLBankAccount.BillingCity,
				GLBankAccount.BillingStateCode,
				GLBankAccount.BillingProvOrOther,
				GLBankAccount.BillingPostalZip,
				GLBankAccount.BillingCountryCode,
				GLBankAccount.BillingEmail,
				GLBankAccount.BillingPhone,
				GLBankAccount.BillingFaxNumber,
				GLBankAccount.PymtCC,
				GLBankAccount.CardTypes,
				GLBankAccount.CardPolicy,
				GLBankAccount.IsHandleFee,
				GLBankAccount.HandleFeeFixed,
				GLBankAccount.HandlefeePcnt,
				GLBankAccount.PymtGateway,
				GLBankAccount.GatewayParms,
				GLBankAccount.InvoiceTemplate,
				GLBankAccount.StatementTemplate,
				GLBankAccount.PaymentTemplate,
				GLBankAccount.StmtMsg,
				GLBankAccount.PrintFormat,
				GLBankAccount.PMailFormat,
				GLBankAccount.ExportFormat,
				GLBankAccount.YrEndMo,
				GLBankAccount.Notifications,
				GLBankAccount.Notes,
				tblUser_1.UserName AS Created_By,
				GLBankAccount.Created_Tmstmp,
				tblUser_2.UserName AS Modified_By,
				GLBankAccount.Modified_Tmstmp
			FROM	GLBankAccount
			LEFT OUTER JOIN	tblUser AS tblUser_1 ON GLBankAccount.Created_By = tblUser_1.UserID
			LEFT OUTER JOIN tblUser AS tblUser_2 ON GLBankAccount.Modified_By = tblUser_2.UserID
			WHERE 		1 = 1
			<cfif ARGUMENTS.GLBankAccountID GT 0>
				AND		GLBankAccount.GLBankAccountID 	= <CFQUERYPARAM Value="#ARGUMENTS.GLBankAccountID#"	CFSQLTYPE="CF_SQL_INTEGER">
			</cfif>
			<cfif ARGUMENTS.Override EQ "N">
				AND	 	GLBankAccount.dFlag 		= 'N'
			</cfif>
			<cfswitch expression="#ARGUMENTS.SortBy#">
				<cfcase value="AccountID">			ORDER BY 	GLBankAccount.AccountID, GLBankAccountName </cfcase>
				<cfcase value="GLBankAccountName">	ORDER BY 	GLBankAccount.GLBankAccountName </cfcase>
			</cfswitch>
		</cfquery>
		<cfreturn qLookup>

	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	View - GLBankAccount
	Modifications
		8/22/2016 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="View" access="public" output="false" returntype="Query" DisplayName="View">
		<cfargument Name="GLBankAccountID"		Type="numeric"		Required="No" 	Hint="GLBankAccountID" 			Default="0">
		<cfargument Name="AccountID"			Type="numeric"		Required="No" 	Hint="AccountID" 				Default="#SESSION.AccountID#">
		<cfargument Name="Override"				Type="String"		Required="No"	Hint="Override" 				Default="N">
		<cfargument Name="SortBy"				Type="String"		Required="No"	Hint="SortBy" 					Default="GLBankAccountName">

		<cfset var qView = "" />
		<cfquery name="qView" datasource="#VARIABLES.dsn#">
SELECT dbo.GLBankAccount.GLBankAccountID, dbo.GLBankAccount.GLBankAccountName, dbo.GLBankAccount.dFlag, dbo.GLBankAccount.ClubID, dbo.GLBankAccountType.GLBankAccountType,
				dbo.GLBankAccount.IsCashBasis, dbo.GLBankAccount.BankAccountID, GLBankAccount.BankFeeAccountID, dbo.GLBankAccount.UpgradedOn, dbo.GLBankAccount.ExpiresOn, dbo.GLBankAccount.Notes, dbo.GLBankAccount.Created_Tmstmp, dbo.GLBankAccount.Modified_Tmstmp,
                  tblUser_1.UserName AS Created_By, tblUser_2.UserName AS Modified_By
FROM     dbo.GLBankAccount INNER JOIN
                  dbo.GLBankAccountType ON dbo.GLBankAccount.GLBankAccountTypeID = dbo.GLBankAccountType.GLBankAccountTypeID LEFT OUTER JOIN
                  dbo.tblUser AS tblUser_1 ON dbo.GLBankAccount.Created_By = tblUser_1.UserID LEFT OUTER JOIN
                  dbo.tblUser AS tblUser_2 ON dbo.GLBankAccount.Modified_By = tblUser_2.UserID

			WHERE 		1 = 1
			<cfif ARGUMENTS.GLBankAccountID GT 0>
				AND		GLBankAccount.GLBankAccountID 	= <CFQUERYPARAM Value="#ARGUMENTS.GLBankAccountID#"	CFSQLTYPE="CF_SQL_INTEGER">
			<cfelse>
				AND		GLBankAccount.AccountID 		= <CFQUERYPARAM Value="#ARGUMENTS.AccountID#"		CFSQLTYPE="CF_SQL_INTEGER">
			</cfif>
			<cfif ARGUMENTS.Override EQ "N">
				AND	 	GLBankAccount.dFlag 		= 'N'
			</cfif>

			<cfswitch expression="#ARGUMENTS.SortBy#">
				<cfcase value="GLBankAccountName">	ORDER BY dbo.GLBankAccount.GLBankAccountName		</cfcase>
			</cfswitch>
		</cfquery>
		<cfreturn qView>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	List - GLBankAccount
	Modifications
		8/22/2016 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="List" access="public" output="false" returntype="Query" DisplayName="List">
		<cfargument Name="GLBankAccountID"		Type="numeric"		Required="No" 	Hint="SortBy" 					Default="0">
		<cfargument Name="AccountID"			Type="Numeric"		Required="No" 	Hint="AccountID" 				Default="#SESSION.AccountID#">
		<cfargument Name="Override"				Type="String"		Required="No" 	Hint="Override" 				Default="N">
		<cfargument Name="SortBy"				Type="String"		Required="No" 	Hint="SortBy" 					Default="GLBankAccountName">

		<cfset var qList = "" />
		<cfquery name="qList" datasource="#VARIABLES.dsn#">
SELECT dbo.GLBankAccount.GLBankAccountID, dbo.GLBankAccount.GLBankAccountName, dbo.GLBankAccount.dFlag, dbo.GLBankAccount.AccountID, dbo.GLBankAccount.ClubID, dbo.GLBankAccount.GLBankAccountTypeID, dbo.GLBankAccount.IsCashBasis,
                  dbo.GLBankAccount.BankAccountID, dbo.GLBankAccount.ReceivableAccountID, dbo.GLBankAccount.CCAccountID, GLBankAccount.BankFeeAccountID,,
				GLBankAccount.UpgradedOn, GLBankAccount.ExpiresOn,
				  GLBankAccount.YrEndMo, dbo.GLBankAccount.Notes,
				  tblUser_1.UserName AS Created_By, dbo.GLBankAccount.Created_Tmstmp, tblUser_2.UserName AS Modified_By, dbo.GLBankAccount.Modified_Tmstmp, dbo.GLBankAccountType.GLBankAccountType
FROM     dbo.GLBankAccount INNER JOIN
                  dbo.GLBankAccountType ON dbo.GLBankAccount.GLBankAccountTypeID = dbo.GLBankAccountType.GLBankAccountTypeID LEFT OUTER JOIN
                  dbo.tblUser AS tblUser_1 ON dbo.GLBankAccount.Created_By = tblUser_1.UserID LEFT OUTER JOIN
                  dbo.tblUser AS tblUser_2 ON dbo.GLBankAccount.Modified_By = tblUser_2.UserID


			WHERE 		1 = 1
			AND			GLBankAccount.AccountID = <CFQUERYPARAM Value="#ARGUMENTS.AccountID#" CFSQLTYPE="CF_SQL_INTEGER">
			<cfif ARGUMENTS.Override EQ "N">
				AND	 	GLBankAccount.dFlag 		= 'N'
			</cfif>
			<cfswitch expression="#ARGUMENTS.SortBy#">
				<cfcase value="GLBankAccountName">	ORDER BY dbo.GLBankAccount.GLBankAccountName		</cfcase>
			</cfswitch>
		</cfquery>
		<cfreturn qList>

	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Read - GLBankAccount
	Modifications
		8/23/2018 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Read" access="public" output="false" returntype="struct" DisplayName="Read GLBankAccount">
		<cfargument name="GLBankAccount"		type="GLBankAccount"		required="Yes" />

		<cfset var qRead = "" />
		cfset var strReturn = structNew() />

		<cfquery name="qRead" datasource="#VARIABLES.dsn#">
			SELECT
				GLBankAccount.GLBankAccountID,
				GLBankAccount.GLBankAccountName,
				GLBankAccount.dFlag,
				GLBankAccount.AccountID,
				GLBankAccount.ClubID,
				GLBankAccount.GLBankAccountTypeID,
				GLBankAccount.IsCashBasis,
				GLBankAccount.BankAccountID,
				GLBankAccount.ReceivableAccountID,
				GLBankAccount.IncomeAccountID,
				GLBankAccount.CCAccountID,
				GLBankAccount.BankFeeAccountID,
				GLBankAccount.UpgradedOn,
				GLBankAccount.ExpiresOn,
				GLBankAccount.BillingContact,
				GLBankAccount.BillingCompany,
				GLBankAccount.BillingAddress1,
				GLBankAccount.BillingAddress2,
				GLBankAccount.BillingAddress3,
				GLBankAccount.BillingCity,
				GLBankAccount.BillingStateCode,
				GLBankAccount.BillingProvOrOther,
				GLBankAccount.BillingPostalZip,
				GLBankAccount.BillingCountryCode,
				GLBankAccount.BillingEmail,
				GLBankAccount.BillingPhone,
				GLBankAccount.BillingFaxNumber,
				GLBankAccount.PymtCC,
				GLBankAccount.CardTypes,
				GLBankAccount.CardPolicy,
				GLBankAccount.IsHandleFee,
				GLBankAccount.HandleFeeFixed,
				GLBankAccount.HandlefeePcnt,
				GLBankAccount.PymtGateway,
				GLBankAccount.GatewayParms,
				GLBankAccount.InvoiceTemplate,
				GLBankAccount.StatementTemplate,
				GLBankAccount.PaymentTemplate,
				GLBankAccount.StmtMsg,
				GLBankAccount.PrintFormat,
				GLBankAccount.PMailFormat,
				GLBankAccount.ExportFormat,
				GLBankAccount.YrEndMo,
				GLBankAccount.Notifications,
				GLBankAccount.Notes,
				tblUser_1.UserName AS Created_By,
				GLBankAccount.Created_Tmstmp,
				tblUser_2.UserName AS Modified_By,
				GLBankAccount.Modified_Tmstmp
			FROM	GLBankAccount
			LEFT OUTER JOIN	tblUser AS tblUser_1 ON GLBankAccount.Created_By = tblUser_1.UserID
			LEFT OUTER JOIN tblUser AS tblUser_2 ON GLBankAccount.Modified_By = tblUser_2.UserID
			WHERE	1 = 1
			AND		GLBankAccountID = <cfqueryparam value="#ARGUMENTS.GLBankAccount.getGLBankAccountID()#" CFSQLType="cf_sql_integer" />
		</cfquery>
		<cfif qRead.recordCount>
			<cfset strReturn = queryRowToStruct(qRead)>
			<cfset ARGUMENTS.GLBankAccount.init(argumentCollection=strReturn)>
		<cfelse>
			<cfset strReturn = GLBankAccount.getMemento()>
		</cfif>
		<cfreturn strReturn>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Exists -  GLBankAccount
	Modifications
		8/28/2019 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Exists" access="public" output="false" returntype="boolean" DisplayName="Exists GLBankAccount">
		<cfargument name="GLBankAccount"	type="GLBankAccount" required="Yes" />

		<cfset var qExists = "">

		<cfquery name="qExists" datasource="#variables.dsn#" maxrows="1">
			SELECT count(1) as idexists
			FROM	GLBankAccount
			WHERE	GLBankAccountID = <cfqueryparam value="#ARGUMENTS.GLBankAccount.getGLBankAccountID()#" CFSQLType="cf_sql_integer" />
		</cfquery>
		<cfif qExists.idexists>
			<cfreturn TRUE />
		<cfelse>
			<cfreturn FALSE />
		</cfif>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Save - GLBankAccount
	Modifications
		8/28/2019 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Save" access="public" output="false" returntype="numeric" DisplayName="Save GLBankAccount GLBankAccount">
		<cfargument name="GLBankAccount"	type="GLBankAccount" required="Yes" />

		<cfset var pkID = 0 />		<!--- 0=false --->
		<cfif exists(arguments.GLBankAccount)>
			<cfset pkID = update(arguments.GLBankAccount) />
		<cfelse>
			<cfset pkID = create(arguments.GLBankAccount) />
		</cfif>

		<cfreturn pkID />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Insert - GLBankAccount
	Modifications
		8/22/2016 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="InsertRec" access="public" output="false" returntype="numeric" DisplayName="InsertRec">
		<cfargument name="GLBankAccountName"		Type="string"	Default="" />
		<cfargument name="dFlag"					Type="string"	Default="N" />
		<cfargument name="AccountID"				Type="numeric"	Default="0" />
		<cfargument name="ClubID"					Type="numeric"	Default="0" />
		<cfargument name="GLBankAccountTypeID"		Type="numeric"	Default="0" />
		<cfargument name="IsCashBasis"				Type="string"	Default="" />
		<cfargument name="BankAccountID"			Type="numeric"	Default="0" />
		<cfargument name="ReceivableAccountID"		Type="numeric"	Default="0" />
		<cfargument name="IncomeAccountID"			Type="numeric"	Required="No"		Default="0" />
		<cfargument name="CCAccountID"				Type="numeric"	Default="0" />
		<cfargument name="BankFeeAccountID"			Type="numeric"	Required="No"		Default="0" />
		<cfargument name="UpgradedOn"				Type="string" />
		<cfargument name="ExpiresOn"				Type="string" />
		<cfargument name="BillingContact"			Type="string"	Default="" />
		<cfargument name="BillingCompany"			Type="string"	Default="" />
		<cfargument name="BillingAddress1"			Type="string"	Default="" />
		<cfargument name="BillingAddress2"			Type="string"	Default="" />
		<cfargument name="BillingAddress3"			Type="string"	Default="" />
		<cfargument name="BillingCity"				Type="string"	Default="" />
		<cfargument name="BillingStateCode"			Type="string"	Default="" />
		<cfargument name="BillingProvOrOther"		Type="string"	Default="" />
		<cfargument name="BillingPostalZip"			Type="string"	Default="" />
		<cfargument name="BillingCountryCode"		Type="string"	Default="" />
		<cfargument name="BillingEmail"				Type="string"	Default="" />
		<cfargument name="BillingPhone"				Type="string"	Default="" />
		<cfargument name="BillingFaxNumber"			Type="string"	Default="" />
		<cfargument name="PymtCC"					Type="string"	Default="" />
		<cfargument name="CardTypes"				Type="string"	Default="" />
		<cfargument name="CardPolicy"				Type="string"	Default="" />
		<cfargument name="IsHandleFee"				Type="string"	Default="" />
		<cfargument name="HandleFeeFixed"			Type="numeric"	Default="0" />
		<cfargument name="HandlefeePcnt"			Type="numeric"	Default="0" />
		<cfargument name="PymtGateway"				Type="string"	Default="" />
		<cfargument name="GatewayParms"				Type="string"	Default="" />
		<cfargument name="InvoiceTemplate"			Type="string"	Default="" />
		<cfargument name="StatementTemplate"		Type="string"	Default="" />
		<cfargument name="PaymentTemplate"			Type="string"	Default="" />
		<cfargument name="StmtMsg"					Type="string"	Default="" />
		<cfargument name="PrintFormat"				Type="string"	Default="" />
		<cfargument name="PMailFormat"				Type="string"	Default="" />
		<cfargument name="ExportFormat"				Type="string"	Default="" />
		<cfargument name="YrEndMo"					Type="numeric"	Default="0" />
		<cfargument name="Notes"					Type="string"	Default="" />
		<cfargument name="OnErrorContinue"			Type="String"	Required="No" 	Default="N" />

		<cfset var qInsert = "" />
		<cfset var R       = "" />

		<cftry>
			<cfquery name="qInsert" datasource="#VARIABLES.dsn#" Result="R">
				INSERT INTO GLBankAccount
					(
					GLBankAccountName,
					dFlag,
					AccountID,
					ClubID,
					GLBankAccountTypeID,
					IsCashBasis,
					BankAccountID,
					ReceivableAccountID,
					IncomeAccountID,
					CCAccountID,
					BankFeeAccountID,
					UpgradedOn,
					ExpiresOn,
					BillingContact,
					BillingCompany,
					BillingAddress1,
					BillingAddress2,
					BillingAddress3,
					BillingCity,
					BillingStateCode,
					BillingProvOrOther,
					BillingPostalZip,
					BillingCountryCode,
					BillingEmail,
					BillingPhone,
					BillingFaxNumber,
					PymtCC,
					CardTypes,
					CardPolicy,
					IsHandleFee,
					HandleFeeFixed,
					HandlefeePcnt,
					PymtGateway,
					GatewayParms,
					InvoiceTemplate,
					StatementTemplate,
					PaymentTemplate,
					StmtMsg,
					PrintFormat,
					PMailFormat,
					ExportFormat,
					YrEndMo,
					Notifications,
					Notes,
					Created_By,
					Created_Tmstmp
					)
				VALUES
					(
					<cfqueryparam value="#Left(ARGUMENTS.GLBankAccountName,80)#" 		CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.GLBankAccountName)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.dFlag,1)#" 					CFSQLType="CF_SQL_CHAR" 			null="#not len(ARGUMENTS.dFlag)#" />,
					<cfqueryparam value="#ARGUMENTS.AccountID#" 						CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#ARGUMENTS.ClubID#" 							CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#ARGUMENTS.GLBankAccountTypeID#" 				CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#Left(ARGUMENTS.IsCashBasis,1)#"				CFSQLType="CF_SQL_CHAR" 			null="#not len(ARGUMENTS.IsCashBasis)#" />,
					<cfqueryparam value="#ARGUMENTS.BankAccountID#" 					CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#ARGUMENTS.ReceivableAccountID#" 				CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#ARGUMENTS.IncomeAccountID#"					CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#ARGUMENTS.CCAccountID#" 						CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#ARGUMENTS.BankFeeAccountID#"					CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#ARGUMENTS.UpgradedOn#" 						CFSQLType="CF_SQL_DATE"				null="#not len(ARGUMENTS.UpgradedOn)#" />,
					<cfqueryparam value="#ARGUMENTS.ExpiresOn#" 						CFSQLType="CF_SQL_DATE"				null="#not len(ARGUMENTS.ExpiresOn)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.BillingContact,50)#"			CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.BillingContact)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.BillingCompany,50)#"			CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.BillingCompany)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.BillingAddress1,50)#"			CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.BillingAddress1)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.BillingAddress2,50)#"			CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.BillingAddress2)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.BillingAddress3,50)#"			CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.BillingAddress3)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.BillingCity,50)#"				CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.BillingCity)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.BillingStateCode,2)#"			CFSQLType="CF_SQL_CHAR" 			null="#not len(ARGUMENTS.BillingStateCode)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.BillingProvOrOther,32)#"		CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.BillingProvOrOther)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.BillingPostalZip,12)#"			CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.BillingPostalZip)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.BillingCountryCode,3)#"		CFSQLType="CF_SQL_CHAR" 			null="#not len(ARGUMENTS.BillingCountryCode)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.BillingEmail,80)#"				CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.BillingEmail)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.BillingPhone,20)#"				CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.BillingPhone)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.BillingFaxNumber,20)#"			CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.BillingFaxNumber)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.PymtCC,80)#"					CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.PymtCC)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.CardTypes,16)#"				CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.CardTypes)#" />,
					<cfqueryparam value="#ARGUMENTS.CardPolicy#"						CFSQLType="CF_SQL_VARCHAR"			null="#not len(ARGUMENTS.CardPolicy)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.IsHandleFee,1)#"				CFSQLType="CF_SQL_CHAR" 			null="#not len(ARGUMENTS.IsHandleFee)#" />,
					<cfqueryparam value="#ARGUMENTS.HandleFeeFixed#"					CFSQLType="CF_SQL_MONEY" />,
					<cfqueryparam value="#ARGUMENTS.HandlefeePcnt#"						CFSQLType="CF_SQL_DECIMAL"  Scale="2" />,
					<cfqueryparam value="#Left(ARGUMENTS.PymtGateway,2)#"				CFSQLType="CF_SQL_CHAR" 			null="#not len(ARGUMENTS.PymtGateway)#" />,
					<cfqueryparam value="#ARGUMENTS.GatewayParms#"						CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.GatewayParms)#" />,
					<cfqueryparam value="#ARGUMENTS.InvoiceTemplate#"					CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.InvoiceTemplate)#" />,
					<cfqueryparam value="#ARGUMENTS.StatementTemplate#"					CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.StatementTemplate)#" />,
					<cfqueryparam value="#ARGUMENTS.PaymentTemplate#"					CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.PaymentTemplate)#" />,
					<cfqueryparam value="#ARGUMENTS.StmtMsg#"							CFSQLType="CF_SQL_VARCHAR"			null="#not len(ARGUMENTS.StmtMsg)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.PrintFormat,8)#"				CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.PrintFormat)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.PMailFormat,8)#"				CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.PMailFormat)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.ExportFormat,8)#"				CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.ExportFormat)#" />,
					<cfqueryparam value="#ARGUMENTS.YrEndMo#"							CFSQLType="CF_SQL_INTEGER"	 />,
					<cfqueryparam value="#ARGUMENTS.Notifications#"						CFSQLType="CF_SQL_VARCHAR"			null="#not len(ARGUMENTS.Notifications)#" />,
					<cfqueryparam value="#ARGUMENTS.Notes#"								CFSQLType="CF_SQL_VARCHAR"			null="#not len(ARGUMENTS.Notes)#" />,
					<cfqueryparam value="#SESSION.UserID#"								CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#Now()#"										CFSQLType="CF_SQL_TIMESTAMP" />
					)
			</cfquery>
			<CF_XLogCart Table="GLBankAccount" type="I" Value="#R.IDENTITYCOL#" Desc="Insert into GLBankAccount">
			<cfcatch type="database">
				<cfif ARGUMENTS.OnErrorContinue EQ "N">
					<CF_XLogCart Table="GLBankAccount" type="E" Value="0" Desc="Error inserting GLBankAccount (#cfcatch.detail#)" >
				</cfif>
				<cfreturn 0 />
			</cfcatch>
		</cftry>
		<cfreturn R.IDENTITYCOL />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Create - GLBankAccount
	Modifications
		11/4/2019 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Create" access="public" output="false" returntype="numeric" DisplayName="Create GLBankAccount">
		<cfargument name="GLBankAccount"		type="GLBankAccount"	Required="Yes" />
		<cfargument name="OnErrorContinue"  	Type="String"		Required="No"	Default="N" />

		<cfset var qCreate = "" />
		<cfset var R       = "" />

		<cftry>
			<cfquery name="qCreate" datasource="#VARIABLES.dsn#" Result="R">
				INSERT INTO GLBankAccount
					(
					GLBankAccountName,
					dFlag,
					AccountID,
					ClubID,
					GLBankAccountTypeID,
					IsCashBasis,
					BankAccountID,
					ReceivableAccountID,
					IncomeAccountID,
					CCAccountID,
					BankFeeAccountID,
					UpgradedOn,
					ExpiresOn,
					BillingContact,
					BillingCompany,
					BillingAddress1,
					BillingAddress2,
					BillingAddress3,
					BillingCity,
					BillingStateCode,
					BillingProvOrOther,
					BillingPostalZip,
					BillingCountryCode,
					BillingEmail,
					BillingPhone,
					BillingFaxNumber,
					PymtCC,
					CardTypes,
					CardPolicy,
					IsHandleFee,
					HandleFeeFixed,
					HandlefeePcnt,
					PymtGateway,
					GatewayParms,
					InvoiceTemplate,
					StatementTemplate,
					PaymentTemplate,
					StmtMsg,
					PrintFormat,
					PMailFormat,
					ExportFormat,
					YrEndMo,
					Notifications,
					Notes,
					Created_By,
					Created_Tmstmp
					)
				VALUES
					(
					<cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getGLBankAccountName(),80)#" 	CFSQLType="CF_SQL_VARCHAR" 		null="#not len(ARGUMENTS.GLBankAccount.getGLBankAccountName())#" />,
					<cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getdFlag(),1)#" 					CFSQLType="CF_SQL_CHAR" 		null="#not len(ARGUMENTS.GLBankAccount.getdFlag())#" />,
					<cfqueryparam value="#ARGUMENTS.GLBankAccount.getAccountID()#" 						CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#ARGUMENTS.GLBankAccount.getClubID()#" 						CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#ARGUMENTS.GLBankAccount.getGLBankAccountTypeID()#" 			CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getIsCashBasis(),1)#" 			CFSQLType="CF_SQL_CHAR" 		null="#not len(ARGUMENTS.GLBankAccount.getIsCashBasis())#" />,
					<cfqueryparam value="#ARGUMENTS.GLBankAccount.getBankAccountID()#" 					CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#ARGUMENTS.GLBankAccount.getReceivableAccountID()#" 			CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#ARGUMENTS.GLBankAccount.getIncomeAccountID()#"				CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#ARGUMENTS.GLBankAccount.getCCAccountID()#" 					CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#ARGUMENTS.GLBankAccount.getBankFeeAccountID()#"				CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#ARGUMENTS.GLBankAccount.getUpgradedOn()#" 					CFSQLType="CF_SQL_DATE"			null="#not len(ARGUMENTS.GLBankAccount.getUpgradedOn())#" />,
					<cfqueryparam value="#ARGUMENTS.GLBankAccount.getExpiresOn()#" 						CFSQLType="CF_SQL_DATE"			null="#not len(ARGUMENTS.GLBankAccount.getExpiresOn())#" />,
					<cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getBillingContact(),50)#"		CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.GLBankAccount.getBillingContact())#" />,
					<cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getBillingCompany(),50)#"		CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.GLBankAccount.getBillingCompany())#" />,
					<cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getBillingAddress1(),50)#"		CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.GLBankAccount.getBillingAddress1())#" />,
					<cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getBillingAddress2(),50)#"		CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.GLBankAccount.getBillingAddress2())#" />,
					<cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getBillingAddress3(),50)#"		CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.GLBankAccount.getBillingAddress3())#" />,
					<cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getBillingCity(),50)#"			CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.GLBankAccount.getBillingCity())#" />,
					<cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getBillingStateCode(),2)#"		CFSQLType="CF_SQL_CHAR"			null="#not len(ARGUMENTS.GLBankAccount.getBillingStateCode())#" />,
					<cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getBillingProvOrOther(),32)#"	CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.GLBankAccount.getBillingProvOrOther())#" />,
					<cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getBillingPostalZip(),12)#"		CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.GLBankAccount.getBillingPostalZip())#" />,
					<cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getBillingCountryCode(),3)#"		CFSQLType="CF_SQL_CHAR"			null="#not len(ARGUMENTS.GLBankAccount.getBillingCountryCode())#" />,
					<cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getBillingEmail(),80)#"			CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.GLBankAccount.getBillingEmail())#" />,
					<cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getBillingPhone(),20)#"			CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.GLBankAccount.getBillingPhone())#" />,
					<cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getBillingFaxNumber(),20)#"		CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.GLBankAccount.getBillingFaxNumber())#" />,
					<cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getPymtCC(),80)#"				CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.GLBankAccount.getPymtCC())#" />,
					<cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getCardTypes(),16)#"				CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.GLBankAccount.getCardTypes())#" />,
					<cfqueryparam value="#ARGUMENTS.GLBankAccount.getCardPolicy()#"						CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.GLBankAccount.getCardPolicy())#" />,
					<cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getIsHandleFee(),1)#"			CFSQLType="CF_SQL_CHAR"			null="#not len(ARGUMENTS.GLBankAccount.getIsHandleFee())#" />,
					<cfqueryparam value="#ARGUMENTS.GLBankAccount.getHandleFeeFixed()#"					CFSQLType="CF_SQL_MONEY" />,
					<cfqueryparam value="#ARGUMENTS.GLBankAccount.getHandlefeePcnt()#"					CFSQLType="CF_SQL_DECIMAL"  Scale="2" />,
					<cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getPymtGateway(),2)#"			CFSQLType="CF_SQL_CHAR"			null="#not len(ARGUMENTS.GLBankAccount.getPymtGateway())#" />,
					<cfqueryparam value="#ARGUMENTS.GLBankAccount.getGatewayParms()#"					CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.GLBankAccount.getGatewayParms())#" />,
					<cfqueryparam value="#ARGUMENTS.GLBankAccount.getInvoiceTemplate()#"				CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.GLBankAccount.getInvoiceTemplate())#" />,
					<cfqueryparam value="#ARGUMENTS.GLBankAccount.getStatementTemplate()#"				CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.GLBankAccount.getStatementTemplate())#" />,
					<cfqueryparam value="#ARGUMENTS.GLBankAccount.getPaymentTemplate()#"				CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.GLBankAccount.getPaymentTemplate())#" />,
					<cfqueryparam value="#ARGUMENTS.GLBankAccount.getStmtMsg()#"						CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.GLBankAccount.getStmtMsg())#" />,
					<cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getPrintFormat(),8)#"			CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.GLBankAccount.getPrintFormat())#" />,
					<cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getPMailFormat(),8)#"			CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.GLBankAccount.getPMailFormat())#" />,
					<cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getExportFormat(),8)#"			CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.GLBankAccount.getExportFormat())#" />,
					<cfqueryparam value="#ARGUMENTS.GLBankAccount.getYrEndMo()#"						CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#ARGUMENTS.GLBankAccount.getNotifications()#"					CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.GLBankAccount.getNotifications())#" />,
					<cfqueryparam value="#ARGUMENTS.GLBankAccount.getNotes()#"							CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.GLBankAccount.getNotes())#" />,
					<cfqueryparam value="#SESSION.UserID#"												CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#Now()#"														CFSQLType="CF_SQL_TIMESTAMP" />
					)
			</cfquery>
			<CF_XLogCart Table="GLBankAccount" type="I" Value="#R.IDENTITYCOL#" Desc="Insert into GLBankAccount">
			<cfcatch type="database">
				<cfif ARGUMENTS.OnErrorContinue EQ "N">
					<CF_XLogCart Table="GLBankAccount" type="E" Value="0" Desc="Error inserting GLBankAccount (#cfcatch.detail#)" >
				</cfif>
				<cfreturn 0 />
			</cfcatch>
		</cftry>
		<cfreturn R.IDENTITYCOL />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Update - GLBankAccount
	Modifications
		8/23/2018 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Update" access="public" output="false" returntype="numeric" DisplayName="Update">
		<cfargument name="GLBankAccount"	type="GLBankAccount"	Required="Yes" />
		<cfargument name="OnErrorContinue"  	Type="String"		Required="No"	Default="N" />

		<cfset var qUpdate = "" />

		<cftry>
			<cfquery name="qUpdate" datasource="#VARIABLES.dsn#">
				UPDATE GLBankAccount
				SET
					GLBankAccountName		= <cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getGLBankAccountName(),80)#" 		CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.GLBankAccount.getGLBankAccountName())#" />,
					dFlag					= <cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getdFlag(),1)#" 					CFSQLType="CF_SQL_CHAR" 			null="#not len(ARGUMENTS.GLBankAccount.getdFlag())#" />,
					AccountID				= <cfqueryparam value="#ARGUMENTS.GLBankAccount.getAccountID()#" 						CFSQLType="CF_SQL_INTEGER" />,
					ClubID					= <cfqueryparam value="#ARGUMENTS.GLBankAccount.getClubID()#" 							CFSQLType="CF_SQL_INTEGER" />,
					GLBankAccountTypeID		= <cfqueryparam value="#ARGUMENTS.GLBankAccount.getGLBankAccountTypeID()#" 				CFSQLType="CF_SQL_INTEGER" />,
					IsCashBasis				= <cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getIsCashBasis(),1)#" 				CFSQLType="CF_SQL_CHAR" 			null="#not len(ARGUMENTS.GLBankAccount.getIsCashBasis())#" />,
					BankAccountID			= <cfqueryparam value="#ARGUMENTS.GLBankAccount.getBankAccountID()#" 					CFSQLType="CF_SQL_INTEGER" />,
					ReceivableAccountID		= <cfqueryparam value="#ARGUMENTS.GLBankAccount.getReceivableAccountID()#" 				CFSQLType="CF_SQL_INTEGER" />,
					IncomeAccountID			= <cfqueryparam value="#ARGUMENTS.GLBankAccount.getIncomeAccountID()#"					CFSQLType="CF_SQL_INTEGER" />,
					CCAccountID				= <cfqueryparam value="#ARGUMENTS.GLBankAccount.getCCAccountID()#" 						CFSQLType="CF_SQL_INTEGER" />,
					BankFeeAccountID		= <cfqueryparam value="#ARGUMENTS.GLBankAccount.getBankFeeAccountID()#"					CFSQLType="CF_SQL_INTEGER" />,
					UpgradedOn				= <cfqueryparam value="#ARGUMENTS.GLBankAccount.getUpgradedOn()#" 						CFSQLType="CF_SQL_DATE"				null="#not len(ARGUMENTS.GLBankAccount.getUpgradedOn())#" />,
					ExpiresOn				= <cfqueryparam value="#ARGUMENTS.GLBankAccount.getExpiresOn()#" 						CFSQLType="CF_SQL_DATE"				null="#not len(ARGUMENTS.GLBankAccount.getExpiresOn())#" />,
					BillingContact			= <cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getBillingContact(),50)#"			CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.GLBankAccount.getBillingContact())#" />,
					BillingCompany			= <cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getBillingCompany(),50)#"			CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.GLBankAccount.getBillingCompany())#" />,
					BillingAddress1			= <cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getBillingAddress1(),50)#"			CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.GLBankAccount.getBillingAddress1())#" />,
					BillingAddress2			= <cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getBillingAddress2(),50)#"			CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.GLBankAccount.getBillingAddress2())#" />,
					BillingAddress3			= <cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getBillingAddress3(),50)#"			CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.GLBankAccount.getBillingAddress3())#" />,
					BillingCity				= <cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getBillingCity(),50)#"				CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.GLBankAccount.getBillingCity())#" />,
					BillingStateCode		= <cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getBillingStateCode(),2)#"			CFSQLType="CF_SQL_CHAR" 			null="#not len(ARGUMENTS.GLBankAccount.getBillingStateCode())#" />,
					BillingProvOrOther		= <cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getBillingProvOrOther(),32)#"		CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.GLBankAccount.getBillingProvOrOther())#" />,
					BillingPostalZip		= <cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getBillingPostalZip(),12)#"		CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.GLBankAccount.getBillingPostalZip())#" />,
					BillingCountryCode		= <cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getBillingCountryCode(),3)#"		CFSQLType="CF_SQL_CHAR" 			null="#not len(ARGUMENTS.GLBankAccount.getBillingCountryCode())#" />,
					BillingEmail			= <cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getBillingEmail(),80)#"			CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.GLBankAccount.getBillingEmail())#" />,
					BillingPhone			= <cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getBillingPhone(),20)#"			CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.GLBankAccount.getBillingPhone())#" />,
					BillingFaxNumber		= <cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getBillingFaxNumber(),20)#"		CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.GLBankAccount.getBillingFaxNumber())#" />,
					PymtCC					= <cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getPymtCC(),80)#"					CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.GLBankAccount.getPymtCC())#" />,
					CardTypes				= <cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getCardTypes(),16)#"				CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.GLBankAccount.getCardTypes())#" />,
					CardPolicy				= <cfqueryparam value="#ARGUMENTS.GLBankAccount.getCardPolicy()#"						CFSQLType="CF_SQL_VARCHAR"			null="#not len(ARGUMENTS.GLBankAccount.getCardPolicy())#" />,
					IsHandleFee				= <cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getIsHandleFee(),1)#"				CFSQLType="CF_SQL_CHAR" 			null="#not len(ARGUMENTS.GLBankAccount.getIsHandleFee())#" />,
					HandleFeeFixed			= <cfqueryparam value="#ARGUMENTS.GLBankAccount.getHandleFeeFixed()#"					CFSQLType="CF_SQL_MONEY" />,
					HandlefeePcnt			= <cfqueryparam value="#ARGUMENTS.GLBankAccount.getHandlefeePcnt()#"					CFSQLType="CF_SQL_DECIMAL"  Scale="2" />,
					PymtGateway				= <cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getPymtGateway(),2)#"				CFSQLType="CF_SQL_CHAR" 			null="#not len(ARGUMENTS.GLBankAccount.getPymtGateway())#" />,
					GatewayParms			= <cfqueryparam value="#ARGUMENTS.GLBankAccount.getGatewayParms()#"						CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.GLBankAccount.getGatewayParms())#" />,
					InvoiceTemplate			= <cfqueryparam value="#ARGUMENTS.GLBankAccount.getInvoiceTemplate()#"					CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.GLBankAccount.getInvoiceTemplate())#" />,
					StatementTemplate		= <cfqueryparam value="#ARGUMENTS.GLBankAccount.getStatementTemplate()#"				CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.GLBankAccount.getStatementTemplate())#" />,
					PaymentTemplate			= <cfqueryparam value="#ARGUMENTS.GLBankAccount.getPaymentTemplate()#"					CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.GLBankAccount.getPaymentTemplate())#" />,
					StmtMsg					= <cfqueryparam value="#ARGUMENTS.GLBankAccount.getStmtMsg()#"							CFSQLType="CF_SQL_VARCHAR"			null="#not len(ARGUMENTS.GLBankAccount.getStmtMsg())#" />,
					PrintFormat				= <cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getPrintFormat(),8)#"				CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.GLBankAccount.getPrintFormat())#" />,
					PMailFormat				= <cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getPMailFormat(),8)#"				CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.GLBankAccount.getPMailFormat())#" />,
					ExportFormat			= <cfqueryparam value="#Left(ARGUMENTS.GLBankAccount.getExportFormat(),8)#"				CFSQLType="CF_SQL_VARCHAR" 			null="#not len(ARGUMENTS.GLBankAccount.getExportFormat())#" />,
					YrEndMo					= <cfqueryparam value="#ARGUMENTS.GLBankAccount.getYrEndMo()#"							CFSQLType="CF_SQL_INTEGER"	/>,
					Notifications			= <cfqueryparam value="#ARGUMENTS.GLBankAccount.getNotifications()#"					CFSQLType="CF_SQL_VARCHAR"			null="#not len(ARGUMENTS.GLBankAccount.getNotifications())#" />,
					Notes					= <cfqueryparam value="#ARGUMENTS.GLBankAccount.getNotes()#"							CFSQLType="CF_SQL_VARCHAR"			null="#not len(ARGUMENTS.GLBankAccount.getNotes())#" />,
					Modified_By				= <cfqueryparam value="#SESSION.UserID#" 												CFSQLType="CF_SQL_INTEGER" />,
					Modified_Tmstmp			= <cfqueryparam value="#Now()#" 														CFSQLType="CF_SQL_TIMESTAMP" />
				WHERE	1 = 1
				AND		GLBankAccountID			= <cfqueryparam value="#ARGUMENTS.GLBankAccount.getGLBankAccountID()#" 				CFSQLType="cf_sql_integer" />
			</cfquery>
			<CF_XLogCart Table="GLBankAccount" type="U" Value="#ARGUMENTS.GLBankAccount.getGLBankAccountID()#" Desc="GLBankAccount #ARGUMENTS.GLBankAccount.getGLBankAccountName()# Updated">
			<cfcatch type="database">
				<cfif ARGUMENTS.OnErrorContinue EQ "N">
					<CF_XLogCart Table="GLBankAccount" type="E" Value="0" Desc="Error updating GLBankAccount (#cfcatch.detail#)" >
				</cfif>
				<cfreturn 0 />
			</cfcatch>
		</cftry>
		<cfreturn ARGUMENTS.GLBankAccount.getGLBankAccountID() />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Delete - GLBankAccount
	Modifications
		11/4/2019 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Delete" access="public" output="false" returntype="boolean" DisplayName="Delete GLBankAccount">
		<cfargument name="GLBankAccount"	type="GLBankAccount"	required="Yes" />
		<cfargument name="OnErrorContinue"  	Type="String"		required="No"	Default="N" />

		<cfset var qDelete = "" />
		<cfset var R       = "" />
		<cftry>
			<cfquery name="qDelete" datasource="#VARIABLES.dsn#" Result="R">
				DELETE FROM	GLBankAccount
				WHERE	1 = 1
				AND		GLBankAccountID = <cfqueryparam value="#ARGUMENTS.GLBankAccount.getGLBankAccountID()#" 					CFSQLType="cf_sql_integer" />
			</cfquery>
			<CF_XLogCart Table="GLBankAccount" type="D" Value="#ARGUMENTS.GLBankAccount.getGLBankAccountID()#" Desc="#ARGUMENTS.GLBankAccount.getGLBankAccountName()# Physically Deleted">
			<cfcatch type="database">
				<cfif ARGUMENTS.OnErrorContinue EQ "N">
					<CF_XLogCart Table="GLBankAccount" type="D" Value="0" Desc="Error deleting GLBankAccount (#cfcatch.detail#)" >
				</cfif>
				<cfreturn FALSE />
			</cfcatch>
		</cftry>
		<cfreturn TRUE />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	DeleteLogical - GLBankAccount
	Modifications
		11/4/2019 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="DeleteLogical" access="public" output="false" returntype="boolean" DisplayName="DeleteLogical GLBankAccount">
		<cfargument name="GLBankAccount" type="GLBankAccount"	required="true" />
		<cfargument name="OnErrorContinue"		type="String"		required="Yes" 	Default="Y"/>

		<cfset var qDelete = "" />
		<cfset var errMsg 	= "" />
		<cfset var GLBankAccountID = ARGUMENTS.GLBankAccount.getGLBankAccountID()>
		<cftry>
			<cfquery name="qDelete" datasource="#variables.DSN#">
				UPDATE  GLBankAccount
				SET
					dFlag				= 'Y',
					Modified_By 		= <cfqueryparam value="#SESSION.UserID#" 					CFSQLType="CF_SQL_INTEGER" />,
					Modified_Tmstmp 	= <cfqueryparam value="#Now()#" 							CFSQLType="CF_SQL_TIMESTAMP" />
				WHERE		GLBankAccountID = <cfqueryparam value="#GLBankAccountID#" 					CFSQLType="cf_sql_integer" />
			</cfquery>

			<CF_XLogCart Table="GLBankAccount" type="D" Value="#GLBankAccountID#" Desc="#ARGUMENTS.GLBankAccount.getGLBankAccountName()# Logically Deleted">
			<cfcatch type="database">
				<cfif ARGUMENTS.OnErrorContinue EQ "N">
					<CF_XLogCart Table="GLBankAccount" type="D" Value="0" Desc="Error deleting logical GLBankAccount (#cfcatch.detail#)" >
				</cfif>
				<cfreturn FALSE />
			</cfcatch>
		</cftry>
		<cfreturn TRUE />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Clone - GLBankAccount
	Modifications
		5/21/2018 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Clone" access="public" output="false" returntype="numeric" DisplayName="Clone">
		<cfargument name="GLBankAccount"	type="GLBankAccount" required="Yes" />

		<cfset var Q 	 = "" />
		<cfset var GLBankAccountObj = "" />
		<cfset var qClone = "" />
		<cfset var CloneID = "" />
		<cfset Q = Lookup( GLBankAccountID=ARGUMENTS.GLBankAccount, UseCustom="N"  ) />

		<cfinvoke component="GLBankAccount" method="init" returnvariable="GLBankAccountObj">
			<cfinvokeargument name="GLBankAccountName"		Value="#Q.GLBankAccountName#" />
			<cfinvokeargument name="dFlag"					Value="#Q.dFlag#" />
			<cfinvokeargument name="AccountID"				Value="#Q.AccountID#" />
			<cfinvokeargument name="ClubID"					Value="#Q.ClubID#" />
			<cfinvokeargument name="GLBankAccountTypeID"	Value="#Q.GLBankAccountTypeID#" />
			<cfinvokeargument name="IsCashBasis"			Value="#Q.IsCashBasis#" />
			<cfinvokeargument name="BankAccountID"			Value="#Q.BankAccountID#" />
			<cfinvokeargument name="ReceivableAccountID"	Value="#Q.ReceivableAccountID#" />
			<cfinvokeargument name="IncomeAccountID"		Value="#Q.IncomeAccountID#" />
			<cfinvokeargument name="CCAccountID"			Value="#Q.CCAccountID#" />
			<cfinvokeargument name="BankFeeAccountID"		Value="#Q.BankFeeAccountID#" />
			<cfinvokeargument name="UpgradedOn"				Value="#Q.UpgradedOn#" />
			<cfinvokeargument name="ExpiresOn"				Value="#Q.ExpiresOn#" />
			<cfinvokeargument name="BillingContact"			Value="#Q.BillingContact#" />
			<cfinvokeargument name="BillingCompany"			Value="#Q.BillingCompany#" />
			<cfinvokeargument name="BillingAddress1"		Value="#Q.BillingAddress1#" />
			<cfinvokeargument name="BillingAddress2"		Value="#Q.BillingAddress2#" />
			<cfinvokeargument name="BillingAddress3"		Value="#Q.BillingAddress3#" />
			<cfinvokeargument name="BillingCity"			Value="#Q.BillingCity#" />
			<cfinvokeargument name="BillingStateCode"		Value="#Q.BillingStateCode#" />
			<cfinvokeargument name="BillingProvOrOther"		Value="#Q.BillingProvOrOther#" />
			<cfinvokeargument name="BillingPostalZip"		Value="#Q.BillingPostalZip#" />
			<cfinvokeargument name="BillingCountryCode"		Value="#Q.BillingCountryCode#" />
			<cfinvokeargument name="BillingEmail"			Value="#Q.BillingEmail#" />
			<cfinvokeargument name="BillingPhone"			Value="#Q.BillingPhone#" />
			<cfinvokeargument name="BillingFaxNumber"		Value="#Q.BillingFaxNumber#" />
			<cfinvokeargument name="PymtCC"					Value="#Q.PymtCC#" />
			<cfinvokeargument name="CardTypes"				Value="#Q.CardTypes#" />
			<cfinvokeargument name="CardPolicy"				Value="#Q.CardPolicy#" />
			<cfinvokeargument name="IsHandleFee"			Value="#Q.IsHandleFee#" />
			<cfinvokeargument name="HandleFeeFixed"			Value="#Q.HandleFeeFixed#" />
			<cfinvokeargument name="HandlefeePcnt"			Value="#Q.HandlefeePcnt#" />
			<cfinvokeargument name="PymtGateway"			Value="#Q.PymtGateway#" />
			<cfinvokeargument name="GatewayParms"			Value="#Q.GatewayParms#" />
			<cfinvokeargument name="InvoiceTemplate"		Value="#Q.InvoiceTemplate#" />
			<cfinvokeargument name="StatementTemplate"		Value="#Q.StatementTemplate#" />
			<cfinvokeargument name="PaymentTemplate"		Value="#Q.PaymentTemplate#" />
			<cfinvokeargument name="StmtMsg"				Value="#Q.StmtMsg#" />
			<cfinvokeargument name="PrintFormat"			Value="#Q.PrintFormat#" />
			<cfinvokeargument name="PMailFormat"			Value="#Q.PMailFormat#" />
			<cfinvokeargument name="ExportFormat"			Value="#Q.ExportFormat#" />
			<cfinvokeargument name="YrEndMo"				Value="#Q.YrEndMo#" />
			<cfinvokeargument name="Notifications"			Value="#Q.Notifications#" />
			<cfinvokeargument name="Notes"					Value="#Q.Notes#" />
		</cfinvoke>
		<cfset CloneID = Create( GLBankAccountObj, "Y" ) />
		<cfreturn CloneID />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	MyGLBankAccounts - MyGLBankAccounts
	Modifications
		10/13/2019 - created from FLAccountDAO, ADD Include Account
		NOTE: Use DISTICT so only one record per account is returned regardless of number of users
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="MyGLBankAccounts" access="public" output="false" returntype="Query" DisplayName="MyGLBankAccounts">
		<cfargument Name="AccountID"		Type="Numeric"  	Required="No" 	Hint="AccountID"		Default="#SESSION.AccountID#">
		<cfargument Name="ClubID"			Type="Numeric"  	Required="No" 	Hint="ClubID"			Default="0">
		<cfargument Name="UserID"			Type="Numeric"  	Required="No" 	Hint="UserID"			Default="#SESSION.UserID#">
		<cfargument Name="RoleID"			Type="Numeric"  	Required="No" 	Hint="RoleID"			Default="#SESSION.RoleID#">
		<cfargument Name="Override"			Type="String"  		Required="No" 	Hint="Override" 		Default="N">
		<cfargument Name="SortBy"			Type="String"  		Required="No" 	Hint="SortBy" 			Default="GLBankAccountName">

		<cfset var qFind = "" />
		<cfquery name="qFind" datasource="#VARIABLES.dsn#">
			SELECT		DISTINCT dbo.GLBankAccount.GLBankAccountID, dbo.GLBankAccount.GLBankAccountName
			FROM		dbo.GLBankAccount
			INNER JOIN	dbo.GLBankAccountUsers ON dbo.GLBankAccount.GLBankAccountID = dbo.GLBankAccountUsers.GLBankAccountID

			WHERE 		1 = 1
			AND			GLBankAccount.AccountID 	= <CFQUERYPARAM Value="#ARGUMENTS.AccountID#"	CFSQLTYPE="CF_SQL_INTEGER">
			AND			GLBankAccount.ClubID 		= <CFQUERYPARAM Value="#ARGUMENTS.ClubID#"		CFSQLTYPE="CF_SQL_INTEGER">
			<cfif ARGUMENTS.Override EQ "N">
				AND	 	GLBankAccount.dFlag 		= 'N'
			</cfif>
			<cfswitch expression="#ARGUMENTS.RoleID#">
				<cfcase value="1,2,3,4,5,6,7,8">
					<cfif ARGUMENTS.UserID GT 0>
						AND		GLBankAccountUsers.UserID 	= <CFQUERYPARAM Value="#ARGUMENTS.UserID#" 		CFSQLTYPE="CF_SQL_INTEGER">
					</cfif>
				</cfcase>
			</cfswitch>

			<cfswitch expression="#ARGUMENTS.SortBy#">
				<cfcase value="GLBankAccountName">	ORDER BY 	GLBankAccount.GLBankAccountName </cfcase>
			</cfswitch>
		</cfquery>
		<cfreturn qFind>
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