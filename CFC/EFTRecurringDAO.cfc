<!--------------------------------------------------------------------------------------------
	EFTRecurringDAO.cfc

	* $Revision: $
	* $Date: 7/13/2020 $
---------------------------------------------------------------------------------------------->

<cfcomponent displayname="EFTRecurringDAO" output="false">

<!--- Local Variables --->
<cfset VARIABLES.dsn 		= REQUEST.DSN>

<!--------------------------------------------------------------------------------------------
	Init - EFTRecurring Constructor

	Entry Conditions:
		DSN			- datasource name
---------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="EFTRecurring">
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
	GetEFTRecurringName - Get the name from  EFTRecurring by EFTRecurringID
	Modifications:
		7/13/2020 $ - created
---------------------------------------------------------------------------------------------->
	<cffunction Name="GetEFTRecurringName" Access="Public" Output="FALSE" returnType="String" DisplayName="GetEFTRecurringName">
		<cfargument Name="EFTRecurringID"		 Type="Numeric"		Required="Yes"		Hint="EFTRecurringID" >

		<cfset var qGetEFTRecurringName = "">
		<cfset var strEFTRecurringName = "">

		<cfquery name="qGetEFTRecurringName" datasource="#Request.DSN#">
			SELECT	dbo.tblUser.UserName
			FROM	dbo.tblEFTRecurring
			INNER JOIN	dbo.tblUser ON dbo.tblEFTRecurring.UserID = dbo.tblUser.UserID
			WHERE 	EFTRecurringID  	= <CFQUERYPARAM Value="#ARGUMENTS.EFTRecurringID#" CFSQLTYPE="CF_SQL_INTEGER">
		</cfquery>
		<cfif qGetEFTRecurringName.Recordcount GT 0>
			<cfset strEFTRecurringName = qGetEFTRecurringName.UserName>
		</cfif>
		<cfreturn strEFTRecurringName>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Pick - EFTRecurring
	Modifications
		7/13/2020 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Pick" access="public" output="false" returntype="Query" DisplayName="Pick">
		<cfargument Name="AccountID"		Type="Numeric"  	Required="No" 	Hint="AccountID"			Default="#SESSION.AccountID#">
		<cfargument Name="Override"			Type="String"  		Required="No" 	Hint="Override" 			Default="N">
		<cfargument Name="SortBy"			Type="String"  		Required="No" 	Hint="SortBy" 				Default="NameOnAccount">

		<cfset var qPick = "" />
		<cfquery name="qPick" datasource="#VARIABLES.dsn#">
			SELECT	EFTRecurringID, NameOnAccount, GLBankAccountID, UserID
			FROM	tblEFTRecurring
			WHERE 		1 = 1
			<cfif ARGUMENTS.Override EQ "N">
				AND		tblEFTRecurring.dFlag 		= 'N'
			</cfif>
			<cfswitch expression="#ARGUMENTS.SortBy#">
				<cfcase value="NameOnAccount">ORDER BY 	tblEFTRecurring.NameOnAccount </cfcase>
			</cfswitch>
		</cfquery>
		<cfreturn qPick>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Lookup - EFTRecurring
	Modifications
		7/13/2020  - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Lookup" access="public" output="false" returntype="Query" DisplayName="Lookup">
		<cfargument name="EFTRecurringID"		Type="numeric"	Required="No"	Hint="EFTRecurringID"		Default="0" />
		<cfargument name="UserID"				Type="numeric"	Required="No"	Hint="UserID"				Default="0" />
		<cfargument Name="Filter"				Type="string"	Required="No"	Hint="Filter Value"			Default="">
		<cfargument Name="Override"				Type="String"	Required="No" 	Hint="Override"				Default="N">
		<cfargument Name="SortBy"				Type="String"	Required="No"	Hint="SortBy"				Default="NameOnAccount">

		<cfset var qLookup = "" />
		<cfquery name="qLookup" datasource="#VARIABLES.dsn#">
			SELECT
				tblEFTRecurring.EFTRecurringID,
				tblEFTRecurring.NameOnAccount,
				tblEFTRecurring.dFlag,
				tblEFTRecurring.fRunNext,
				tblEFTRecurring.fTestMode,
				tblEFTRecurring.GLBankAccountID,
				tblEFTRecurring.UserID,
				tblEFTRecurring.TranType,
				tblEFTRecurring.AccountType,
				tblEFTRecurring.Amount,
				tblEFTRecurring.Period,
				tblEFTRecurring.StartDate,
				tblEFTRecurring.EndDate,
				tblEFTRecurring.CardNumber,
				tblEFTRecurring.CardExpiryMonth,
				tblEFTRecurring.CardExpiryYear,
				tblEFTRecurring.Token,
				tblEFTRecurring.Notes,
				tblEFTRecurring.hmJSON,
				tblEFTRecurring.AuthCode,
				tblEFTRecurring.ResponseText,
				tblEFTRecurring.TransactionID,
				tblEFTRecurring.Created_By,
				tblEFTRecurring.Created_Tmstmp,
				tblEFTRecurring.Modified_By,
				tblEFTRecurring.Modified_Tmstmp
				FROM	tblEFTRecurring
			WHERE 		1 = 1
			<cfif ARGUMENTS.EFTRecurringID GT 0>
				AND		tblEFTRecurring.EFTRecurringID 	= <CFQUERYPARAM Value="#ARGUMENTS.EFTRecurringID#"	CFSQLTYPE="CF_SQL_INTEGER">
			<cfelseif ARGUMENTS.UserID GT 0>
				AND		tblEFTRecurring.UserID 			= <CFQUERYPARAM Value="#ARGUMENTS.UserID#"	CFSQLTYPE="CF_SQL_INTEGER">
			<cfelse>
				<cfif ARGUMENTS.Override EQ "N">
					AND	 	tblEFTRecurring.dFlag 		= 'N'
				</cfif>
				<cfif Len(ARGUMENTS.Filter) GT 0>
					AND		tblEFTRecurring.NameOnAccount	LIKE <CFQUERYPARAM Value="#ARGUMENTS.Filter#%"		CFSQLTYPE="CF_SQL_VARCHAR">
				</cfif>
			</cfif>
			<cfswitch expression="#ARGUMENTS.SortBy#">
				<cfcase value="NameOnAccount">ORDER BY 	tblEFTRecurring.NameOnAccount </cfcase>
			</cfswitch>
		</cfquery>
		<cfreturn qLookup>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	View -  EFTRecurring
	Modifications
		7/13/2020 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="View" access="public" output="false" returntype="Query" DisplayName="View">
		<cfargument name="GLBankAccountID"		Type="numeric"	Required="No"	Hint="GLBankAccountID"		Default="0" />
		<cfargument name="EFTRecurringID"		Type="numeric"	Required="No"	Hint="EFTRecurringID"		Default="0" />
		<cfargument Name="Filter"				Type="string"	Required="No"	Hint="Filter Value"			Default="">
		<cfargument Name="Override"				Type="String"	Required="No"	Hint="Override"				Default="N">
		<cfargument Name="SortBy"				Type="String"	Required="No"	Hint="SortBy"				Default="GLBankAccountID">

		<cfset var qView = "" />
		<cfquery name="qView" datasource="#VARIABLES.dsn#">
SELECT        dbo.tblEFTRecurring.EFTRecurringID, dbo.tblEFTRecurring.GLBankAccountID, dbo.tblEFTRecurring.UserID, dbo.tblEFTRecurring.TranType, dbo.tblEFTRecurring.AccountType, dbo.tblEFTRecurring.NameOnAccount,
                         dbo.tblEFTRecurring.Amount, dbo.tblEFTRecurring.Period, dbo.tblEFTRecurring.StartDate, dbo.tblEFTRecurring.EndDate, dbo.tblEFTRecurring.Token, dbo.tblEFTRecurring.Notes, dbo.tblEFTRecurring.Created_Tmstmp,
                         dbo.tblEFTRecurring.Modified_Tmstmp, dbo.tblUser.dFlag AS Fterm, dbo.tblUser.UserName, dbo.tblUser.AccountID, dbo.tblUser.ClubID, dbo.GLBankAccount.GatewayParms, dbo.GLBankAccount.IsHandleFee,
                         dbo.GLBankAccount.HandleFeeFixed, dbo.GLBankAccount.HandlefeePcnt, dbo.GLBankAccount.PymtGateway, dbo.GLBankAccount.Notifications, dbo.GLBankAccount.GLBankAccountName,
                         dbo.GLBankAccount.AccountID AS GLBankAccount, dbo.tblUser.Email, dbo.tblUser.FName
FROM            dbo.tblEFTRecurring INNER JOIN
                         dbo.tblUser ON dbo.tblEFTRecurring.UserID = dbo.tblUser.UserID INNER JOIN
                         dbo.GLBankAccount ON dbo.tblEFTRecurring.GLBankAccountID = dbo.GLBankAccount.GLBankAccountID

			WHERE 	1 = 1
			AND		dbo.tblEFTRecurring.dFlag 	= 'N'
			AND		dbo.tblUser.dFlag 			= 'N'
			AND		dbo.GLBankAccount.dFlag 	= 'N'
			<cfif ARGUMENTS.GLBankAccountID GT 0>
				AND		tblEFTRecurring.GLBankAccountID = <CFQUERYPARAM Value="#ARGUMENTS.GLBankAccountID#"	CFSQLTYPE="CF_SQL_INTEGER">
			</cfif>
			<cfif ARGUMENTS.EFTRecurringID GT 0>
				AND		tblEFTRecurring.EFTRecurringID 	= <CFQUERYPARAM Value="#ARGUMENTS.EFTRecurringID#"	CFSQLTYPE="CF_SQL_INTEGER">
			</cfif>

			<cfswitch expression="#ARGUMENTS.SortBy#">
				<cfcase value="GLBankAccountID">	ORDER BY dbo.tblEFTRecurring.GLBankAccountID		</cfcase>
			</cfswitch>
		</cfquery>
		<cfreturn qView>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	List -  EFTRecurring
	Modifications
		10/28/2019 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="List" access="public" output="false" returntype="Query" DisplayName="List">
		<cfargument name="GLBankAccountID"		Type="numeric"	Required="No"	Hint="GLBankAccountID"		Default="0" />
		<cfargument Name="Filter"				Type="string"	Required="No"	Hint="Filter Value"			Default="">
		<cfargument Name="SortBy"				Type="String"	Required="No"	Hint="SortBy"				Default="UserName">

		<cfset var qList = "" />
		<cfquery name="qList" datasource="#VARIABLES.dsn#">
SELECT	dbo.tblEFTRecurring.EFTRecurringID, dbo.tblEFTRecurring.GLBankAccountID, dbo.tblEFTRecurring.UserID, dbo.tblEFTRecurring.dFlag, dbo.tblEFTRecurring.fRunNext,dbo.tblEFTRecurring.fTestMode,dbo.tblEFTRecurring.TranType, dbo.tblEFTRecurring.AccountType, dbo.tblEFTRecurring.NameOnAccount, dbo.tblEFTRecurring.Amount,
		dbo.tblEFTRecurring.Period, dbo.tblEFTRecurring.StartDate, dbo.tblEFTRecurring.EndDate, dbo.tblEFTRecurring.Token, dbo.tblEFTRecurring.Notes, tblUser_1.UserName AS Created_By, dbo.tblEFTRecurring.Created_Tmstmp,
		tblUser_2.UserName AS Modified_By, dbo.tblEFTRecurring.Modified_Tmstmp, dbo.tblUser.UserName, dbo.tblUser.dFlag as fTERM,
		Derived.Created_tmstmp as LastPymtDate,
		IsNull(derived.Amount,0) as LastPymt,
		Derived.ReturnCode,
		Derived.ReturnText

FROM            dbo.tblEFTRecurring
INNER JOIN		dbo.tblUser ON dbo.tblEFTRecurring.UserID = dbo.tblUser.UserID
LEFT OUTER JOIN	(
					SELECT		TOP 1 EFTRecurringID, ReturnCode, ReturnText, Amount, Created_Tmstmp
					FROM		dbo.tblEFTTransactions
					ORDER BY 	Created_tmstmp desc
				) AS derived ON dbo.tblEFTRecurring.EFTRecurringID = derived.EFTRecurringID
LEFT OUTER JOIN	dbo.tblUser AS tblUser_1 ON dbo.tblEFTRecurring.Created_By = tblUser_1.UserID
LEFT OUTER JOIN	dbo.tblUser AS tblUser_2 ON dbo.tblEFTRecurring.Modified_By = tblUser_2.UserID


			WHERE 		1 = 1
			AND			tblEFTRecurring.GLBankAccountID	= <CFQUERYPARAM Value="#ARGUMENTS.GLBankAccountID#"		CFSQLTYPE="CF_SQL_INTEGER">
			<cfif Len(ARGUMENTS.Filter) GT 0>
				AND 	dbo.tblUser.UserName 			LIKE <cfqueryparam value="#ARGUMENTS.Filter#%">
			</cfif>
			<cfswitch expression="#ARGUMENTS.SortBy#">
				<cfcase value="UserName">	ORDER BY dbo.tblUser.UserName		</cfcase>
			</cfswitch>
		</cfquery>
		<cfreturn qList>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Read -  EFTRecurring
	Modifications
		7/13/2020 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Read" access="public" output="false" returntype="struct" DisplayName="Read EFTRecurring">
		<cfargument name="EFTRecurring"		type="EFTRecurring"		required="Yes" />

		<cfset var qRead = "" />
		<cfset var strReturn = structNew() />

		<cfquery name="qRead" datasource="#VARIABLES.dsn#">
			SELECT
				tblEFTRecurring.EFTRecurringID,
				tblEFTRecurring.NameOnAccount,
				tblEFTRecurring.dFlag,
				tblEFTRecurring.fRunNext,
				tblEFTRecurring.fTestMode,
				tblEFTRecurring.GLBankAccountID,
				tblEFTRecurring.UserID,
				tblEFTRecurring.TranType,
				tblEFTRecurring.AccountType,
				tblEFTRecurring.Amount,
				tblEFTRecurring.Period,
				tblEFTRecurring.StartDate,
				tblEFTRecurring.EndDate,
				tblEFTRecurring.CardNumber,
				tblEFTRecurring.CardExpiryMonth,
				tblEFTRecurring.CardExpiryYear,
				tblEFTRecurring.Token,
				tblEFTRecurring.Notes,
				tblEFTRecurring.hmJSON,
				tblEFTRecurring.AuthCode,
				tblEFTRecurring.ResponseText,
				tblEFTRecurring.TransactionID,
				tblUser_1.UserName AS Created_By,
				tblEFTRecurring.Created_Tmstmp,
				tblUser_2.UserName AS Modified_By,
				tblEFTRecurring.Modified_Tmstmp
			FROM	tblEFTRecurring
			LEFT OUTER JOIN	tblUser AS tblUser_1 ON tblEFTRecurring.Created_By = tblUser_1.UserID
			LEFT OUTER JOIN tblUser AS tblUser_2 ON tblEFTRecurring.Modified_By = tblUser_2.UserID
			WHERE	1 = 1

			<cfif ARGUMENTS.EFTRecurring.getEFTRecurringID() GT 0>
				AND		tblEFTRecurring.EFTRecurringID = <cfqueryparam value="#ARGUMENTS.EFTRecurring.getEFTRecurringID()#"		CFSQLType="cf_sql_integer" />
			<cfelse>
				AND		tblEFTRecurring.GLBankAccountID = <cfqueryparam value="#ARGUMENTS.EFTRecurring.getGLBankAccountID()#"	CFSQLType="cf_sql_integer" />
				AND		tblEFTRecurring.UserID 			= <cfqueryparam value="#ARGUMENTS.EFTRecurring.getUserID()#" 			CFSQLType="cf_sql_integer" />
			</cfif>
		</cfquery>

		<cfif qRead.recordCount>
			<cfset strReturn = queryRowToStruct(qRead)>
			<cfset ARGUMENTS.EFTRecurring.init(argumentCollection=strReturn)>
		<cfelse>
			<cfset strReturn = EFTRecurring.getMemento()>
		</cfif>
		<cfreturn strReturn>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Exists -  EFTRecurring
	Modifications
		7/13/2020 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Exists" access="public" output="false" returntype="boolean" DisplayName="Exists EFTRecurring">
		<cfargument name="EFTRecurring"		type="EFTRecurring"		required="Yes" />

		<cfset var qExists = "">

		<cfquery name="qExists" datasource="#variables.dsn#" maxrows="1">
			SELECT	count(1) as idexists
			FROM	tblEFTRecurring
			WHERE	1 = 1
			<cfif ARGUMENTS.EFTRecurring.getEFTRecurringID() GT 0>
				AND		tblEFTRecurring.EFTRecurringID = <cfqueryparam value="#ARGUMENTS.EFTRecurring.getEFTRecurringID()#"		CFSQLType="cf_sql_integer" />
			<cfelse>
				AND		tblEFTRecurring.GLBankAccountID = <cfqueryparam value="#ARGUMENTS.EFTRecurring.getGLBankAccountID()#"	CFSQLType="cf_sql_integer" />
				AND		tblEFTRecurring.UserID 			= <cfqueryparam value="#ARGUMENTS.EFTRecurring.getUserID()#" 			CFSQLType="cf_sql_integer" />
			</cfif>
		</cfquery>
		<cfif qExists.idexists>
			<cfreturn TRUE />
		<cfelse>
			<cfreturn FALSE />
		</cfif>
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Save -  EFTRecurring
	Modifications
		7/13/2020 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Save" access="public" output="true" returntype="numeric" DisplayName="Save EFTRecurring EFTRecurring">
		<cfargument name="EFTRecurring"		type="EFTRecurring"		required="Yes" />
		<cfargument name="fDebug" 			Type="boolean"			required="No"		Default="FALSE" />

		<cfset var pkID = 0 />		<!--- 0=false --->

		<cfif exists(arguments.EFTRecurring)>
			<cfif fDebug>update EFTRecurring</cfif>
			<cfset pkID = update(arguments.EFTRecurring, fDebug) />
		<cfelse>
			<cfif fDebug>create EFTRecurring</cfif>
			<cfset pkID = create(arguments.EFTRecurring, fDebug) />
		</cfif>

		<cfreturn pkID />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	InsertRec -  EFTRecurring
	Modifications
		7/13/2020 - created

	<cfinvoke component="#APPLICATION.DIR#cfc\EFTRecurringDAO" method="InsertRec" returnvariable="EFTRecurringID">
		<cfinvokeargument name="NameOnAccount"		Value="#FORM.NameOnAccount#">
		<cfinvokeargument name="dFlag"		Value="#FORM.dFlag#">
		<cfinvokeargument name="fRunNext"		Value="#FORM.fRunNext#">
		<cfinvokeargument name="fTestMode"		Value="#FORM.fTestMode#">
		<cfinvokeargument name="GLBankAccountID"		Value="#FORM.GLBankAccountID#">
		<cfinvokeargument name="UserID"		Value="#FORM.UserID#">
		<cfinvokeargument name="TranType"		Value="#FORM.TranType#">
		<cfinvokeargument name="AccountType"		Value="#FORM.AccountType#">
		<cfinvokeargument name="Amount"		Value="#FORM.Amount#">
		<cfinvokeargument name="Period"		Value="#FORM.Period#">
		<cfinvokeargument name="StartDate"		Value="#FORM.StartDate#">
		<cfinvokeargument name="EndDate"		Value="#FORM.EndDate#">
		<cfinvokeargument name="CardNumber"		Value="#FORM.CardNumber#">
		<cfinvokeargument name="CardExpiryMonth"		Value="#FORM.CardExpiryMonth#">
		<cfinvokeargument name="CardExpiryYear"		Value="#FORM.CardExpiryYear#">
		<cfinvokeargument name="Token"		Value="#FORM.Token#">
		<cfinvokeargument name="Notes"		Value="#FORM.Notes#">
		<cfinvokeargument name="hmJSON"		Value="#FORM.hmJSON#">
		<cfinvokeargument name="AuthCode"		Value="#FORM.AuthCode#">
		<cfinvokeargument name="ResponseText"		Value="#FORM.ResponseText#">
		<cfinvokeargument name="TransactionID"		Value="#FORM.TransactionID#">
	</cfinvoke>
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="InsertRec" access="public" output="false" returntype="numeric" DisplayName="InsertRec EFTRecurring">
		<cfargument name="NameOnAccount"			Type="string"		Required="No"		Default="" />
		<cfargument name="dFlag"					Type="string"		Required="No"		Default="N" />
		<!--- <cfargument name="fRunNext"					Type="string"		Required="No"		Default="N" /> --->
		<!--- <cfargument name="fTestMode"				Type="string"		Required="No"		Default="N" /> --->
		<cfargument name="GLBankAccountID"			Type="numeric"		Required="No"		Default="0" />
		<cfargument name="UserID"					Type="numeric"		Required="No"		Default="0" />
		<cfargument name="TranType"					Type="string"		Required="No"		Default="" />
		<cfargument name="AccountType"				Type="string"		Required="Yes"		Default="" />
		<cfargument name="Amount"					Type="numeric"		Required="No"		Default="0.00" />
		<cfargument name="Period"					Type="numeric"		Required="No"		Default="0" />
		<cfargument name="StartDate"				Type="string" />
		<cfargument name="EndDate"					Type="string" />
		<cfargument name="CardNumber"				Type="string"		Required="Yes"		Default="" />
		<cfargument name="CardExpiryMonth"			Type="numeric"		Required="No"		Default="0" />
		<cfargument name="CardExpiryYear"			Type="numeric"		Required="No"		Default="0" />
		<cfargument name="Token"					Type="string"		Required="Yes"		Default="" />
		<cfargument name="Notes"					Type="string"		Required="Yes"		Default="" />
		<cfargument name="hmJSON"					Type="string"		Required="Yes"		Default="" />
		<cfargument name="AuthCode"					Type="string"		Required="Yes"		Default="" />
		<cfargument name="ResponseText"				Type="string"		Required="Yes"		Default="" />
		<cfargument name="TransactionID"			Type="string"		Required="Yes"		Default="" />
		<cfargument name="OnErrorContinue"			Type="String"		Required="No"		Default="N" />

		<cfset var qInsert = "" />
		<cfset var R       = "" />

		<cftry>
			<cfquery name="qInsert" datasource="#VARIABLES.dsn#" Result="R">
				INSERT INTO tblEFTRecurring
					(
					tblEFTRecurring.NameOnAccount,
					tblEFTRecurring.dFlag,
					<!--- tblEFTRecurring.fRunNext, --->
					<!--- tblEFTRecurring.fTestMode, --->
					tblEFTRecurring.GLBankAccountID,
					tblEFTRecurring.UserID,
					tblEFTRecurring.TranType,
					tblEFTRecurring.AccountType,
					tblEFTRecurring.Amount,
					tblEFTRecurring.Period,
					tblEFTRecurring.StartDate,
					tblEFTRecurring.EndDate,
					tblEFTRecurring.CardNumber,
					tblEFTRecurring.CardExpiryMonth,
					tblEFTRecurring.CardExpiryYear,
					tblEFTRecurring.Token,
					tblEFTRecurring.Notes,
					tblEFTRecurring.hmJSON,
					tblEFTRecurring.AuthCode,
					tblEFTRecurring.ResponseText,
					tblEFTRecurring.TransactionID,
					tblEFTRecurring.Created_By,
					tblEFTRecurring.Created_Tmstmp
					)
				VALUES
					(
					<cfqueryparam value="#Left(ARGUMENTS.NameOnAccount,50)#"		CFSQLType="CF_SQL_VARCHAR" 	null="#not len(ARGUMENTS.NameOnAccount)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.dFlag,1)#"					CFSQLType="CF_SQL_CHAR" 	null="#not len(ARGUMENTS.dFlag)#" />,
					<!--- <cfqueryparam value="#Left(ARGUMENTS.fRunNext,1)#"				CFSQLType="CF_SQL_CHAR" 	null="#not len(ARGUMENTS.fRunNext)#" />, --->
					<!--- <cfqueryparam value="#Left(ARGUMENTS.fTestMode,1)#"				CFSQLType="CF_SQL_CHAR" 	null="#not len(ARGUMENTS.fTestMode)#" />, --->
					<cfqueryparam value="#ARGUMENTS.GLBankAccountID#"				CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#ARGUMENTS.UserID#"						CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#Left(ARGUMENTS.TranType,2)#"				CFSQLType="CF_SQL_CHAR" 	null="#not len(ARGUMENTS.TranType)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.AccountType,16)#"			CFSQLType="CF_SQL_VARCHAR" 	null="#not len(ARGUMENTS.AccountType)#" />,
					<cfqueryparam value="#ARGUMENTS.Amount#"						CFSQLType="CF_SQL_MONEY" />,
					<cfqueryparam value="#ARGUMENTS.Period#"						CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#ARGUMENTS.StartDate#"						CFSQLType="CF_SQL_DATE"		null="#not len(ARGUMENTS.StartDate)#" />,
					<cfqueryparam value="#ARGUMENTS.EndDate#"						CFSQLType="CF_SQL_DATE"		null="#not len(ARGUMENTS.EndDate)#" />,
					<cfqueryparam value="#Right(ARGUMENTS.CardNumber,4)#"			CFSQLType="CF_SQL_CHAR" 	null="#not len(ARGUMENTS.CardNumber)#" />,
					<cfqueryparam value="#ARGUMENTS.CardExpiryMonth#"				CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#ARGUMENTS.CardExpiryYear#"				CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#Left(ARGUMENTS.Token,32)#"				CFSQLType="CF_SQL_VARCHAR" 	null="#not len(ARGUMENTS.Token)#" />,
					<cfqueryparam value="#ARGUMENTS.Notes#"							CFSQLType="CF_SQL_VARCHAR"	null="#not len(ARGUMENTS.Notes)#" />,
					<cfqueryparam value="#ARGUMENTS.hmJSON#"						CFSQLType="CF_SQL_VARCHAR"	null="#not len(ARGUMENTS.hmJSON)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.AuthCode,32)#"				CFSQLType="CF_SQL_VARCHAR" 	null="#not len(ARGUMENTS.AuthCode)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.ResponseText,32)#"			CFSQLType="CF_SQL_VARCHAR" 	null="#not len(ARGUMENTS.ResponseText)#" />,
					<cfqueryparam value="#Left(ARGUMENTS.TransactionID,32)#"		CFSQLType="CF_SQL_VARCHAR" 	null="#not len(ARGUMENTS.TransactionID)#" />,
					<cfqueryparam value="#SESSION.UserID#"							CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#Now()#"									CFSQLType="CF_SQL_TIMESTAMP" />
					)
			</cfquery>
			<CF_XLogCart Table="EFTRecurring" type="I" Value="#R.IDENTITYCOL#" Desc="Insert into EFTRecurring">
			<cfcatch type="database">
				<cfif ARGUMENTS.OnErrorContinue EQ "N">
					<CF_XLogCart Table="EFTRecurring" type="E" Value="0" Desc="Error inserting EFTRecurring (#cfcatch.detail#)" >
				</cfif>
				<cfreturn 0 />
			</cfcatch>
		</cftry>
		<cfreturn R.IDENTITYCOL />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Create -  EFTRecurring
	Modifications
		7/13/2020 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Create" access="public" output="true" returntype="numeric" DisplayName="Create EFTRecurring">
		<cfargument name="EFTRecurring"			Type="EFTRecurring"	required="Yes" />
		<cfargument name="fDebug" 				Type="boolean"		required="No"	Default="FALSE" />
		<cfargument name="OnErrorContinue"  	Type="String"		required="No"	Default="N" />

		<cfset var qCreate = "" />
		<cfset var R       = "" />

		<cftry>
			<cfquery name="qCreate" datasource="#VARIABLES.dsn#" Result="R">
				INSERT INTO tblEFTRecurring
					(
					tblEFTRecurring.NameOnAccount,
					tblEFTRecurring.dFlag,
					<!--- tblEFTRecurring.fRunNext, --->
					<!--- tblEFTRecurring.fTestMode, --->
					tblEFTRecurring.GLBankAccountID,
					tblEFTRecurring.UserID,
					tblEFTRecurring.TranType,
					tblEFTRecurring.AccountType,
					tblEFTRecurring.Amount,
					tblEFTRecurring.Period,
					tblEFTRecurring.StartDate,
					tblEFTRecurring.EndDate,
					tblEFTRecurring.CardNumber,
					tblEFTRecurring.CardExpiryMonth,
					tblEFTRecurring.CardExpiryYear,
					tblEFTRecurring.Token,
					tblEFTRecurring.Notes,
					tblEFTRecurring.hmJSON,
					tblEFTRecurring.AuthCode,
					tblEFTRecurring.ResponseText,
					tblEFTRecurring.TransactionID,
					tblEFTRecurring.Created_By,
					tblEFTRecurring.Created_Tmstmp
					)
				VALUES
					(
					<cfqueryparam value="#Left(ARGUMENTS.EFTRecurring.getNameOnAccount(),50)#"		CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.EFTRecurring.getNameOnAccount())#" />,
					<cfqueryparam value="#Left(ARGUMENTS.EFTRecurring.getdFlag(),1)#"				CFSQLType="CF_SQL_CHAR"		null="#not len(ARGUMENTS.EFTRecurring.getdFlag())#" />,
					<!--- <cfqueryparam value="#Left(ARGUMENTS.EFTRecurring.getfRunNext(),1)#"			CFSQLType="CF_SQL_CHAR"		null="#not len(ARGUMENTS.EFTRecurring.getfRunNext())#" />, --->
					<!--- <cfqueryparam value="#Left(ARGUMENTS.EFTRecurring.getfTestMode(),1)#"			CFSQLType="CF_SQL_CHAR"		null="#not len(ARGUMENTS.EFTRecurring.getfTestMode())#" />, --->
					<cfqueryparam value="#ARGUMENTS.EFTRecurring.getGLBankAccountID()#"				CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#ARGUMENTS.EFTRecurring.getUserID()#"						CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#Left(ARGUMENTS.EFTRecurring.getTranType(),2)#"			CFSQLType="CF_SQL_CHAR"		null="#not len(ARGUMENTS.EFTRecurring.getTranType())#" />,
					<cfqueryparam value="#Left(ARGUMENTS.EFTRecurring.getAccountType(),16)#"		CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.EFTRecurring.getAccountType())#" />,
					<cfqueryparam value="#ARGUMENTS.EFTRecurring.getAmount()#"						CFSQLType="CF_SQL_MONEY" />,
					<cfqueryparam value="#ARGUMENTS.EFTRecurring.getPeriod()#"						CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#ARGUMENTS.EFTRecurring.getStartDate()#"					CFSQLType="CF_SQL_DATE"		null="#not len(ARGUMENTS.EFTRecurring.getStartDate())#" />,
					<cfqueryparam value="#ARGUMENTS.EFTRecurring.getEndDate()#"						CFSQLType="CF_SQL_DATE"		null="#not len(ARGUMENTS.EFTRecurring.getEndDate())#" />,
					<cfqueryparam value="#Right(ARGUMENTS.EFTRecurring.getCardNumber(),4)#"			CFSQLType="CF_SQL_CHAR"		null="#not len(ARGUMENTS.EFTRecurring.getCardNumber())#" />,
					<cfqueryparam value="#ARGUMENTS.EFTRecurring.getCardExpiryMonth()#"				CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#ARGUMENTS.EFTRecurring.getCardExpiryYear()#"				CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#Left(ARGUMENTS.EFTRecurring.getToken(),32)#"				CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.EFTRecurring.getToken())#" />,
					<cfqueryparam value="#ARGUMENTS.EFTRecurring.getNotes()#"						CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.EFTRecurring.getNotes())#" />,
					<cfqueryparam value="#ARGUMENTS.EFTRecurring.gethmJSON()#"						CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.EFTRecurring.gethmJSON())#" />,
					<cfqueryparam value="#Left(ARGUMENTS.EFTRecurring.getAuthCode(),32)#"			CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.EFTRecurring.getAuthCode())#" />,
					<cfqueryparam value="#Left(ARGUMENTS.EFTRecurring.getResponseText(),32)#"		CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.EFTRecurring.getResponseText())#" />,
					<cfqueryparam value="#Left(ARGUMENTS.EFTRecurring.getTransactionID(),32)#"		CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.EFTRecurring.getTransactionID())#" />,
					<cfqueryparam value="#SESSION.UserID#"											CFSQLType="CF_SQL_INTEGER" />,
					<cfqueryparam value="#Now()#"													CFSQLType="CF_SQL_TIMESTAMP" />
				)
			</cfquery>
			<CF_XLogCart Table="EFTRecurring" type="I" Value="#R.IDENTITYCOL#" Desc="#ARGUMENTS.EFTRecurring.getNameOnAccount()# created">
			<cfcatch type="database">
				<cfif ARGUMENTS.OnErrorContinue EQ "N">
					<CF_XLogCart Table="EFTRecurring" type="E" Value="0" Desc="Error inserting EFTRecurring (#cfcatch.detail#)" >
				</cfif>
				<cfreturn 0 />
			</cfcatch>
		</cftry>
		<cfreturn R.IDENTITYCOL />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Update -  EFTRecurring
	Modifications
		1/28/2020 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Update" access="public" output="false" returntype="numeric" DisplayName="Update EFTRecurring">
		<cfargument name="EFTRecurring"				Type="EFTRecurring"	required="Yes" />
		<cfargument name="fDebug" 				Type="boolean"		required="No"	Default="FALSE" />
		<cfargument name="OnErrorContinue"		Type="String"		required="No"	Default="N" />

		<cfset var qUpdate = "" />

		<cftry>
			<cfquery name="qUpdate" datasource="#VARIABLES.dsn#">
				UPDATE tblEFTRecurring
				SET
					NameOnAccount			= <cfqueryparam value="#Left(ARGUMENTS.EFTRecurring.getNameOnAccount(),50)#"		CFSQLType="CF_SQL_VARCHAR" 		null="#not len(ARGUMENTS.EFTRecurring.getNameOnAccount())#" />,
					dFlag					= <cfqueryparam value="#Left(ARGUMENTS.EFTRecurring.getdFlag(),1)#"					CFSQLType="CF_SQL_CHAR" 		null="#not len(ARGUMENTS.EFTRecurring.getdFlag())#" />,
					fRunNext				= <cfqueryparam value="#Left(ARGUMENTS.EFTRecurring.getfRunNext(),1)#"				CFSQLType="CF_SQL_CHAR" 		null="#not len(ARGUMENTS.EFTRecurring.getfRunNext())#" />,
					fTestMode				= <cfqueryparam value="#Left(ARGUMENTS.EFTRecurring.getfTestMode(),1)#"				CFSQLType="CF_SQL_CHAR" 		null="#not len(ARGUMENTS.EFTRecurring.getfTestMode())#" />,
					GLBankAccountID			= <cfqueryparam value="#ARGUMENTS.EFTRecurring.getGLBankAccountID()#"				CFSQLType="CF_SQL_INTEGER" />,
					UserID					= <cfqueryparam value="#ARGUMENTS.EFTRecurring.getUserID()#"						CFSQLType="CF_SQL_INTEGER" />,
					TranType				= <cfqueryparam value="#Left(ARGUMENTS.EFTRecurring.getTranType(),2)#"				CFSQLType="CF_SQL_CHAR" 		null="#not len(ARGUMENTS.EFTRecurring.getTranType())#" />,
					AccountType				= <cfqueryparam value="#Left(ARGUMENTS.EFTRecurring.getAccountType(),16)#"			CFSQLType="CF_SQL_VARCHAR" 		null="#not len(ARGUMENTS.EFTRecurring.getAccountType())#" />,
					Amount					= <cfqueryparam value="#ARGUMENTS.EFTRecurring.getAmount()#"						CFSQLType="CF_SQL_MONEY" />,
					Period					= <cfqueryparam value="#ARGUMENTS.EFTRecurring.getPeriod()#"						CFSQLType="CF_SQL_INTEGER" />,
					StartDate				= <cfqueryparam value="#ARGUMENTS.EFTRecurring.getStartDate()#"						CFSQLType="CF_SQL_DATE"			null="#not len(ARGUMENTS.EFTRecurring.getStartDate())#" />,
					EndDate					= <cfqueryparam value="#ARGUMENTS.EFTRecurring.getEndDate()#"						CFSQLType="CF_SQL_DATE"			null="#not len(ARGUMENTS.EFTRecurring.getEndDate())#" />,
					CardNumber				= <cfqueryparam value="#Left(ARGUMENTS.EFTRecurring.getCardNumber(),4)#"			CFSQLType="CF_SQL_CHAR" 		null="#not len(ARGUMENTS.EFTRecurring.getCardNumber())#" />,
					CardExpiryMonth			= <cfqueryparam value="#ARGUMENTS.EFTRecurring.getCardExpiryMonth()#"				CFSQLType="CF_SQL_INTEGER" />,
					CardExpiryYear			= <cfqueryparam value="#ARGUMENTS.EFTRecurring.getCardExpiryYear()#"				CFSQLType="CF_SQL_INTEGER" />,
					Token					= <cfqueryparam value="#Left(ARGUMENTS.EFTRecurring.getToken(),32)#"				CFSQLType="CF_SQL_VARCHAR" 		null="#not len(ARGUMENTS.EFTRecurring.getToken())#" />,
					Notes					= <cfqueryparam value="#ARGUMENTS.EFTRecurring.getNotes()#"							CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.EFTRecurring.getNotes())#" />,
					hmJSON					= <cfqueryparam value="#ARGUMENTS.EFTRecurring.gethmJSON()#"						CFSQLType="CF_SQL_VARCHAR"		null="#not len(ARGUMENTS.EFTRecurring.gethmJSON())#" />,
					AuthCode				= <cfqueryparam value="#Left(ARGUMENTS.EFTRecurring.getAuthCode(),32)#"				CFSQLType="CF_SQL_VARCHAR" 		null="#not len(ARGUMENTS.EFTRecurring.getAuthCode())#" />,
					ResponseText			= <cfqueryparam value="#Left(ARGUMENTS.EFTRecurring.getResponseText(),32)#"			CFSQLType="CF_SQL_VARCHAR" 		null="#not len(ARGUMENTS.EFTRecurring.getResponseText())#" />,
					TransactionID			= <cfqueryparam value="#Left(ARGUMENTS.EFTRecurring.getTransactionID(),32)#"		CFSQLType="CF_SQL_VARCHAR" 		null="#not len(ARGUMENTS.EFTRecurring.getTransactionID())#" />,
					Modified_By				= <cfqueryparam value="#SESSION.UserID#" 											CFSQLType="CF_SQL_INTEGER" />,
					Modified_Tmstmp			= <cfqueryparam value="#Now()#" 													CFSQLType="CF_SQL_TIMESTAMP" />
				WHERE	1 = 1
				<cfif ARGUMENTS.EFTRecurring.getEFTRecurringID() GT 0>
					AND		tblEFTRecurring.EFTRecurringID = <cfqueryparam value="#ARGUMENTS.EFTRecurring.getEFTRecurringID()#"		CFSQLType="cf_sql_integer" />
				<cfelse>
					AND		tblEFTRecurring.GLBankAccountID = <cfqueryparam value="#ARGUMENTS.EFTRecurring.getGLBankAccountID()#"	CFSQLType="cf_sql_integer" />
					AND		tblEFTRecurring.UserID 			= <cfqueryparam value="#ARGUMENTS.EFTRecurring.getUserID()#" 			CFSQLType="cf_sql_integer" />
				</cfif>
			</cfquery>
			<CF_XLogCart Table="EFTRecurring" type="U" Value="#ARGUMENTS.EFTRecurring.getEFTRecurringID()#" Desc="EFTRecurring #ARGUMENTS.EFTRecurring.getNameOnAccount()# Updated">
			<cfcatch type="database">
				<cfif ARGUMENTS.OnErrorContinue EQ "N">
					<CF_XLogCart Table="EFTRecurring" type="E" Value="0" Desc="Error updating EFTRecurring (#cfcatch.detail#)" >
				</cfif>
				<cfreturn 0 />
			</cfcatch>
		</cftry>
		<cfreturn ARGUMENTS.EFTRecurring.getEFTRecurringID() />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	Delete -  EFTRecurring
	Modifications
		7/13/2020 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Delete" access="public" output="false" returntype="boolean" DisplayName="Delete EFTRecurring">
		<cfargument name="EFTRecurring"			type="EFTRecurring"	required="Yes" />
		<cfargument name="OnErrorContinue"  	Type="String"		required="No"	Default="N" />

		<cfset var qDelete = "" />
		<cfset var R       = "" />
		<cftry>
			<cfquery name="qDelete" datasource="#VARIABLES.dsn#" Result="R">
				DELETE FROM	tblEFTRecurring
				WHERE	1 = 1
				AND		EFTRecurringID = <cfqueryparam value="#ARGUMENTS.EFTRecurring.getEFTRecurringID()#" 					CFSQLType="cf_sql_integer" />
			</cfquery>
			<CF_XLogCart Table="EFTRecurring" type="D" Value="#ARGUMENTS.EFTRecurring.getEFTRecurringID()#" Desc="#ARGUMENTS.EFTRecurring.getNameOnAccount()# Physically Deleted">
			<cfcatch type="database">
				<cfif ARGUMENTS.OnErrorContinue EQ "N">
					<CF_XLogCart Table="EFTRecurring" type="D" Value="0" Desc="Error deleting EFTRecurring (#cfcatch.detail#)" >
				</cfif>
				<cfreturn FALSE />
			</cfcatch>
		</cftry>
		<cfreturn TRUE />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	DeleteLogical -  EFTRecurring
	Modifications
		7/13/2020 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="DeleteLogical" access="public" output="false" returntype="boolean" DisplayName="DeleteLogical EFTRecurring">
		<cfargument name="EFTRecurring"			type="EFTRecurring"	required="true" />
		<cfargument name="OnErrorContinue"		type="String"		required="Yes" 	Default="Y"/>

		<cfset var qDelete = "" />
		<cfset var errMsg 	= "" />
		<cfset var EFTRecurringID = ARGUMENTS.EFTRecurring.getEFTRecurringID()>
		<cftry>
			<cfquery name="qDelete" datasource="#variables.DSN#">
				UPDATE  tblEFTRecurring
				SET
					dFlag				= 'Y',
					Token				= '',
					Modified_By 		= <cfqueryparam value="#SESSION.UserID#" 			CFSQLType="CF_SQL_INTEGER" />,
					Modified_Tmstmp 	= <cfqueryparam value="#Now()#" 					CFSQLType="CF_SQL_TIMESTAMP" />
				WHERE	EFTRecurringID	= <cfqueryparam value="#EFTRecurringID#" 			CFSQLType="cf_sql_integer" />
			</cfquery>

			<CF_XLogCart Table="EFTRecurring" type="D" Value="#EFTRecurringID#" Desc="#ARGUMENTS.EFTRecurring.getNameOnAccount()# Logically Deleted">
			<cfcatch type="database">
				<cfif ARGUMENTS.OnErrorContinue EQ "N">
					<CF_XLogCart Table="EFTRecurring" type="D" Value="0" Desc="Error deleting logical EFTRecurring (#cfcatch.detail#)" >
				</cfif>
				<cfreturn FALSE />
			</cfcatch>
		</cftry>
		<cfreturn TRUE />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	DeleteByID -  EFTRecurring
	Modifications
		7/13/2020 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="DeleteByID" access="public" output="false" returntype="boolean" DisplayName="DeleteByID EFTRecurring">
		<cfargument name="EFTRecurringID"		type="Numeric"		Required="true" />
		<cfargument name="OnErrorContinue"		type="String"		Required="Yes" 	Default="Y"/>

		<cfset var qDelete = "" />
		<cfset var R       = "" />

		<cftry>
			<cfquery name="qDelete" datasource="#VARIABLES.dsn#" Result="R">
				DELETE 	FROM	tblEFTRecurring
				WHERE	1 = 1
				AND		EFTRecurringID = <cfqueryparam value="#ARGUMENTS.EFTRecurringID#" 					CFSQLType="cf_sql_integer" />
			</cfquery>
			<CF_XLogCart Table="EFTRecurring" type="D" Value="#ARGUMENTS.EFTRecurringID#" Desc="EFTRecurring Deleted">
			<cfcatch type="database">
				<cfif ARGUMENTS.OnErrorContinue EQ "N">
					<CF_XLogCart Table="EFTRecurring" type="D" Value="#ARGUMENTS.EFTRecurringID#" Desc="Error deleting EFTRecurring (#cfcatch.detail#)" >
				</cfif>
				<cfreturn FALSE />
			</cfcatch>
		</cftry>
		<cfreturn TRUE />
	</cffunction>

<!--- ----------------------------------------------------------------------------------------------------------------
	UpdateToken -  EFTRecurring Update the Token
	Modifications
		10/28/2019 - created
---------------------------------------------------------------------------------------------------------------------->
	<cffunction name="UpdateToken" access="public" output="false" returntype="Boolean" DisplayName="UpdateToken">
		<cfargument name="EFTRecurringID" 	type="Numeric" 	required="Yes" />
		<cfargument name="Token" 			type="String" 	required="Yes" />

		<cfset var qUpdate = "" />
		<cfset var errMsg 	= "" />

		<cftry>
			<cfquery name="qUpdate" datasource="#variables.DSN#">
				UPDATE	tblEFTRecurring
				SET
					Token 			= <cfqueryparam value="#ARGUMENTS.Token#" 			CFSQLType="CF_SQL_VARCHAR" />,
					Modified_By 	= <cfqueryparam value="#SESSION.UserID#" 			CFSQLType="CF_SQL_INTEGER" />,
					Modified_Tmstmp = <cfqueryparam value="#Now()#" 					CFSQLType="CF_SQL_TIMESTAMP" />
				WHERE
					EFTRecurringID = <cfqueryparam value="#ARGUMENTS.EFTRecurringID#"	CFSQLType="cf_sql_integer" />
			</cfquery>
			<CF_XLogCart Table="EFTRecurring" type="U" Value="#ARGUMENTS.EFTRecurringID#" Desc="Token updated to #ARGUMENTS.Token#">
			<cfcatch>
				<cfreturn FALSE />
			</cfcatch>
		</cftry>
		<cfreturn  TRUE />
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