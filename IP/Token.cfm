<!--------------------------------------------------------------------------------------
	Copyright(c) 2003-2020 DACdb, LLC.
	Token.cfm - Tokenize CC Recurring Transaction Return

	Modifications:
		03/15/2020 - Created
--------------------------------------------------------------------------------------->
<cfsetting showdebugoutput="No">

<cftry>
	<cfparam name="FORM.PaymentType"			default="CC"				type="string">
	<cfparam name="FORM.Amount"					default="0.00"				type="numeric">
	<cfparam name="FORM.Notes"					default=""					type="string">
	<cfparam name="FORM.UDField1"				default="0"					type="string">		<!--- EFTTransactionID Passed Back--->

	<cfparam name="FORM.CardHolderName"			default="missing"			type="string">
	<cfparam name="FORM.CardNumber"				default=""					type="string">		<!--- 12XXXXXXXXXX3456 is returned -- we want last 4 --->
	<cfparam name="FORM.CardExpiryMonth"		default="0"					type="string">
	<cfparam name="FORM.CardExpiryYear"			default="0"					type="string">

	<cfparam name="FORM.AuthCode"				default="missing"			type="string">
	<cfparam name="FORM.CardToken"				default="missing"			type="string">
	<cfparam name="FORM.ResponseText"			default="missing"			type="string">
	<cfparam name="FORM.TransactionID"			default="1"					type="string">

	<cfcatch>
		<CF_XLogCart  AccountID="0" Table="EFTRecurring" type="I" Value="#FORM.UserID#"  Desc="CC Tokenize Failed">
	</cfcatch>
</cftry>

<!--------------------------------------------------------------------------------------------
	Update EFT Transaction Record with Tokenize Results
----------------------------------------------------------------------------------------------->
<cfset EFTRecurringID = FORM.UDField1>
<cfif NOT IsNumeric(EFTRecurringID)>
	<cf_problem message="Invalid EFT Recurring Parameter">
</cfif>

<cfset EFTRecurringObj = createObject("component", "CFC\EFTRecurring").init( EFTRecurringID="#EFTRecurringID#" ) />
<cfinvoke component="\CFC\EFTRecurringDAO" method="Read" EFTRecurring="#EFTRecurringObj#" returnvariable="EFTRecurring">

<!--- Update the EFTRecurring with changes from the FORM --->
<cfinvoke component="\CFC\EFTRecurring" method="init" ArgumentCollection="#EFTRecurring#"  returnvariable="EFTRecurringObj">
	<cfinvokeargument name="NameOnAccount"			Value="#Form.CardHolderName#">		<!--- Update the Name on Account, Might be different from Member Name --->

	<cfinvokeargument name="CardNumber"				Value="#Right(Form.CardNumber,4)#">	<!--- Only want the right 4 digits --->
	<cfinvokeargument name="CardExpiryMonth"		Value="#Form.CardExpiryMonth#">
	<cfinvokeargument name="CardExpiryYear"			Value="#Form.CardExpiryYear#">

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
	<cfinvokeargument name="UserID"					Value="#SESSION.UserID#">
	<cfinvokeargument name="TotalAmount"			Value="#EFTRecurring.Amount#">
	<cfinvokeargument name="Period"					Value="#EFTRecurring.Period#">
	<cfinvokeargument name="StartDate"				Value="#EFTRecurring.StartDate#">
	<cfinvokeargument name="EndDate"				Value="#EFTRecurring.EndDate#">
</cfinvoke>
<cfoutput>#ReceiptHTML#</cfoutput>
