public class WalletFactory {

    public static void generateWalletAccount(String leadFirstname, String leadLastname, String leadMobilePhone, String leadEmail, String leadCompanyName, String companySiret) {
    
        // Create a Lead from SDR
        
        Lead lead = new Lead(
            FirstName = leadFirstname,
            LastName = leadLastname,
            Company = leadCompanyName,
            MobilePhone = leadMobilePhone,
            Email = leadEmail,
            Canal__c = 'seo',
            Detail__c = 'seo-direct',
            MeansOfContact__c = 'Chat',
            OrigineWebsite__c = 'Novaa',
            Branding__c = 'Novaa',
            TypeOfNeed__c = 'Comptabilité',
            Echeance_de_besoin_de_creation__c = 'Immédiat',
            Activity__c = 'Prestataire B2B',
            WillHaveEmployes__c = 'Non',
            LegalStatus__c = 'EURLSARL',
            City = 'Paris',
            Country = 'France',
            Street = '15 rue Auber',
            PostalCode = '75008'
        );
        
        insert lead;
        
        
        // Lead Transfert
        List<Account> accountsNovaa = [SELECT Id, (SELECT Id FROM Contacts WHERE IsActif__c = true) FROM Account WHERE Name LIKE 'Novaa%' AND RecordType.DeveloperName = 'AccountantPartner'];
        
        
        lead.Partenaire__c = accountsNovaa.get(0).Id;
        lead.Contact_Partenaire__c = accountsNovaa.get(0).Contacts.get(0).Id;
        lead.Appointment_Type__c = 'Transfert direct';
        
        update lead;
        
        // Convert the lead
        List<Transfert__c> transferts = [SELECT Id FROM Transfert__c WHERE Lead__c = :lead.Id];
        
        //LTC20_SendProposal.save(lead.Id, '1', LTC20_SendProposal_TEST.SELECTED_OFFERS);
        
        List<String> stringIds = LTC20_SendProposal.leadConversion(lead.Id);
        
        //LTC20_SendProposal.saveAccountId(transferts.get(0).Id, stringIds.get(0));
        
        LTC20_SendProposal.linkSurveysOnContact(lead.Id, stringIds.get(1), stringIds.get(0));
        
        update new Contact(Id = stringIds.get(1), Salutation = 'Monsieur');
        
        
        List<Stakeholder__c> shs = [SELECT Id, Officer__c, MainStakeholder__c FROM Stakeholder__c WHERE Company__c = :stringIds.get(0) AND Contact__c = :stringIds.get(1)];
        update new Stakeholder__c(
            Id = shs.get(0).Id,
            Officer__c = true,
            MainStakeholder__c = true,
            JobTitleBank__c = 'Gérant',
            ContactType__c = 'Mandataire social'
        );
        
        
        List<ApeCode__c> apeCodes = [SELECT Id FROM ApeCode__c LIMIT 10];
        // Validate the contacts
        update new Account(
            Id = stringIds.get(0),
            Siret__c = companySiret,
            BillingCity = 'Paris', 
            BillingCountry = 'France', 
            BillingStreet = '15 rue Auber',
            BillingPostalCode = '75008',
            RegistrationDate__c = Date.today(),
            ShareCapital__c = 50000.0,
            LastNetIncome__c = '10-49',
            AnnualTurnover__c = '40-99',
            NumberOfEmployees__c = '0',
            LegalStatus__c = 'SARL',
            ApeCode__c = apeCodes.get(0).Id
            
        );
        
        
        update new Contact(
            Id = stringIds.get(1),
            Birthdate = Date.newInstance(1990, 01, 01),
            BirthPlace__c = 'Paris',
            NativeCountry__c = 'France',
            Nationality__c = 'France',
            IncomPerTranche__c = '19 - 23 K€',
            Networth__c = '23 - 128K€'
        );
        
        System.debug('Account id : ' + stringIds.get(0));
        
        //enableWallet(stringIds.get(0));
        
    }
    
    @future
    public static void enableWallet(String accountId) {
        ContactsValidationCtrl.enableWallet(accountId);
    }
    
    public static void enableWalletSynchro(String accountId) {
        ContactsValidationCtrl.enableWallet(accountId);
        update new Account(Id = accountId, OwnerId = '0050N000007jfwtQAA');
    }
    
}