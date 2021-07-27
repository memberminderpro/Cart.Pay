<!--------------------------------------------------------------------------------------
	Copyright 2003-2020 DACdb, LLC.
	Index.cfm - Pay Cart OnLine

	Modifications:
		02/07/2017 - Created
--------------------------------------------------------------------------------------->
<cfsetting showdebugoutput="No">
<cfinclude template="cfscript/profile.cfm">

<cftry>
	<cfparam name="TransactionID" 						default="0"				type="numeric">
	<cfparam name="Amount" 								default="0"				type="string">
	<cfparam name="UserID" 								default="0"				type="numeric">	<!--- Person Making the Transaction -- URL.UserID --->
	<cfcatch>
		Contact Support.</cfcatch>
</cftry>

<cfset fDebug = TRUE>
<cfif fDebug>
	<cfsavecontent variable="PageData">
	<cfdump var="#Form#">
	</cfsavecontent>
	<cffile action="WRITE"  file="#ExpandPath(".")#/return.html"  output="FORM:<BR>#PageData#">
</cfif>
<!-------------------------------------------------------------------------------------------------
	Setup
---------------------------------------------------------------------------------------------------->

<cfinvoke component="#APPLICATION.DIR#CFC\GLBankAccountDAO" method="Lookup" GLBankAccountID="100"  returnvariable="BankAccountQ">
<cfset AccountName 			= BankAccountQ.GLBankAccountName>
<cfset AccountID 			= BankAccountQ.AccountID>

<cfset PymtGateway 			= BankAccountQ.PymtGateway>
<cfset CardTypes 			= BankAccountQ.CardTypes>
<cfset CardPolicy 			= BankAccountQ.CardPolicy>
<cfset IsHandleFee 			= BankAccountQ.IsHandleFee>
<cfset HandleFeeFixed 		= BankAccountQ.HandleFeeFixed>
<cfset HandlefeePcnt 		= BankAccountQ.HandlefeePcnt>
<cfset PymtGateway 			= BankAccountQ.PymtGateway>
<cfset GatewayParms 		= BankAccountQ.GatewayParms>

<CF_XLogCart AccountID="0" Table="Cart" type="A" Value="IPPay"  Desc="Step 1: Amount=#Amount#">

<cfswitch expression="#PymtGateway#">
	<cfcase value="No">		<!--- None --->
		<CF_XLogCart AccountID="0" Table="Cart" type="E" Value="#PymtGateway#"  Desc="Payment Gateway NOT defined">
		<CF_Problem Message="Sorry, but your payment gateway [#PymtGateway#] is NOT defined.">
	</cfcase>
	<cfcase value="IP">		<!--- AuthorizeNET, PayPal, SecurePay, JetPay, eProcessing, Affinity --->
		<cfif Len(GatewayParms) GT 0>
			<cfinclude template="IP/index.cfm">
		<cfelse>
			<CF_XLogCart AccountID="0" Table="Cart" type="E" Value="#PymtGateway#"  Desc="Payment Gateway params NOT defined">
			<CF_Problem Message="Sorry, but your payment gateway params [#GatewayParms#] are NOT defined.">
		</cfif>
	</cfcase>
	<cfdefaultcase>
		<CF_XLogCart AccountID="0" Table="CART" type="E" Value="#PymtGateway#"  Desc="No Payment Gateway Found or Supported [#PymtGateway#]">
		<CF_Problem Message="No Payment Gateway Found or Supported<BR>Payment Gateway parameters were not configured for his bank account.<BR>On-line Payment Processing cannot continue at this point.">
	</cfdefaultcase>
</cfswitch>

