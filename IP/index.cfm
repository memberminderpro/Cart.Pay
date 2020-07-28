<!--------------------------------------------------------------------------------------------
	Copyright(c) 2003-2020 DACdb, LLC.
	Return.cfm - CC Return
	Modifications:
		07/22/2019 - created

	TestCard: 4111111111111111
----------------------------------------------------------------------------------------------->
<cfsetting showdebugoutput="No">

<cfset fDebug = FALSE>
<cfif fDebug>
	<cfsavecontent variable="PageData">
	<cfdump var="#FORM#">
	</cfsavecontent>
	<cffile action="WRITE"  file="#ExpandPath(".")#/Return.html"  output="Return:<BR>#PageData#">
</cfif>

<cftry>
	<cfparam name="Amount" 				default="0" 					type="string">	<!--- Transaction Amount --->
	<cfparam name="ResponseCode" 		default="000"					type="string">
	<cfparam name="ResponseText" 		default="" 						type="string">
	<cfparam name="ReferenceID" 		default="" 						type="string">
	<cfparam name="TransactionID" 		default="" 						type="string">
	<cfparam name="AuthCode" 			default="" 						type="string">
	<cfparam name="PaymentType" 		default="CC" 					type="string">
	<cfparam name="Valid" 				default="True" 					type="Boolean">
	<cfparam name="UserID" 				default="0" 					type="numeric">		<!--- Passed on the URL --->
	<cfparam name="UDField1" 			default=""						type="string">		<!--- ContributionID --->
	<cfcatch>contact support</cfcatch>
</cftry>

<cfset GLBankAccountID = 100>
<cfset SESSION.GLBankAccountID  = GLBankAccountID>
<cfset TranAmt 			= REReplace(Amount,   "[^0-9\.]+", "", "ALL")>
<cfset ContributionID	= UDField1>
<cfset Memo    			= "">
<cfset errMsg			= "">

<CF_XLogCart AccountID="0" Table="Pay" type="I" Value="#UserID#"  Desc="Success IP: ID=#ContributionID# TranAmt:#DecimalFormat(TranAmt)#">
<cfif NOT IsNumeric(ContributionID)>
	<!--- <cfdump var="#FORM#"> --->
	<cf_problem message="Sorry, the contribution is not valid. #ResponseText#  Please contact support.">
</cfif>

<cfif Valid>
	<!--------------------------------------------------------------------------------------------
		Check for dups (multiple call backs).  Lookup the payment by the approval number and registration ID
	----------------------------------------------------------------------------------------------->
	<cfinvoke component="#APPLICATION.DIR#CFC\ContributionDAO" method="CheckDupPymt" returnvariable="fDup">
		<cfinvokeargument name="TranNo"				Value="#TransactionID#">
		<cfinvokeargument name="TranAmt"			Value="#TranAmt#">
	</cfinvoke>

	<cfif NOT fDup>

		<!--------------------------------------------------------------------------------------------
			Find Member
		----------------------------------------------------------------------------------------------->
		<cfinvoke component="#APPLICATION.DIR#CFC\UserDAO" method="View" UserID="#UserID#"  returnvariable="MemberQ">
		<cfif MemberQ.Recordcount EQ 0>
			<cf_problem Message="Member Not Found.">
		</cfif>

		<!--------------------------------------------------------------------------------------------
			Compute OrgYear
		----------------------------------------------------------------------------------------------->
		<cf_OrgYear YearEndMo="6">

		<!--------------------------------------------------------------------------------------------
			Update The Contribution
		----------------------------------------------------------------------------------------------->
		<cfinvoke component="\CFC\ContributionDAO" method="UpdateByContributionID" returnvariable="ContributionID">
			<cfinvokeargument name="ContributionID"	Value="#ContributionID#">
			<cfinvokeargument name="TranNo"			Value="#TransactionID#">
			<cfinvokeargument name="TranAmt"		Value="#TranAmt#">
			<cfinvokeargument name="Notes"			Value="#ResponseCode# #ResponseText#">
		</cfinvoke>

		<cfinvoke component="\CFC\ReceiptDAO" method="Success" returnvariable="ReceiptHTML">
			<cfinvokeargument name="GLBankAccountID"	Value="#GLBankAccountID#">
			<cfinvokeargument name="ContributionID"		Value="#ContributionID#">
			<cfinvokeargument name="TransactionID"		Value="#TransactionID#">

			<cfinvokeargument name="ResponseCode"		Value="#ResponseCode#">
			<cfinvokeargument name="ResponseText"		Value="#ResponseText#">
			<cfinvokeargument name="AuthCode"			Value="#AuthCode#">

			<cfinvokeargument name="SendEMail"			Value="Yes">
		</cfinvoke>
		<cfoutput>#ReceiptHTML#</cfoutput>

	<cfelse>
		<!--------------------------------------------------------------------------------------------
			Duplicate Payment == Display and Log the Information
		----------------------------------------------------------------------------------------------->
		<cfinvoke component="\CFC\ReceiptDAO" method="Failure" returnvariable="ReceiptHTML">
			<cfinvokeargument name="ContributionID"		Value="#ContributionID#">
			<cfinvokeargument name="UserID"				Value="#UserID#">
			<cfinvokeargument name="TotalAmount"		Value="#TranAmt#">

			<cfinvokeargument name="ResponseCode"		Value="#ResponseCode#">
			<cfinvokeargument name="ResponseText"		Value="#ResponseText#">
			<cfinvokeargument name="ErrorText"			Value="This payment was not posted. We believe it is a duplicate transactions">
		</cfinvoke>
		<cfoutput>#ReceiptHTML#</cfoutput>

	</cfif>

<cfelse>

	<!--------------------------------------------------------------------------------------------
		Update The Contribution
	----------------------------------------------------------------------------------------------->
	<cfinvoke component="\CFC\ContributionDAO" method="UpdateByContributionID" returnvariable="ContributionID">
		<cfinvokeargument name="ContributionID"	Value="#ContributionID#">
		<cfinvokeargument name="TranNo"			Value="#TransactionID#">
		<cfinvokeargument name="Notes"			Value="#ResponseCode# #ResponseText#">
	</cfinvoke>

	<!--------------------------------------------------------------------------------------------
		Error response from Merchant
	----------------------------------------------------------------------------------------------->
	<cfinvoke component="#APPLICATION.DIR#cfc\ReceiptDAO" method="Failure" returnvariable="ReceiptHTML">
		<cfinvokeargument name="TransactionID"		Value="#TransactionID#">
		<cfinvokeargument name="UserID"				Value="#UserID#">
		<cfinvokeargument name="TotalAmount"		Value="#TranAmt#">

		<cfinvokeargument name="ResponseCode"		Value="#ResponseCode#">
		<cfinvokeargument name="ResponseText"		Value="#ResponseText#">
		<cfinvokeargument name="ErrorText"			Value="Invalid Transaction Returned from Merchant">
	</cfinvoke>
	<cfoutput>#ReceiptHTML#</cfoutput>

</cfif>

