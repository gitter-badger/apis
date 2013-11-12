/**
 * resource server and client definitions for voltrondev.utest.com
 */

REPLACE INTO resourceserver
(id,creationDate,modificationDate,contactEmail,contactName,description,resourceServerKey,resourceServerName,owner,secret,thumbNailUrl)
VALUES
(99997,current_date,current_date,'sysops@utest.com','uTest Sysops','voltrondev.utest.com','8b47c730-58c8-4a72-bd6b-f6a2769dd104','voltrondev.utest.com','sysops@utest.com','90654a91-938a-4a98-a7ab-d0da54f42d78',NULL);

REPLACE INTO ResourceServer_scopes
VALUES
(99997, 'API');

REPLACE INTO client
(id,creationDate,modificationDate,clientId,contactEmail,contactName,description,expireDuration,clientName,allowedImplicitGrant,allowedClientCredentials,secret,skipConsent,includePrincipal,thumbNailUrl,useRefreshTokens,resourceserver_id)
VALUES
(99997,current_date,current_date,'voltrondev.utest.com','sysops@utest.com','uTest Sysops','Voltron UI (voltrondev.utest.com)','86400','voltrondev.utest.com',1,0,NULL,0,1,NULL,0,99997);

REPLACE INTO Client_scopes
VALUES
(99997, 'API');

REPLACE INTO Client_redirectUris (CLIENT_ID, element)
VALUES
(99997, 'https://voltrondev.utest.com/wsgi/api/redirect');
