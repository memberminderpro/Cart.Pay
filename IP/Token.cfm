<!--------------------------------------------------------------------------------------
	Copyright(c) 2003-2020 DACdb, LLC.
	Token.cfm - Tokenize CC Recurring Transaction Return

	Modifications:
		03/15/2020 - Created
		02/25/2021 - MOdified
		07/14/2021 - updated for new API
--------------------------------------------------------------------------------------->
<cfsetting showdebugoutput="No">

<cfset fDebug = FALSE>
<cfif fDebug>
	<cfsavecontent variable="PageData">
	<cfdump var="#FORM#">
	</cfsavecontent>
	<cffile action="WRITE"  file="#ExpandPath(".")#/Token.html"  output="Token:<BR>#PageData#">
</cfif>


<cftry>
	<cfparam name="FORM.AccountType"			default="CHECKING"			type="string">
	<cfparam name="FORM.PaymentType"			default="CC"				type="string">
	<cfparam name="FORM.Notes"					default=""					type="string">
	<cfparam name="FORM.CUSTOMFIELD1"			default="0"					type="string">		<!--- EFTTransactionID Passed Back--->
	<cfparam name="FORM.CUSTOMFIELD2"			default="0"					type="string">		<!--- UserID Passed Back--->

	<cfparam name="FORM.CardHolderName"			default=""					type="string">
	<cfparam name="FORM.CardNumber"				default=""					type="string">		<!--- 12XXXXXXXXXX3456 is returned -- we want last 4 --->
	<cfparam name="FORM.CardExpiryMonth"		default=""					type="string">
	<cfparam name="FORM.CardExpiryYear"			default=""					type="string">

	<cfparam name="FORM.AuthCode"				default=""					type="string">
	<cfparam name="FORM.CardToken"				default=""					type="string">
	<cfparam name="FORM.ResponseCode"			default=""					type="string">
	<cfparam name="FORM.ResponseText"			default=""					type="string">
	<cfparam name="FORM.TransactionID"			default=""					type="string">

	<cfparam name="Valid" 						default="TRUE" 				type="Boolean">

	<cfcatch>
		<CF_XLogCart  AccountID="0" Table="EFTRecurring" type="E" Value="#FORM.UDField2#"  Desc="CC Tokenize Failed">
	</cfcatch>
</cftry>

<cfset GLBankAccountID = 100>
<cfset SESSION.GLBankAccountID  = GLBankAccountID>


<!--------------------------------------------------------------------------------------------
	Update EFT Transaction Record with Tokenize Results
----------------------------------------------------------------------------------------------->
<cfset EFTRecurringID = FORM.CUSTOMFIELD1>
<cfif NOT IsNumeric(EFTRecurringID) OR EFTRecurringID EQ 0>
	<CF_XLog AccountID="0" Table="Pay" type="E" Value="#EFTRecurringID#"  Desc="Invalid or Missing EFTRecurringID: #EFTRecurringID#">
	<cf_problem message="Sorry, the EFT ID is not valid. #ResponseText#  Please contact support.">
</cfif>

<cfset UserID = FORM.CUSTOMFIELD2>
<cfif NOT IsNumeric(UserID) OR UserID EQ 0>
	<CF_XLog AccountID="0" Table="Pay" type="E" Value="#UserID#"  Desc="Invalid or Missing UserID: #UserID#">
	<cf_problem message="Sorry, the user is not valid. #ResponseText#  Please contact support.">
</cfif>

<cfif NOT IsNumeric(FORM.CardExpiryMonth)>
	<cfset FORM.CardExpiryMonth = 0>
</cfif>
<cfif NOT IsNumeric(FORM.CardExpiryYear)>
	<cfset FORM.CardExpiryYear = 0>
</cfif>

<cfif Valid>

	<!--------------------------------------------------------------------------------------------
		Valid Token CC Credit Card
	----------------------------------------------------------------------------------------------->
	<CF_XLogCart AccountID="0" Table="Pay" type="I" Value="#EFTRecurringID#"  Desc="UserID=#UserID# Tokenization success: #ResponseText#">

	<cfset EFTRecurringObj = createObject("component", "CFC\EFTRecurring").init( EFTRecurringID="#EFTRecurringID#" ) />
	<cfinvoke component="\CFC\EFTRecurringDAO" method="Read" EFTRecurring="#EFTRecurringObj#" returnvariable="EFTRecurring">

	<!--- Update the EFTRecurring with changes from the FORM --->
	<cfinvoke component="\CFC\EFTRecurring" method="init" ArgumentCollection="#EFTRecurring#"  returnvariable="EFTRecurringObj">
		<cfinvokeargument name="NameOnAccount"			Value="#Form.CardHolderName#">		<!--- Update the Name on Account, Might be different from Member Name --->

		<cfinvokeargument name="CardNumber"				Value="#Right(Form.CardNumber,4)#">	<!--- Only want the right 4 digits --->
		<cfinvokeargument name="CardExpiryMonth"		Value="#Form.CardExpiryMonth#">
		<cfinvokeargument name="CardExpiryYear"			Value="#Form.CardExpiryYear#">

		<cfinvokeargument name="AccountType"			Value="#Form.AccountType#">
		<cfinvokeargument name="AuthCode"				Value="#Form.AuthCode#">
		<cfinvokeargument name="Token"					Value="#Form.CardToken#">
		<cfinvokeargument name="ResponseText"			Value="#Form.ResponseText#">
		<cfinvokeargument name="TransactionID"			Value="#Form.TransactionID#">
	</cfinvoke>
	<cfinvoke component="\CFC\EFTRecurringDAO" method="Update" EFTRecurring="#EFTRecurringObj#" returnvariable="EFTRecurringID">
	<cfif EFTRecurringID EQ 0>
		<cfset returnStruct.success = FALSE />
		<cfset returnStruct.error   = "Could not save EFTRecurring" />
		<CF_XLogCart  AccountID="0" Table="EFTRecurring" type="I" Value="#EFTRecurringID#"  Desc="AuthCode=#AuthCode#, AuthCode=#AuthCode#, ResponseText=#ResponseText#, TransactionID=#TransactionID#">
	</cfif>

	<!--------------------------------------------------------------------------------------------
		Display Scheduled Transactions
	----------------------------------------------------------------------------------------------->
	<cfinvoke component="\CFC\ReceiptDAO" method="Scheduled" returnvariable="ReceiptHTML">
		<cfinvokeargument name="UserID"					Value="#UserID#">
		<cfinvokeargument name="TotalAmount"			Value="#EFTRecurring.Amount#">
		<cfinvokeargument name="Period"					Value="#EFTRecurring.Period#">
		<cfinvokeargument name="StartDate"				Value="#EFTRecurring.StartDate#">
		<cfinvokeargument name="EndDate"				Value="#EFTRecurring.EndDate#">
	</cfinvoke>
	<cfoutput>#ReceiptHTML#</cfoutput>

<cfelse>
	<CF_XLogCart AccountID="0" Table="Pay" type="E" Value="#EFTRecurringID#"  Desc="UserID=#UserID# Tokenization failed: #ResponseText#">

	<!--------------------------------------------------------------------------------------------
		Error response from Merchant
	----------------------------------------------------------------------------------------------->
	<cfinvoke component="\cfc\ReceiptDAO" method="Failure" returnvariable="ReceiptHTML">
		<cfinvokeargument name="TransactionID"		Value="#EFTRecurringID#">
		<cfinvokeargument name="UserID"				Value="#UserID#">

		<cfinvokeargument name="ResponseCode"		Value="#FORM.ResponseCode#">
		<cfinvokeargument name="ResponseText"		Value="#FORM.ResponseText#">
		<cfinvokeargument name="ErrorText"			Value="Invalid Transaction Returned from Merchant">
	</cfinvoke>
	<cfoutput>#ReceiptHTML#</cfoutput>

</cfif>