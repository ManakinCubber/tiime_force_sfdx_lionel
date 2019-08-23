/*
 * @author Jérémy LAMBERT (jeremy.lambert@tiime.fr)
 * @date 18/12/2018 (dd/mm/yyyy)
 * @description Mock Class allowing the test of http callout from WS02_Chronos
 */
@isTest
global class MockHttpResponse_SendJson implements HttpCalloutMock {

	global HTTPResponse respond(HTTPRequest req) {
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setStatusCode(200);
		String body = '{ "company": {"id": 2, "unhandled": true}, "user": {"id": 1} }';
		res.setBody(body);
		return res;
	}
}