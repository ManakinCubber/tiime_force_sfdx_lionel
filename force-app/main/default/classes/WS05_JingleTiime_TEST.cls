/*
 * @author Jérémy LAMBERT (jeremy.lambert@tiime.fr)
 * @date 11/02/2019 (dd/mm/yyyy)
 * @description Test class for WS05_JingleTiime
 */
@isTest
private class WS05_JingleTiime_TEST {
	
	private static final String TRIGGER_ID = 'triggerid';

	@isTest static void testSendTrigger() {
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse_Jingle(true, true, TRIGGER_ID));
		Test.startTest();

		WS05_JingleTiime ws = new WS05_JingleTiime();
		ws.sendTrigger(TRIGGER_ID);

		ws.sendTrigger(TRIGGER_ID); // Send second trigger to check when already authenticated 

		Test.stopTest();
	}

	@isTest static void testSendTriggerInvocable() {
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse_Jingle(true, true, TRIGGER_ID));
		Test.startTest();
		List<String> params = new List<String>();
		params.add(TRIGGER_ID);
		WS05_JingleTiime.triggerJingle(params);
		Test.stopTest();
	}

	@isTest static void testAlreadyAuthenticated() {
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse_Jingle(true, true, TRIGGER_ID));
		Test.startTest();
		Cache.Org.put('local.AuthTokens.jingletiime', 'temptoken', 172800);
		WS05_JingleTiime ws = new WS05_JingleTiime();
		Test.stopTest();
	}

	@isTest static void testAuthErrorOnConstruct() {
		boolean hasError = false;
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse_Jingle(false, true, TRIGGER_ID));
		Test.startTest();
		try {
			WS05_JingleTiime ws = new WS05_JingleTiime();
		} catch(AuthException e) {
			hasError = true;
		}
		Test.stopTest();
		System.assertEquals(true, hasError);
	}

	@isTest static void testAuthErrorOnJingle() {
		boolean hasError = false;
		MockHttpResponse_Jingle mock = new MockHttpResponse_Jingle(true, false, TRIGGER_ID);
		Test.setMock(HttpCalloutMock.class, mock);
		Test.startTest();

		WS05_JingleTiime ws = new WS05_JingleTiime();
		try {
			mock.setSuccessAuth(false);
			ws.sendTrigger(TRIGGER_ID);
		} catch(AuthException e) {
			hasError = true;
		}

		Test.stopTest();
		System.assertEquals(true, hasError);
	}

	@isTest static void testAuthOnJingle() {
		boolean hasError = false;
		MockHttpResponse_Jingle mock = new MockHttpResponse_Jingle(true, false, TRIGGER_ID);
		mock.setUpdateJingleSuccessOnAuth(true);
		Test.setMock(HttpCalloutMock.class, mock);
		Test.startTest();

		WS05_JingleTiime ws = new WS05_JingleTiime();
		try {
			ws.sendTrigger(TRIGGER_ID);
		} catch(AuthException e) {
			hasError = true;
		}

		Test.stopTest();
		System.assertEquals(false, hasError);
	}
}