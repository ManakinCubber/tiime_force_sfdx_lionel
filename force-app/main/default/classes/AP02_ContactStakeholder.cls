public class AP02_ContactStakeholder {
    public class ICXException extends Exception {}    
    //Méthode permettant de créer un StakeHolder à la création d'un contact. Il rattache le compte au contact.
    public static void onInsert(Map<id,Contact> newMap) { 
        RecordType personnePhysiqueRT = [SELECT id, name from RecordType Where developerName = 'Personne_Physique' AND SObjectType = 'Stakeholder__c'];
        RecordType personneMoraleRT = [SELECT id, name from RecordType Where developerName = 'Personne_Morale' AND SObjectType = 'Stakeholder__c'];
        List<Stakeholder__c> shToInsert = new List<Stakeholder__c>();
        
        set<id> AccountIds = new set<id>();
        set<id> ContactIds = new set<id>(); // Added Isochronix
        for( Contact contact : newMap.values()) {
            AccountIds.add(contact.AccountId);
        }
        List<Stakeholder__c> stakeHolders = [SELECT id, PrincipalContact__c, Company__c, Contact__c FROM Stakeholder__c WHERE Company__c in: AccountIds AND PrincipalContact__c = true];
        
        for(id contactId : newMap.keyset()) {
            Contact newContact = newMap.get(contactId);
            //Faire la vérification sur l'origine du contact, s'il provient d'une app externe, il ne faut pas créer de stakeholder
            if(newContact.FromApp__c == false) {
                System.debug('fromapp false');
                boolean mainContact = true;
                for(StakeHolder__c unSH : stakeHolders) {
                    if(unSH.Company__c == newContact.AccountId) {
                        mainContact = false;
                    }
                }
                Stakeholder__c newSH = new StakeHolder__c(RecordTypeId = personnePhysiqueRT.Id, Contact__c = contactId, Company__c = newContact.AccountId, PrincipalContact__c = mainContact, StartDate__c = Date.today());
                // Isochronix
                // Add contact reference to retrieve Associates informations
                ContactIds.add(contactId);
                shToInsert.add(newSH);
            }
        }
        if(shToInsert.size() > 0) {
            // ---------
            // Isochronix: Map Associate informations ton contact (enhance)
            // ---------
            Contact[] contact_list = [Select id, 
                                      associate__c, associate__r.Start__c, associate__r.CapitalContribution__c, associate__r.Civility__c, associate__r.PostalCode__c, 
                                      associate__r.BirthCity__c, associate__r.AccreConditions__c, associate__r.KindShareCapital__c,associate__r.CashShareCapital__c,
                                      associate__r.PoleEmploiInscriptionDate__c, associate__r.BirthDate__c, associate__r.AccreRequest__c, associate__r.ID_Id_Card__c, 
                                      associate__r.ID_Vital_Card__c, associate__r.AccreInformations__c, associate__r.Nationnality__c, associate__r.Name, associate__r.SocialSecurityNumber__c, 
                                      associate__r.FirstName__c, associate__r.Street__c, associate__r.SocialMandat__c, associate__r.City__c 
                                      From Contact where id In :ContactIds and associate__c != null
                                     ];
            Map<Id, Contact> update_contacts = new Map<Id, Contact>( contact_list ); 
            List<Stakeholder__c> final_shtoinsert = new List<Stakeholder__c>();
            
            for(Stakeholder__c sh: shToInsert) {
                if(update_contacts.containsKey(sh.Contact__c) != true) final_shtoinsert.add(sh);
                else {
                    Contact sh_contact = update_contacts.get(sh.Contact__c);
                    // Get related associate informations
                    Associate__c associate = new Associate__c(
                        Start__c = sh_contact.associate__r.Start__c,
                        Civility__c = sh_contact.associate__r.Civility__c,
                        PostalCode__c = sh_contact.associate__r.PostalCode__c,
                        BirthCity__c = sh_contact.associate__r.BirthCity__c,
                        KindShareCapital__c = sh_contact.associate__r.KindShareCapital__c,
                        CashShareCapital__c  = sh_contact.associate__r.CashShareCapital__c,
                        AccreConditions__c = sh_contact.associate__r.AccreConditions__c,
                        PoleEmploiInscriptionDate__c = sh_contact.associate__r.PoleEmploiInscriptionDate__c,
                        BirthDate__c = sh_contact.associate__r.BirthDate__c,
                        AccreRequest__c = sh_contact.associate__r.AccreRequest__c,
                        ID_Id_Card__c = sh_contact.associate__r.ID_Id_Card__c,
                        ID_Vital_Card__c = sh_contact.associate__r.ID_Vital_Card__c,
                        AccreInformations__c = sh_contact.associate__r.AccreInformations__c,
                        Nationnality__c = sh_contact.associate__r.Nationnality__c,
                        Name = sh_contact.associate__r.Name,
                        SocialSecurityNumber__c = sh_contact.associate__r.SocialSecurityNumber__c,
                        FirstName__c = sh_contact.associate__r.FirstName__c,
                        Street__c = sh_contact.associate__r.Street__c,
                        SocialMandat__c = sh_contact.associate__r.SocialMandat__c,
                        City__c = sh_contact.associate__r.City__c
                    );
                    
                    final_shtoinsert.add( IcxConvertProject.enhanceStakeholder( associate, sh) );   
                }
            }
            
            // ---- END EDIT Isochronix --
            Try {
                insert final_shtoinsert;   
                
            } catch(Exception e) {
                String err = ''+e.getMessage();
                System.debug('Entered Error Trigger '+ err);
                throw new ICXException( err );
            }            
        }
    }
    
    //Méthode permettant de créer un StakeHolder à la mise à jour d'un contact. Il rattache le compte au contact.
    public static void onUpdateContact(Map<id,Contact> oldMap, Map<id,Contact> newMap) {
        System.debug('AP02_ContactStakeholder::onUpdateContact::Begin');
        
        Map<Id, Map<Id, StakeHolder__c>> mapSHByContactIds = new Map<Id,Map<Id, StakeHolder__c>>();
        for(StakeHolder__c sh : [SELECT id, Company__c, Contact__c, PrincipalContact__c FROM Stakeholder__c WHERE Contact__c IN: newMap.keySet()]) {
            Map<Id, StakeHolder__c> shById = mapSHByContactIds.get(sh.Contact__c);
            if(shById == null) {
                shById = new Map<id, StakeHolder__c>();
                mapSHByContactIds.put(sh.Contact__c, shById);
            }
            shById.put(sh.Id, sh);
        }
        Set<Id> setCompanyId = new Set<Id>();
        for(Id contactId : newMap.keySet()) {
            Contact unCtc = newMap.get(contactId);
            setCompanyId.add(unCtc.AccountId);
        }
        
        Map<Id, Map<Id, StakeHolder__c>> mapSHByCompanyIds = new Map<Id,Map<Id, StakeHolder__c>>();
        for(StakeHolder__c sh : [SELECT id, Company__c, Contact__c, PrincipalContact__c FROM Stakeholder__c WHERE Company__c IN: setCompanyId]) {
            Map<Id, StakeHolder__c> shById2 = mapSHByCompanyIds.get(sh.Company__c);
            if(shById2 == null) {
                shById2 = new Map<id, StakeHolder__c>();
                mapSHByCompanyIds.put(sh.Company__c, shById2);
            }
            shById2.put(sh.Id, sh);
        }
        List<Stakeholder__c> shToInsert = new List<Stakeholder__c>();
        for(id contactId : newMap.keySet()) {
            Contact newContact = newMap.get(contactId);
            Contact oldContact = oldMap.get(contactId);
            boolean shAlreadyExists = false;
            boolean mainContact = true;
            if(newContact.AccountId != oldContact.AccountId) {
                for(Id unShId : mapSHByContactIds.get(contactId).keyset()) {
                    StakeHolder__c sh = mapSHByContactIds.get(contactId).get(unShId);
                    if(sh.Company__c == newContact.AccountId) {
                        shAlreadyExists = true;
                    }
                }
                if(mapSHByCompanyIds.containsKey(newContact.AccountId)) {
                for(Id unShId : mapSHByCompanyIds.get(newContact.AccountId).keyset()) {
                    StakeHolder__c sh = mapSHByCompanyIds.get(newContact.AccountId).get(unShId);
                    if(sh.PrincipalContact__c == true) {
                        mainContact = false;
                    }
                }
                }
                if(shAlreadyExists == false) {
                    System.debug('AP02_ContactStakeholder::onUpdateContact::CreationSH');
                    Stakeholder__c newSH = new StakeHolder__c(RecordTypeId = Utils.getStakeholderRecordTypeIdByDeveloperName(Constants.STAKEHOLDER_RECORDTYPE_DEVELOPERNAME_PP), Contact__c = contactId, Company__c = newContact.AccountId, PrincipalContact__c = mainContact, StartDate__c = Date.today());
                    shToInsert.add(newSH);
                }
            } 
        }
        if(shToInsert.size() > 0) insert shToInsert;
    }
    
    //Méthode empêchant la suppression des contacts s'ils sont définis comme principal dans un stakeholder
    public static void beforeDeleteContact(Map<Id,Contact> oldMap) {
        Map<Id,Stakeholder__c> MapStakeholderByIdContact = new Map<Id,Stakeholder__c>();
        for(Stakeholder__c stakeholder : [SELECT Id, PrincipalContact__c, Contact__c FROM Stakeholder__c WHERE PrincipalContact__c = true]) {
            if(MapStakeholderByIdContact.containsKey(stakeholder.Contact__c) == false) {
                MapStakeholderByIdContact.put(stakeholder.Contact__c, stakeholder);
            }
        }
        for(Id idContact : oldMap.keySet()) {
            if(MapStakeholderByIdContact.containsKey(idContact)) {
                Contact ctcError = oldMap.get(idContact);
                ctcError.addError(Label.errorDelMainContact);
            }
        }
    }
}