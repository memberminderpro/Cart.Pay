<!--------------------------------------------------------------------------------------------
	Copyright(c) Member Minder Pro, LLC.
	PC\Token.cfm - Paycove Recurring Payment-Method Store Return (zero-charge tokenize)

	Mirrors Cart.Pay\IP\Token.cfm's role (fills in the Token on the tblEFTRecurring row that
	Donate\Save.cfm already created), but the inbound shape is Paycove's "store" transaction_type
	callback, modeled on Pay\PC\1\RPay.cfm. No money moves in this step.

	Modifications:
		2026 - created for Paycove gateway integration
----------------------------------------------------------------------------------------------->
<cfsetting showdebugoutput="No">

<cfset fDebug = FALSE>

<cftry>
	<cfparam name="BID" 						default="0"		type="string">		<!--- BID=BankAccountID --->
	<cfparam name="EID" 						default="0"		type="string">		<!--- EID=EntityID --->
	<cfparam name="transaction_id" 				default="0"		type="string">	<!--- EFTRecurringID --->
	<cfparam name="payment_method_id" 			default=""		type="string">
	<cfparam name="payment_method_type" 		default=""		type="string">	<!--- CARD or ACH --->
	<cfparam name="payment_method_last_four" 	default=""		type="string">
	<cfparam name="payment_method_brand" 		default=""		type="string">
	<cfparam name="deal_id" 					default=""		type="string">
	<cfparam name="gateway" 					default="payconex"	type="string">
	<cfparam name="user_id"						default="0"		type="string">
	<cfcatch>
		<CF_XLogCart AccountID="0" Table="EFTRecurring" type="E" Value="Error" Desc="Paycove Token callback param error">
	</cfcatch>
</cftry>

<cfset GLBankAccountID = (user_id EQ 800654030 ? 101 : 100)>
<cfset SESSION.GLBankAccountID  = GLBankAccountID>

<!--------------------------------------------------------------------------------------------------
	Paycove sends this as a JSON IPN POST or a GET/POST redirect with the same field names
	(mirrors Pay\PC\1\RPay.cfm's dual-path handling).
---------------------------------------------------------------------------------------------------->
<cfset respData = GetHttpRequestData()>

<cfif IsJSON(respData.content)>
	<cftry>
		<cfset respStruct = deserializeJSON(respData.content)>
		<cfif StructKeyExists(respStruct, "transaction_id")>
			<cfset transaction_id = respStruct.transaction_id>
			<cfset BID			  = respStruct.BID>
			<cfset EID 			  = respStruct.EID>
		</cfif>
		<cfif StructKeyExists(respStruct, "deal_id")>
			<cfset deal_id = respStruct.deal_id>
		</cfif>
		<cfif StructKeyExists(respStruct, "payment_method_id")>
			<cfset payment_method_id = respStruct.payment_method_id>
		</cfif>
		<cfif StructKeyExists(respStruct, "payment_method_type")>
			<cfset payment_method_type = respStruct.payment_method_type>
		</cfif>
		<cfif StructKeyExists(respStruct, "payment_method_last_four")>
			<cfset payment_method_last_four = respStruct.payment_method_last_four>
		</cfif>
		<cfif StructKeyExists(respStruct, "payment_method_brand")>
			<cfset payment_method_brand = respStruct.payment_method_brand>
		</cfif>
		<cfif StructKeyExists(respStruct, "gateway")>
			<cfset gateway = respStruct.gateway>
		</cfif>
		<cfcatch>
			<CF_XLogCart AccountID="0" Table="EFTRecurring" type="E" Value="IPN" Desc="#cfcatch.message# #cfcatch.detail#">
		</cfcatch>
	</cftry>
</cfif>

<cfset EFTRecurringID = Val(Trim(transaction_id))>
<cfif NOT IsNumeric(EFTRecurringID) OR EFTRecurringID EQ 0>
	<CF_XLog AccountID="0" Table="Pay" type="E" Value="#EFTRecurringID#"  Desc="Invalid or Missing EFTRecurringID (transaction_id): #transaction_id#">
	<cf_problem message="Sorry, there was a problem registering your Payment Method. Invalid Transaction ID. Please contact support.">
</cfif>

<cfif LEN(payment_method_id) EQ 0 OR payment_method_id EQ "undefined">
	<CF_XLog AccountID="0" Table="Pay" type="E" Value="#EFTRecurringID#"  Desc="Invalid or Missing Token [#payment_method_id#]">
	<cf_problem message="Sorry, there was a problem registering your Payment Method. Invalid Token. Please contact support.">
</cfif>

<cfif Trim(payment_method_type) EQ "CARD">
	<cfset TranType = "CC">
<cfelse>
	<cfset TranType = "EC">
</cfif>

<CF_XLogCart AccountID="0" Table="Pay" type="I" Value="#EFTRecurringID#"  Desc="Paycove Store callback: payment_method_id=#payment_method_id#, type=#TranType#, gateway=#gateway#">

<cftry>
	<cfinvoke component="\CFC\EFTRecurringDAO" method="UpdateToken" returnvariable="UpdateTokenSuccess">
		<cfinvokeargument name="EFTRecurringID"	Value="#EFTRecurringID#">
		<cfinvokeargument name="Token"			Value="#payment_method_id#">
	</cfinvoke>
	<cfcatch>
		<CF_XLogCart AccountID="0" Table="EFTRecurring" type="E" Value="#EFTRecurringID#"  Desc="UpdateToken failed: #cfcatch.message#">
		<cfset UpdateTokenSuccess = FALSE>
	</cfcatch>
</cftry>

<cfif NOT UpdateTokenSuccess>
	<CF_XLog AccountID="0" Table="Pay" type="E" Value="#EFTRecurringID#"  Desc="Update Failed: Token=#payment_method_id#, TranType=#TranType#">
	<cf_problem message="Your Payment Method details have been securely stored with our payment processor, but we were unable to update our system. Please contact support [#EFTRecurringID#].">
<cfelse>
	<cfset EFTRecurringObj = createObject("component", "\CFC\EFTRecurring").init( EFTRecurringID="#EFTRecurringID#" ) />
	<cfinvoke component="\CFC\EFTRecurringDAO" method="Read" EFTRecurring="#EFTRecurringObj#" returnvariable="EFTRecurring">

	<cfinvoke component="\CFC\ReceiptDAO" method="Scheduled" returnvariable="ReceiptHTML">
		<cfinvokeargument name="UserID"				Value="#EFTRecurring.UserID#">
		<cfinvokeargument name="TotalAmount"		Value="#EFTRecurring.Amount#">
		<cfinvokeargument name="Period"				Value="#EFTRecurring.Period#">
		<cfinvokeargument name="StartDate"			Value="#EFTRecurring.StartDate#">
		<cfinvokeargument name="EndDate"			Value="#EFTRecurring.EndDate#">
	</cfinvoke>
	<cfoutput>#ReceiptHTML#</cfoutput>
</cfif>
