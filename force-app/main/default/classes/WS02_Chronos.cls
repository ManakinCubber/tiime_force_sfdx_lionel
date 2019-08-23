public class WS02_Chronos {

	public static String errorMsg;

	@future(callout=true)
	public static void sendFileChronosAsync(String authToken, String cache, String contentType, String contentDisposition, String endpoint, Blob body) {
		sendFileChronos(authToken,cache,contentType,contentDisposition,endpoint,body);
	}

	public static void sendAccountToTreezorViaChronos(String chronosAccountId) {
    	AuthChronos__mdt auth = retrieveAuthParams();
    	String authToken = getToken(auth);
    	System.debug(authToken);
    	Http http = new Http();
    	HttpRequest req = new HttpRequest();
    	req.setMethod('POST');
    	req.setHeader('Authorization','Bearer '+authToken);
    	req.setTimeout(60000);
    	req.setEndpoint(auth.url_chronos_api__c + '/v1/wallet/companies/' + chronosAccountId + '/request_kyc?_HttpMethod=PATCH');
    	System.debug(req);
    	
	    HttpResponse res;
	    if(Test.isRunningTest()) {
	       	MockHttpResponse_RequestKYC mock = new MockHttpResponse_RequestKYC();
	       	res = mock.respond(req);
	    } else {
	      	res = http.send(req);
	    }
	      	
	    if(res.getStatusCode() != 200) {
	    	String resBody = res.getBody();
		    Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(resBody);
		    throw new AuraHandledException(m.get('error_description').toString());
		}
    }

	/*
	 * @author LUA Wailly (Wailly.lua@carrenet.com)
	 * @date 14/09/2018 (dd/mm/yyyy)
	 * @description Get OAuth secure token to call Chronos API
	 */
	public static String getToken(Authchronos__mdt Auth) {
		HttpResponse res;

		ChronosTokenRequestBody reqBody = new ChronosTokenRequestBody(
			Auth.grant_type__c, Auth.client_id__c, Auth.client_secret__c, Auth.audience__c, '{!$Credential.Username}', '{!$Credential.Password}', Auth.realm__c
		);

		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint('callout:ChronosToken');
		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/json');//'application/x-www-form-urlencoded'
		req.setBody(reqBody.generateJSON());
		System.debug('### WS02_Chronos.getToken body='+req.getBody());

		if(Test.isRunningTest()) {
			MockHttpResponse_SendFile mock = new MockHttpResponse_SendFile();
			res = mock.respondAuth(req);
		} else {
			res = h.send(req);
		}
		String token = '';
		String result = res.getBody();
		System.debug('### WS02_Chronos.getToken result='+result);
		Map<String, Object> mapResult = (Map<String, Object>)JSON.deserializeUntyped(result);
		if(res.getStatusCode() == 200) {
			token = (String)mapResult.get('access_token');
		} else {
			errorMsg = mapResult.get('error_description').toString();
			System.debug('### WS02_Chronos.getToken SendFile HttpRequest failure errorMsg=='+errorMsg);
			throw new AuraHandledException(errorMsg);
		}

		return token;
	}

	public class ChronosTokenRequestBody {
		private String grant_type;
		private String client_id;
		private String client_secret;
		private String audience;
		private String username;
		private String password;
		private String realm;

		public ChronosTokenRequestBody(String grant_type, String client_id, String client_secret, String audience, String username, String password, String realm) {
			this.grant_type = grant_type;
			this.client_id = client_id;
			this.client_secret = client_secret;
			this.audience = audience;
			this.username = username;
			this.password = password;
			this.realm = realm;
		}

		public String generateJSON() {
			return JSON.serialize(this);
		}
	}

	/*
	 * @author LUA Wailly (Wailly.lua@carrenet.com)
	 * @date 14/09/2018 (dd/mm/yyyy)
	 * @description Call Chronos webservice to send file
	 */
	public static String sendFileChronos(String authToken, String cache, String contentType, String contentDisposition, String endpoint, Blob body) {  
		HttpResponse res;
		String result = '';

		System.debug(contentType);

		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint(endpoint);
		req.setMethod('POST');
		req.setHeader('Authorization','Bearer '+authToken);
		req.setHeader('Content-Type', contentType);
		//req.setHeader('Accept-Encoding', '*');
		//req.setHeader('Cache-Control', cache);
		//req.setHeader('Content-length', String.valueOf(body.length()));
		req.setHeader('Content-Disposition', contentDisposition);
		//req.setBody(body);
		req.setBodyAsBlob(body);
		req.setTimeout(60000);

		if(Test.isRunningTest()) {
			MockHttpResponse_SendFile mock = new MockHttpResponse_SendFile();
			res = mock.respond(req);
		} else {
			res = h.send(req);
			System.debug(res);
			System.debug(res.getStatusCode());
			System.debug(res.getStatus());
		}

		result = res.getBody();
		System.debug('### WS02_Chronos.sendFileChronos res.getStatusCode()=='+res.getStatusCode());
		if(res.getStatusCode() == 200) {
			//result = res.getBody();
		} else {
			Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(result);
			errorMsg = m.get('error_description').toString();
			System.debug('### WS02_Chronos.sendFileChronos SendFile HttpRequest failure errorMsg=='+errorMsg);

			throw new AuraHandledException(errorMsg);
		}

		System.debug('### WS02_Chronos.sendFileChronos result=='+result);
		return result;
	}

	public static String sendJsonChronos(String authToken, String cache, String endpoint, String body) {
		HttpResponse res;
		String result;
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint(endpoint);
		req.setMethod('POST');
		req.setHeader('Authorization','Bearer '+authToken);
		req.setHeader('Content-Type', 'Content-type: application/json; charset=utf-8');
		req.setBody(body);

		req.setTimeout(60000);

		if(Test.isRunningTest()) {
			MockHttpResponse_SendJson mock = new MockHttpResponse_SendJson();
			res = mock.respond(req);
		} else {
			res = h.send(req);
		}

		result = res.getBody();

		if(res.getStatusCode() != 200) {
			Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(result);
			errorMsg = m.get('error_description').toString();
			System.debug('### WS02_Chronos.sendJsonChronos HttpRequest failure errorMsg=='+errorMsg);

			throw new AuraHandledException(errorMsg);
		}

		return result;
	}

	private static AuthChronos__mdt retrieveAuthParams() {
		AuthChronos__mdt auth = null;
		AuthChronos__mdt[] authList = [SELECT audience__c,client_secret__c,client_id__c,grant_type__c,
		                               realm__c,scope__c,url_chronos_api__c
		                               FROM AuthChronos__mdt
		                               WHERE DeveloperName=:Label.ChronosEnvironement];

		if(!authList.isEmpty()) {
			auth = authList[0];
		}

		return auth;
	}

	public class tokenWrapper{
		public String token {get; set;}
	}
}