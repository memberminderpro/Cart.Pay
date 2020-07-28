
<cfset GLBankAccountID 	= 100>
<cfset ContributionID  	= 2911>
<cfset ResponseCode 	= "000">
<cfset ResponseText 	= "Approved">
<cfset AuthCode 		= "DC890123SAF">


<cfinvoke component="#APPLICATION.DIR#cfc\ReceiptDAO" method="Success" returnvariable="ReceiptHTML">
	<cfinvokeargument name="GLBankAccountID"	Value="#GLBankAccountID#">
	<cfinvokeargument name="ContributionID"		Value="#ContributionID#">

	<cfinvokeargument name="ResponseCode"		Value="#ResponseCode#">
	<cfinvokeargument name="ResponseText"		Value="#ResponseText#">
	<cfinvokeargument name="AuthCode"			Value="#AuthCode#">

	<cfinvokeargument name="SendEMail"			Value="Yes">
</cfinvoke>
<cfoutput>#ReceiptHTML#</cfoutput>