<!--------------------------------------------------------------------------------------------
	Receit.cfc

	* $Revision: $
	* $Date: 10/31/2019 $
---------------------------------------------------------------------------------------------->
<cfcomponent displayname="Receipt" output="true">

<!--------------------------------------------------------------------------------------------
	Internal Tranlate Function
----------------------------------------------------------------------------------------------->
<cfscript>
/*
 * function - XlateToStateCode(string) -- state name to statecode
*/

function xlateThisDay(day)  {
switch( day )
{
case "1": 				{ string = "1st"; break; }
case "2": 				{ string = "2nd"; break; }
case "3": 				{ string = "3rd"; break; }
case "4": 				{ string = "4th"; break; }
case "5": 				{ string = "5th"; break; }
case "6": 				{ string = "6th"; break; }
case "7": 				{ string = "7th"; break; }
case "8": 				{ string = "8th"; break; }
case "9": 				{ string = "9th"; break; }
case "10": 				{ string = "10th"; break; }
case "11": 				{ string = "11th"; break; }
case "12": 				{ string = "12th"; break; }
case "13": 				{ string = "13th"; break; }
case "14": 				{ string = "14th"; break; }
case "15": 				{ string = "15th"; break; }
case "16": 				{ string = "16th"; break; }
case "17": 				{ string = "17th"; break; }
case "18": 				{ string = "18th"; break; }
case "19": 				{ string = "19th"; break; }
case "20": 				{ string = "20th"; break; }
case "21": 				{ string = "21st"; break; }
case "22": 				{ string = "22nd"; break; }
case "23": 				{ string = "23rd"; break; }
case "24": 				{ string = "24th"; break; }
case "25": 				{ string = "25th"; break; }
case "26": 				{ string = "26th"; break; }
case "27": 				{ string = "27th"; break; }
case "28": 				{ string = "28th"; break; }
case "29": 				{ string = "29th"; break; }
case "30": 				{ string = "30th"; break; }
case "31": 				{ string = "31st"; break; }

}
return string;
}

</cfscript>
<cfscript>

function xlatePayment(string, Amount, ConvFee, TotalAmt, ContributionID, TranNo)  {
string = ReplaceNoCase(string, "{%Date%}", 				DateFormat(now(),'mmm-dd-yyyy'), "ALL");
string = ReplaceNoCase(string, "{%Today%}", 			DateFormat(now(),'mmm-dd-yyyy'), "ALL");

string = ReplaceNoCase(string, "{%AccountID%}", 		AccountID, "ALL");

string = ReplaceNoCase(string, "{%UserID%}", 			UserID, "ALL");
string = ReplaceNoCase(string, "{%MemberName%}", 		MemberName, "ALL");
string = ReplaceNoCase(string, "{%UserName%}", 			UserName, "ALL");

string = ReplaceNoCase(string, "{%LastName%}", 			LastName, "ALL");
string = ReplaceNoCase(string, "{%FirstName%}", 		FirstName, "ALL");
string = ReplaceNoCase(string, "{%MidName%}", 			MidName, "ALL");
string = ReplaceNoCase(string, "{%NameSfx%}", 			NameSfx, "ALL");
string = ReplaceNoCase(string, "{%FName%}", 			FName, "ALL");

string = ReplaceNoCase(string, "{%Email%}", 			Email, "ALL");
string = ReplaceNoCase(string, "{%MemberID%}", 			MemberID, "ALL");

Address = Address1;
if (Len(Address2) GT 0) Address = Address1 & "<BR>" & Address2;
string = ReplaceNoCase(string, "{%Address%}", 			Address, "ALL");
string = ReplaceNoCase(string, "{%Address1%}", 			Address1, "ALL");
string = ReplaceNoCase(string, "{%Address2%}", 			Address2, "ALL");
string = ReplaceNoCase(string, "{%City%}", 				City, "ALL");
string = ReplaceNoCase(string, "{%StateCode%}", 		StateCode, "ALL");
string = ReplaceNoCase(string, "{%ProvOrOther%}", 		ProvOrOther, "ALL");
string = ReplaceNoCase(string, "{%PostalZip%}", 		PostalZip, "ALL");
string = ReplaceNoCase(string, "{%CountryCode%}", 		CountryCode, "ALL");

string = ReplaceNoCase(string, "{%PhoneNumber%}", 		PhoneNumber, "ALL");

BillingAddress = BillingAddress1;
if (Len(BillingAddress2) GT 0) BillingAddress = BillingAddress1 & "<BR>" & BillingAddress2;
string = ReplaceNoCase(string, "{%BillingContact%}", 	BillingContact, "ALL");
string = ReplaceNoCase(string, "{%BillingCompany%}", 	BillingCompany, "ALL");
string = ReplaceNoCase(string, "{%BillingAddress%}", 	BillingAddress, "ALL");
string = ReplaceNoCase(string, "{%BillingAddress1%}", 	BillingAddress1, "ALL");
string = ReplaceNoCase(string, "{%BillingAddress2%}", 	BillingAddress2, "ALL");
string = ReplaceNoCase(string, "{%BillingAddress3%}", 	BillingAddress3, "ALL");
string = ReplaceNoCase(string, "{%BillingCity%}", 		BillingCity, "ALL");
string = ReplaceNoCase(string, "{%BillingStateCode%}", 	BillingStateCode, "ALL");
string = ReplaceNoCase(string, "{%BillingPostalZip%}", 	BillingPostalZip, "ALL");
string = ReplaceNoCase(string, "{%BillingCountryCode%}",BillingCountryCode, "ALL");
string = ReplaceNoCase(string, "{%BillingEmail%}", 		BillingEmail, "ALL");
string = ReplaceNoCase(string, "{%BillingPhone%}", 		BillingPhone, "ALL");
string = ReplaceNoCase(string, "{%BillingFaxNumber%}",  BillingFaxNumber, "ALL");

string = ReplaceNoCase(string, "{%HMMsg%}", 			HMMsg, "ALL");

string = ReplaceNoCase(string, "{%TranNo%}", 			TranNo, "ALL");
string = ReplaceNoCase(string, "{%ContributionID%}", 	ContributionID, "ALL");
string = ReplaceNoCase(string, "{%ContribType%}", 		ContribType, "ALL");
string = ReplaceNoCase(string, "{%Amount%}", 			DollarFormat(Amount), "ALL");
string = ReplaceNoCase(string, "{%ConvFee%}", 			DollarFormat(ConvFee), "ALL");
string = ReplaceNoCase(string, "{%TotalAmt%}", 			DollarFormat(TotalAmt), "ALL");

return string;
}
</cfscript>
	<!--------------------------------------------------------------------------------------------
		Receipt - SUCCESS Generate and Return Receipt HTML
	----------------------------------------------------------------------------------------------->

	<cffunction name="Success" access="public" returntype="string" output="true">
		<cfargument NAME="GLBankAccountID" 		type="Numeric"	Required="Yes"		Default="#SESSION.GLBankAccountID#">
		<cfargument NAME="ContributionID" 		type="String"	Required="Yes"		Default="0">		<!--- CART ContributionID --->

		<cfargument NAME="ResponseCode" 		type="String"	Required="Yes"		Default="">
		<cfargument NAME="ResponseText" 		type="String"	Required="Yes"		Default="">
		<cfargument NAME="AuthCode" 			type="String"	Required="Yes"		Default="">

		<cfargument NAME="SendEMail"			type="String"	Required="No"		Default="Yes">

		<cfset var ReceiptHTML = "">
		<cfset var SendHMEMail = FALSE>

		<!--------------------------------------------------------------------------------------------
			Find the Contribution
		----------------------------------------------------------------------------------------------->
		<cfinvoke component="\CFC\ContributionDAO" method="Lookup" ContributionID="#ContributionID#" returnvariable="ContributionQ">
		<cfif ContributionQ.Recordcount EQ 0>
			<cfreturn ReceiptHTML>
		</cfif>
		<cfset UserID	= ContributionQ.UserID>			<!--- if > 0 personal donation --->
		<cfset ClubID	= ContributionQ.ClubID>			<!--- if > 0 Club donation, if > 10000 District Club --->
		<cfset CreatedBy= ContributionQ.Created_By>		<!--- Person entering donation --->
		<cfset Amount	= ContributionQ.Amount>
		<cfset ConvFee	= ContributionQ.ConvFee>
		<cfset TranAmt	= ContributionQ.TranAmt>
		<cfset TranNo	= ContributionQ.TranNo>

		<cfset HM 		 = ContributionQ.hm>
		<cfset HMName 	 = ContributionQ.HMName>
		<cfset HMAddress = ContributionQ.HMAddress>
		<cfset HMMsg	 = "">

		<!--------------------------------------------------------------------------------------------
			Build the Honorary/Memorial output string
		----------------------------------------------------------------------------------------------->
		<cfif Len(Trim(hm)) GT 0 AND Len(Trim(HMName)) GT 0>
			<cfset SendHMEMail = TRUE>
			<CF_XLogCart  AccountID="0" Table="" type="U" Value="#CreatedBy#"  Desc="UserID=#UserID#, Hm=#hm#, Name=#hmname#, Addr=#HMAddress#">
			<cfsavecontent variable="HMMsg">
			<P style="font-size: 11pt;">
				This donation is in
				<strong>
					<cfswitch expression="#hm#">
						<cfcase value="H">Honor of: </cfcase>
						<cfcase value="M">Memory of: </cfcase>
					</cfswitch>
				</strong>
				<cfoutput>
					#HMName#<br />
					#HMAddress#<BR>
				</cfoutput>
			</P>
			</cfsavecontent>
		<cfelse>
			<CF_XLogCart  AccountID="0" Table="" type="U" Value="#CreatedBy#"  Desc="UserID=#UserID#, Hm=#hm#, Name=#hmname# Not found.">
		</cfif>
		<CF_XLogCart  AccountID="0" Table="" type="U" Value="#CreatedBy#"  Desc="Hm=#hm#, Name=#hmname#, Addr=#HMAddress#">

		<!--------------------------------------------------------------------------------------------
			Find Member - Use the Created_By value since this could be a club of district contribution
		----------------------------------------------------------------------------------------------->
		<cfif UserID GT 0>
			<cfinvoke component="\CFC\UserDAO" method="View" UserID="#UserID#"  returnvariable="MemberQ">
		<cfelse>
			<cfinvoke component="\CFC\UserDAO" method="View" UserID="#CreatedBy#"  returnvariable="MemberQ">
		</cfif>
		<CF_XLogCart  AccountID="0" Table="" type="U" Value="#ContributionID#"  Desc="Success Receipt, Member=#MemberQ.UserName# (#UserID#), $=#DecimalFormat(TranAmt)#">

		<!--------------------------------------------------------------------------------------------
			Build how this contribution was recorded: Personal, Club or District
		----------------------------------------------------------------------------------------------->
		<cfif UserID GT 0>
			<cfset ContribType = "Personal">
		<cfelseif ClubID GT 0 AND ClubID LT 100000>
			<cfset ContribType = "Club">
		<cfelse>
			<cfset ContribType = "District">
		</cfif>
		<!--------------------------------------------------------------------------------------------
			Find Finance Account
		----------------------------------------------------------------------------------------------->
		<cfinvoke component="\CFC\GLBankAccountDAO" method="Lookup" GLBankAccountID="#GLBankAccountID#"  returnvariable="BankAccountQ">
		<cfset AccountName 			= BankAccountQ.GLBankAccountName>
		<cfset IsHandleFee 			= BankAccountQ.IsHandleFee>
		<cfset HandleFeeFixed 		= BankAccountQ.HandleFeeFixed>
		<cfset HandlefeePcnt 		= BankAccountQ.HandlefeePcnt>
		<cfset PymtGateway 			= BankAccountQ.PymtGateway>
		<cfset GatewayParms 		= BankAccountQ.GatewayParms>
		<cfset PaymentTemplate 		= BankAccountQ.PaymentTemplate>

		<cfset BillingContact 		= BankAccountQ.BillingContact>
		<cfset BillingCompany 		= BankAccountQ.BillingCompany>
		<cfset BillingCompany 		= BankAccountQ.BillingCompany>
		<cfset BillingAddress1 		= BankAccountQ.BillingAddress1>
		<cfset BillingAddress2 		= BankAccountQ.BillingAddress2>
		<cfset BillingAddress3 		= BankAccountQ.BillingAddress3>
		<cfset BillingCity 			= BankAccountQ.BillingCity>
		<cfset BillingStateCode 	= BankAccountQ.BillingStateCode>
		<cfset BillingProvOrOther 	= BankAccountQ.BillingProvOrOther>
		<cfset BillingPostalZip 	= BankAccountQ.BillingPostalZip>
		<cfset BillingCountryCode 	= BankAccountQ.BillingCountryCode>

		<cfset BillingEmail 		= BankAccountQ.BillingEmail>
		<cfset BillingPhone 		= BankAccountQ.BillingPhone>
		<cfset BillingFaxNumber 	= BankAccountQ.BillingFaxNumber>
		<cfset Notifications 		= BankAccountQ.Notifications>

		<!--------------------------------------------------------------------------------------------
			Display The Receipt
		----------------------------------------------------------------------------------------------->
		<cfset xlateText = "Member not found. Contact Support.">
		<cfoutput query="MemberQ">
			<cftry>
				<cfset xlateText = xlatePayment(PaymentTemplate, Amount, ConvFee, TranAmt, ContributionID, TranNo)>
				<cfcatch><cfset xlateText = "#cfcatch.message#<br>#cfcatch.detail#"></cfcatch>
			</cftry>
		</cfoutput>
		<cfsavecontent variable="ReceiptHTML">
			<div style="width: 700px; margin: auto;">
				<div style="position:relative; top:40px; text-align: center; font-family:Arial;">
					<cfoutput>#xlateText#</cfoutput>
				</div>
			</div>
		</cfsavecontent>

		<!--------------------------------------------------------------------------------------------
			Display The Receipt
		----------------------------------------------------------------------------------------------->
		<cfif SendEMail>
			<cfset rc = SendReceipt(MemberQ.EMail, MemberQ.MemberName, Notifications, BillingContact, ReceiptHTML, SendHMEMail)>
		</cfif>

		<cfreturn ReceiptHTML>
	</cffunction>

	<!--------------------------------------------------------------------------------------------
		Receipt - FAILURE Generate error receipt and Return Receipt HTML
	----------------------------------------------------------------------------------------------->
	<cffunction name="Failure" access="public" returntype="string" output="true">
		<cfargument NAME="GLBankAccountID" 		type="Numeric"	Required="Yes"		Default="#SESSION.GLBankAccountID#">
		<cfargument NAME="ContributionID" 		type="String"	Required="Yes"		Default="0">		<!--- CART ContributionID --->
		<cfargument NAME="UserID" 				type="Numeric"	Required="Yes"		Default="0">
		<cfargument NAME="TotalAmount"	 		type="Numeric"	Required="Yes"		Default="0">

		<cfargument NAME="ResponseCode" 		type="String"	Required="Yes"		Default="">
		<cfargument NAME="ResponseText" 		type="String"	Required="Yes"		Default="">
		<cfargument NAME="AuthCode" 			type="String"	Required="Yes"		Default="">

		<cfargument NAME="ErrorText"	 		type="String"	Required="Yes"		Default="">

		<cfargument NAME="SendEMail"			type="String"	Required="No"		Default="No">

		<cfset var ReceiptHTML = "">

		<cfset TotalAmount   = REReplace(TotalAmount, "[^0-9\.]+", "", "ALL")>

		<!--------------------------------------------------------------------------------------------
			Find Member
		----------------------------------------------------------------------------------------------->
		<cfinvoke component="\CFC\UserDAO" method="View" UserID="#UserID#"  returnvariable="MemberQ">
		<CF_XLogCart  AccountID="0" Table="" type="U" Value="#ContributionID#"  Desc="Failure Receipt, Member=#MemberQ.UserName# (#UserID#), $=#DecimalFormat(TotalAmount)#">

		<!--------------------------------------------------------------------------------------------
			Find Finance Account
		----------------------------------------------------------------------------------------------->
		<cfinvoke component="\CFC\GLBankAccountDAO" method="Lookup" GLBankAccountID="#GLBankAccountID#"  returnvariable="BankAccountQ">
		<cfset AccountName 			= BankAccountQ.GLBankAccountName>
		<cfset IsHandleFee 			= BankAccountQ.IsHandleFee>
		<cfset HandleFeeFixed 		= BankAccountQ.HandleFeeFixed>
		<cfset HandlefeePcnt 		= BankAccountQ.HandlefeePcnt>
		<cfset PymtGateway 			= BankAccountQ.PymtGateway>
		<cfset GatewayParms 		= BankAccountQ.GatewayParms>
		<cfset PaymentTemplate 		= BankAccountQ.PaymentTemplate>

		<cfset BillingContact 		= BankAccountQ.BillingContact>
		<cfset BillingCompany 		= BankAccountQ.BillingCompany>
		<cfset BillingCompany 		= BankAccountQ.BillingCompany>
		<cfset BillingAddress1 		= BankAccountQ.BillingAddress1>
		<cfset BillingAddress2 		= BankAccountQ.BillingAddress2>
		<cfset BillingAddress3 		= BankAccountQ.BillingAddress3>
		<cfset BillingCity 			= BankAccountQ.BillingCity>
		<cfset BillingStateCode 	= BankAccountQ.BillingStateCode>
		<cfset BillingProvOrOther 	= BankAccountQ.BillingProvOrOther>
		<cfset BillingPostalZip 	= BankAccountQ.BillingPostalZip>
		<cfset BillingCountryCode 	= BankAccountQ.BillingCountryCode>

		<cfset BillingEmail 		= BankAccountQ.BillingEmail>
		<cfset BillingPhone 		= BankAccountQ.BillingPhone>
		<cfset BillingFaxNumber 	= BankAccountQ.BillingFaxNumber>
		<cfset Notifications 		= BankAccountQ.Notifications>

		<!--------------------------------------------------------------------------------------------
			Payment Failure == Display and Log the Information
		----------------------------------------------------------------------------------------------->
		<cfsavecontent variable="ReceiptHTML">
			<div style="width: 700px; margin: auto;">
				<div style="position:relative; top:40px; text-align:  left; font-family:Arial;">
					<cfoutput>
					<h3>There was a problem with your request.</h3>
					<P><span style="color: red">#ErrorText#</span></P>
					<BR>
					<table border="0" cellpadding="0" cellspacing="0"  width="600">
						<tr>
							<TD class="TDLabel" width="140">Member: &nbsp;</TD>
							<TD class="TDData"><strong>#MemberQ.MemberName# (#UserID#)</strong></TD>
						</tr>
						<cfif Len(ContributionID) GT 0>
							<tr>
								<TD class="TDLabel" width="140">ContributionID: &nbsp;</TD>
								<TD class="TDData"><strong>#ContributionID#</strong></TD>
							</tr>
						</cfif>
						<tr>
							<TD class="TDLabel" width="140">Total Amount: &nbsp;</TD>
							<TD class="TDData"><strong>#DollarFormat(TotalAmount)#</strong></TD>
						</tr>
						<cfif Len(Trim(AuthCode)) GT 0>
							<tr>
								<TD class="TDLabel" width="140">AuthCode: &nbsp;</TD>
								<TD class="TDData"><strong>#AuthCode#</strong></TD>
							</tr>
						</cfif>
						<cfif Len(Trim(ResponseCode)) GT 0>
							<tr>
								<TD class="TDLabel" width="140">Return Code: &nbsp;</TD>
								<TD class="TDData"><strong>#ResponseCode#</strong></TD>
							</tr>
						</cfif>
						<cfif Len(Trim(ResponseText)) GT 0>
							<tr>
								<TD class="TDLabel" width="140">Response Text: &nbsp;</TD>
								<TD class="TDData"><strong>#ResponseText#</strong></TD>
							</tr>
						</cfif>
					</table>
					<P>Please contact support if the problem persists.</P>
					</cfoutput>
				</div>
			</div>
		</cfsavecontent>

		<!--------------------------------------------------------------------------------------------
			Display The Receipt
		----------------------------------------------------------------------------------------------->
		<cfif SendEMail>
			<cfset rc = SendReceipt(MemberQ.EMail, MemberQ.MemberName, Notifications, BillingContact, ReceiptHTML, FALSE )>
		</cfif>

		<cfreturn ReceiptHTML>
	</cffunction>

	<!--------------------------------------------------------------------------------------------
		Scheduled - Scheduled Tranaction Receipt
	----------------------------------------------------------------------------------------------->
	<cffunction name="Scheduled" access="public" returntype="string" output="true">
		<cfargument NAME="UserID" 				type="Numeric"	Required="Yes">
		<cfargument NAME="TotalAmount"	 		type="Numeric"	Required="Yes">

		<cfargument NAME="Period"	 			type="Numeric"	Required="Yes">
		<cfargument NAME="StartDate"	 		type="String"	Required="Yes">
		<cfargument NAME="EndDate"	 			type="String"	Required="Yes">


		<cfset var ReceiptHTML = "">

		<cfset TotalAmount   = REReplace(TotalAmount, "[^0-9\.]+", "", "ALL")>

		<!--------------------------------------------------------------------------------------------
			Find Member
		----------------------------------------------------------------------------------------------->
		<cfinvoke component="\CFC\UserDAO" method="View" UserID="#ARGUMENTS.UserID#"  returnvariable="MemberQ">

		<!--------------------------------------------------------------------------------------------
			Payment Failure == Display and Log the Information
		----------------------------------------------------------------------------------------------->
		<cfsavecontent variable="ReceiptHTML">
			<div style="width: 700px; margin: auto;">
				<div style="position:relative; top:40px; text-align: left; font-family:Arial;">
					<cfoutput>
					<h3>EFT Transaction</h3>
					<P>An Electronic Funds Transfer (EFT) transaction has been scheduled</P>
					<BR>
					<table border="0" cellpadding="0" cellspacing="0" width="600">
						<tr>
							<TD class="TDLabel" width="140">Member: &nbsp;</TD>
							<TD class="TDData"><strong>#MemberQ.MemberName# (#UserID#)</strong></TD>
						</tr>
						<tr>
							<TD class="TDLabel" width="140">Total Amount: &nbsp;</TD>
							<TD class="TDData"><strong>#DollarFormat(TotalAmount)#</strong></TD>
						</tr>
						<tr>
							<TD class="TDLabel" width="140">Period: &nbsp;</TD>
							<TD class="TDData">
								<cfswitch expression="#Period#">
									<cfcase value="1">
										Monthly
									</cfcase>
									<cfcase value="3">
										Quarterly
									</cfcase>
									<cfcase value="6">
										Semi-Annual
									</cfcase>
									<cfcase value="12">
										Yearly
									</cfcase>
									<cfdefaultcase>
										 Bad Period [#Period#]
									</cfdefaultcase>
								</cfswitch>
							</TD>
						</tr>
						<tr>
							<TD class="TDLabel" width="140">EFT Date: &nbsp;</TD>
							<TD class="TDData">
								#xlateThisDay(Day(StartDate))# of the Month
							</TD>
						</tr>
						<tr>
							<TD class="TDLabel" width="140">EFT Start Date: &nbsp;</TD>
							<TD class="TDData">#DateFormat(EndDate)#</TD>
						</tr>
						<cfif IsDate(EndDate)>
							<tr>
								<TD class="TDLabel" width="140">EFT End Date: &nbsp;</TD>
								<TD class="TDData">#DateFormat(EndDate)#</TD>
							</tr>
						</cfif>
					</table>
					<P>Please contact support if this is incorrect.</P>
					</cfoutput>
				</div>
			</div>
		</cfsavecontent>

		<cfreturn ReceiptHTML>
	</cffunction>

	<!--------------------------------------------------------------------------------------------
		SendReceipt - Send Receipt via EMail
		<cfset rc = SendReceipt(MemberQ.EMail, MemberQ.MemberName, Notifications, BillingContact )>
	----------------------------------------------------------------------------------------------->
	<cffunction name="SendReceipt" access="public" returntype="string" output="true">
		<cfargument NAME="ToEMail"	 		type="String"	Required="Yes">
		<cfargument NAME="ToName"	 		type="String"	Required="Yes">
		<cfargument NAME="Notifications"	type="String"	Required="Yes">
		<cfargument NAME="BillingContact"	type="String"	Required="Yes">
		<cfargument NAME="ReceiptHTML"		type="String"	Required="Yes">
		<cfargument NAME="SendHMEMail"		type="String"	Required="Yes"		default="none">

		<CF_XLogCart  AccountID="0" Table="" type="U" Value="SendReceipt"  Desc="ToEMail=#ToEMail#, ToName=#ToName#, N=#Notifications#, BC=#BillingContact#">

		<cfif IsJSON(Notifications)>
			<cfset NoteStruct  		= deserializeJSON(Notifications)>
			<cfset ContributionEMail= NoteStruct.ContributionEMail>
			<cfset hmEMail			= NoteStruct.hmEMail>
		<cfelse>
			<cfset ContributionEMail= "">
			<cfset hmEMail			= "">
		</cfif>

		<CF_XLogCart  AccountID="0" Table="" type="M" Value="ContributionEMail"	Desc="#ContributionEMail#">
		<CF_XLogCart  AccountID="0" Table="" type="M" Value="hmEMail" 			Desc="#hmEMail#">

		<cfset FromEMail = GetToken(ContributionEMail, 1, ",")>
		<cfif Len(Trim(FromEMail))>
			<cfset FromEMail = "support@dacdb.com">
		</cfif>

		<!--------------------------------------------------------------------------------------------
			EMail The Receipt to the Contributor
		----------------------------------------------------------------------------------------------->
		<cfif IsValid("EMail", ToEMail)>
			<cftry>
				<CF_SendEMail TO="#ToEMail#" FROM="#FromEMail#" FromName="CART Fund" ReplyTo="#ContributionEMail#" CC="#ContributionEMail#" SUBJECT="CART Contribution: #ToName#" MESSAGE="#ReceiptHTML#" BCC="mark@dacdb.com" IsUseAlt="Y" TYPE="HTML">
				<CF_XLogCart  AccountID="0" Table="" type="M" Value="#ToName#"  Desc="CART Contribution EMail Sent To: #ToEMail#">
				<cfcatch>
					<CF_XLogCart  AccountID="0" Table="" type="M" Value="#ToName#"  Desc="Could not Send Contribution EMail Sent To: #ToEMail#, #cfcatch.message#">
				</cfcatch>
			</cftry>
		<cfelse>
			<cfset eMail = "">
			<cfloop index="E" list="#ContributionEMail#" delimiters=",">
				<cfif IsValid("EMail", E)>
					<cfset eMail = ListAppend(eMail, e)>
				</cfif>
			</cfloop>
			<cfif Len(eMail) GT 0>
				<cftry>
					<CF_SendEMail TO="#eMail#" FROM="#FromEMail#" FromName="Cart Fund" ReplyTo="#ContributionEMail#" SUBJECT="CART Contribution: #ToName#" MESSAGE="Member EMail Missing:<BR><HR><BR>#xlateText#" BCC="mark@dacdb.com" IsUseAlt="Y" TYPE="HTML">
					<CF_XLogCart  AccountID="0" Table="" type="M" Value="#ToName#"  Desc="CART Contribution EMail to: #eMail#, To:#ToName#  Mail: #ToEMail# missing or not valid">
					<cfcatch>
						<CF_XLogCart  AccountID="0" Table="" type="M" Value="#ToName#"  Desc="Could Not Send Contribution EMail to: #eMail#, To:#ToName#  Mail: #ToEMail# missing or not valid">
					</cfcatch>
				</cftry>
			<cfelse>
				<CF_XLogCart  AccountID="0" Table="" type="M" Value="#ToName#"  Desc="CART Contribution EMail missing or not valid">
			</cfif>
		</cfif>

		<!--------------------------------------------------------------------------------------------
			EMail The Honor/Memory EMail  List
		----------------------------------------------------------------------------------------------->
		<cfif SendHMEMail AND Len(Trim(hmEMail))>
			<cftry>
				<CF_SendEMail TO="#hmEMail#" FROM="#FromEMail#" FromName="CART Fund" ReplyTo="#ContributionEMail#" CC="#ContributionEMail#" SUBJECT="CART H/M Contribution: #ToName#" MESSAGE="#ReceiptHTML#" BCC="mark@dacdb.com" IsUseAlt="Y" TYPE="HTML">
				<CF_XLogCart  AccountID="0" Table="" type="M" Value="#ToName#"  Desc="CART H/M Contribution EMail Sent To: #hmEMail#">
				<cfcatch>
					<CF_XLogCart  AccountID="0" Table="" type="M" Value="#ToName#"  Desc="Could not SendH/M Contribution EMail Sent To: #hmEMail#, #cfcatch.message#">
				</cfcatch>
			</cftry>
		</cfif>

		<cfreturn TRUE>
	</cffunction>

</cfcomponent>
