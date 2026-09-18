<!--------------------------------------------------------------------------------------------
	Copyright(c) Member Minder Pro, LLC.
	PC\index.cfm - Paycove One-Time Payment Return (IPN + browser redirect)

	Mirrors Cart.Pay\IP\index.cfm's contract (ContributionDAO.CheckDupPymt / UpdateByContributionID /
	ReceiptDAO.Success|Failure), but the inbound shape is Paycove's, modeled on Pay\PC\1\ReturnEFT.cfm.
	ContributionID/UserID are carried in the success_url/webhook_url query string set by
	Donate\Save.cfm's PC checkout payload (PCCallbackURL), not via Paycove custom fields.

	Modifications:
		2026 - created for Paycove gateway integration
----------------------------------------------------------------------------------------------->
<cfsetting showdebugoutput="No">

<cfset fDebug = FALSE>

<cftry>
	<cfparam name="ContributionID"			default="0"		type="string">
	<cfparam name="UserID"					default="0"		type="string">
	<cfparam name="ConvMethod"				default="A"		type="string">	<!--- A=Add/PF, D=Deduct/NP --->
	<!--- Paycove GET redirect params (also present on IPN as URL vars in webhook_url) --->
	<cfparam name="URL.charge_id"			default="">
	<cfparam name="URL.charge_total"		default="0">
	<cfparam name="URL.fee_amount"			default="0">
	<cfparam name="URL.net_amount"			default="0">
	<cfparam name="URL.status"				default="">
	<cfparam name="URL.gateway"				default="">
	<cfparam name="URL.payment_method_id"	default="">
	<cfparam name="URL.payment_method_type"	default="">
	<cfparam name="URL.charge_created_at"	default="">
	<cfcatch>Contact Support.</cfcatch>
</cftry>

<cfset GLBankAccountID = (UserID EQ 800654030 ? 101 : 100)>
<cfset SESSION.GLBankAccountID = GLBankAccountID>

<!--------------------------------------------------------------------------------------------------
	Paycove sends the payment result as a JSON IPN POST; fall back to URL/FORM params if not JSON
	(mirrors Pay\PC\1\ReturnEFT.cfm's dual-path handling).
---------------------------------------------------------------------------------------------------->
<cfset respData = GetHttpRequestData()>
<cfset TranAmt		= 0.00>
<cfset TransactionID	= "">
<cfset ResponseCode	= "200">
<cfset ResponseText	= "">
<cfset Valid			= FALSE>
<cfset isRespJSON	= FALSE>

<!--- Subscription and payment-method fields populated from IPN JSON --->
<cfset RecurringKey				= "">
<cfset RecurringFrequency		= "">
<cfset RecurringStartDate		= "">
<cfset RecurringAmount			= 0>
<cfset RecurringLabel 			= "">
<cfset RecurringDescription 	= "">
<cfset RecurringAmountType 		= "">
<cfset payment_method_id		= "">
<cfset payment_method_type		= "">
<cfset payment_method_brand		= "">
<cfset payment_method_last_four	= "">
<cfset fee_amount				= "0">
<cfset net_amount				= "0">
<cfset gateway					= "">
<cfset charge_created_at		= "">

<cfif IsJSON(respData.content)>
	<cftry>
		<cfset respStruct = deserializeJSON(respData.content)>
		<cfset isRespJSON = TRUE>

		<!--- Process charges array — all transaction and payment method details live here --->
		<cfset charges = structKeyExists(respStruct, "charges") AND isArray(respStruct.charges) ? respStruct.charges : []>
		<cfloop index="j" from="1" to="#arrayLen(charges)#">
			<cfset charge 					= charges[j]>
			<cfset payment_method_id 		= structKeyExists(charge, "payment_method_id") 			? charge.payment_method_id 			: "">
			<cfset payment_method_type 		= structKeyExists(charge, "payment_method_type") 		? charge.payment_method_type 		: "">
			<cfset payment_method_last_four = structKeyExists(charge, "payment_method_last_four") 	? charge.payment_method_last_four 	: "">
			<cfset payment_method_brand 	= structKeyExists(charge, "payment_method_brand") 		? charge.payment_method_brand 		: "">
			<cfset TransactionID 			= structKeyExists(charge, "charge_id") 					? charge.charge_id 					: "">
			<cfset TranAmt 					= structKeyExists(charge, "charge_total") 				? REReplace(charge.charge_total, "[^0-9\.]+", "", "ALL") : TranAmt>
			<cfset ResponseText 			= structKeyExists(charge, "status") 					? charge.status 					: ResponseText>
			<cfset fee_amount 				= structKeyExists(charge, "fee_amount") 				? charge.fee_amount 				: "0">
			<cfset net_amount 				= structKeyExists(charge, "net_amount") 				? charge.net_amount 				: "0">
			<cfset gateway 					= structKeyExists(charge, "gateway") 					? charge.gateway 					: "">
			<cfset charge_created_at 		= structKeyExists(charge, "charge_created_at") 			? charge.charge_created_at 			: "">
		</cfloop>
		<cfif NOT arrayLen(charges) AND StructKeyExists(respStruct, "status")>
			<cfset ResponseText = respStruct.status>
		</cfif>

		<!--- Process fields array --->
		<cfset fields = structKeyExists(respStruct, "fields") AND isArray(respStruct.fields) ? respStruct.fields : []>
		<cfloop index="i" from="1" to="#arrayLen(fields)#">
			<cfset field = fields[i]>
			<cfset #i# = structKeyExists(field, "name") ? field.name : "">
			<cfswitch expression="#UCASE(i)#">
				<cfcase value="CONTRIBUTIONID"> <cfset ContributionID 	= structKeyExists(field, "value") ? field.value : "0"> </cfcase>
				<cfcase value="USERID"> 		<cfset UserID 			= structKeyExists(field, "value") ? field.value : "0"> </cfcase>
				<cfcase value="CONVMETHOD"> 	<cfset ConvMethod 		= structKeyExists(field, "value") ? field.value : "0"> </cfcase>
				<cfcase value="SUBSCRIPTION_DATA">
					<cfset subscription_data = structKeyExists(field, "value") ? field.value : "">				
					<!--- Preprocess to fix invalid JSON syntax: replace /" with " and remove trailing / --->
					<cfset subscription_data = replace(subscription_data, '\"', '"', "all")>
					<cfset subscription_data = replace(subscription_data, '"\', '"', "all")>
					<cfset subscription_data = replace(subscription_data, '\}', '}', "all")>
					<cfset subscription_data = replace(subscription_data, '{\', '{', "all")>						

					<!--- Special handling for subscription_data json--->
					<cfif IsJSON(subscription_data) >
						<cfset subscription_struct 	= deserializeJSON(subscription_data)>
						<cfset RecurringLabel 		= structKeyExists(subscription_struct, "label") ? subscription_struct.label : "">
						<cfset RecurringDescription = structKeyExists(subscription_struct, "description") ? subscription_struct.description : "">
						<cfset RecurringAmountType 	= structKeyExists(subscription_struct, "amount_type") ? subscription_struct.amount_type : "">
						<cfset RecurringAmount 		= structKeyExists(subscription_struct, "amount") ? subscription_struct.amount : 0>
						<cfset RecurringStartDate 	= structKeyExists(subscription_struct, "start_date") ? subscription_struct.start_date : "">
						<cfset RecurringFrequency 	= structKeyExists(subscription_struct, "frequency") ? subscription_struct.frequency : "">
						<cfset RecurringKey 		= structKeyExists(subscription_struct, "subscription_key") ? subscription_struct.subscription_key : "">
					</cfif>
				</cfcase>
			</cfswitch>
		</cfloop>

		<cfset Valid = ListFindNoCase("success,succeeded,pending", ResponseText) GT 0>

		<cfcatch>
			<CF_XLogCart AccountID="0" Table="PC" type="E" Value="IPN" Desc="#cfcatch.message# #cfcatch.detail#">
		</cfcatch>
	</cftry>
<cfelse>
	<!--- Browser GET redirect: Paycove appends payment result as URL params.
		Map them to the same shared variables used by the IPN path. --->
	<cfset TransactionID		= URL.charge_id>
	<cfset TranAmt				= Val(URL.charge_total)>
	<cfset fee_amount			= URL.fee_amount>
	<cfset net_amount			= URL.net_amount>
	<cfset ResponseText			= URL.status>
	<cfset gateway				= URL.gateway>
	<cfset payment_method_id	= URL.payment_method_id>
	<cfset payment_method_type	= URL.payment_method_type>
	<cfset charge_created_at	= URL.charge_created_at>
	<cfset Valid = LEN(Trim(URL.charge_id)) GT 0
				AND ListFindNoCase("success,succeeded,pending", URL.status) GT 0>
</cfif>

<cfif NOT IsNumeric(ContributionID) OR ContributionID EQ 0>
	<CF_XLog AccountID="0" Table="Pay" type="E" Value="#ContributionID#"  Desc="Invalid or Missing ContributionID: #ContributionID#">
	<cf_problem message="Sorry, the contribution is not valid. #ResponseText#  Please contact support.">
</cfif>

<cfif NOT IsNumeric(UserID) OR UserID EQ 0>
	<CF_XLog AccountID="0" Table="Pay" type="E" Value="#UserID#"  Desc="Invalid or Missing UserID: #UserID#">
	<cf_problem message="Sorry, the user is not valid. #ResponseText#  Please contact support.">
</cfif>

<CF_XLogCart AccountID="0" Table="Pay" type="I" Value="#ContributionID#"  Desc="Paycove callback: UserID=#UserID# TranAmt=#DecimalFormat(TranAmt)# Status=#ResponseText#">

<cfif Valid>
	<cfif isRespJSON>
		<!------------------------------------------------------------------------------------------
			IPN JSON POST path: full payment processing
		-------------------------------------------------------------------------------------------->
		<cfinvoke component="#APPLICATION.DIR#CFC\ContributionDAO" method="CheckDupPymt" returnvariable="fDup">
			<cfinvokeargument name="TranNo"		Value="#ContributionID#">
			<cfinvokeargument name="TranAmt"	Value="#TranAmt#">
		</cfinvoke>

		<cfif NOT fDup>
			<cfinvoke component="#APPLICATION.DIR#CFC\UserDAO" method="View" UserID="#UserID#" returnvariable="MemberQ">
			<cfif MemberQ.Recordcount EQ 0>
				<cf_problem Message="Member Not Found.">
			</cfif>
			<CF_XLogCart AccountID="0" Table="Pay" type="A" Value="#UserID#" Desc="#MemberQ.UserName#">

			<cf_OrgYear YearEndMo="6">

			<cfinvoke component="\CFC\ContributionDAO" method="UpdateByContributionID" returnvariable="ContributionID">
				<cfinvokeargument name="ContributionID"	Value="#ContributionID#">
				<cfinvokeargument name="TranNo"			Value="#TransactionID#">
				<cfinvokeargument name="TranAmt"		Value="#TranAmt#">
				<cfinvokeargument name="Notes"			Value="#ResponseCode# #ResponseText#">
			</cfinvoke>

			<!--- Look up contribution to get HM (in honor/memory of) data for the recurring record --->
			<cfinvoke component="\CFC\ContributionDAO" method="Lookup" ContributionID="#ContributionID#" returnvariable="ContribHMQ">
			<cfif ContribHMQ.Recordcount GT 0>
				<cfset hmJSON = SerializeJSON({
					"HM"        : Trim(ContribHMQ.hm),
					"HMNAME"    : Trim(ContribHMQ.HMName),
					"HMADDRESS" : Trim(ContribHMQ.HMAddress)
				})>
			<cfelse>
				<cfset hmJSON = '{"HM":"","HMNAME":"","HMADDRESS":""}'>
			</cfif>

			<!--- Create/update EFTRecurring if user chose a recurring option --->
			<cfif LEN(Trim(RecurringFrequency)) GT 0 AND LEN(Trim(RecurringKey)) GT 0>
				<cfswitch expression="#Trim(RecurringFrequency)#">
					<cfcase value="Monthly">	<cfset RecurringPeriod = 1>		</cfcase>
					<cfcase value="Quarterly">	<cfset RecurringPeriod = 3>		</cfcase>
					<cfcase value="6 Months">	<cfset RecurringPeriod = 6>		</cfcase>
					<cfcase value="Yearly">		<cfset RecurringPeriod = 12>	</cfcase>
					<cfdefaultcase>				<cfset RecurringPeriod = 1>		</cfdefaultcase>
				</cfswitch>

				<cfset RecurringTranType = (UCASE(payment_method_type) EQ "CARD" ? "CC" : "EC")>

				<cfset CardDescription = Trim(payment_method_brand)>
				<cfif Len(CardDescription) GT 0 AND Len(Trim(payment_method_last_four)) GT 0>
					<cfset CardDescription = CardDescription & " [.." & Trim(payment_method_last_four) & "]">
				<cfelseif Len(Trim(payment_method_last_four)) GT 0>
					<cfset CardDescription = "[.." & Trim(payment_method_last_four) & "]">
				<cfelseif Len(CardDescription) EQ 0 AND Len(Trim(payment_method_id)) GT 0>
					<cfset CardDescription = "[.." & Right(Trim(payment_method_id), 4) & "]">
				</cfif>

				<cfif LEN(RecurringStartDate) GT 0 AND isDate(RecurringStartDate)>
					<cfset EFTStartDate = DateFormat(RecurringStartDate, "yyyy-mm-dd")>
				<cfelse>
					<cfset EFTStartDate = DateFormat(DateAdd("m", 1, Now()), "yyyy-mm-dd")>
				</cfif>

				<!--- Always create a new recurring record; DeleteLogicalByUserID below deactivates any prior ones --->
				<cfset EFTRecurringObj = createObject("component", "\CFC\EFTRecurring").init(EFTRecurringID="0")>
				<cfinvoke component="\CFC\EFTRecurring" method="init" EFTRecurringID="0" returnvariable="EFTRecurringObj">
					<cfinvokeargument name="UserID"				Value="#UserID#">
					<cfinvokeargument name="AccountID"			Value="#MemberQ.AccountID#">
					<cfinvokeargument name="ClubID"				Value="#MemberQ.ClubID#">
					<cfinvokeargument name="GLBankAccountID"	Value="#GLBankAccountID#">
					<cfinvokeargument name="NameOnAccount"		Value="#Trim(MemberQ.MemberName)#">
					<cfinvokeargument name="TranType"			Value="#RecurringTranType#">
					<cfinvokeargument name="Amount"				Value="#RecurringAmount#">
					<cfinvokeargument name="ConvMethod"			Value="#ConvMethod#">
					<cfinvokeargument name="Period"				Value="#RecurringPeriod#">
					<cfinvokeargument name="StartDate"			Value="#EFTStartDate#">
					<cfinvokeargument name="Token"				Value="#payment_method_id#">
					<cfinvokeargument name="hmJSON"				Value="#hmJSON#">
					<cfinvokeargument name="Notes"				Value="PC Recurring Contribution">
					<cfinvokeargument name="ResponseText"		Value="Paycove Subscription Callback">
					<cfinvokeargument name="CardNumber"			Value="#payment_method_last_four#">
					<cfinvokeargument name="CardDescription"	Value="#CardDescription#">
					<cfinvokeargument name="CardBrand"			Value="#payment_method_brand#">
					<cfinvokeargument name="dFlag"				Value="N">
					<cfinvokeargument name="PymtGateway"		Value="PC">
					<cfinvokeargument name="Created_by"			Value="0">
					<cfinvokeargument name="Modified_by"		Value="#UserID#">
					<cfinvokeargument name="Modified_Tmstmp"	Value="#now()#">
				</cfinvoke>
				<cfinvoke component="\CFC\EFTRecurringDAO" method="Create" EFTRecurring="#EFTRecurringObj#" returnvariable="NewEFTRecurringID">

				<cfif NewEFTRecurringID GT 0>
					<CF_XLogCart AccountID="0" Table="EFTRecurring" type="A" Value="#NewEFTRecurringID#" Desc="PC Recurring created/updated: UserID=#UserID#, Amount=#DecimalFormat(RecurringAmount)#, Period=#RecurringPeriod#, Start=#EFTStartDate#">
					<!--- Deactivate any other active recurring records for this user+account --->
					<cfinvoke component="\CFC\EFTRecurringDAO" method="DeleteLogicalByUserID"
						UserID="#UserID#"
						GLBankAccountID="#GLBankAccountID#"
						ExcludeEFTRecurringID="#NewEFTRecurringID#"
						Modified_By="#UserID#">
				<cfelse>
					<CF_XLogCart AccountID="0" Table="EFTRecurring" type="E" Value="#ContributionID#" Desc="PC Recurring: failed to save EFTRecurring for UserID=#UserID#">
				</cfif>
			</cfif>

			<!--- Send confirmation email, return JSON 200 to Paycove --->
			<cfinvoke component="\CFC\ReceiptDAO" method="Success" returnvariable="ReceiptHTML">
				<cfinvokeargument name="GLBankAccountID"	Value="#GLBankAccountID#">
				<cfinvokeargument name="ContributionID"		Value="#ContributionID#">
				<cfinvokeargument name="TransactionID"		Value="#TransactionID#">
				<cfinvokeargument name="ResponseCode"		Value="#ResponseCode#">
				<cfinvokeargument name="ResponseText"		Value="#ResponseText#">
				<cfinvokeargument name="AuthCode"			Value="">
				<cfinvokeargument name="SendEMail"			Value="Yes">
			</cfinvoke>

		<cfelse>
			<!--- Duplicate IPN: log and fall through to JSON 200 acknowledgment --->
			<CF_XLogCart AccountID="0" Table="Pay" type="I" Value="#ContributionID#" Desc="UserID=#UserID# Duplicate IPN Detected">
		</cfif>

		<!--- Always return JSON 200 to Paycove so it does not retry --->
		<cfset returnStruct = structNew()>
		<cfset returnStruct["status"]    = "200">
		<cfset returnStruct["message"]   = "Success">
		<cfset returnStruct["timestamp"] = Now()>
		<cfoutput>#serializeJSON(returnStruct)#</cfoutput>

	<cfelse>
		<!------------------------------------------------------------------------------------------
			Browser redirect GET path: IPN has already processed the payment (or will shortly).
			Just render the receipt — no re-processing, no second email.
			Pass TranAmt from URL params so the receipt shows the correct amount even when the
			IPN POST hasn't been recorded yet (race condition).
		-------------------------------------------------------------------------------------------->
		<cfinvoke component="\CFC\ReceiptDAO" method="Success" returnvariable="ReceiptHTML">
			<cfinvokeargument name="GLBankAccountID"	Value="#GLBankAccountID#">
			<cfinvokeargument name="ContributionID"		Value="#ContributionID#">
			<cfinvokeargument name="TransactionID"		Value="#TransactionID#">
			<cfinvokeargument name="ResponseCode"		Value="#ResponseCode#">
			<cfinvokeargument name="ResponseText"		Value="#ResponseText#">
			<cfinvokeargument name="AuthCode"			Value="">
			<cfinvokeargument name="SendEMail"			Value="No">
			<cfinvokeargument name="TranAmt"			Value="#TranAmt#">
		</cfinvoke>
		<cfoutput>#ReceiptHTML#</cfoutput>
	</cfif>

<cfelse>
	<CF_XLogCart AccountID="0" Table="Pay" type="E" Value="#ContributionID#"  Desc="UserID=#UserID# Transaction was not valid">

	<cfinvoke component="\CFC\ContributionDAO" method="UpdateByContributionID" returnvariable="ContributionID">
		<cfinvokeargument name="ContributionID"	Value="#ContributionID#">
		<cfinvokeargument name="TranNo"			Value="#TransactionID#">
		<cfinvokeargument name="Notes"			Value="#ResponseCode# #ResponseText#">
	</cfinvoke>

	<cfif isRespJSON>
		<!--- IPN failure: return JSON 200 so Paycove does not retry; error is logged above --->
		<cfset returnStruct = structNew()>
		<cfset returnStruct["status"]    = "200">
		<cfset returnStruct["message"]   = "Received">
		<cfset returnStruct["timestamp"] = Now()>
		<cfoutput>#serializeJSON(returnStruct)#</cfoutput>
	<cfelse>
		<cfinvoke component="#APPLICATION.DIR#cfc\ReceiptDAO" method="Failure" returnvariable="ReceiptHTML">
			<cfinvokeargument name="TransactionID"		Value="#TransactionID#">
			<cfinvokeargument name="UserID"				Value="#UserID#">
			<cfinvokeargument name="TotalAmount"		Value="#TranAmt#">
			<cfinvokeargument name="ResponseCode"		Value="#ResponseCode#">
			<cfinvokeargument name="ResponseText"		Value="#ResponseText#">
			<cfinvokeargument name="ErrorText"			Value="Invalid Transaction Returned from Paycove">
		</cfinvoke>
		<cfoutput>#ReceiptHTML#</cfoutput>
	</cfif>
</cfif>
