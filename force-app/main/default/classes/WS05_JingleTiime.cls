/*
 * @author Jérémy LAMBERT (jeremy.lambert@tiime.fr)
 * @date 11/02/2019 (dd/mm/yyyy)
 * @description Class to call JingleTiime webservice to trigger a jingle on
 * specific events.
 */
public without sharing class WS05_JingleTiime extends WS01_Generic {

	private AuthJingleTiime__mdt auth;
	private String token;
	private Integer retry;

	public WS05_JingleTiime() {
		retry = 0;
		List<AuthJingleTiime__mdt> authList = [SELECT client_id__c, client_secret__c, host__c FROM AuthJingleTiime__mdt WHERE DeveloperName=:Label.JingleTiimeEnvironment];

		if(!authList.isEmpty()) {
			auth = authList[0];
		} else {
			throw new AuthException('No Jingle Tiime Auth found.');
		}

		if (Cache.Org.contains('local.AuthTokens.jingletiime')) {
			token = (String) Cache.Org.get('local.AuthTokens.jingletiime');
		} else {
			authenticate();
		}
	}

	private void authenticate() {
		HttpResponse res;
		Http http = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint('callout:JingleTiimeToken');
		req.setMethod('POST');
		req.setHeader('Content-Type', 'Content-type: application/json; charset=utf-8');
		req.setHeader('Accept', 'application/json');
		req.setBody(buildAuthBody());

		req.setTimeout(60000);

		res = http.send(req);

		Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

		if(res.getStatusCode() != 200) {
			String error = m.get('error').toString();
			String message = m.get('message').toString();
			String hintMessage = m.containsKey('hint') ? m.get('hint').toString() : '';
			System.debug('### WS05_JingleTiime.authenticate HttpRequest failure. ' + error + ': ' + message + ' ' + hintMessage);

			throw new AuthException(message);
		}

		token = m.get('access_token').toString();
		Cache.Org.put('local.AuthTokens.jingletiime', token, 172800); // 48h
	}

	private String buildAuthBody() {
		String body = '{';
		body += '"grant_type": "password",';
		body += '"client_id": "' + auth.client_id__c + '",';
		body += '"client_secret": "' + auth.client_secret__c + '",';
		body += '"username": "{!$Credential.Username}",';
		body += '"password": "{!$Credential.Password}"';
		body += '}';
		return body;
	}

	public void sendTrigger(String triggerId) {
		setRequest(auth);
		this.req.setEndpoint(auth.host__c + 'api/notify/' + triggerId);
		this.req.setHeader('Accept', 'application/json');
		Http http = new Http();
		HttpResponse resp;

		resp = http.send(this.req);

		if(resp.getStatusCode() == 401 && retry == 0) { // Unauthenticated
			authenticate();
			retry++;
			sendTrigger(triggerId);
		} else if(resp.getStatusCode() != 204) {
			Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
			String message = m.get('message').toString();
			System.debug('### WS05_JingleTiime.sendTrigger HttpRequest failed with state ' + resp.getStatusCode() + ': ' + message);
			throw new CalloutException('JingleTiime Trigger failed with state ' + resp.getStatusCode() + ': ' + message);
		}
	}

	public override void setRequest(SObject authObject) {
		this.req = new HttpRequest();
		this.req.setHeader('Authorization', 'Bearer ' + token);
		this.req.setMethod('GET');
		this.req.setTimeout(60000);
	}

	public override HttpResponse callMock(HttpRequest request) { return null; } // TODO remove this in favor of Test.setMock

	@InvocableMethod
	public static void triggerJingle(List<String> params) {
		triggerJingleCallout(params[0]);
	}

	@future(callout=true)
	public static void triggerJingleCallout(String triggerId) {
		WS05_JingleTiime ws = new WS05_JingleTiime();
		ws.sendTrigger(triggerId);
	}

}