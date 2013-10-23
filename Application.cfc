<cfcomponent output="false">

<cfset this.name = "gDrive" />
<cfset this.sessionManagement = true />
<cfset this.sessionTimeout = createTimeSpan(0, 0, 30, 0) />

<cffunction name="onApplicationStart" access="public" returntype="boolean" output="false">

	<cfset application.gDrive = new gDrive(
		client_id = "***",
		client_secret = "***",
		redirect_uri = REReplace("http://#cgi.server_name##cgi.script_name#", "index\.cfm$", ""),
		access_type = "offline"
	) />

	<cfreturn true />

</cffunction>


<cffunction name="onRequestStart" returntype="boolean" access="public" output="false">

	<cfif StructKeyExists(url, "updateapp")>
		<cfset onApplicationStart() />
		<cflocation url="./" addtoken="false" />
	</cfif>

	<cfreturn true />

</cffunction>

</cfcomponent>
