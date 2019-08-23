public class IcxConvertProject {
	private static String temp_email_format = '@temp.fr';
    
    // Partners accounts
    public static Account[] PartnersEC = [Select Id, Name from Account where RecordType.developerName = 'AccountantPartner'];
    public static Id ProspectRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
    public class ICXException extends Exception {}
    
    private static List<Database.LeadConvertResult> convertLead(Set<Id> leadIds) {
        List<Database.LeadConvertResult> lcr = new List<Database.LeadConvertResult>();
        
        LeadStatus CLeadStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true Limit 1];
        List<Database.LeadConvert> MassLeadconvert = new List<Database.LeadConvert>();
        for(id currentlead: LeadIds){
            Database.LeadConvert Leadconvert = new Database.LeadConvert();
            Leadconvert.setLeadId(currentlead);                
            Leadconvert.setConvertedStatus(CLeadStatus.MasterLabel);
            Leadconvert.setDoNotCreateOpportunity(TRUE);
            MassLeadconvert.add(Leadconvert);
        }
        
        if (!MassLeadconvert.isEmpty()) {
        	// KMD 13/02/2019 mis en commentaire en attendant d'autoriser la conversion de Leads.
            //lcr.addAll(Database.convertLead(MassLeadconvert));
        }
        return lcr;
    }
    
    public static Id getPartnerEC( String accountName ) {
        // search in existing partner EC2 accounts
        Id result;
        for(Account a: PartnersEC) {
            if(a.name == accountName) {
                result = a.Id;
                break;                
            }
        }        
        return result;
    }
    
    // will converta lead, then attach to the new Account / contact / Stakeholder the updated informations.
    @InvocableMethod(label='Convert Project')
    public static void convertProject(RequestConversion[] req) {
        Set<Id> lead_entries = new Set<Id>();
        Set<Id> opp_entries = new Set<Id>();
        
        for(RequestConversion r: req) {
            if(''+r.itemId.getsobjecttype() == 'Lead') lead_entries.add(r.itemId);
            else opp_entries.add(r.itemId);
        }
        
        if(lead_entries.isEmpty() == false ) convertProjectFromLead(lead_entries);
        if(opp_entries.isEmpty() == false ) convertProjectFromOpportunity(opp_entries);
    }

    public static void convertProjectFromLead(Set<Id> lead_ids) {
        Map<Id,Id> lead_CA = new Map<Id,Id>(); // AccountId/LeadId
        Map<Id, lead> lead_detail = new Map<Id, lead>(); // store lead Info
        Map<Id, Account> account_detail = new Map<Id, Account>(); // store Account Info
        

        // Store informations of Project
        for(Lead  l : [ Select Id, 
                       FirstName,LastName,  Company , Email, Fax, Industry, LeadSource, Status, MobilePhone, NumberOfEmployees, Phone, Title, Website, HowManyEmployees__c, WebFormComments__c, TmcComments__c, SourceDetails__c, Partner__c, AdvisorCompany__c, Advisor__c, OrigineWebsite__c, 
                       (Select Id, 
                        PrimaryCompanyPurpose__c, ShareCapital__c, AdressPostalCode__c, AccountsClosingDate__c, CompanyName__c, LegalStatus__c, 
                        ProfitsTaxation__c, CMARegistration__c, CommercialName__c, AdressStreetName__c, AssociateNumber__c, /*AdressStreetNumber__c, */
                        IncomeTaxOption__c, CompanyCity__c from Starts__r ),
                       (Select Id, Start__c, lead__r.email, lead__r.firstname, lead__r.lastname, CapitalContribution__c, Civility__c, PostalCode__c, 
                        BirthCity__c, AccreConditions__c, PoleEmploiInscriptionDate__c, BirthDate__c, AccreRequest__c, ID_Id_Card__c, ID_Vital_Card__c, 
                        AccreInformations__c, Nationnality__c, Name, SocialSecurityNumber__c, FirstName__c, Street__c, SocialMandat__c, City__c 
                        from Associates__r)
                       from lead where Id IN: lead_ids ]) {
                           
                           // Ensure we have a project
                           if( l.Starts__r.isEmpty() == false ) lead_detail.put( l.Id,  l);
		}
        
        // Do nothing if none of the lead has a project
        if(lead_detail.isEmpty()) return;
        
        // Launch conversion for all leads
        List<Database.LeadConvertResult> conv_lead = convertLead( lead_ids );
        
        // for all converted lead, get Account and contact id
        for(Database.LeadConvertResult cl : conv_lead) {
            Id leadId = cl.getLeadId();
            
            if( cl.isSuccess() == false ) lead_detail.remove( leadId ); // Ignore failed conversions and cleanup
            else lead_CA.put( cl.getAccountId(), leadId); // Populate ccount <> lead map 
        }
        
        // For all accounts, get stakeholders and contact informations (should be 1 account = 1 contact + 1 SH)
        for(Account a: [Select id,Name, RecordType.DeveloperName,
                        (SELECT Id, contact__r.firstName, contact__r.lastName, contact__r.email, EmailAddress__c  from Parties_Prenantes__r ),
                        (SELECT id, firstName, LastName, Email, phone from Contacts ) 
                        from Account where Id In :lead_CA.keySet() ]) {
                            account_detail.put( lead_CA.get( a.Id ), a );
        }
        
        // Stakeholders Creation is handled by AP02_Contactstaholder
        List<Account> update_accounts = new Account[]{};
        List<Start__c> update_projects = new Start__c[]{};        
        List<Contact> insert_contacts = new List<Contact>(); // Insert contact will trigger AP02_contactStakeholder, handling the SH creation
		Map<Id, Contact> update_contacts = new Map<Id, Contact>();
        Map<Id, Stakeholder__c> update_stakeholders = new Map<Id, Stakeholder__c>();
        
        
        // Finally, for every converted lead, retrieve Account informations
        for(Lead lead:  lead_detail.values()) {
            
            Account acc = account_detail.get(lead.Id);
            if(acc != null) {
	            Map<Id, Contact> cs = new Map<Id, Contact>(acc.Contacts);            
	            Start__c pjt = lead.Starts__r[ 0 ];
	            Associate__c[] ast = lead.Associates__r;
	            Stakeholder__c[] sh = acc.Parties_Prenantes__r;
	            
	            // Match associates with existing contacts or create new contact
	            for(Associate__c at: ast) {
	                Boolean matchedContact = false;
	                Boolean matchedStakholder = false;                
	                ID contact_match = null;
	                
	                // Update existing Stakeholder: Should have 1 match, created by carrenet's script
	                for(Stakeholder__c s:sh ) {
	                    if(s.contact__r.firstName == at.firstName__c && s.contact__r.lastName == at.Name  ) {
	                        update_stakeholders.put(s.id, enhanceStakeholder(at, s));
	                        contact_match = s.contact__c;
	                        break;
	                    }
	                }
	                
	                // Update existing contacts
	                if( contact_match != null && cs.containsKey(contact_match)) update_contacts.put(contact_match, enhanceContact(at, cs.get(contact_match)));
	                else  {                    
	                    Contact c = new Contact(accountId = acc.Id);
	                    c.email = at.Id + temp_email_format; 	// required field
	                    c.associate__c = at.Id; 		// Mandatory to correctly handle SH after update creation
	                    insert_contacts.add(enhanceContact( at, c));
	                }                
	            }
	            
	            
	            // Attach Project to Account
	            pjt.Account__c = acc.Id;
	            // Try to match a picklist value to an existing partner EC account
	            if(lead.Partner__c != null) acc.Partner__c = getPartnerEC( lead.Partner__c );     
	            
	            update_accounts.add( enhanceAccount( pjt, acc) );    
	           
	            update_projects.add( pjt );
	        }
        }
        
        if( !update_accounts.isEmpty() ) update update_accounts;
        if( !update_projects.isEmpty() ) update update_projects;        
        if( !update_contacts.isEmpty() ) update update_contacts.values();
        if( !update_stakeholders.isEmpty() ) update update_stakeholders.values();
        if( !insert_contacts.isEmpty() ) insert insert_contacts;
        
    }
    
	public static void convertProjectFromOpportunity(Set<Id> opportunity_ids) {
        Map<Id,Id> opp_CA = new Map<Id,Id>(); // AccountId/ oppId
        Map<Id, Opportunity> opp_detail = new Map<Id, Opportunity>(); // store opp Info
        Map<Id, Account> account_detail = new Map<Id, Account>(); // store Account Info
        
        
        // Store informations of Project
        for(Opportunity  o : [ Select Id, AccountId, Account.Name, Account.RecordType.DeveloperName,
                               (Select Id, 
                                PrimaryCompanyPurpose__c, ShareCapital__c, AdressPostalCode__c, AccountsClosingDate__c, CompanyName__c, LegalStatus__c, 
                                ProfitsTaxation__c, CMARegistration__c, CommercialName__c, AdressStreetName__c, AssociateNumber__c, /*AdressStreetNumber__c, */
                                IncomeTaxOption__c, CompanyCity__c from StartsOpp__r ),
                               (Select Id, Start__c, lead__r.email, lead__r.firstname, lead__r.lastname, CapitalContribution__c, Civility__c, PostalCode__c, 
                                BirthCity__c, AccreConditions__c, PoleEmploiInscriptionDate__c, BirthDate__c, AccreRequest__c, ID_Id_Card__c, ID_Vital_Card__c, 
                                AccreInformations__c, Nationnality__c, Name, SocialSecurityNumber__c, FirstName__c, Street__c, SocialMandat__c, City__c 
                                from AssociatesOpp__r)
                       		from Opportunity where Id IN: opportunity_ids ]) {
                           
                           // Ensure we have a project
                                if( o.StartsOpp__r.isEmpty() == false ) {
                                    opp_detail.put( o.Id,  o);
                                    opp_CA.put( o.AccountId,  o.Id);
                                }
		}
        
        // Do nothing if none of the opportunity has a project
        if(opp_detail.isEmpty()) return;
       
        // For all accounts, get stakeholders and contact informations (should be 1 account = 1 contact + 1 SH)
        for(Account a: [Select Id,
                        (SELECT Id, contact__r.firstName, contact__r.lastName, contact__r.email, EmailAddress__c  from Parties_Prenantes__r ),
                        (SELECT id, firstName, LastName, Email, phone from Contacts ) 
                        from Account where Id In :opp_CA.keySet() ]) {
                            account_detail.put( a.Id, a );
        }
        
        // Stakeholders Creation is handled by AP02_Contactstaholder
        List<Account> update_accounts = new Account[]{};
        List<Start__c> update_projects = new Start__c[]{};        
        List<Contact> insert_contacts = new List<Contact>(); // Insert contact will trigger AP02_contactStakeholder, handling the SH creation
		Map<Id, Contact> update_contacts = new Map<Id, Contact>();
        Map<Id, Stakeholder__c> update_stakeholders = new Map<Id, Stakeholder__c>();
        
        // Finally, for every opportunity, retrieve Account informations
        for(Opportunity o:  opp_detail.values()) {
            
            Account acc = account_detail.get(o.AccountId);

            Map<Id, Contact> cs = new Map<Id, Contact>(acc.Contacts);            
            Start__c pjt = o.StartsOpp__r[ 0 ];
            Associate__c[] ast = o.AssociatesOpp__r;
            Stakeholder__c[] sh = acc.Parties_Prenantes__r;
            
            // Match associates with existing contacts or create new contact
            for(Associate__c at: ast) {
                Boolean matchedContact = false;
                Boolean matchedStakholder = false;                
                ID contact_match = null;
                
                // Update existing Stakeholder: Should have 1 match, created by carrenet's script
                for(Stakeholder__c s:sh ) {
                    if(s.contact__r.firstName == at.firstName__c && s.contact__r.lastName == at.Name  ) {
                        update_stakeholders.put(s.id, enhanceStakeholder(at, s));
                        contact_match = s.contact__c;
                        break;
                    }
                }
                
                // Update existing contacts
                if( contact_match != null && cs.containsKey(contact_match)) update_contacts.put(contact_match, enhanceContact(at, cs.get(contact_match)));
                else  {                    
                    Contact c = new Contact(accountId = acc.Id);
                    c.email = at.Id + temp_email_format; 	// required field
                    c.associate__c = at.Id; 		// Mandatory to correctly handle SH after update creation
                    insert_contacts.add(enhanceContact( at, c));
                }                
            }
            
            // Attach Project to Account
            pjt.Account__c = acc.Id;
            
            // Map Start / Project informations to current Account
            update_accounts.add( enhanceAccount( pjt, acc) );            
            update_projects.add( pjt );
        }
        
        if( !update_accounts.isEmpty() ) update update_accounts;
        if( !update_projects.isEmpty() ) update update_projects;        
        if( !update_contacts.isEmpty() ) update update_contacts.values();
        if( !update_stakeholders.isEmpty() ) update update_stakeholders.values();
        if( !insert_contacts.isEmpty() ) insert insert_contacts;
    }
 
   /**
    * Map Project fields to Account
    * **/
    public static Account enhanceAccount(Start__c p, Account a) {
        // a.recordTypeId = ProspectRecordType;
        if( p.CompanyName__c != null) a.Name = p.CompanyName__c;
        
        //  Populate Account field with due Start__c fields
        if( p.LegalStatus__c != null) a.LegalStatus__c = p.LegalStatus__c;
        if( p.ShareCapital__c != null) a.ShareCapital__c = p.ShareCapital__c;
        if( p.CommercialName__c != null) a.CommercialName__c = p.CommercialName__c;
        if( p.AdressStreetName__c != null) a.BillingStreet = p.AdressStreetName__c;
        //if( p.AdressStreetNumber__c != null) a.BillingStreet = p.AdressStreetNumber__c + ' ' + a.BillingStreet;
        if( p.CompanyCity__c != null) a.BillingCity = p.CompanyCity__c;
        if( p.AdressPostalCode__c != null) a.BillingPostalCode = p.AdressPostalCode__c;
        if( p.ProfitsTaxation__c != null) a.ProfitsTaxation__c = p.ProfitsTaxation__c;
        if( p.IncomeTaxOption__c != null) a.IncomeTaxOption__c = p.IncomeTaxOption__c;
        if( p.CMARegistration__c != null) a.CMARegistration__c = p.CMARegistration__c;
        if( p.AssociateNumber__c != null) a.AssociateNumber__c = p.AssociateNumber__c;
        if( p.PrimaryCompanyPurpose__c != null) a.Activity__c = p.PrimaryCompanyPurpose__c;
        if( p.AccountsClosingDate__c != null) a.FirstClosingDate__c = p.AccountsClosingDate__c;
        return a;
    }
    
   /**
    * Map Associate fields to Stakeholder
    * **/
    public static Stakeholder__c enhanceStakeholder(Associate__c a, Stakeholder__c sh) {
        //  Populate Stakeholder__c field with due Associate fields
        if( a.SocialMandat__c != null) {
            sh.Officer__c  = true;
            sh.OfficerType__c = a.SocialMandat__c;
        } 
        if( a.AccreRequest__c != null) sh.AccreRequest__c = a.AccreRequest__c;
        if( a.CapitalContribution__c != null) sh.CapitalContribution__c = a.CapitalContribution__c;
        if( a.AccreConditions__c != null) sh.AccreConditions__c = a.AccreConditions__c;
        if( a.AccreInformations__c != null) sh.AccreInformations__c = a.AccreInformations__c;
        if( a.PoleEmploiInscriptionDate__c != null) sh.PoleEmploiInscriptionDate__c = a.PoleEmploiInscriptionDate__c;
        return sh;
    } 
    
   /**
    * Map Associate fields to Contact
    * **/
    public static Contact enhanceContact(Associate__c a, Contact c) {
        
        //  Populate Contact field with due Associate fields
        if( a.Name != null) c.LastName = a.Name;
        if( a.City__c != null) c.MailingCity = a.City__c;
        if( a.Street__c != null) c.MailingStreet = a.Street__c;
        if( a.Civility__c != null) c.Salutation = a.Civility__c;
        if( a.BirthDate__c != null) c.BirthDate = a.BirthDate__c;
        if( a.FirstName__c != null) c.FirstName = a.FirstName__c;
        if( a.BirthCity__c != null) c.BirthPlace__c = a.BirthCity__c;
        if( a.ID_Id_Card__c != null) c.ID_Id_Card__c = a.ID_Id_Card__c;
        if( a.Nationnality__c != null) c.Nationality__c = a.Nationnality__c;
        if( a.PostalCode__c != null) c.MailingPostalCode = ''+a.PostalCode__c;
        if( a.ID_Vital_Card__c != null) c.ID_Vital_Card__c = a.ID_Vital_Card__c;
        if( a.SocialSecurityNumber__c != null) c.SocialSecurityNumber__c = ''+a.SocialSecurityNumber__c;
        
        return c;
    }
    
    public class RequestConversion {
        @InvocableVariable(label='Lead/Opportunity ID' required=true)
        public Id itemId;
    }
}