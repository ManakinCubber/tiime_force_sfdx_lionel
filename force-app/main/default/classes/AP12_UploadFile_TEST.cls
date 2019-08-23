@isTest
private class AP12_UploadFile_TEST {

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

	@isTest static void testIdCardDeleted() {
		Associate__c partner = generateAssociate();

		ContentDocument idCard    = [SELECT Id FROM ContentDocument WHERE Id = :partner.ID_Id_Card__c];
		ContentDocument vitalCard = [SELECT Id FROM ContentDocument WHERE Id = :partner.ID_Vital_Card__c];

		Test.startTest();
		Database.DeleteResult result = Database.delete(idCard, false);
		Test.stopTest();

		System.assert(result.isSuccess());
		System.assert(result.getErrors().isEmpty());

		partner = [SELECT Id,ID_Id_Card__c,ID_Vital_Card__c FROM Associate__c WHERE Id = :partner.Id];
		System.assertEquals(null, partner.ID_Id_Card__c);
		System.assertEquals(vitalCard.Id, partner.ID_Vital_Card__c);
	}

	@isTest static void testKbisDeleted() {
		Associate__c partner = generateAssociate();

		ContentDocument kbis = [SELECT Id FROM ContentDocument WHERE Id = :partner.ID_Kbis__c];

		Test.startTest();
		Database.DeleteResult result = Database.delete(kbis, false);
		Test.stopTest();

		System.assert(result.isSuccess());
		System.assert(result.getErrors().isEmpty());

		partner = [SELECT Id,ID_Kbis__c FROM Associate__c WHERE Id = :partner.Id];
		System.assertEquals(null, partner.ID_Kbis__c);
	}

	@isTest static void testStatusDeleted() {
		Associate__c partner = generateAssociate();

		ContentDocument status = [SELECT Id FROM ContentDocument WHERE Id = :partner.ID_Status__c];

		Test.startTest();
		Database.DeleteResult result = Database.delete(status, false);
		Test.stopTest();

		System.assert(result.isSuccess());
		System.assert(result.getErrors().isEmpty());

		partner = [SELECT Id,ID_Status__c FROM Associate__c WHERE Id = :partner.Id];
		System.assertEquals(null, partner.ID_Status__c);
	}

	@isTest static void testVitalCardDeleted() {
		Associate__c partner = generateAssociate();

		ContentDocument idCard    = [SELECT Id FROM ContentDocument WHERE Id = :partner.ID_Id_Card__c];
		ContentDocument vitalCard = [SELECT Id FROM ContentDocument WHERE Id = :partner.ID_Vital_Card__c];

		Test.startTest();
		Database.DeleteResult result = Database.delete(vitalCard, false);
		Test.stopTest();

		System.assert(result.isSuccess());
		System.assert(result.getErrors().isEmpty());

		partner = [SELECT Id,ID_Id_Card__c,ID_Vital_Card__c FROM Associate__c WHERE Id = :partner.Id];
		System.assertEquals(null, partner.ID_Vital_Card__c);
		System.assertEquals(idCard.Id, partner.ID_Id_Card__c);
	}

	@isTest static void testPartnerDocumentsDeleted() {
		Associate__c partner = generateAssociate();

		ContentDocument idCard    = [SELECT Id FROM ContentDocument WHERE Id = :partner.ID_Id_Card__c];
		ContentDocument vitalCard = [SELECT Id FROM ContentDocument WHERE Id = :partner.ID_Vital_Card__c];
		ContentDocument kbis      = [SELECT Id FROM ContentDocument WHERE Id = :partner.ID_Kbis__c];
		ContentDocument status    = [SELECT Id FROM ContentDocument WHERE Id = :partner.ID_Status__c];

		Test.startTest();
		List<Database.DeleteResult> result = Database.delete(new List<ContentDocument> {idCard, vitalCard, kbis, status}, false);
		Test.stopTest();

		for(Database.DeleteResult res : result) {
			System.assert(res.isSuccess());
			System.assert(res.getErrors().isEmpty());
		}

		partner = [SELECT Id,ID_Id_Card__c,ID_Vital_Card__c,ID_Kbis__c,ID_Status__c FROM Associate__c WHERE Id = :partner.Id];
		System.assertEquals(null, partner.ID_Id_Card__c);
		System.assertEquals(null, partner.ID_Vital_Card__c);
		System.assertEquals(null, partner.ID_Kbis__c);
		System.assertEquals(null, partner.ID_Status__c);
	}


	@isTest static void testStartRegisteredOfficeOwnerDeleted() {
		Start__c start = generateStart();

		ContentDocument registeredOfficeOwner  = [SELECT Id FROM ContentDocument WHERE Id = :start.ID_Registered_Office_Owner__c];
		ContentDocument registeredOfficeHosted = [SELECT Id FROM ContentDocument WHERE Id = :start.ID_Registered_Office_Hosted__c];
		ContentDocument registeredOfficeLessee = [SELECT Id FROM ContentDocument WHERE Id = :start.ID_Registered_Office_Lessee__c];
		ContentDocument lease                  = [SELECT Id FROM ContentDocument WHERE Id = :start.ID_Lease__c];

		Test.startTest();
		Database.DeleteResult result = Database.delete(registeredOfficeOwner, false);
		Test.stopTest();

		System.assert(result.isSuccess());
		System.assert(result.getErrors().isEmpty());

		start = [SELECT Id,ID_Registered_Office_Owner__c,ID_Registered_Office_Lessee__c,ID_Registered_Office_Hosted__c,ID_Lease__c FROM Start__c WHERE Id = :start.Id];
		System.assertEquals(null, start.ID_Registered_Office_Owner__c);
		System.assertEquals(registeredOfficeHosted.Id, start.ID_Registered_Office_Hosted__c);
		System.assertEquals(registeredOfficeLessee.Id, start.ID_Registered_Office_Lessee__c);
		System.assertEquals(lease.Id, start.ID_Lease__c);
	}

	@isTest static void testStartRegisteredOfficeHostedDeleted() {
		Start__c start = generateStart();

		ContentDocument registeredOfficeOwner  = [SELECT Id FROM ContentDocument WHERE Id = :start.ID_Registered_Office_Owner__c];
		ContentDocument registeredOfficeHosted = [SELECT Id FROM ContentDocument WHERE Id = :start.ID_Registered_Office_Hosted__c];
		ContentDocument registeredOfficeLessee = [SELECT Id FROM ContentDocument WHERE Id = :start.ID_Registered_Office_Lessee__c];
		ContentDocument lease                  = [SELECT Id FROM ContentDocument WHERE Id = :start.ID_Lease__c];

		Test.startTest();
		Database.DeleteResult result = Database.delete(registeredOfficeHosted, false);
		Test.stopTest();

		System.assert(result.isSuccess());
		System.assert(result.getErrors().isEmpty());

		start = [SELECT Id,ID_Registered_Office_Owner__c,ID_Registered_Office_Lessee__c,ID_Registered_Office_Hosted__c,ID_Lease__c FROM Start__c WHERE Id = :start.Id];
		System.assertEquals(null, start.ID_Registered_Office_Hosted__c);
		System.assertEquals(registeredOfficeOwner.Id, start.ID_Registered_Office_Owner__c);
		System.assertEquals(registeredOfficeLessee.Id, start.ID_Registered_Office_Lessee__c);
		System.assertEquals(lease.Id, start.ID_Lease__c);
	}

	@isTest static void testStartRegisteredOfficeLesseeDeleted() {
		Start__c start = generateStart();

		ContentDocument registeredOfficeOwner  = [SELECT Id FROM ContentDocument WHERE Id = :start.ID_Registered_Office_Owner__c];
		ContentDocument registeredOfficeHosted = [SELECT Id FROM ContentDocument WHERE Id = :start.ID_Registered_Office_Hosted__c];
		ContentDocument registeredOfficeLessee = [SELECT Id FROM ContentDocument WHERE Id = :start.ID_Registered_Office_Lessee__c];
		ContentDocument lease                  = [SELECT Id FROM ContentDocument WHERE Id = :start.ID_Lease__c];

		Test.startTest();
		Database.DeleteResult result = Database.delete(registeredOfficeLessee, false);
		Test.stopTest();

		System.assert(result.isSuccess());
		System.assert(result.getErrors().isEmpty());

		start = [SELECT Id,ID_Registered_Office_Owner__c,ID_Registered_Office_Lessee__c,ID_Registered_Office_Hosted__c,ID_Lease__c FROM Start__c WHERE Id = :start.Id];
		System.assertEquals(null, start.ID_Registered_Office_lessee__c);
		System.assertEquals(registeredOfficeOwner.Id, start.ID_Registered_Office_Owner__c);
		System.assertEquals(registeredOfficeHosted.Id, start.ID_Registered_Office_Hosted__c);
		System.assertEquals(lease.Id, start.ID_Lease__c);
	}

	@isTest static void testStartLeaseDeleted() {
		Start__c start = generateStart();

		ContentDocument registeredOfficeOwner  = [SELECT Id FROM ContentDocument WHERE Id = :start.ID_Registered_Office_Owner__c];
		ContentDocument registeredOfficeHosted = [SELECT Id FROM ContentDocument WHERE Id = :start.ID_Registered_Office_Hosted__c];
		ContentDocument registeredOfficeLessee = [SELECT Id FROM ContentDocument WHERE Id = :start.ID_Registered_Office_Lessee__c];
		ContentDocument lease                  = [SELECT Id FROM ContentDocument WHERE Id = :start.ID_Lease__c];

		Test.startTest();
		Database.DeleteResult result = Database.delete(lease, false);
		Test.stopTest();

		System.assert(result.isSuccess());
		System.assert(result.getErrors().isEmpty());

		start = [SELECT Id,ID_Registered_Office_Owner__c,ID_Registered_Office_Lessee__c,ID_Registered_Office_Hosted__c,ID_Lease__c FROM Start__c WHERE Id = :start.Id];
		System.assertEquals(null, start.ID_Lease__c);
		System.assertEquals(registeredOfficeOwner.Id, start.ID_Registered_Office_Owner__c);
		System.assertEquals(registeredOfficeHosted.Id, start.ID_Registered_Office_Hosted__c);
		System.assertEquals(registeredOfficeLessee.Id, start.ID_Registered_Office_Lessee__c);
	}

	@isTest static void testStartAllDocumentsDeleted() {
		Start__c start = generateStart();

		ContentDocument registeredOfficeOwner  = [SELECT Id FROM ContentDocument WHERE Id = :start.ID_Registered_Office_Owner__c];
		ContentDocument registeredOfficeHosted = [SELECT Id FROM ContentDocument WHERE Id = :start.ID_Registered_Office_Hosted__c];
		ContentDocument registeredOfficeLessee = [SELECT Id FROM ContentDocument WHERE Id = :start.ID_Registered_Office_Lessee__c];
		ContentDocument lease                  = [SELECT Id FROM ContentDocument WHERE Id = :start.ID_Lease__c];

		Test.startTest();
		List<Database.DeleteResult> result = Database.delete(new List<ContentDocument> {registeredOfficeOwner, registeredOfficeHosted, registeredOfficeLessee, lease}, false);
		Test.stopTest();

		for(Database.DeleteResult res : result) {
			System.assert(res.isSuccess());
			System.assert(res.getErrors().isEmpty());
		}

		start = [SELECT Id,ID_Registered_Office_Owner__c,ID_Registered_Office_Lessee__c,ID_Registered_Office_Hosted__c,ID_Lease__c FROM Start__c WHERE Id = :start.Id];
		System.assertEquals(null, start.ID_Lease__c);
		System.assertEquals(null, start.ID_Registered_Office_Owner__c);
		System.assertEquals(null, start.ID_Registered_Office_Hosted__c);
		System.assertEquals(null, start.ID_Registered_Office_Lessee__c);
	}

	private static Associate__c generateAssociate() {
		Associate__c partner     = [SELECT Id,ID_Id_Card__c,ID_Vital_Card__c FROM Associate__c WHERE FirstName__c = :PARTNER_NAME LIMIT 1];
		partner.ID_Id_Card__c    = Utils.generateDocument('ID_CARD.txt', 'ID_CARD', partner.Id, 'ID card content');
		partner.ID_Vital_Card__c = Utils.generateDocument('VITAL_CARD.txt', 'VITAL_CARD', partner.Id, 'Vital card content');
		partner.ID_Kbis__c       = Utils.generateDocument('KBIS.txt', 'KBIS', partner.Id, 'Kbis content');
		partner.ID_Status__c     = Utils.generateDocument('STATUS.txt', 'STATUS', partner.Id, 'Status content');

		update partner;
		return partner;
	}

	private static Start__c generateStart() {
		Start__c start = [SELECT Id,ID_Registered_Office_Owner__c,ID_Registered_Office_Lessee__c,ID_Registered_Office_Hosted__c,ID_Lease__c 
		                  FROM Start__c WHERE CompanyName__c = :START_NAME LIMIT 1];
		start.ID_Registered_Office_Owner__c  = Utils.generateDocument('Registered_Office_Owner.txt', 'Registered_Office_Owner', start.Id, 'content');
		start.ID_Registered_Office_Lessee__c = Utils.generateDocument('Registered_Office_Lessee.txt', 'Registered_Office_Lessee', start.Id, 'content');
		start.ID_Registered_Office_Hosted__c = Utils.generateDocument('ID_Registered_Office_Hosted.txt', 'ID_Registered_Office_Hosted', start.Id, 'content');
		start.ID_Lease__c                    = Utils.generateDocument('Lease.txt', 'Lease', start.Id, 'content');

		update start;
		return start;
	}
}