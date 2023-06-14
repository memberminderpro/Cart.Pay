<!-------------------------------------------------------------------------------------------------
 	Copyright(c) 2003-2020 DACdb, LLC.
 	Applcication.cfc - Pay.Cart
	04/20/2020 - Created
---------------------------------------------------------------------------------------------------->

<cfcomponent output="false">

	<cfset This.DIR						= "">							<!--- Logical directory application starts NO SLASH --->
	<cfset This.DSN						= "Cart">						<!--- Name the DSN (If its test, make it state so) --->
	<cfset This.Name					= "CartPay">					<!--- SESSION Name the application. --->

	<cfset This.setClientCookies 		= FALSE />						<!--- This prevents CFID and CFTOKEN being sent as cookies --->

	<cfset This.sessionManagement		= TRUE>							<!--- Turn on session management. --->
	<cfset This.clientManagement		= TRUE>							<!--- Turn on client management. --->
	<cfif IsLocalhost(CGI.REMOTE_HOST)>
		<cfset This.DSN						= "MyCartFund">					<!--- Name the DSN (If its test, make it state so) --->
		<cfset This.clientStorage			= "MyCartFund">					<!--- Turn on client storage. --->
	<cfelse>
		<cfset This.DSN						= "Cart">						<!--- Name the DSN (If its test, make it state so) --->
		<cfset This.clientStorage			= "Cart">						<!--- Turn on client storage. --->
	</cfif>
	<cfset This.loginstorage			= "SESSION">
	<cfset This.Sessiontimeout			= "#createtimespan(0,0,15,0)#">
	<cfset This.applicationtimeout		= "#createtimespan(0,1,0,0)#">
	<cfset This.blockedExtForFileUpload = "php,js,cfm,cfc,cfml,cmd,jsp,exe">
	<cfset This.sessioncookie.httponly	= TRUE>
	<cfset This.scriptprotect			= "ALL">

<!---------------------------------- Application Handling ------------------------------------------->

	<cffunction name="onApplicationStart" output="false" returnType="void">

		<!--- Any variables set here can be used by all our pages --->
		<cfset APPLICATION.appStarted 		= now()>

		<cfset APPLICATION.serverTimeZone 	= GetTimeZoneInfo()>
		<cfset APPLICATION.MinFromGMT 		= APPLICATION.serverTimeZone.utcMinuteOffset>
		<cfset APPLICATION.HrsFromGMT 		= APPLICATION.serverTimeZone.utcHourOffset>
		<cfset APPLICATION.LastMonitor 		= "">
		<cfset APPLICATION.MaxOnlineReboot	= 0>

		<cfset APPLICATION.System		 	= "MyCartFund">
		<cfset APPLICATION.fromDoNotReply 	= "DoNotReply@MyCartFund.org">
		<cfset APPLICATION.fromSupport	 	= "support@MyCartFund.org">
		<cfset APPLICATION.fromEFT			= "pay@MyCartFund.org">
		<cfset APPLICATION.Public			= TRUE>
		<cfset APPLICATION.currentPath 		= getCurrentTemplatePath()>

		<cfset APPLICATION.DIR				= This.DIR>	<!--- Logical dir starts, include / used by CFC references --->

		<cfset REQUEST.DSN 					= This.DSN>  		<!--- Need to define this here as session scope has not been established --->

	</cffunction>

	<cffunction name="onApplicationEnd" output="false" returnType="void">
		<cfargument name="appScope" required="true">
	</cffunction>

<!---------------------------------- Session Handling ------------------------------------------->

	<cffunction name="onSessionStart" output="false" returnType="void">

			<cfset SESSION.Created 		= now()>
			<cfset SESSION.Started 		= TRUE>
			<cfset SESSION.Login 		= FALSE>

			<cfset SESSION.Name 		= This.Name>								<!--- Application Name --->

			<!--- These setup the environment  CONFIGURE THESE, they may be overridden later by account  --->
			<cfset SESSION.RoleID 		= 0>
			<cfset SESSION.UserID	 	= 0>										<!--- XLOG needs an Account Defined --->
			<cfset SESSION.AccountID 	= 0>										<!--- XLOG needs an Account Defined --->
			<cfset SESSION.UserID 		= 0>
			<cfset SESSION.UserName		= "">
			<cfset SESSION.ClubID 		= 0>
			<cfset SESSION.ClubName		= "">
			<cfset SESSION.ClubNumber	= "">
			<cfset SESSION.RoleID 		= 0>
			<cfset SESSION.CountryCode	= "USA">				<!--- Set initial value used to set defaults --->
			<cfset SESSION.EMail		= "">
			<cfset SESSION.DisplayAs	= "">
			<cfset SESSION.IsUseAlt		= "Y">

			<cfif IsLocalhost(CGI.REMOTE_HOST)>
				<cfset SESSION.Domain 		= "http://cart.com/">							<!--- Name the Localhost Domain --->
				<cfset SESSION.ApplURL 		= "http://cart.com/">
			<cfelse>
				<cfset SESSION.Domain 		= "https://www.MyCartFund.org/">				<!--- Name the Domain (if not Localhost)--->
				<cfset SESSION.ApplURL 		= "https://www.MyCartFund.org/">
			</cfif>

			<cfset SESSION.LogPath 		= "D:\Logfiles\">							<!--- Set Application log file path --->
			<cfset SESSION.DebugLevel	= 0>
	</cffunction>

	<cffunction name="onSessionEnd" returnType="void">
		<cfargument name="SessionScope" type="struct" required="true" />

		<cfset var duration = dateDiff("s", ARGUMENTS.SessionScope.created, now())>

		<cfset StructClear(Arguments.SessionScope) />

	</cffunction>

<!---------------------------------- Request Handling ------------------------------------------->
	<cffunction name="onRequestStart" output="false" returnType="void">

		<cfset start_tick 					= GetTickCount()>
		<cfset APPLICATION.SysMsg.MtcSched  = "N">
		<cfset REQUEST.DSN 	= This.DSN>  		<!--- Need to define this here as session scope has not been established --->

		<cfif IsLocalhost(CGI.REMOTE_HOST)>
			<cfset SESSION.Domain 		= "http://pay.cart.com/">							<!--- Name the Localhost Domain --->
			<cfset SESSION.ApplURL 		= "http://pay.cart.com/">
		<cfelse>
			<cfset SESSION.Domain 		= "https://www.MyCartFund.org/">				<!--- Name the Domain (if not Localhost)--->
			<cfset SESSION.ApplURL 		= "https://www.MyCartFund.org/">
		</cfif>

		<cfif ListContainsNoCase(QUERY_STRING, "CAST ") GT 0 OR
			ListContainsNoCase(QUERY_STRING, "DECLARE ") GT 0 OR
			ListContainsNoCase(QUERY_STRING, "CONCAT ") GT 0 OR
			ListContainsNoCase(QUERY_STRING, "SELECT ") GT 0 OR
			ListContainsNoCase(QUERY_STRING, "UNION ") GT 0 OR
			find("<",QUERY_STRING) OR find(">",QUERY_STRING) OR find("%3C",QUERY_STRING) OR find("%3E",QUERY_STRING) OR find("=-1%27",QUERY_STRING)>
			<cffile action="APPEND" file="D:\HackLog.html" output="#REMOTE_ADDR# #DateFormat(now(),'mm/dd/yyyy')# #TimeFormat(now(),'hh:mm:ss')# Mobile<BR>">
			<cfabort>
		</cfif>
	</cffunction>

	<cffunction name="onRequestEnd" output="false" returnType="void">
		<cfset elapsed = GetTickCount() - start_tick>
	</cffunction>

</cfcomponent>