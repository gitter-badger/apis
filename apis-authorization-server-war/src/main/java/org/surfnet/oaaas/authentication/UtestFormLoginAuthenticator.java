package org.surfnet.oaaas.authentication;

import java.io.IOException;

import javax.inject.Named;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
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

		//TODO: Password ends up in the open here.
		String username = request.getParameter("j_username");
		String password = request.getParameter("j_password");

		try
		{
			StringBuilder loginUrlBuilder = new StringBuilder();
			loginUrlBuilder.append("https://my.utest.com/platform/services/v4/rest/auth/login?username=");
			loginUrlBuilder.append(username);
			loginUrlBuilder.append("&password=");
			loginUrlBuilder.append(password);

			DefaultHttpClient httpClient = new DefaultHttpClient();
			HttpGet getRequest = new HttpGet(loginUrlBuilder.toString());
			HttpResponse response = httpClient.execute(getRequest);

			if (response.getStatusLine().getStatusCode() != 200)
			{
				throw new RuntimeException("Failed : HTTP error code : " + response.getStatusLine().getStatusCode());
			}

			//			BufferedReader br = new BufferedReader(new InputStreamReader((response.getEntity().getContent())));
			//			String output;
			//			System.out.println("Output from Server .... \n");
			//			while ((output = br.readLine()) != null)
			//			{
			//				System.out.println(output);
			//			}

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

		request.getSession().setAttribute(SESSION_IDENTIFIER, principal);
		setPrincipal(request, principal);
	}
}
