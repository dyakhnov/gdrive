<cfif StructKeyExists(url, "login")>
	<cflocation url="#application.gDrive.getLoginUrl()#" addtoken="false" />
<cfelseif StructKeyExists(url, "code")>
	<cfset auth = application.gDrive.getAccessToken(url.code) />
	<cfif auth.success>
		<cfset session["gdrive"] = auth.data />
		<cfif StructKeyExists(session.gdrive, "expires_in")>
			<cfset session.gdrive["expires"] = DateAdd("s", session.gdrive.expires_in, Now()) />
		</cfif>
		<cflocation url="./" addtoken="false" />
	<cfelse>
		<p>Authentication failed.</p>
	</cfif>
<cfelseif StructKeyExists(url, "refresh")>
	<cfif StructKeyExists(session, "gdrive")>
		<cfif StructKeyExists(session.gdrive, "refresh_token")>
			<cfset rt = session.gdrive.refresh_token />
			<cfset auth = application.gDrive.updateAccessToken(rt) />
			<cfif auth.success>
				<cfset session["gdrive"] = auth.data />
				<cfset session.gdrive["refresh_token"] = rt />
				<cfif StructKeyExists(session.gdrive, "expires_in")>
					<cfset session.gdrive["expires"] = DateAdd("s", session.gdrive.expires_in, Now()) />
				</cfif>
				<cflocation url="./" addtoken="false" />
			<cfelse>
				<p>Refresh failed.</p>
			</cfif>
		<cfelse>
			<p>No token to refresh.</p>
		</cfif>
	<cfelse>
		<p>No session.</p>
	</cfif>
<cfelseif StructKeyExists(url, "logout")>
	<cfif StructKeyExists(session, "gdrive")>
		<cfset rsp = application.gDrive.revokeAccess(session.gdrive.access_token) />
		<cfif rsp.success>
			<cfset StructDelete(session, "gdrive") />
			<cflocation url="./" addtoken="false" />
		<cfelse>
			<p>Logout failed.</p>
		</cfif>
	<cfelse>
		<p>No session.</p>
	</cfif>
</cfif>

<cfoutput>

<ul>
	<li><a href="./?updateapp">Reload App</a></li>
	<cfif StructKeyExists(session, "gdrive")>
		<cfif StructKeyExists(session.gdrive, "refresh_token")>
			<li><a href="./?refresh">Refresh Token</a></li>
		</cfif>
		<li><a href="./?logout">Logout</a></li>
	<cfelse>
		<li><a href="./?login">Login</a></li>
	</cfif>
</ul>

<cfif StructKeyExists(session, "gdrive")>
	<p>Here is your gDrive session:</p>
	<cfdump var="#session.gdrive#">
	<cfflush>
	<cfset rsp = application.gDrive.listFiles(
		session.gdrive.access_token,
		session.gdrive.token_type
	) />
	<cfif rsp.success>
		<p>Here are your files:</p>
		<ul>
			<cfloop index="f" array="#rsp.data.items#">
				<li><a href="#f.alternateLink#" target="_blank">#f.title#</a> (#ArrayToList(f.ownerNames, ", ")#)</li>
			</cfloop>
		</ul>
	<cfelse>
		<p>Can't list your files.</p>
	</cfif>
</cfif>

</cfoutput>
