/*
 * @author Kévin Melliand (kevin.melliand@tiime.fr)
 * @date 31/01/2019 (dd/mm/yyyy)
 * @description Mock Class allowing the test of http callout from WS02_Chronos
 */
 @isTest
global class MockHttpResponse_RequestKYC {
    
    global HTTPResponse respond(HTTPRequest req) {
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setStatusCode(200);
		String body = 'auth0|token';
		res.setBody(body);
		return res;
	}
}