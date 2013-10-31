package org.surfnet.oaaas.authentication;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

import javax.inject.Named;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.BasicHttpParams;
import org.surfnet.oaaas.auth.AbstractAuthenticator;
import org.surfnet.oaaas.auth.principal.AuthenticatedPrincipal;

/**
* {@link AbstractAuthenticator} that redirects to a form. Note that other
* implementations can go wild because they have access to the
* {@link HttpServletRequest} and {@link HttpServletResponse}.
* 
*  NOTE: This class is a modified copy of FormLoginAuthenticator. Extending
*  that class was tried but just ended up copying
*/
@Named("utestFormAuthenticator")
public class UtestFormLoginAuthenticator extends FormLoginAuthenticator
{
	/**
	 * 
	 * Validate the user against the platform.
	 * 
	 * @param request
	 *          the {@link HttpServletRequest}
	 */
	@Override
	protected void processForm(final HttpServletRequest request)
	{
		setAuthStateValue(request, request.getParameter(AUTH_STATE));
		AuthenticatedPrincipal principal = new AuthenticatedPrincipal(request.getParameter("j_username"));

		//Trying to get parameters
		String username = request.getParameter("j_username");
		String password = request.getParameter("j_password");

		//TODO: validate the user here

		try
		{
			DefaultHttpClient httpClient = new DefaultHttpClient();
			//This just keeps pulling down the actual login page
			//			HttpGet getRequest = new HttpGet("https://my.utest.com/u/platform/services/v4/rest/auth/login");

			//This gets a 401 at this point, with the username and password params
			//			HttpGet getRequest = new HttpGet("https://my.utest.com/platform/services/v4/rest/auth/login");

			//This one: gets us through with no real pass check, and feels really hacky
			//TODO: get the username and password entered from the form
			//TODO: is there a better way to do this than just string concat?
			HttpGet getRequest = new HttpGet("https://my.utest.com/platform/services/v4/rest/auth/login?username=" + username + "&password=" + password);

			//Bad pass fails by throwing out a 401:
			//			HttpGet getRequest = new HttpGet("https://my.utest.com/platform/services/v4/rest/auth/login?username=llowry@utest.com&password=Push30Squad_bad");

			BasicHttpParams params = new BasicHttpParams();

			//TODO: What's missing here? I need to get the creds over to mimic the cookie grab process, but I'm
			//just pulling down a copy of the web page
			//NEXT: Review the curl flags, maybe they're doing something I'm missing
			params.setParameter("username", "llowry@utest.com");
			params.setParameter("password", "Push30Squad");

			//			getRequest.setParams(params);

			//			getRequest.addHeader("accept", "application/json");

			HttpResponse response = httpClient.execute(getRequest);

			if (response.getStatusLine().getStatusCode() != 200)
			{
				throw new RuntimeException("Failed : HTTP error code : " + response.getStatusLine().getStatusCode());
			}

			BufferedReader br = new BufferedReader(new InputStreamReader((response.getEntity().getContent())));

			String output;
			System.out.println("Output from Server .... \n");
			while ((output = br.readLine()) != null)
			{
				System.out.println(output);
			}

			httpClient.getConnectionManager().shutdown();
		}
		catch (ClientProtocolException e)
		{
			e.printStackTrace();
		}
		catch (IOException e)
		{
			e.printStackTrace();
		}

		//Something is going on that's removing the AUTH_STATE from the request?
		//End user authentication testing

		request.getSession().setAttribute(SESSION_IDENTIFIER, principal);
		setPrincipal(request, principal);
	}
}
