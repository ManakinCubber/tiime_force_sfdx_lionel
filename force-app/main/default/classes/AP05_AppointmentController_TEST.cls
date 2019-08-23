@isTest
public with sharing class AP05_AppointmentController_TEST {
	
	private static final Integer RECORD_COUNT = 8;

	private static User generateUser() {
		Profile profile = [Select id from Profile where Name = 'TMC' limit 1];
		System.debug('### Profile = ' + profile.id);
		User user = new User(
			FirstName = 'John', LastName = 'Doe',
			Username = 'JohnDoe@example.org', Alias = 'JohnDoe',
			Email = 'JohnDoe@example.org',
			ProfileId = profile.Id,
			TimeZoneSidKey = 'Europe/Paris',
			LanguageLocaleKey = 'fr',
			EmailEncodingKey = 'UTF-8',
			LocaleSidKey = 'fr');
		insert user;
		return user;
	}

	private static Lead generateLead() {
		Lead lead = new Lead(FirstName = 'LeadTestFirst', LastName = 'LeadTestLast', 
							Email = 'lead@example.org', Company = 'CompanyName', MobilePhone = '0601010101');
		insert lead;
		return lead;
	}

	private static List<Account> generateFirms() {
		List<Account> firms = new List<Account>();
		Id recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = :Constants.LEAD_ACCOUNT_RECORDTYPES_FOR_APPOINTMENT[0] AND SObjectType = 'Account'].Id;

		System.debug('### Account RecordType Id = ' + recordTypeId);

		for(Integer i= 0 ; i < RECORD_COUNT ; i++) {
			Account firm = new Account(
				Name = 'TestAccount' + i,
				Actif__c = math.mod(i,2) == 0,
				OnlinePartner__c = math.mod(i,3) == 0,
				RecordTypeId = recordTypeId,
				PartnerType__c = 'Groupe',
				MainPhoneNumber__c = '06000000' + (i < 10 ? '0' + i : String.valueOf(i)));
			firms.add(firm);
		}
		insert firms;

		return firms;
	}

	private static List<Contact> generateContacts(List<Account> firms) {
		List<Contact> contacts = new List<Contact>();
		Id recordTypeId = Utils.getContactRecordTypeIdByDeveloperName(Constants.CONTACT_RECORDTYPE_DEVELOPERNAME_PARTNER);

		System.debug('### Contact RecordType Id = ' + recordTypeId);

		for(Integer i= 0 ; i < RECORD_COUNT ; i++) {
			Contact contact = new Contact(FirstName = 'TestContactFirst' + i, LastName = 'TestContactLast' + i,
				MobilePhone = '06000000' + (i < 10 ? '0' + i : String.valueOf(i)),
				AccountId = firms.get(i).Id);
			if(math.mod(i,2) == 0)
				contact.RecordTypeId = recordTypeId;
			contacts.add(contact);
		}
		insert contacts;

		return contacts;
	}

	@isTest static void testContacts() {
		List<Account> firms    = generateFirms();
		List<Contact> contacts = generateContacts(firms);
		List<Contact> result;
		Account firm;
		
		Test.startTest();

		for(Integer i = 0 ; i < RECORD_COUNT ; i++) {
			firm = firms.get(i);
			result = AP05_AppointmentController.getContacts(firm.Id);
			System.assertEquals(math.mod(i,2) != 0 || !firm.Actif__c, result.size() == 0);
		}
		Test.stopTest();
	}

	@isTest static void testFirms() {
		Lead lead = generateLead();

		Test.startTest();
		List<Account> firms  = generateFirms();
		List<AP11_AccountWrapper> result = AP05_AppointmentController.getFirms(lead.Id);
		Test.stopTest();

		System.assertEquals(RECORD_COUNT / 2, result.size());
	}

	@isTest static void testGetFirm() {
		Test.startTest();
		Account firm = generateFirms()[0];

		Account acc = AP05_AppointmentController.getFirm(firm.id);
		System.assertEquals(true, acc.PartnerType__c != null && acc.PartnerType__c != '');
		System.assertEquals(true, acc.MainPhoneNumber__c != null && acc.MainPhoneNumber__c != '');

		Test.stopTest();
	}

	@isTest static void testUpdateFirm() {
		boolean hasError = false;

		Test.startTest();
		Account firm = generateFirms()[0];
		firm.PartnerType__c = 'Groupe';
		firm.MainPhoneNumber__c= '0102030405';
		update firm;
		Lead lead = generateLead();
		
		AP05_AppointmentController.updateFirm(lead.Id, firm.Id);
		lead = [SELECT id,Partenaire__c,Contact_Partenaire__c FROM Lead WHERE Id = :lead.id];

		System.assertEquals(null, lead.Contact_Partenaire__c, 'Partner contact is not null');
		System.assertEquals(firm.id, lead.Partenaire__c);

		//Test wrong ID
		try {
			AP05_AppointmentController.updateFirm(lead.Id, 'wrongId');
		} catch(Exception e) {
			System.assertEquals('System.StringException', e.getTypeName());
			hasError = true;
		}

		System.assertEquals(true, hasError, 'No exception thrown when wrong id is given');
		hasError = false;

		try {
			AP05_AppointmentController.updateFirm(lead.Id, '0120N000000AOUsAAA');
		} catch(Exception e) {
			System.assertEquals('System.DmlException', e.getTypeName());
			hasError = true;
		}

		System.assertEquals(true, hasError, 'No exception thrown when wrong id is given');
		
		Test.stopTest();

	}
	
	@isTest
	static void testCallBaseGI() {
		AP04_Factory.createGenericDataSample();
		List<Account> accounts = [SELECT Id, Name, IdBureauBaseGI__c FROM Account];
		List<Lead> leads = [SELECT Id, name, Partenaire__c, Contact_Partenaire__c FROM Lead];
		List<Contact> contacts = [SELECT Id, Name, AccountId FROM Contact];
		
		accounts.get(0).IdBureauBaseGI__c = 75;
		update accounts;
		
		leads.get(0).Partenaire__c = accounts.get(0).Id;
		leads.get(0).Contact_Partenaire__c = contacts.get(0).Id;
		update leads;
		
		WSParamBaseGI__mdt auth = new WSParamBaseGI__mdt(MasterLabel = 'AccountCreationFromLead', MethodeAppel__c = 'POST', StatutCodeSucces__c = 200);
		
		Test.startTest();
		AP05_AppointmentController.sendLeadToBaseGI(leads.get(0).Id);
		Test.stopTest();
		
		leads = [SELECT ID, NumeroCompteBaseGI__c FROM Lead WHERE Id = :leads.get(0).Id];
		System.assertEquals(1, leads.get(0).NumeroCompteBaseGI__c);
	}
	
	@isTest
	static void testChangeStatusToECaTrouver() {
		User user = AP04_Factory.UserStandardFactory(1, 'nomPourTes', 'PrenomDeTest' , 'userTest@test.fr')[0];
		insert user;

		System.runAs(user){
			Lead c = AP04_Factory.newWebLeadsFactory(1)[0];
			c.City = 'Paris';
			insert c;
		}
		Lead oldLead = [SELECT Id,Status FROM Lead WHERE OwnerId=:user.Id][0];
		System.debug(oldLead.Status);

		Test.startTest();
		AP05_AppointmentController.changeStatusToECaTrouver(oldLead.Id);
		Test.stopTest();
		
		Lead newLead = [SELECT Id,Status FROM Lead WHERE Id=:oldlead.Id][0];
		System.debug(newLead.Status);

		System.assertNotEquals(oldLead.Status, newLead.Status);
		System.assertEquals(Constants.LEAD_STATUS_EC_A_TROUVER, newLead.Status);
	}
	
	@isTest
	static void testNewTransfert() {
		AP04_Factory.createGenericDataSample();
		List<Lead> leads = [SELECT Id, name, Is_Appointment_Set__c FROM Lead];
		leads.get(0).Is_Appointment_Set__c = true;
		update leads.get(0);
		
		Test.startTest();
		AP05_AppointmentController.changeAptPlannedForNewTransfert(leads.get(0).Id, false);
		Test.stopTest();
		
		leads = [SELECT ID, Is_Appointment_Set__c FROM Lead WHERE Id = :leads.get(0).Id];
		System.assertEquals(false, leads.get(0).Is_Appointment_Set__c);
	}
    
    @isTest
    static void testsendEmailForRdv(){
        AP04_Factory.createGenericDataSample();
        Lead l = [SELECT Id, Branding__c,Email, Email_Body__c, Rendez_vous__c, OwnerId FROM Lead][0];
        Contact c = [SELECT Id FROM Contact][0];
        Transfert__c t = new Transfert__c(Name='testTransfert', Lead__c=l.Id, ContactPartenaire__c=c.Id, OwnerId=l.OwnerId);
        insert t;
        
        List<Event> events = [SELECT Id FROM Event];
        System.assert(events.isEmpty());
        
        Test.startTest();
      	AP05_AppointmentController.sendEmailForRdv(t.Id, l.ID, c.Id, l.Branding__c, l.Email, 'corp du mail !', DateTime.now(), 'Au bureau');
        Test.stopTest();
        
        events = [SELECT Id FROM Event];
        System.assert(events.size() == 1);
    }
}