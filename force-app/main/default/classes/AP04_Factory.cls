/*******************************************************
Nom ......... : AP04_Factory.cls
Description	  : Classe Factory pour la création d'instances pour les TEST
            
Auteur ...... : JEAN-BAPTISTE Félix 
********************************************************/
public class AP04_Factory {
	
	public static void createGenericDataSample() {
		// Create Accounts
		// Create a partner account
		List<Account> partnerAccounts = partnerAccountsFactory(2);
		partnerAccounts.get(1).Name = Constants.LEAD_BRANDING_TIIME;
		insert partnerAccounts;
		
		// Create Client Accounts
		List<Account> clientAccounts = clientAccountsFactory(1);
		insert clientAccounts;
		
		
		// Create Contacts
		// Create partner contacts
		List<Contact> partnerContacts = partnerContactsFactory(3, partnerAccounts.get(0).Id);
		partnerContacts.addAll(partnerContactsFactory(1, partnerAccounts.get(1).Id));
		insert partnerContacts;
		
		// Create client contact
		List<Contact> clientContacts = clientContactsFactory(1, clientAccounts.get(0).Id);
		insert clientContacts;
		
		// Create Leads
		// Create leads from a web site
		List<Lead> webLeads = newWebLeadsFactory(4);
		insert webLeads;
		
	}
	
	

	// Leads
	
	public static List<Lead> newWebLeadsFactory(Integer nbLeads) {
		String origineWebsite = Lead.OrigineWebsite__c.getDescribe().getPicklistValues().get(0).getValue();
		String branding = Lead.Branding__c.getDescribe().getPicklistValues().get(0).getValue();
		List<Lead> leads = new List<Lead>();
		for(Integer i = 1; i <= nbLeads; i++) {
			leads.add(leadFactory(origineWebsite, chooseSalutation(i), 'firstname', 'lastname'+i, 'lead'+i+'@tiime.fr', '0612345789', 'firstname lastname'+i, branding));
		}
		return leads;
	}
	
	public static Lead leadFactory(String origineWebsite, String salutation, String fName, String lName, String email, String mobilePhone, String company, String branding) {
		return new Lead(OrigineWebsite__c = origineWebsite, Salutation = salutation, FirstName = fName, LastName = lName, Email = email, MobilePhone = mobilePhone, Company = company, Branding__c = branding);
	}
	
    public static List<Lead> LeadFactory(Integer nbLeads, String phone, String lName, String corp){
        List<Lead> leads = new list<Lead>();
        for(Integer i=1; i<=nbLeads; i++){
            leads.add(new Lead(MobilePhone=phone, LastName=lName+i, Company=corp));
        }
        return leads;
     }

	// Users
     public static List<User> UserStandardFactory(Integer nbUser, String lName,String fName , String userN){

     	Profile standardProfile = [Select id from Profile where Name =: 'Utilisateur standard' or Name =: 'Standard User' limit 1];
        List<User> users = new list<User>();
        for(Integer i=1; i<=nbUser; i++){
            users.add(new User(
            	LastName = lName+i,
                FirstName = fName+i,
                Alias = lName.substring(0,2)+fName.substring(0,2),
                Email = userN,
                Username = userN,
                ProfileId = standardProfile.Id,
                TimeZoneSidKey = 'Europe/Paris',
                LanguageLocaleKey = 'fr',
                EmailEncodingKey = 'UTF-8',
                LocaleSidKey = 'fr'
            ));
        }
        return users;
     }
     
     public static List<User> userSpecificProfileFactory(Integer nbUser, String lName,String fName , String userN, String profileName){

     	Profile profile = [Select id from Profile where Name =:profileName limit 1];
        List<User> users = new list<User>();
        for(Integer i=1; i<=nbUser; i++){
            users.add(new User(
            	LastName = lName+i,
                FirstName = fName+i,
                Alias = lName.substring(0,2)+fName.substring(0,2),
                Email = userN,
                Username = userN,
                ProfileId = profile.Id,
                TimeZoneSidKey = 'Europe/Paris',
                LanguageLocaleKey = 'fr',
                EmailEncodingKey = 'UTF-8',
                LocaleSidKey = 'fr'
            ));
        }
        return users;
     }

     public static List<User> UserAdminFactory(Integer nbUser, String lName,String fName , String userN){

     	Profile adminProfile = [Select id from Profile where Name = 'Administrateur système' or Name = 'System Administrator' limit 1];
        List<User> users = new list<User>();
        for(Integer i=1; i<=nbUser; i++){
            users.add(new User(
                LastName = lName+i,
                FirstName = fName+i,
                Alias = lName.substring(0,2)+fName.substring(0,2),
                Email = userN,
                Username = userN,
                ProfileId = adminProfile.Id,
                TimeZoneSidKey = 'Europe/Paris',
                LanguageLocaleKey = 'fr',
                EmailEncodingKey = 'UTF-8',
                LocaleSidKey = 'fr'
            ));
        }
        return users;
     }
     
     // Accounts
     public static List<Account> partnerAccountsFactory(Integer nbAccount) {
     	List<Account> accounts = new List<Account>();
     	Id recordTypeId = Utils.getAccountRecordTypeByDeveloperName(Constants.ACCOUNT_RECORDTYPE_DEVELOPERNAME_PARTNER);
     	for(Integer i = 1; i <= nbAccount; i++) {
     		accounts.add(accountFactory('PartnerAccountN'+i, recordTypeId));
     	}
     	return accounts;
     }
     
     public static List<Account> clientAccountsFactory(Integer nbAccount) {
     	List<Account> accounts = new List<Account>();
     	Id recordTypeId = Utils.getAccountRecordTypeByDeveloperName(Constants.ACCOUNT_RECORDTYPE_DEVELOPERNAME_CLIENT);
     	for(Integer i = 1; i <= nbAccount; i++) {
     		accounts.add(accountFactory('ClientAccountN'+i, recordTypeId));
     	}
     	return accounts;
     }
     
     public static Account accountFactory(String name, Id recordTypeId) {
     	return new Account(Name = name, RecordTypeId = recordTypeId);
     }
     
     // Contacts
     public static List<Contact> partnerContactsFactory(Integer nbContacts, Id entrepriseId) {
     	List<Contact> contacts = new List<Contact>();
     	
     	for(Integer i = 1; i <= nbContacts; i++) {
     		contacts.add(contactFactory(
     		chooseSalutation(i), 'partnerFirstname', 'partnerLastname'+i, 'partnerContact'+i+'@tiime.fr', entrepriseId, Utils.getContactRecordTypeIdByDeveloperName(Constants.CONTACT_RECORDTYPE_DEVELOPERNAME_PARTNER)
     		));
     	}
     	return contacts;
     }
     
     public static List<Contact> clientContactsFactory(Integer nbContacts, Id entrepriseId) {
     	List<Contact> contacts = new List<Contact>();
     	
     	for(Integer i = 1; i <= nbContacts; i++) {
     		contacts.add(contactFactory(
     		chooseSalutation(i), 'clientFirstname', 'clientLastname'+i, 'clientContact'+i+'@tiime.fr', entrepriseId, Utils.getContactRecordTypeIdByDeveloperName(Constants.CONTACT_RECORDTYPE_DEVELOPERNAME_CLIENT)
     		));
     	}
     	return contacts;
     }
     
     public static Contact contactFactory(String salutation, string fName, String lName, String email, Id entrepriseId, Id recordtypeId) {
     	return new Contact(Salutation = salutation, FirstName = fName, LastName = lName, Email = email, AccountId = entrepriseId, RecordTypeId = recordtypeId);
     }
     
     private static String chooseSalutation(Integer i) {
     	return Contact.Salutation.getDescribe().getPicklistValues().get(Math.mod(i, 2)).getValue();
     }
     
     //Stakeholder
	public static List<Account> generateStakeholderTestCases() {
		List<Account> companies = new List<Account>();
		List<Contact> contacts = new List<Contact>();
		List<Stakeholder__c> stakeholders = new List<Stakeholder__c>();
		Id recordTypeId = Utils.getAccountRecordTypeByDeveloperName(Constants.ACCOUNT_RECORDTYPE_DEVELOPERNAME_PARTNER);

		companies.add(accountFactory('NO_SH', recordTypeId));
		companies.add(accountFactory('ONE_SH', recordTypeId));
		companies.add(accountFactory('MULTIPLE_PRIMARY_SH_NO_BENEFICIARY', recordTypeId));
		companies.add(accountFactory('SINGLE_PRIMARY_SH_NO_BENEFICAIRY', recordTypeId));
		companies.add(accountFactory('MULTIPLE_PRIMARY_SH', recordTypeId));
		companies.add(accountFactory('SINGLE_PRIMARY_SH', recordTypeId));

		insert companies;
		
		for(Account a : companies) {
			contacts.add(contactFactory('madame', 'TestContact', 'Test', 'Test@test.com', a.Id, Utils.getContactRecordTypeIdByDeveloperName(Constants.CONTACT_RECORDTYPE_DEVELOPERNAME_CLIENT)));
		}
		insert contacts;

		stakeholders.add(stakeholderFactory(false, false, false, companies[1].Id, contacts[1].Id));

		stakeholders.add(stakeholderFactory(false, false, true, companies[2].Id, contacts[2].Id));
		stakeholders.add(stakeholderFactory(false, false, true, companies[2].Id, contacts[2].Id));

		stakeholders.add(stakeholderFactory(false, false, true, companies[3].Id, contacts[3].Id));
		stakeholders.add(stakeholderFactory(false, false, false, companies[3].Id, contacts[3].Id));

		stakeholders.add(stakeholderFactory(false, true, true, companies[4].Id, contacts[4].Id));
		stakeholders.add(stakeholderFactory(true, false, true, companies[4].Id, contacts[4].Id));

		stakeholders.add(stakeholderFactory(true, false, true, companies[5].Id, contacts[5].Id));
		stakeholders.add(stakeholderFactory(true, false, false, companies[5].Id, contacts[5].Id));
		stakeholders.add(stakeholderFactory(true, true, false, companies[5].Id, contacts[5].Id));
		stakeholders.add(stakeholderFactory(false, true, false, companies[5].Id, contacts[5].Id));

		insert stakeholders;
		return companies;
	}

	public static Stakeholder__c stakeholderFactory(Boolean actualBeneficiary, Boolean officer, Boolean mainStakeHolder, Id company, Id contact) {
		return new Stakeholder__c(ActualBeneficiary__c = actualBeneficiary, Officer__c = officer, MainStakeholder__c = mainStakeHolder, Company__c = company, Contact__c = contact);
	}

	//Associate__c
	public static List<Associate__c> associatesFactory(Integer count, Id startId) {
		List<Associate__c> partners = new List<Associate__c>();

		for(Integer i = 0 ; i < count ; i++) {
			partners.add(associateFactory('Associate ' + i, startId));
		}
		return partners;
	}

	public static Associate__c associateFactory(String firstName, Id startId) {
		return new Associate__c(FirstName__c = firstName, Start__c = startId);
	}

	//Start
	public static Start__c startFactory(String companyName, Id leadId) {
		return new Start__c(CompanyName__c = companyName, Crea__c = leadId);
	}
	
	//Enquête de Satisfaction
	public static enquetedeSatisfaction__c createEnqueteSatisfaction(Id accountID, Id leadId){
		Id recordTypeId = Utils.getEnqueteRecordTypeByDeveloperName(Constants.ENQUETE_RECORDTYPE_DEVELOPERNAME_J10);
		enquetedeSatisfaction__c enquete = new enquetedeSatisfaction__c(RecordTypeId=recordTypeId, Partner__c=accountID, Lead__c=leadId);
		return enquete;
	}
	public static List<enquetedeSatisfaction__c> enqueteFactory(Integer nbEnquetes, Id accountID, Id leadId){
		List<enquetedeSatisfaction__c> enquetes = new List<enquetedeSatisfaction__c>();

		for(Integer i = 0 ; i < nbEnquetes ; i++) {
			enquetes.add(createEnqueteSatisfaction(accountID,leadId));
		}
		return enquetes;
	}

 }