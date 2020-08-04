<!--------------------------------------------------------------------------------------------
	EFTRecurring.cfc

	* $Revision: $
	* $Date: 7/16/2020 $
---------------------------------------------------------------------------------------------->

<cfcomponent displayname="EFTRecurring" output="false">

	<cfproperty name="EFTRecurringID"			Type="numeric"	default="" />
	<cfproperty name="NameOnAccount"			Type="string"	default="" />
	<cfproperty name="dFlag"					Type="string"	default="" />
	<cfproperty name="fRunNext"					Type="string"	default="" />
	<cfproperty name="fTestMode"				Type="string"	default="" />
	<cfproperty name="GLBankAccountID"			Type="numeric"	default="" />
	<cfproperty name="AccountID"				Type="numeric"	default="" />
	<cfproperty name="ClubID"					Type="numeric"	default="" />
	<cfproperty name="UserID"					Type="numeric"	default="" />
	<cfproperty name="ContributionType"			Type="string"	default="" />
	<cfproperty name="ConvMethod"				Type="string"	default="" />
	<cfproperty name="TranType"					Type="string"	default="" />
	<cfproperty name="AccountType"				Type="string"	default="" />
	<cfproperty name="Amount"					Type="numeric"	default="" />
	<cfproperty name="Period"					Type="numeric"	default="" />
	<cfproperty name="StartDate"				Type="date"		default="" />
	<cfproperty name="EndDate"					Type="date"		default="" />
	<cfproperty name="CardNumber"				Type="string"	default="" />
	<cfproperty name="CardExpiryMonth"			Type="numeric"	default="" />
	<cfproperty name="CardExpiryYear"			Type="numeric"	default="" />
	<cfproperty name="Token"					Type="string"	default="" />
	<cfproperty name="Notes"					Type="string"	default="" />
	<cfproperty name="hmJSON"					Type="string"	default="" />
	<cfproperty name="AuthCode"					Type="string"	default="" />
	<cfproperty name="ResponseText"				Type="string"	default="" />
	<cfproperty name="TransactionID"			Type="string"	default="" />
	<cfproperty name="Created_By"				Type="numeric"	default="" />
	<cfproperty name="Created_Tmstmp"			Type="date"	default="" />
	<cfproperty name="Modified_By"				Type="numeric"	default="" />
	<cfproperty name="Modified_Tmstmp"			Type="date"		default="" />


	<!---
	PROPERTIES
	--->
	<cfset variables.instance = StructNew() />
	<!---
	INITIALIZATION / CONFIGURATION
	--->

	<cffunction name="init" access="public" returntype="EFTRecurring" output="false">
		<cfargument name="EFTRecurringID"				Type="numeric"	required="false"	default="0"	/>
		<cfargument name="NameOnAccount"				Type="string"	required="false"	default=""	/>
		<cfargument name="dFlag"						Type="string"	required="false"	default="N"	/>
		<cfargument name="fRunNext"						Type="string"	required="false"	default="N"	/>
		<cfargument name="fTestMode"					Type="string"	required="false"	default="N"	/>
		<cfargument name="GLBankAccountID"				Type="numeric"	required="false"	default="0"	/>
		<cfargument name="AccountID"					Type="numeric"	required="false"	default="#SESSION.AccountID#"	/>
		<cfargument name="ClubID"						Type="numeric"	required="false"	default="#SESSION.ClubID#"	/>
		<cfargument name="UserID"						Type="numeric"	required="false"	default="0"	/>
		<cfargument name="ContributionType"				Type="string"	required="false"	default="C"	/>
		<cfargument name="ConvMethod"					Type="string"	required="false"	default="A"	/>
		<cfargument name="TranType"						Type="string"	required="false"	default="EC"	/>
		<cfargument name="AccountType"					Type="string"	required="false"	default=""	/>
		<cfargument name="Amount"						Type="numeric"	required="false"	default="0.00"	/>
		<cfargument name="Period"						Type="numeric"	required="false"	default="0"	/>
		<cfargument name="StartDate"					Type="string"	required="false"	default="#Now()+1#"	/>
		<cfargument name="EndDate"						Type="string"	required="false"	default=""	/>
		<cfargument name="CardNumber"					Type="string"	required="false"	default=""	/>
		<cfargument name="CardExpiryMonth"				Type="numeric"	required="false"	default="0"	/>
		<cfargument name="CardExpiryYear"				Type="numeric"	required="false"	default="0"	/>
		<cfargument name="Token"						Type="string"	required="false"	default=""	/>
		<cfargument name="Notes"						Type="string"	required="false"	default=""	/>
		<cfargument name="hmJSON"						Type="string"	required="false"	default='{"HMADDRESS":"","HM":"","HMNAME":""}'	/>
		<cfargument name="AuthCode"						Type="string"	required="false"	default=""	/>
		<cfargument name="ResponseText"					Type="string"	required="false"	default=""	/>
		<cfargument name="TransactionID"				Type="string"	required="false"	default=""	/>
		<cfargument name="Created_By"					Type="string"	required="false"	default="#SESSION.UserID#"	/>
		<cfargument name="Created_Tmstmp"				Type="string"	required="false"	default="#now()#"	/>
		<cfargument name="Modified_By"					Type="string"	required="false"	default="#SESSION.UserID#"	/>
		<cfargument name="Modified_Tmstmp"				Type="string"	required="false"	default="#now()#"	/>

		<!--- run setters --->
		<cfset setEFTRecurringID(ARGUMENTS.EFTRecurringID) />
		<cfset setNameOnAccount(ARGUMENTS.NameOnAccount) />
		<cfset setdFlag(ARGUMENTS.dFlag) />
		<cfset setfRunNext(ARGUMENTS.fRunNext) />
		<cfset setfTestMode(ARGUMENTS.fTestMode) />
		<cfset setGLBankAccountID(ARGUMENTS.GLBankAccountID) />
		<cfset setAccountID(ARGUMENTS.AccountID) />
		<cfset setClubID(ARGUMENTS.ClubID) />
		<cfset setUserID(ARGUMENTS.UserID) />
		<cfset setContributionType(ARGUMENTS.ContributionType) />
		<cfset setConvMethod(ARGUMENTS.ConvMethod) />
		<cfset setTranType(ARGUMENTS.TranType) />
		<cfset setAccountType(ARGUMENTS.AccountType) />
		<cfset setAmount(ARGUMENTS.Amount) />
		<cfset setPeriod(ARGUMENTS.Period) />
		<cfset setStartDate(ARGUMENTS.StartDate) />
		<cfset setEndDate(ARGUMENTS.EndDate) />
		<cfset setCardNumber(ARGUMENTS.CardNumber) />
		<cfset setCardExpiryMonth(ARGUMENTS.CardExpiryMonth) />
		<cfset setCardExpiryYear(ARGUMENTS.CardExpiryYear) />
		<cfset setToken(ARGUMENTS.Token) />
		<cfset setNotes(ARGUMENTS.Notes) />
		<cfset sethmJSON(ARGUMENTS.hmJSON) />
		<cfset setAuthCode(ARGUMENTS.AuthCode) />
		<cfset setResponseText(ARGUMENTS.ResponseText) />
		<cfset setTransactionID(ARGUMENTS.TransactionID) />
		<cfset setCreated_By(ARGUMENTS.Created_By) />
		<cfset setCreated_Tmstmp(ARGUMENTS.Created_Tmstmp) />
		<cfset setModified_By(ARGUMENTS.Modified_By) />
		<cfset setModified_Tmstmp(ARGUMENTS.Modified_Tmstmp) />

		<cfreturn this />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="setMemento" access="public" returntype="EFTRecurring" output="false">
		<cfargument name="memento" type="struct" required="yes"/>
		<cfset variables.instance = arguments.memento />
		<cfreturn this />
	</cffunction>
	<cffunction name="getMemento" access="public" returntype="struct" output="false" >
		<cfreturn variables.instance />
	</cffunction>

	<!---
	VALIDATION FUNCTIONS
	--->
	<cffunction name="validate" access="public" returntype="array" output="false">
		<cfargument name="abort" type="boolean" required="yes"  default="TRUE" />

		<cfset var N 		= 0 />
		<cfset var errors 	= arrayNew(1) />
		<cfset var thisError = structNew() />


		<!--- EFTRecurringID --->
		<cfif len(trim( getEFTRecurringID() )) AND NOT isNumeric(trim( getEFTRecurringID() ))>
			<cfset thisError.field = "EFTRecurringID" />
			<cfset thisError.type = "invalidType" />
			<cfset thisError.message = "EFTRecurringID is not a number" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>

		<!--- NameOnAccount --->
		<cfif len(trim( getNameOnAccount() )) AND NOT IsSimpleValue(trim( getNameOnAccount() ))>
			<cfset thisError.field = "NameOnAccount" />
			<cfset thisError.type = "invalidType" />
			<cfset thisError.message = "NameOnAccount is not a string" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>
		<cfif len(trim( getNameOnAccount() )) GT 50>
			<cfset thisError.field = "NameOnAccount" />
			<cfset thisError.type = "too Long" />
			<cfset thisError.message = "NameOnAccount is too long" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>

		<!--- dFlag --->
		<cfif len(trim( getdFlag() )) AND NOT IsSimpleValue(trim( getdFlag() ))>
			<cfset thisError.field = "dFlag" />
			<cfset thisError.type = "invalidType" />
			<cfset thisError.message = "dFlag is not a string" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>
		<cfif len(trim( getdFlag() )) GT 1>
			<cfset thisError.field = "dFlag" />
			<cfset thisError.type = "too Long" />
			<cfset thisError.message = "dFlag is too long" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>

		<!--- fRunNext --->
		<cfif len(trim( getfRunNext() )) AND NOT IsSimpleValue(trim( getfRunNext() ))>
			<cfset thisError.field = "fRunNext" />
			<cfset thisError.type = "invalidType" />
			<cfset thisError.message = "fRunNext is not a string" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>
		<cfif len(trim( getfRunNext() )) GT 1>
			<cfset thisError.field = "fRunNext" />
			<cfset thisError.type = "too Long" />
			<cfset thisError.message = "fRunNext is too long" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>

		<!--- fTestMode --->
		<cfif len(trim( getfTestMode() )) AND NOT IsSimpleValue(trim( getfTestMode() ))>
			<cfset thisError.field = "fTestMode" />
			<cfset thisError.type = "invalidType" />
			<cfset thisError.message = "fTestMode is not a string" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>
		<cfif len(trim( getfTestMode() )) GT 1>
			<cfset thisError.field = "fTestMode" />
			<cfset thisError.type = "too Long" />
			<cfset thisError.message = "fTestMode is too long" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>

		<!--- GLBankAccountID --->
		<cfif len(trim( getGLBankAccountID() )) AND NOT isNumeric(trim( getGLBankAccountID() ))>
			<cfset thisError.field = "GLBankAccountID" />
			<cfset thisError.type = "invalidType" />
			<cfset thisError.message = "GLBankAccountID is not a number" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>

		<!--- AccountID --->
		<cfif len(trim( getAccountID() )) AND NOT isNumeric(trim( getAccountID() ))>
			<cfset thisError.field = "AccountID" />
			<cfset thisError.type = "invalidType" />
			<cfset thisError.message = "AccountID is not a number" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>

		<!--- ClubID --->
		<cfif len(trim( getClubID() )) AND NOT isNumeric(trim( getClubID() ))>
			<cfset thisError.field = "ClubID" />
			<cfset thisError.type = "invalidType" />
			<cfset thisError.message = "ClubID is not a number" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>

		<!--- UserID --->
		<cfif len(trim( getUserID() )) AND NOT isNumeric(trim( getUserID() ))>
			<cfset thisError.field = "UserID" />
			<cfset thisError.type = "invalidType" />
			<cfset thisError.message = "UserID is not a number" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>

		<!--- ContributionType --->
		<cfif len(trim( getContributionType() )) AND NOT IsSimpleValue(trim( getContributionType() ))>
			<cfset thisError.field = "ContributionType" />
			<cfset thisError.type = "invalidType" />
			<cfset thisError.message = "ContributionType is not a string" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>
		<cfif len(trim( getContributionType() )) GT 1>
			<cfset thisError.field = "ContributionType" />
			<cfset thisError.type = "too Long" />
			<cfset thisError.message = "ContributionType is too long" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>

		<!--- ConvMethod --->
		<cfif len(trim( getConvMethod() )) AND NOT IsSimpleValue(trim( getConvMethod() ))>
			<cfset thisError.field = "ConvMethod" />
			<cfset thisError.type = "invalidType" />
			<cfset thisError.message = "ConvMethod is not a string" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>
		<cfif len(trim( getConvMethod() )) GT 1>
			<cfset thisError.field = "ConvMethod" />
			<cfset thisError.type = "too Long" />
			<cfset thisError.message = "ConvMethod is too long" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>

		<!--- TranType --->
		<cfif len(trim( getTranType() )) AND NOT IsSimpleValue(trim( getTranType() ))>
			<cfset thisError.field = "TranType" />
			<cfset thisError.type = "invalidType" />
			<cfset thisError.message = "TranType is not a string" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>
		<cfif len(trim( getTranType() )) GT 2>
			<cfset thisError.field = "TranType" />
			<cfset thisError.type = "too Long" />
			<cfset thisError.message = "TranType is too long" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>

		<!--- AccountType --->
		<cfif len(trim( getAccountType() )) AND NOT IsSimpleValue(trim( getAccountType() ))>
			<cfset thisError.field = "AccountType" />
			<cfset thisError.type = "invalidType" />
			<cfset thisError.message = "AccountType is not a string" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>
		<cfif len(trim( getAccountType() )) GT 16>
			<cfset thisError.field = "AccountType" />
			<cfset thisError.type = "too Long" />
			<cfset thisError.message = "AccountType is too long" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>

		<!--- Amount --->

		<!--- Period --->
		<cfif len(trim( getPeriod() )) AND NOT isNumeric(trim( getPeriod() ))>
			<cfset thisError.field = "Period" />
			<cfset thisError.type = "invalidType" />
			<cfset thisError.message = "Period is not a number" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>

		<!--- StartDate --->
		<cfif len(trim( getStartDate() )) AND NOT isDate(trim( getStartDate() ))>
			<cfset thisError.field = "StartDate" />
			<cfset thisError.type = "invalidType" />
			<cfset thisError.message = "StartDate is not a date" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>

		<!--- EndDate --->
		<cfif len(trim( getEndDate() )) AND NOT isDate(trim( getEndDate() ))>
			<cfset thisError.field = "EndDate" />
			<cfset thisError.type = "invalidType" />
			<cfset thisError.message = "EndDate is not a date" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>

		<!--- CardNumber --->
		<cfif len(trim( getCardNumber() )) AND NOT IsSimpleValue(trim( getCardNumber() ))>
			<cfset thisError.field = "CardNumber" />
			<cfset thisError.type = "invalidType" />
			<cfset thisError.message = "CardNumber is not a string" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>
		<cfif len(trim( getCardNumber() )) GT 4>
			<cfset thisError.field = "CardNumber" />
			<cfset thisError.type = "too Long" />
			<cfset thisError.message = "CardNumber is too long" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>

		<!--- CardExpiryMonth --->
		<cfif len(trim( getCardExpiryMonth() )) AND NOT isNumeric(trim( getCardExpiryMonth() ))>
			<cfset thisError.field = "CardExpiryMonth" />
			<cfset thisError.type = "invalidType" />
			<cfset thisError.message = "CardExpiryMonth is not a number" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>

		<!--- CardExpiryYear --->
		<cfif len(trim( getCardExpiryYear() )) AND NOT isNumeric(trim( getCardExpiryYear() ))>
			<cfset thisError.field = "CardExpiryYear" />
			<cfset thisError.type = "invalidType" />
			<cfset thisError.message = "CardExpiryYear is not a number" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>

		<!--- Notes --->

		<!--- hmJSON --->

		<!--- AuthCode --->
		<cfif len(trim( getAuthCode() )) AND NOT IsSimpleValue(trim( getAuthCode() ))>
			<cfset thisError.field = "AuthCode" />
			<cfset thisError.type = "invalidType" />
			<cfset thisError.message = "AuthCode is not a string" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>
		<cfif len(trim( getAuthCode() )) GT 32>
			<cfset thisError.field = "AuthCode" />
			<cfset thisError.type = "too Long" />
			<cfset thisError.message = "AuthCode is too long" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>

		<!--- ResponseText --->
		<cfif len(trim( getResponseText() )) AND NOT IsSimpleValue(trim( getResponseText() ))>
			<cfset thisError.field = "ResponseText" />
			<cfset thisError.type = "invalidType" />
			<cfset thisError.message = "ResponseText is not a string" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>
		<cfif len(trim( getResponseText() )) GT 32>
			<cfset thisError.field = "ResponseText" />
			<cfset thisError.type = "too Long" />
			<cfset thisError.message = "ResponseText is too long" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>

		<!--- TransactionID --->
		<cfif len(trim( getTransactionID() )) AND NOT IsSimpleValue(trim( getTransactionID() ))>
			<cfset thisError.field = "TransactionID" />
			<cfset thisError.type = "invalidType" />
			<cfset thisError.message = "TransactionID is not a string" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>
		<cfif len(trim( getTransactionID() )) GT 32>
			<cfset thisError.field = "TransactionID" />
			<cfset thisError.type = "too Long" />
			<cfset thisError.message = "TransactionID is too long" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>

		<cfif ARGUMENTS.abort EQ TRUE AND ARGUMENTS.abort and ArrayLen(errors) GT 0>
			<cfoutput>
			<h3>EFTRecurring Validation Errors</h3>
			<table border="1" cellpadding="3" cellspacing="0">
				<TR>
					<TH>##</TH>
					<TH>Field</TH>
					<TH>Message</TH>
					<TH>Type</TH>
				</TR>
				<cfloop index="N" from="1" to="#ArrayLen(errors)#">
					<TR>
						<TD>#N#</TD>
						<TD>#errors[N].Field#</TD>
						<TD>#errors[N].Message#</TD>
						<TD>#errors[N].Type#</TD>
					</TR>
				</cfloop>
			</table>
			</cfoutput>
			<cfabort>
		</cfif>
		<cfreturn errors />
	</cffunction>

	<!---
		PUTS and GETS
	--->

	<!--- -------------------------------------------------------------------------------------------------
	EFTRecurringID -- Get/Set
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="setEFTRecurringID" access="public" returntype="void" output="false">
		<cfargument name="EFTRecurringID" type="string" required="true" />
			<cfset variables.instance.EFTRecurringID = ARGUMENTS.EFTRecurringID />
	</cffunction>

	<cffunction name="getEFTRecurringID" access="public" returntype="string" output="false">
		<cfreturn variables.instance.EFTRecurringID />
	</cffunction>


	<!--- -------------------------------------------------------------------------------------------------
	NameOnAccount -- Get/Set
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="setNameOnAccount" access="public" returntype="void" output="false">
		<cfargument name="NameOnAccount" type="string" required="true" />
			<cfset variables.instance.NameOnAccount = ARGUMENTS.NameOnAccount />
	</cffunction>

	<cffunction name="getNameOnAccount" access="public" returntype="string" output="false">
		<cfreturn variables.instance.NameOnAccount />
	</cffunction>


	<!--- -------------------------------------------------------------------------------------------------
	dFlag -- Get/Set
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="setdFlag" access="public" returntype="void" output="false">
		<cfargument name="dFlag" type="string" required="true" />
			<cfset variables.instance.dFlag = ARGUMENTS.dFlag />
	</cffunction>

	<cffunction name="getdFlag" access="public" returntype="string" output="false">
		<cfreturn variables.instance.dFlag />
	</cffunction>


	<!--- -------------------------------------------------------------------------------------------------
	fRunNext -- Get/Set
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="setfRunNext" access="public" returntype="void" output="false">
		<cfargument name="fRunNext" type="string" required="true" />
			<cfset variables.instance.fRunNext = ARGUMENTS.fRunNext />
	</cffunction>

	<cffunction name="getfRunNext" access="public" returntype="string" output="false">
		<cfreturn variables.instance.fRunNext />
	</cffunction>


	<!--- -------------------------------------------------------------------------------------------------
	fTestMode -- Get/Set
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="setfTestMode" access="public" returntype="void" output="false">
		<cfargument name="fTestMode" type="string" required="true" />
			<cfset variables.instance.fTestMode = ARGUMENTS.fTestMode />
	</cffunction>

	<cffunction name="getfTestMode" access="public" returntype="string" output="false">
		<cfreturn variables.instance.fTestMode />
	</cffunction>


	<!--- -------------------------------------------------------------------------------------------------
	GLBankAccountID -- Get/Set
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="setGLBankAccountID" access="public" returntype="void" output="false">
		<cfargument name="GLBankAccountID" type="string" required="true" />
			<cfset variables.instance.GLBankAccountID = ARGUMENTS.GLBankAccountID />
	</cffunction>

	<cffunction name="getGLBankAccountID" access="public" returntype="string" output="false">
		<cfreturn variables.instance.GLBankAccountID />
	</cffunction>


	<!--- -------------------------------------------------------------------------------------------------
	AccountID -- Get/Set
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="setAccountID" access="public" returntype="void" output="false">
		<cfargument name="AccountID" type="string" required="true" />
			<cfset variables.instance.AccountID = ARGUMENTS.AccountID />
	</cffunction>

	<cffunction name="getAccountID" access="public" returntype="string" output="false">
		<cfreturn variables.instance.AccountID />
	</cffunction>


	<!--- -------------------------------------------------------------------------------------------------
	ClubID -- Get/Set
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="setClubID" access="public" returntype="void" output="false">
		<cfargument name="ClubID" type="string" required="true" />
			<cfset variables.instance.ClubID = ARGUMENTS.ClubID />
	</cffunction>

	<cffunction name="getClubID" access="public" returntype="string" output="false">
		<cfreturn variables.instance.ClubID />
	</cffunction>


	<!--- -------------------------------------------------------------------------------------------------
	UserID -- Get/Set
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="setUserID" access="public" returntype="void" output="false">
		<cfargument name="UserID" type="string" required="true" />
			<cfset variables.instance.UserID = ARGUMENTS.UserID />
	</cffunction>

	<cffunction name="getUserID" access="public" returntype="string" output="false">
		<cfreturn variables.instance.UserID />
	</cffunction>


	<!--- -------------------------------------------------------------------------------------------------
	ContributionType -- Get/Set
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="setContributionType" access="public" returntype="void" output="false">
		<cfargument name="ContributionType" type="string" required="true" />
			<cfset variables.instance.ContributionType = ARGUMENTS.ContributionType />
	</cffunction>

	<cffunction name="getContributionType" access="public" returntype="string" output="false">
		<cfreturn variables.instance.ContributionType />
	</cffunction>


	<!--- -------------------------------------------------------------------------------------------------
	ConvMethod -- Get/Set
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="setConvMethod" access="public" returntype="void" output="false">
		<cfargument name="ConvMethod" type="string" required="true" />
			<cfset variables.instance.ConvMethod = ARGUMENTS.ConvMethod />
	</cffunction>

	<cffunction name="getConvMethod" access="public" returntype="string" output="false">
		<cfreturn variables.instance.ConvMethod />
	</cffunction>


	<!--- -------------------------------------------------------------------------------------------------
	TranType -- Get/Set
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="setTranType" access="public" returntype="void" output="false">
		<cfargument name="TranType" type="string" required="true" />
			<cfset variables.instance.TranType = ARGUMENTS.TranType />
	</cffunction>

	<cffunction name="getTranType" access="public" returntype="string" output="false">
		<cfreturn variables.instance.TranType />
	</cffunction>


	<!--- -------------------------------------------------------------------------------------------------
	AccountType -- Get/Set
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="setAccountType" access="public" returntype="void" output="false">
		<cfargument name="AccountType" type="string" required="true" />
			<cfset variables.instance.AccountType = ARGUMENTS.AccountType />
	</cffunction>

	<cffunction name="getAccountType" access="public" returntype="string" output="false">
		<cfreturn variables.instance.AccountType />
	</cffunction>


	<!--- -------------------------------------------------------------------------------------------------
	Amount -- Get/Set
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="setAmount" access="public" returntype="void" output="false">
		<cfargument name="Amount" type="string" required="true" />
			<cfset variables.instance.Amount = ARGUMENTS.Amount />
	</cffunction>

	<cffunction name="getAmount" access="public" returntype="string" output="false">
		<cfreturn variables.instance.Amount />
	</cffunction>


	<!--- -------------------------------------------------------------------------------------------------
	Period -- Get/Set
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="setPeriod" access="public" returntype="void" output="false">
		<cfargument name="Period" type="string" required="true" />
			<cfset variables.instance.Period = ARGUMENTS.Period />
	</cffunction>

	<cffunction name="getPeriod" access="public" returntype="string" output="false">
		<cfreturn variables.instance.Period />
	</cffunction>


	<!--- -------------------------------------------------------------------------------------------------
	StartDate -- Get/Set
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="setStartDate" access="public" returntype="void" output="false">
		<cfargument name="StartDate" type="string" required="true" />
			<cfset variables.instance.StartDate = ARGUMENTS.StartDate />
	</cffunction>

	<cffunction name="getStartDate" access="public" returntype="string" output="false">
		<cfreturn variables.instance.StartDate />
	</cffunction>


	<!--- -------------------------------------------------------------------------------------------------
	EndDate -- Get/Set
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="setEndDate" access="public" returntype="void" output="false">
		<cfargument name="EndDate" type="string" required="true" />
			<cfset variables.instance.EndDate = ARGUMENTS.EndDate />
	</cffunction>

	<cffunction name="getEndDate" access="public" returntype="string" output="false">
		<cfreturn variables.instance.EndDate />
	</cffunction>


	<!--- -------------------------------------------------------------------------------------------------
	CardNumber -- Get/Set
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="setCardNumber" access="public" returntype="void" output="false">
		<cfargument name="CardNumber" type="string" required="true" />
			<cfset variables.instance.CardNumber = ARGUMENTS.CardNumber />
	</cffunction>

	<cffunction name="getCardNumber" access="public" returntype="string" output="false">
		<cfreturn variables.instance.CardNumber />
	</cffunction>


	<!--- -------------------------------------------------------------------------------------------------
	CardExpiryMonth -- Get/Set
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="setCardExpiryMonth" access="public" returntype="void" output="false">
		<cfargument name="CardExpiryMonth" type="string" required="true" />
			<cfset variables.instance.CardExpiryMonth = ARGUMENTS.CardExpiryMonth />
	</cffunction>

	<cffunction name="getCardExpiryMonth" access="public" returntype="string" output="false">
		<cfreturn variables.instance.CardExpiryMonth />
	</cffunction>


	<!--- -------------------------------------------------------------------------------------------------
	CardExpiryYear -- Get/Set
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="setCardExpiryYear" access="public" returntype="void" output="false">
		<cfargument name="CardExpiryYear" type="string" required="true" />
			<cfset variables.instance.CardExpiryYear = ARGUMENTS.CardExpiryYear />
	</cffunction>

	<cffunction name="getCardExpiryYear" access="public" returntype="string" output="false">
		<cfreturn variables.instance.CardExpiryYear />
	</cffunction>


	<!--- -------------------------------------------------------------------------------------------------
	Token -- Get/Set
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="setToken" access="public" returntype="void" output="false">
		<cfargument name="Token" type="string" required="true" />
			<cfset variables.instance.Token = ARGUMENTS.Token />
	</cffunction>

	<cffunction name="getToken" access="public" returntype="string" output="false">
		<cfreturn variables.instance.Token />
	</cffunction>


	<!--- -------------------------------------------------------------------------------------------------
	Notes -- Get/Set
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="setNotes" access="public" returntype="void" output="false">
		<cfargument name="Notes" type="string" required="true" />
			<cfset variables.instance.Notes = ARGUMENTS.Notes />
	</cffunction>

	<cffunction name="getNotes" access="public" returntype="string" output="false">
		<cfreturn variables.instance.Notes />
	</cffunction>


	<!--- -------------------------------------------------------------------------------------------------
	hmJSON -- Get/Set
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="sethmJSON" access="public" returntype="void" output="false">
		<cfargument name="hmJSON" type="string" required="true" />
			<cfset variables.instance.hmJSON = ARGUMENTS.hmJSON />
	</cffunction>

	<cffunction name="gethmJSON" access="public" returntype="string" output="false">
		<cfreturn variables.instance.hmJSON />
	</cffunction>


	<!--- -------------------------------------------------------------------------------------------------
	AuthCode -- Get/Set
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="setAuthCode" access="public" returntype="void" output="false">
		<cfargument name="AuthCode" type="string" required="true" />
			<cfset variables.instance.AuthCode = ARGUMENTS.AuthCode />
	</cffunction>

	<cffunction name="getAuthCode" access="public" returntype="string" output="false">
		<cfreturn variables.instance.AuthCode />
	</cffunction>


	<!--- -------------------------------------------------------------------------------------------------
	ResponseText -- Get/Set
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="setResponseText" access="public" returntype="void" output="false">
		<cfargument name="ResponseText" type="string" required="true" />
			<cfset variables.instance.ResponseText = ARGUMENTS.ResponseText />
	</cffunction>

	<cffunction name="getResponseText" access="public" returntype="string" output="false">
		<cfreturn variables.instance.ResponseText />
	</cffunction>


	<!--- -------------------------------------------------------------------------------------------------
	TransactionID -- Get/Set
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="setTransactionID" access="public" returntype="void" output="false">
		<cfargument name="TransactionID" type="string" required="true" />
			<cfset variables.instance.TransactionID = ARGUMENTS.TransactionID />
	</cffunction>

	<cffunction name="getTransactionID" access="public" returntype="string" output="false">
		<cfreturn variables.instance.TransactionID />
	</cffunction>


	<!--- -------------------------------------------------------------------------------------------------
	Created_By -- Get/Set
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="setCreated_By" access="public" returntype="void" output="false">
		<cfargument name="Created_By" type="string" required="true" />
			<cfset variables.instance.Created_By = ARGUMENTS.Created_By />
	</cffunction>

	<cffunction name="getCreated_By" access="public" returntype="string" output="false">
		<cfreturn variables.instance.Created_By />
	</cffunction>


	<!--- -------------------------------------------------------------------------------------------------
	Created_Tmstmp -- Get/Set
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="setCreated_Tmstmp" access="public" returntype="void" output="false">
		<cfargument name="Created_Tmstmp" type="string" required="true" />
			<cfset variables.instance.Created_Tmstmp = ARGUMENTS.Created_Tmstmp />
	</cffunction>

	<cffunction name="getCreated_Tmstmp" access="public" returntype="string" output="false">
		<cfreturn variables.instance.Created_Tmstmp />
	</cffunction>


	<!--- -------------------------------------------------------------------------------------------------
	Modified_By -- Get/Set
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="setModified_By" access="public" returntype="void" output="false">
		<cfargument name="Modified_By" type="string" required="true" />
			<cfset variables.instance.Modified_By = ARGUMENTS.Modified_By />
	</cffunction>

	<cffunction name="getModified_By" access="public" returntype="string" output="false">
		<cfreturn variables.instance.Modified_By />
	</cffunction>


	<!--- -------------------------------------------------------------------------------------------------
	Modified_Tmstmp -- Get/Set
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="setModified_Tmstmp" access="public" returntype="void" output="false">
		<cfargument name="Modified_Tmstmp" type="string" required="true" />
			<cfset variables.instance.Modified_Tmstmp = ARGUMENTS.Modified_Tmstmp />
	</cffunction>

	<cffunction name="getModified_Tmstmp" access="public" returntype="string" output="false">
		<cfreturn variables.instance.Modified_Tmstmp />
	</cffunction>


	<!--- -------------------------------------------------------------------------------------------------
	DUMP
	--------------------------------------------------------------------------------------------------- --->
	<cffunction name="dump" access="public" output="true" return="void">
		<cfargument	name="abort"	type="boolean"	default="false" />
		<cfdump var="#variables.instance#" />
		<cfif arguments.abort>
			<cfabort />
		</cfif>
	</cffunction>

</cfcomponent>