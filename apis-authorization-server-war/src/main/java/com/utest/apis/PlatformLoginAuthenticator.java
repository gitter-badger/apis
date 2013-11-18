package com.utest.apis;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.surfnet.oaaas.auth.principal.AuthenticatedPrincipal;
import org.surfnet.oaaas.authentication.FormLoginAuthenticator;
import org.surfnet.oaaas.config.SpringConfiguration;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class PlatformLoginAuthenticator extends FormLoginAuthenticator
{

	private static final String	URN_ORG_APACHE_CXF_AEGIS_TYPES_URI	= "urn:org.apache.cxf.aegis.types";

	private static final String	HTTP_V4_MODEL_WEBSERVICE_UTEST_COM_URI	= "http://v4.model.webservice.utest.com";

	private static final Logger	LOG	= LoggerFactory.getLogger(PlatformLoginAuthenticator.class);
	
	private static final DocumentBuilderFactory DBF;
	
	@Autowired
	private SpringConfiguration config;
	
	static
	{
		DBF = DocumentBuilderFactory.newInstance();
		DBF.setNamespaceAware(true);
	}

	@Override
	protected boolean processForm(HttpServletRequest request)
	{
	    setAuthStateValue(request, request.getParameter(AUTH_STATE));
		try
		{
			String protoHostPath = config.getPlatformRestURL();
			if (protoHostPath.endsWith("/"))
			{
				protoHostPath = protoHostPath.substring(0, protoHostPath.length() - 1);
			}
			String query = String.format("username=%s&password=%s", URLEncoder.encode(request.getParameter("j_username"), "UTF-8"),
					URLEncoder.encode(request.getParameter("j_password"), "UTF-8"));
			HttpURLConnection huc = (HttpURLConnection)new URL(protoHostPath + "/auth/login?" + query).openConnection();
			huc.setRequestProperty("Accept", "application/xml");
			huc.connect();
			AuthenticatedPrincipal ap = getAuthenticatedPrincipal(request.getParameter("j_username"), huc);
			if (ap != null)
			{
			    request.getSession().setAttribute(SESSION_IDENTIFIER, ap);
				setPrincipal(request, ap);
				return true;
			}
			else
			{
				request.setAttribute("j_username", request.getParameter("j_username"));
				request.setAttribute("error", "Unable to authenticate");
				return false;
			}
		}
		catch (Exception e)
		{
			throw new RuntimeException(e);
		}
	}
	
	AuthenticatedPrincipal getAuthenticatedPrincipal(String name, HttpURLConnection huc) throws Exception
	{
		if (huc.getResponseCode() == HttpServletResponse.SC_OK)
		{
			// platform returns 200 along with an XML document detailing the user's permissions, etc. in the case
			// of successful authentication
			Document d = parsePlatformResponse(huc.getInputStream());
			AuthenticatedPrincipal ap =  new AuthenticatedPrincipal(getUserName(d), getRoles(d), getAttributes(d));
			LOG.info("Authenticated " + name + " as " + ap.getName());
			return ap;
		}
		else if (huc.getResponseCode() == HttpServletResponse.SC_UNAUTHORIZED)
		{
			LOG.info("Received 401 response from platform authenticating " + name);
			return null;
		}
		else
		{
			throw new Exception("Received " + huc.getResponseCode() + " response from platform!");
		}
	}
	
	private String getValue(Document d, String namespaceURI, String localName) throws Exception
	{
		NodeList nl = d.getElementsByTagNameNS(namespaceURI, localName);
		for (int i = 0, len = nl.getLength(); i < len; )
		{
			Node n = nl.item(i);
			String code = n.getTextContent().trim();
			if (code != null && !"".equals(code)) 
			{
				return code;
			}
			else
			{
				return null;
			}
			
		}
		throw new Exception("Can't find '" + namespaceURI + "/" + localName + "' element in platform response!");
	}
	
	String getUserName(Document d) throws Exception
	{
		return getValue(d, HTTP_V4_MODEL_WEBSERVICE_UTEST_COM_URI, "userName");
	}
	
	private List<String> getValues(Document d, String parentNamespaceURI, String parentLocalName, String namespaceURI, String localName) throws Exception
	{
		NodeList nli = d.getElementsByTagNameNS(parentNamespaceURI, parentLocalName);
		for (int i = 0, ilen = nli.getLength(); i < ilen; )
		{
			List<String> roles = new ArrayList<String>();
			Node n = nli.item(i);
			if (n instanceof Element)
			{
				Element e = (Element)n;
				NodeList nlj = e.getElementsByTagNameNS(namespaceURI, localName);
				for (int j = 0, jlen = nlj.getLength(); j < jlen; j++)
				{
					Node nj = nlj.item(j);
					String roleId = nj.getTextContent().trim();
					if (roleId != null && !"".equals(roleId)) 
					{
						roles.add(roleId);
					}
				}
			}
			return roles;
		}
		throw new Exception("Can't find '" + namespaceURI + "/" + localName + "' element in platform response!");
	}
	
	List<String> getRoles(Document d) throws Exception
	{
		return getValues(d, HTTP_V4_MODEL_WEBSERVICE_UTEST_COM_URI, "roles", URN_ORG_APACHE_CXF_AEGIS_TYPES_URI, "int");
	}

	Document parsePlatformResponse(InputStream is) throws Exception
	{
		DocumentBuilder db = DBF.newDocumentBuilder();
		return db.parse(is);
	}
	
	Map<String, String> getAttributes(Document d) throws Exception
	{
		Map<String, String> attributes = new HashMap<String, String>();
		String[] attributeNames = { "appKey", "authDate", "chatUUID", "code", "impsersonatedUserId", "ipAddress", "token", "userId" };
		for (String attributeName : attributeNames)
		{
			String attributeValue = getValue(d, HTTP_V4_MODEL_WEBSERVICE_UTEST_COM_URI, attributeName);
			if (attributeValue != null)
			{
				attributes.put(attributeName, attributeValue);
			}
		}

		List<String> features = getValues(d, HTTP_V4_MODEL_WEBSERVICE_UTEST_COM_URI, "applicationFeatures", URN_ORG_APACHE_CXF_AEGIS_TYPES_URI, "string");
		attributes.put("applicationFeatures", StringUtils.join(features, ","));
		
		List<String> grantedAuthorities = getValues(d, HTTP_V4_MODEL_WEBSERVICE_UTEST_COM_URI, "grantedAuthorities", URN_ORG_APACHE_CXF_AEGIS_TYPES_URI, "string");
		attributes.put("grantedAuthorities", StringUtils.join(grantedAuthorities, ","));

		return attributes;
	}
	
}
