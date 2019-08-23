@isTest
private class LTC17_LeadBackController_TEST {

	static testMethod void testBackLeadFromStart() {
		Id queueId = [SELECT Id FROM Group WHERE Type = :Constants.FILE_ATTENTE_OBJECT_TYPE AND DeveloperName = :Constants.FILE_ATTENTE_CALL1_DEV_NAME].Id;
		Lead lead = AP04_Factory.newWebLeadsFactory(1)[0];
		lead.Status = 'Call 2'; // Prevent jingle tiime from triggering
		insert lead;

		Start__c start = AP04_Factory.startFactory('testCompany', lead.Id);
		start.Crea__c = lead.Id;
		insert start;

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse_Jingle(true, true, Constants.WS_JINGLE_TIIME_TRIGGER_ID_TEST));

		Test.startTest();
		LTC17_LeadBackController.backLeadFromStart(start.Id, 'ongoing');
		lead = [SELECT Id,Type_de_renvoi__c,OwnerId FROM Lead WHERE Id = :lead.Id];
		System.assertEquals(Constants.LEAD_TYPE_RENVOI_EN_COURS, lead.Type_de_renvoi__c);

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse_Jingle(true, true, Constants.WS_JINGLE_TIIME_TRIGGER_ID_TEST));
		LTC17_LeadBackController.backLeadFromStart(start.Id, 'castingError');
		Test.stopTest();

		lead = [SELECT Id,Type_de_renvoi__c,OwnerId FROM Lead WHERE Id = :lead.Id];
		System.assertEquals(Constants.LEAD_TYPE_RENVOI_ERREUR_CASTING, lead.Type_de_renvoi__c);

		System.assertEquals(queueId, lead.OwnerId);
	}

	static testMethod void testBackLeadFromTransfer() {
		Id queueId = [SELECT Id FROM Group WHERE Type = :Constants.FILE_ATTENTE_OBJECT_TYPE AND DeveloperName = :Constants.FILE_ATTENTE_CALL1_DEV_NAME].Id;
		Lead lead = AP04_Factory.newWebLeadsFactory(1)[0];
		lead.Status = 'Call 2'; // Prevent jingle tiime from triggering
		insert lead;

		Transfert__c transfer = new Transfert__c(Lead__c = lead.id);
		insert transfer;

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse_Jingle(true, true, Constants.WS_JINGLE_TIIME_TRIGGER_ID_TEST));

		Test.startTest();
		LTC17_LeadBackController.backLeadFromTransfer(transfer.Id, 'ongoing');
		lead = [SELECT Id,Type_de_renvoi__c,OwnerId FROM Lead WHERE Id = :lead.Id];
		System.assertEquals(Constants.LEAD_TYPE_RENVOI_EN_COURS, lead.Type_de_renvoi__c);
		System.assertEquals(queueId, lead.OwnerId);

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse_Jingle(true, true, Constants.WS_JINGLE_TIIME_TRIGGER_ID_TEST));
		LTC17_LeadBackController.backLeadFromTransfer(transfer.Id, 'castingError');
		Test.stopTest();

		lead = [SELECT Id,Type_de_renvoi__c,OwnerId FROM Lead WHERE Id = :lead.Id];
		System.assertEquals(Constants.LEAD_TYPE_RENVOI_ERREUR_CASTING, lead.Type_de_renvoi__c);
		System.assertEquals(queueId, lead.OwnerId);
	}

	static testMethod void testBackLeadInvalidId() {
		Boolean hasError = false;
		Lead lead = AP04_Factory.newWebLeadsFactory(1)[0];
		insert lead;

		Test.startTest();
		try {
			Test.setMock(HttpCalloutMock.class, new MockHttpResponse_Jingle(true, true, Constants.WS_JINGLE_TIIME_TRIGGER_ID_TEST));
			LTC17_LeadBackController.backLeadFromStart(lead.Id, 'ongoing');
		} catch(AuraHandledException e) {
			hasError = true;
		}

		System.assertEquals(true, hasError);

		hasError = false;
		try {
			Test.setMock(HttpCalloutMock.class, new MockHttpResponse_Jingle(true, true, Constants.WS_JINGLE_TIIME_TRIGGER_ID_TEST));
			LTC17_LeadBackController.backLeadFromTransfer(lead.Id, 'ongoing');
		} catch(AuraHandledException e) {
			hasError = true;
		}

		System.assertEquals(true, hasError);

		hasError = false;
		try {
			Start__c start = AP04_Factory.startFactory('testCompany', lead.Id);
			insert start;
			Test.setMock(HttpCalloutMock.class, new MockHttpResponse_Jingle(true, true, Constants.WS_JINGLE_TIIME_TRIGGER_ID_TEST));
			LTC17_LeadBackController.backLead(start.Id, 'ongoing');
		} catch(AuraHandledException e) {
			hasError = true;
		}

		System.assertEquals(true, hasError);

		Test.stopTest();
	}
}