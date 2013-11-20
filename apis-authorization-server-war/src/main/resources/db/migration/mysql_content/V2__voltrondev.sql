/**
 * resource server and client definitions for voltrondev.utest.com
 */

REPLACE INTO resourceserver
(id,creationDate,modificationDate,contactEmail,contactName,description,resourceServerKey,resourceServerName,owner,secret,thumbNailUrl)
VALUES
(99997,current_date,current_date,'sysops@utest.com','uTest Sysops','voltrondev.utest.com','voltrondev.utest.com','voltrondev.utest.com','sysops@utest.com','wQs!xzx9=',NULL);

REPLACE INTO ResourceServer_scopes
VALUES
(99997, 'API'),
(99997, 'SSO');

REPLACE INTO resourceserver
(id,creationDate,modificationDate,contactEmail,contactName,description,resourceServerKey,resourceServerName,owner,secret,thumbNailUrl)
VALUES
(99998,current_date,current_date,'sysops@utest.com','uTest Sysops','securitytest.utest.com','securitytest.utest.com','securitytest.utest.com','sysops@utest.com','O8^jsdw1',NULL);

REPLACE INTO ResourceServer_scopes
VALUES
(99998, 'SSO'),
(99997, 'API');

REPLACE INTO client
(id,creationDate,modificationDate,clientId,contactEmail,contactName,description,expireDuration,clientName,allowedImplicitGrant,allowedClientCredentials,secret,skipConsent,includePrincipal,thumbNailUrl,useRefreshTokens,resourceserver_id)
VALUES
(99997,current_date,current_date,'browser','sysops@utest.com','uTest Sysops','browser','86400','browser',1,0,NULL,0,1,NULL,0,99997);

REPLACE INTO Client_scopes
VALUES
(99997, 'SSO');
