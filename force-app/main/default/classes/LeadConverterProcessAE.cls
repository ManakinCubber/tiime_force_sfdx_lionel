public with sharing class LeadConverterProcessAE {
    
    private Id leadId;
    
    public LeadConverterProcessAE(Id leadId) {
    	this.leadId = leadId;
    }
    
    public Database.LeadConvertResult launchLeadConversion() {
    	Database.LeadConvert lc = new database.LeadConvert();
		lc.setLeadId(leadId);
		
		LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
		lc.setConvertedStatus(convertStatus.MasterLabel);
		
		List<Lead> leads = [SELECT Id, NumeroCompteBaseGI__c, MobilePhone, Email FROM Lead WHERE Id = :this.leadId];
		
		// Look for account and contact duplicates
		String duplicateContactId = null;
		if(!leads.isEmpty()){
			
			if(String.isNotBlank(String.valueOf(leads.get(0).NumeroCompteBaseGI__c))) {
				List<Account> accounts = [SELECT Id FROM Account WHERE NumberBGI__c = :leads.get(0).NumeroCompteBaseGI__c];
				if(!accounts.isEmpty()) {
					lc.setAccountId(accounts.get(0).Id);
				}
			}
			if(String.isNotBlank(leads.get(0).MobilePhone) || String.isNotBlank(leads.get(0).Email)) {
				List<Contact> contacts = [SELECT Id FROM Contact WHERE MobilePhone = :leads.get(0).MobilePhone OR Email = :leads.get(0).Email];
				if(!contacts.isEmpty()) {
					//lc.setContactId(contacts.get(0).Id);
					duplicateContactId = contacts.get(0).Id;
				}
			}
		}
		
		Database.LeadConvertResult lcr = Database.convertLead(lc);
		if(!lcr.isSuccess()) {
			throw new AuraException('Echec de la conversion de la lead. Erreurs : ' + lcr.getErrors());
		}
		
		// Update company with lead email and phone number
		update new Account(Id = lcr.getAccountId(), MainEmail__c = leads.get(0).Email, MainPhoneNumber__c = leads.get(0).MobilePhone);
		
		// In case of contact duplicate, we create a stakeholder, then we delete the newly created contact, sorry bro..
		if(duplicateContactId != null) {
			changeStakeHolderContact(lcr.getAccountId(), lcr.getContactId(), duplicateContactId);
			
			delete new Contact(Id = lcr.getContactId());
		}
		
		return lcr;
    }
    
    private static void changeStakeHolderContact(Id accountId, Id currentContactId, Id newContactId) {
    	List<Stakeholder__c> stakeholders =  [SELECT Id, Contact__c FROM Stakeholder__c WHERE Company__c = :accountId AND Contact__c = :currentContactId];
		if(!stakeholders.isEmpty()) {
			stakeholders.get(0).Contact__c = newContactId;
			update stakeholders.get(0);
		} else {
			throw new AuraException('Echec de la conversion de la lead. Erreurs : Le stakeholder est requis pour la conversion avec fusion de contact.');
		}
    }
}