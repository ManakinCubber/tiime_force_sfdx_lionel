/*
 * @author Jérémy LAMBERT (jeremy.lambert@tiime.fr)
 * @date 11/02/2019 (dd/mm/yyyy)
 * @description Mock Class for JingleTiime testing (WS05_JingleTiime)
 */
@isTest
global with sharing class MockHttpResponse_Jingle implements HttpCalloutMock {

	private boolean successAuth;
	private boolean successJingle;
	private boolean updateJingleSuccessOnAuth;
	private String triggerId;

	global MockHttpResponse_Jingle(boolean successAuth, boolean successJingle, String triggerId) {
		this.successAuth = successAuth;
		this.successJingle = successJingle;
		this.triggerId = triggerId;
		this.updateJingleSuccessOnAuth = false;
	}

	global void setSuccessAuth(boolean successAuth) {
		this.successAuth = successAuth;
	}

	global void setSuccessJingle(boolean successJingle) {
		this.successJingle = successJingle;
	}

	global void setUpdateJingleSuccessOnAuth(boolean updateJingleSuccessOnAuth) {
		this.updateJingleSuccessOnAuth = updateJingleSuccessOnAuth;
	}

	global HTTPResponse respond(HttpRequest request) {
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');

		if(request.getEndpoint() == 'callout:JingleTiimeToken') {
			if(successAuth) {
				res.setStatusCode(200);
				res.setBody(buildAuthResponseBody());
				if(updateJingleSuccessOnAuth) {
					successJingle = true;
				}
			} else {
				res.setStatusCode(401);
				res.setBody(buildAuthFailureBody());
				if(updateJingleSuccessOnAuth) {
					successJingle = false;
				}
			}
		} else if(request.getEndpoint().endsWith('/notify/' + triggerId)) {
			if(successJingle) {
				res.setStatusCode(204);
				res.setBody('');
			} else {
				res.setStatusCode(401);
				res.setBody('{"message": "Unauthenticated."}');
			}
		} else {
			throw new TestException('Invalid endpoint: ' + request.getEndpoint());
		}
		
		return res;
	}

	private String buildAuthResponseBody() {
		String body = '{';
		body += '"token_type": "Bearer",';
		body += '"expires_in": 31536000,';
		body += '"access_token": "azeiofusdhfkgsdyg",';
		body += '"refresh_token": "dqsuidhuifhsdyfgd"';
		body += '}';
		return body;
	}

	private String buildAuthFailureBody() {
		String body = '{';
		body += '"error": "invalid_credentials",';
		body += '"message": "The user credentials were incorrect."';
		body += '}';
		return body;
	}
}