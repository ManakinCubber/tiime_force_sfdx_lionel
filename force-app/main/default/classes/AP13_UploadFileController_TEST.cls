@isTest
private class AP13_UploadFileController_TEST {

	private static final String PARTNER_NAME = 'John';
	private static final String START_NAME   = 'John Inc.';

	@testSetup static void setup() {
		AP04_Factory.createGenericDataSample();
		List<Lead> leads = [SELECT Id FROM Lead];
		System.assert(!leads.isEmpty());
		Start__c start = AP04_Factory.startFactory(START_NAME, leads.get(0).Id);
		insert start;
		insert AP04_Factory.associateFactory(PARTNER_NAME, start.Id);
	}

	@isTest static void testGetFilesStartEmpty() {
		Start__c start = [SELECT Id FROM Start__c WHERE CompanyName__c = :START_NAME LIMIT 1];
		List<ContentDocumentLink> files = AP13_UploadFileController.getFiles(start.Id);
		System.assertEquals(true, files.isEmpty());
	}

	@isTest static void testGetFilesPartnerEmpty() {
		Associate__c partner = [SELECT Id FROM Associate__c WHERE FirstName__c = :PARTNER_NAME LIMIT 1];
		List<ContentDocumentLink> files = AP13_UploadFileController.getFiles(partner.Id);
		System.assertEquals(true, files.isEmpty());
	}

	@isTest static void testGetFilesStart() {
		Start__c start = [SELECT Id FROM Start__c WHERE CompanyName__c = :START_NAME LIMIT 1];
		start.ID_Registered_Office_Owner__c = Utils.generateDocument('Registered_Office_Owner.txt', 'Registered_Office_Owner', start.Id, 'content');

		update start;

		Test.startTest();
		List<ContentDocumentLink> files = AP13_UploadFileController.getFiles(start.Id);
		Test.stopTest();

		System.assertEquals(1, files.size());
		System.assertEquals('ID_Registered_Office_Owner__c', files.get(0).ContentDocument.Title);
	}

	@isTest static void testGetFilesPartner() {
		Associate__c partner  = [SELECT Id FROM Associate__c WHERE FirstName__c = :PARTNER_NAME LIMIT 1];
		partner.ID_Id_Card__c = Utils.generateDocument('ID_CARD.txt', 'ID_CARD', partner.Id, 'ID card content');

		update partner;

		Test.startTest();
		List<ContentDocumentLink> files = AP13_UploadFileController.getFiles(partner.Id);
		Test.stopTest();
		
		System.assertEquals(1, files.size());
		System.assertEquals('ID_Id_Card__c', files.get(0).ContentDocument.Title);
	}

	@isTest static void testUpdateStart() {
		Start__c start = [SELECT Id FROM Start__c WHERE CompanyName__c = :START_NAME LIMIT 1];
		Id docId = Utils.generateDocument('Registered_Office_Lessee.txt', 'Registered_Office_Lessee', start.Id, 'content');

		Test.startTest();
		AP13_UploadFileController.updateDocumentId(start.Id, 'ID_Registered_Office_Lessee__c', docId);
		Test.stopTest();

		start = [SELECT Id,ID_Registered_Office_Lessee__c FROM Start__c WHERE Id = :start.Id];

		System.assertEquals(docId, start.ID_Registered_Office_Lessee__c);
	}

	@isTest static void testUpdateStartInvalid() {
		Start__c start = [SELECT Id FROM Start__c WHERE CompanyName__c = :START_NAME LIMIT 1];
		Id docId = Utils.generateDocument('Registered_Office_Lessee.txt', 'Registered_Office_Lessee', start.Id, 'content');
		boolean hasError = false;

		Test.startTest();
		try {
			AP13_UploadFileController.updateDocumentId(start.Id, 'Invalid field', docId);
		} catch(Exception e) {
			System.assertEquals('System.AuraHandledException', e.getTypeName());
			System.assertEquals('Invalid field provided.', e.getMessage());
			hasError = true;
		}
		Test.stopTest();

		System.assertEquals(true, hasError);
	}

	@isTest static void testUpdatePartner() {
		Associate__c partner = [SELECT Id FROM Associate__c WHERE FirstName__c = :PARTNER_NAME LIMIT 1];
		Id docId = Utils.generateDocument('ID_CARD.txt', 'ID_CARD', partner.Id, 'ID card content');

		Test.startTest();
		AP13_UploadFileController.updateDocumentId(partner.Id, 'ID_Id_Card__c', docId);
		Test.stopTest();

		partner = [SELECT Id,ID_Id_Card__c FROM Associate__c WHERE Id = :partner.Id];

		System.assertEquals(docId, partner.ID_Id_Card__c);
	}

	@isTest static void testUpdatePartnerInvalid() {
		Associate__c partner = [SELECT Id FROM Associate__c WHERE FirstName__c = :PARTNER_NAME LIMIT 1];
		Id docId = Utils.generateDocument('ID_CARD.txt', 'ID_CARD', partner.Id, 'ID card content');
		boolean hasError = false;

		Test.startTest();
		try {
			AP13_UploadFileController.updateDocumentId(partner.Id, 'Invalid field', docId);
		} catch(Exception e) {
			System.assertEquals('System.AuraHandledException', e.getTypeName());
			System.assertEquals('Invalid field provided.', e.getMessage());
			hasError = true;
		}
		Test.stopTest();

		System.assertEquals(true, hasError);
	}


}