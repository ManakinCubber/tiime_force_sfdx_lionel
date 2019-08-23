public class AP03_StakeHolder {
    public static void beforeUpdate(Map<id,Stakeholder__c> oldMap, Map<id,Stakeholder__c> newMap) {
        System.debug('AP03_StakeHolder::beforeUpdate::Begin');
        List<String> lstChamps = new List<string>{'StartDate__c','EndDate__c', 'PrincipalContact__c', 'Company__c', 'Contact__c'};
       	boolean isChanged = false;
        for(id shId : newMap.keySet()) {
            Stakeholder__c shOld = oldMap.get(shId);
            Stakeholder__c shNew = newMap.get(shId);
            for(string champ: lstChamps){
                if(shOld.get(champ)!=shNew.get(champ)){
                	isChanged = true;
                    break;
                }
            }
        }
        if(isChanged == true) {
            boolean updateSHPrincipal = true;
            set<id> companyIds = new set<id>();
            set<id> contactIds = new set<id>();
            set<id> recordTypeIds = new set<id>();
            List<Contact> contactsToUpdate = new List<Contact>();
            for(Stakeholder__c stakeholder : newMap.values()) {
                companyIds.add(stakeholder.Company__c);
                contactIds.add(stakeholder.Contact__c);
                recordTypeIds.add(stakeholder.RecordTypeId);
            }
            Map<Id, recordType> mapRTById = new Map<id,recordType>([Select id, DeveloperName FROM recordType WHERE Id in:recordTypeIds]); 
            List<Stakeholder__c> sHAlreadyExists2 = [SELECT id, PrincipalContact__c, Company__c, Contact__c, StartDate__c, EndDate__c  FROM Stakeholder__c WHERE Company__c IN: companyIds
                                                     AND Contact__c IN: contactIds AND RecordTypeId IN: recordTypeIds AND Id NOT IN :newMap.keySet()];
            List<Stakeholder__c> listSHPrincipal = [SELECT id, PrincipalContact__c, Company__c, Contact__c FROM Stakeholder__c WHERE Company__c IN: companyIds AND PrincipalContact__c = true];
            //On recherche les stakeholder principaux rattachés au contact, s'il n'y en a pas, on met à jour le contact en le rattachant à l'entreprise par le champ AccountId de l'objet Contact
            List<Stakeholder__c> listSHRelatedToContact = [SELECT id, PrincipalContact__c, Company__c, Contact__c FROM Stakeholder__c WHERE PrincipalContact__c = true AND Contact__c IN: contactIds];
            
            List<Contact> majContact2 = [SELECT id, name, AccountId FROM Contact Where id IN: contactIds ];
            for(id shId : newMap.keySet()) {
                Stakeholder__c oldSH2 = oldMap.get(shId);
                Stakeholder__c newSH2 = newMap.get(shId);
                System.debug('SH update => '+ shId);
                for(Stakeholder__c unSHPrincipal : listSHPrincipal) {
                    if(unSHPrincipal.Id == newSH2.Id) {
                        updateSHPrincipal = false;
                    }
                }
                
                Boolean doublon2 = false;
                for(Stakeholder__c unSH2 : sHAlreadyExists2) {
                    if(unSH2.Contact__c == newSH2.Contact__c && unSH2.Company__c == newSH2.Company__c) {
                        if((unSH2.StartDate__c >= newSH2.StartDate__c && unSH2.StartDate__c <= newSH2.EndDate__c) ||
                           (unSH2.EndDate__c >= newSH2.StartDate__c && unSH2.EndDate__c <= newSH2.EndDate__c) ||
                           (unSH2.StartDate__c <= newSH2.StartDate__c && unSH2.EndDate__c >= newSH2.StartDate__c) ||
                           (unSH2.StartDate__c >= newSH2.StartDate__c && unSH2.EndDate__c <= newSH2.EndDate__c) || newSH2.EndDate__c == null) {
                               if((newSH2.EndDate__c == null)) {
                                   if(newSH2.StartDate__c < unSH2.StartDate__c || newSH2.StartDate__c <= unSH2.EndDate__c) {
                                       doublon2 = true;
                                   }
                               }
                               else {
                                    doublon2 = true;
                               }
                           }
                    }
                    if(doublon2 == true) {
                        newSH2.addError(Label.errorShAlreadyexists);
                    }
                }
                
                //Si cette mise à jour de StakeHolder ne génère pas de doublon, alors on peut continuer.
                if(doublon2 == false) {
                    //Si le stakeholder devient principal, alors on doit passer le stakeholder principal rattaché à cette entreprise à non principal 
                    //afin de ne pas avoir deux stakeholder principal pour une même entreprise
                    recordType shRT = mapRTById.get(newSH2.recordTypeId);
                    if(newSH2.PrincipalContact__c == true && oldSH2.PrincipalContact__c == false && shRT.DeveloperName == 'Personne_Physique') {
                        for(Stakeholder__c unStakeholderPrincipal : listSHPrincipal) {
                            if(unStakeholderPrincipal.Company__c == newSH2.Company__c) {
                                unStakeholderPrincipal.PrincipalContact__c = false;
                            }
                        }
                        
                        //On recherche les stakeholder principaux rattachés au contact, s'il n'y en a pas, 
                        //on met à jour le contact en le rattachant à l'entreprise par le champ AccountId de l'objet Contact
                        Boolean shPrincipalFound = false;
                        for(Stakeholder__c unSHPrincipal : listSHRelatedToContact) {
                            if(newSH2.Contact__c == unSHPrincipal.Contact__c) {
                                shPrincipalFound = true;
                            }
                        }
                        if(shPrincipalFound == false){
                            for(Contact contactToEdit : majContact2) {
                                if(newSH2.Contact__c == contactToEdit.Id) {
                                    contactToEdit.AccountId = newSH2.Company__c;
                                    contactsToUpdate.add(contactToEdit);
                                }
                            }
                        }
                    }
                }
            }
            if(listSHPrincipal.size() > 0) {
                System.debug('-----1-----> listSHPrincipal :: ' + listSHPrincipal + '  taille: '+ + listSHPrincipal.size());
                if(updateSHPrincipal == true) {
                    update listSHPrincipal;
                }
            }
            if(contactsToUpdate.size() > 0) {
                System.debug('-----2-----> majContact2 :: ' + contactsToUpdate + '  taille: '+ + contactsToUpdate.size());
                update contactsToUpdate;
            }
            System.debug('AP03_StakeHolder::beforeUpdate::End');
        }
    }
    
    public static void onInsert(List<Stakeholder__c> listNewSH) {
        system.debug('AP03_Stakeholder::onInsert::Begin');
        List<Stakeholder__c> listShToUpdate = new List<Stakeholder__c>();
        List<Contact> listContactToUpdate = new List<Contact>();
        Map<Id,Stakeholder__c> shById = new Map<Id, Stakeholder__c>([SELECT id, PrincipalContact__c, Company__c, Contact__c, StartDate__c, EndDate__c, RecordTypeId FROM Stakeholder__c]);
        Map<id,Contact> mapContact = new Map<Id,Contact>([SELECT Id, AccountId FROM Contact]);
        for(Stakeholder__c unShToInsert : listNewSH) {
            Boolean doublon = false;
            for( Id unShId : shById.keySet()) {
                Stakeholder__c unSh = shById.get(unShId);
                //On vérifie si le StakeHolder que l'on tente de crée existe déjà ou non (en prenant en compte le recordType)
                if(unSh.Company__c == unShToInsert.Company__c && unSh.Contact__c == unShToInsert.Contact__c && unSh.RecordTypeId == unShToInsert.RecordTypeId
                  	&& ((unSh.StartDate__c >= unShToInsert.StartDate__c && unSh.StartDate__c <= unShToInsert.EndDate__c) || (unSh.EndDate__c >= unShToInsert.StartDate__c && unSh.EndDate__c <= unShToInsert.EndDate__c)
                         || (unSh.StartDate__c <= unShToInsert.StartDate__c && unSh.EndDate__c >= unShToInsert.StartDate__c) || (unSh.StartDate__c >= unShToInsert.StartDate__c && unSh.EndDate__c <= unShToInsert.EndDate__c)
                         || (unSh.StartDate__c >= unShToInsert.StartDate__c && unSh.EndDate__c == unShToInsert.EndDate__c) || (unSh.StartDate__c <= unShToInsert.StartDate__c && unSh.EndDate__c == null))) {
                             //Une vérification supplémentaire 
                             if((unShToInsert.EndDate__c == null)) {
                                     if(unShToInsert.StartDate__c <= unSh.StartDate__c || unShToInsert.StartDate__c <= unSh.EndDate__c) {
                                         doublon = true;
                                     }
                                     else if(unShToInsert.StartDate__c >= unSh.StartDate__c && unSh.EndDate__c == null) {
                                         doublon = true;
                                     }
                             }
                             else {
                                 doublon = true;
                             }
                             if(doublon == true) {
                                 unShToInsert.addError(Label.errorShAlreadyexists);
                             }
                }
            }
            //Si le stakeholder est principal, on récupère la liste des stakeholders de l'entreprise et on passe l'attribut PrincipalContact__c à false
            if(doublon == false) {
                if(unShToInsert.PrincipalContact__c == true) {
                    for(Id unShId : shById.keySet()) {
                        Stakeholder__c unSh = shById.get(unShId);
                        if(unSh.Company__c == unShToInsert.Company__c) {
                            unSh.PrincipalContact__c = false;
                            listShToUpdate.add(unSh);
                        }
                    }
                }
            }
        }
        //Maj de la liste des SH
        if(listShToUpdate.size() > 0) {
            update listShToUpdate;
        }
    }
}