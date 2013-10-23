<cfcomponent output="false">

<cfset variables.instance = {} />

<cffunction name="init" returntype="any" access="public" output="false">
	<cfargument name="client_id" type="string" required="true" />
	<cfargument name="client_secret" type="string" required="true" />
	<cfargument name="redirect_uri" type="string" required="true" />
	<cfargument name="scope" type="string" required="false" default="https://www.googleapis.com/auth/drive" />
	<cfargument name="access_type" type="string" required="false" default="online" />
	<cfargument name="auth_endpoint" type="string" required="false" default="https://accounts.google.com/o/oauth2/" />

	<cfset variables.instance.client_id = arguments.client_id />
	<cfset variables.instance.client_secret = arguments.client_secret />
	<cfset variables.instance.redirect_uri = arguments.redirect_uri />
	<cfset variables.instance.scope = arguments.scope />
	<cfset variables.instance.access_type = arguments.access_type />
	<cfset variables.instance.auth_endpoint = arguments.auth_endpoint />

	<cfreturn this />

</cffunction>

<cffunction name="getLoginUrl" returntype="string" access="public" output="false">

	<cfreturn variables.instance.auth_endpoint & "auth?"
		& "&client_id=" & variables.instance.client_id
		& "&redirect_uri=" & variables.instance.redirect_uri
		& "&scope=" & variables.instance.scope
		& "&access_type=" & variables.instance.access_type
		& "&response_type=code" />

</cffunction>

<cffunction name="getAccessToken" returntype="struct" access="public" output="false">
	<cfargument name="code" type="string" required="true" />

	<cfset local.rsp = {
		"success" = false,
		"error" = "",
		"data" = ""
	} />
	<cfset local.callUrl = variables.instance.auth_endpoint & "token" />

	<cfhttp method="post" url="#local.callUrl#" result="local.http">
		<cfhttpparam type="formfield" name="code" value="#arguments.code#" />
		<cfhttpparam type="formfield" name="client_id" value="#variables.instance.client_id#" />
		<cfhttpparam type="formfield" name="client_secret" value="#variables.instance.client_secret#" />
		<cfhttpparam type="formfield" name="redirect_uri" value="#variables.instance.redirect_uri#" />
		<cfhttpparam type="formfield" name="grant_type" value="authorization_code" />
	</cfhttp>

	<cfif Find("200", local.http.StatusCode)>
		<cfset local.rsp.success = true />
		<cfset local.rsp.data = DeserializeJSON(local.http.FileContent) />
	<cfelse>
		<!--- TODO: parse response and return error --->
	</cfif>

	<cfreturn local.rsp />

</cffunction>

<cffunction name="updateAccessToken" returntype="struct" access="public" output="false">
	<cfargument name="refresh_token" type="string" required="true" />

	<cfset local.rsp = {
		"success" = false,
		"error" = "",
		"data" = ""
	} />
	<cfset local.callUrl = variables.instance.auth_endpoint & "token" />

	<cfhttp method="post" url="#local.callUrl#" result="local.http">
		<cfhttpparam type="formfield" name="refresh_token" value="#arguments.refresh_token#" />
		<cfhttpparam type="formfield" name="client_id" value="#variables.instance.client_id#" />
		<cfhttpparam type="formfield" name="client_secret" value="#variables.instance.client_secret#" />
		<cfhttpparam type="formfield" name="grant_type" value="refresh_token" />
	</cfhttp>

	<cfif Find("200", local.http.StatusCode)>
		<cfset local.rsp.success = true />
		<cfset local.rsp.data = DeserializeJSON(local.http.FileContent) />
	<cfelse>
		<!--- TODO: parse response and return error --->
	</cfif>

	<cfreturn local.rsp />

</cffunction>

<cffunction name="revokeAccess" returntype="struct" access="public" output="false">
	<cfargument name="access_token" type="string" required="true" />

	<cfset local.rsp = {
		"success" = false,
		"error" = "",
		"data" = ""
	} />
	<cfset local.callUrl = variables.instance.auth_endpoint & "revoke?token=" & arguments.access_token />

	<cfhttp method="get" url="#local.callUrl#" result="local.http" />

	<cfif Find("200", local.http.StatusCode)>
		<cfset local.rsp.success = true />
	<cfelse>
		<!--- TODO: parse response and return error --->
	</cfif>

	<cfreturn local.rsp />

</cffunction>

<cffunction name="listFiles" access="public" output="false">
	<cfargument name="access_token" type="string" required="true" />
	<cfargument name="token_type" type="string" required="true" />

	<cfset local.rsp = {
		"success" = false,
		"error" = "",
		"data" = ""
	} />
	<cfset local.callUrl = "https://www.googleapis.com/drive/v2/files" />

	<cfhttp method="get" url="#local.callUrl#" result="local.http">
		<cfhttpparam type="header" name="Authorization" value="#arguments.token_type# #arguments.access_token#" />
	</cfhttp>

	<cfif Find("200", local.http.StatusCode)>
		<cfset local.rsp.success = true />
		<cfset local.rsp.data = DeserializeJSON(local.http.FileContent) />
	<cfelse>
		<!--- TODO: parse response and return error --->
	</cfif>

	<cfreturn local.rsp />

</cffunction>

</cfcomponent>
