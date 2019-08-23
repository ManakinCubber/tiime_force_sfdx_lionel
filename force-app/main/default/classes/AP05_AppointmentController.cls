public with sharing class AP05_AppointmentController {
	
	@AuraEnabled
	public static List<Contact> getContacts(Id firm) {
		Id recordTypeId = Utils.getContactRecordTypeIdByDeveloperName(Constants.CONTACT_RECORDTYPE_DEVELOPERNAME_PARTNER);
		List<Contact> contacts = [SELECT Id, Name, FirstName, MobilePhone FROM Contact WHERE RecordTypeId = :recordTypeId AND AccountId = :firm And Account.Actif__c = true AND IsActif__c = true]; //Partenaire EC
		System.debug(contacts.size());
		return contacts;
	}

	@AuraEnabled
	public static List<AP11_AccountWrapper> getFirms(Id leadId) {
		Lead lead = [SELECT Latitude,Longitude, Street, City, PostalCode, Country FROM Lead WHERE Id = :leadId];
		
		Location leadLocation = Location.newInstance(lead.Latitude, lead.Longitude);

		List<Account> results = [SELECT Id,Name,OnlinePartner__c,BillingAddress,BillingLatitude,BillingLongitude, BillingStreet, BillingCity, 
								BillingPostalCode, PartnerType__c, Floor__c FROM Account
								 WHERE RecordType.DeveloperName IN :Constants.LEAD_ACCOUNT_RECORDTYPES_FOR_APPOINTMENT AND Actif__c = true ORDER BY Name];
								 
		
		
		List<AP11_AccountWrapper> filtered = new List<AP11_AccountWrapper>();

		for(Account account : results) {
			AP11_AccountWrapper wrapper = new AP11_AccountWrapper(account, leadLocation);
			if(lead.Latitude == null || account.OnlinePartner__c || wrapper.distance <= Constants.LEAD_MAX_DISTANCE_FROM_PARTNER)
				filtered.add(wrapper);
		}

		filtered.sort();
		System.debug(filtered);
		return filtered;
	}

	@AuraEnabled
	public static void updateFirm(Id record, Id firm) {
		Lead l = new Lead(Id = record);
		l.Contact_Partenaire__c = null;
		l.Partenaire__c = firm;
		update l;
	}

	@AuraEnabled
	public static Account getFirm(Id firm) {
		Account acc = [SELECT PartnerType__c, MainPhoneNumber__c From Account Where  Id=:firm];
		return acc;
	}
	
	@AuraEnabled
	public static void sendLeadToBaseGI(Id leadId) {
		WS03_BaseGI_CreateDossierBGI wsCaller = new WS03_BaseGI_CreateDossierBGI();
		wsCaller.createAccountFromLead(leadId);
	}
	
	@AuraEnabled
    public static void logAnError(String errorMessage) {
    	Utils.createLogError(errorMessage);
    }
	
	@AuraEnabled
	public static void changeStatusToECaTrouver(Id leadId){
		Lead lead = [Select Id, Name, Status From Lead Where Id=:leadId];
		lead.Status = Constants.LEAD_STATUS_EC_A_TROUVER;
		lead.Partenaire__c = null;
		lead.Contact_Partenaire__c = null;
		update lead;
	}
	
	@AuraEnabled
	public static void changeAptPlannedForNewTransfert(Id leadId, boolean isAptPlanned) {
		update new Lead(Id = leadId, Is_Appointment_Set__c = isAptPlanned, Rendez_vous__c = null);
	}
    
    @AuraEnabled
    public static void sendEmailForRdv(Id transfertId, Id leadId, Id leadContactPartenaire, String leadBranding, String leadEmail, String leadEmailBody, DateTime leadRendezVous, String lieuRDV){ 	
    	List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
        
        Map<Id, Contact> contactsPartenairesMap = new Map<Id, Contact> ([SELECT Id, Name, Email FROM Contact WHERE Id =:leadContactPartenaire]);
    	String[] additionnalEmailList = Constants.SEND_EMAIL_FROM_LEAD_ADDITIONNAL_RECIPIENTS.split(Constants.CUSTOM_LABEL_INNER_SEPARATOR);
    	
    	String queryValue = (leadBranding == Constants.LEAD_BRANDING_LEC_LILLE ? Constants.LEAD_BRANDING_LEC : leadBranding);
    	List<OrgWideEmailAddress> owdList = [SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName = :queryValue];
    	if(!owdList.isEmpty()) {
    		singleEmail.setOrgWideEmailAddressId(owdList.get(0).Id);
    	}
    	
    	singleEmail.setToAddresses(new String[] {leadEmail});
    	singleEmail.setBccAddresses(additionnalEmailList);   	
        singleEmail.setCcAddresses(new String[] {UserInfo.getUserEmail()});
        singleEmail.setPlainTextBody(leadEmailBody);
        singleEmail.setSubject(Constants.SEND_EMAIL_FROM_LEAD_SUBJECT + contactsPartenairesMap.get(leadContactPartenaire).Name);	
    	singleEmail.setTargetObjectId(leadId);

    	if(leadRendezVous != null) {
    		String emailForICS = (owdList.isEmpty() ? 'test@test.com' : owdList.get(0).Address);
    		singleEmail.setFileAttachments(AP08_IcsFileGenerator.generateIcsAttachment(leadRendezVous, emailForICS, singleEmail.getSubject()));
        }
		
        emails.add(singleEmail);
	    System.debug(emails);
        if(!Test.isRunningTest()) {
            Messaging.sendEmail(emails);
        }
        createEvent(transfertId, leadId, leadContactPartenaire, leadRendezVous, leadEmailBody, lieuRDV);
    }
    
    private static void createEvent(id transfertId, Id leadId, Id leadContactPartenaire, DateTime leadRendezVous, String leadEmailBody, String lieuRDV){
        Lead l = [SELECT Id, MappingFullName__c, OwnerId FROM Lead WHERE Id=:leadId];
        Contact c = [SELECT Name FROM Contact WHERE Id=:leadContactPartenaire];
        Transfert__c t = [SELECT Id, OwnerId FROM Transfert__c WHERE Id=:transfertId];
        Event event = new Event(
            ContactName__c = l.MappingFullName__c,
            Location = lieuRDV,
            OwnerId = t.OwnerId,
            WhatId = transfertId,
            ActivityDateTime = leadRendezVous, 
			Subject  = 'Rendez-vous avec '+ l.MappingFullName__c,
            DurationInMinutes = 30,
            Description = leadEmailBody
		);
        insert event;
    }
}