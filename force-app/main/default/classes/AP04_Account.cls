public class AP04_Account {
    
    public static boolean fromUpdateHA = false;
    public static boolean fireTriggerHA = true;
    
    //A la création d'un compte, un BR est créé si le champ PrincipalBillingCompany__c est renseigné et que le compte créé est de type Prospect ou Client.
  /*  public static void onInsert(Map<id,Account> newMap) {
        RecordType rtProspect = [SELECT id, name from RecordType Where developerName = 'Prospect'];
        RecordType rtClient = [SELECT id, name from RecordType Where developerName = 'Client'];
        List<BillingRelationship__c> brToInsert = new List<BillingRelationship__c>();
        for(id accountId : newMap.keyset()) {
            Account newAccount = newMap.get(accountId);
            if(newAccount.RecordTypeId == rtProspect.Id || newAccount.RecordTypeId == rtClient.Id) {
                if(newAccount.PrincipalBillingCompany__c != null) {
                    BillingRelationship__c newBR = new BillingRelationship__c(Company__c = newAccount.Id, InternalCompany__c = newAccount.PrincipalBillingCompany__c, PrincipalRelationship__c = true);
                    brToInsert.add(newBR);
                }            
            }
        }
        if(brToInsert.size() > 0) {
            insert brToInsert;
        }
    }*/
    
    //Lors de la mise à jour d'un compte, si celui-ci est de type Client ou Prospect et que le champ PrincipalBillingCompany__c est modifié, alors on met à jour le BR s'il existe déjà en passant son attribut
    //PrincipalRelationship__c à true et en passant les autres BR rattachés à ce compte à false, sinon, on crée le BR avec l'attribut PrincipalRelationship__c à true et on passe les autres BR à false.
  /*  public static void onUpdateAccount(Map<Id,Account> oldMap, Map<Id,Account> newMap) {
        //On passe la variable fromUpdateAcc à true afin de ne pas déclencher le code de la méthode AP05_BillingRelationship.onUpdate qui générerait une erreur lié au fait que la resssource serait verouillée.
        AP05_BillingRelationship.fromUpdateAcc = true;
        //RecordType rtProspect = [SELECT id, name from RecordType Where developerName = 'Prospect'];
        //RecordType rtClient = [SELECT id, name from RecordType Where developerName = 'Client'];
        
        Id rtProspect = Utility.GetRecordTypeId('Account','Prospect');
        Id rtClient = Utility.GetRecordTypeId('Account','Client');
        List<BillingRelationship__c> brToInsert = new List<BillingRelationship__c>();
        List<BillingRelationship__c> brToUpdate = new List<BillingRelationship__c>();
        List<BillingRelationship__c> brToUpdate2 = new List<BillingRelationship__c>();
        Map<Id, List<BillingRelationship__c>> mapBrByAccountIds = new Map<Id,List<BillingRelationship__c>>();
        for(BillingRelationship__c br : [SELECT id, PrincipalRelationship__c, Company__c, InternalCompany__c FROM BillingRelationship__c  WHERE Company__c IN: newMap.keyset()]) {
            List<BillingRelationship__c> listBr = mapBrByAccountIds.get(br.Company__c);
            if(listBr == null) {
                listBr = new List<BillingRelationship__c>();
                mapBrByAccountIds.put(br.Company__c, listBr);
            }
            listBr.add(br);
        }
        
        for(id accountId : newMap.keyset()) { 
            Account newAccount = newMap.get(accountId);
            Account oldAccount = oldMap.get(accountId);
            boolean brToAdd = true;
            if((newAccount.RecordTypeId == rtProspect || newAccount.RecordTypeId == rtClient) && newAccount.PrincipalBillingCompany__c != oldAccount.PrincipalBillingCompany__c) {
                if(mapBrByAccountIds.get(accountId) != null) {
                    for(BillingRelationship__c brLinkedToAcc : mapBrByAccountIds.get(accountId)) {
                        brLinkedToAcc.PrincipalRelationship__c = false;
                        brToUpdate.add(brLinkedToAcc);
                        System.debug('brLinkedToAcc.InternalCompany__c =>'+ brLinkedToAcc.InternalCompany__c);
                        System.debug('newAccount.PrincipalBillingCompany__c =>'+ newAccount.PrincipalBillingCompany__c);
                        if(brLinkedToAcc.InternalCompany__c == newAccount.PrincipalBillingCompany__c) {
                            brLinkedToAcc.PrincipalRelationship__c = true;
                            brToUpdate2.add(brLinkedToAcc);
                        }
                        if((brLinkedToAcc.Company__c == newAccount.id && brLinkedToAcc.InternalCompany__c == newAccount.PrincipalBillingCompany__c) || newAccount.PrincipalBillingCompany__c == null) {
                            brToAdd = false;
                            if(newAccount.PrincipalBillingCompany__c == null && oldAccount.PrincipalBillingCompany__c == brLinkedToAcc.InternalCompany__c) {
                                brLinkedToAcc.PrincipalRelationship__c = false;
                                brToUpdate2.add(brLinkedToAcc);
                            }
                        }
                    }
                    if(brToAdd == true) {
                        BillingRelationship__c newBR = new BillingRelationship__c(Company__c = newAccount.Id, InternalCompany__c = newAccount.PrincipalBillingCompany__c, PrincipalRelationship__c = true);
                        brToInsert.add(newBR);
                        System.debug('brToInsert => '+brToInsert);
                    }
                }
                else {
                    if(newAccount.PrincipalBillingCompany__c != null) {
                        BillingRelationship__c newBR = new BillingRelationship__c(Company__c = newAccount.Id, InternalCompany__c = newAccount.PrincipalBillingCompany__c, PrincipalRelationship__c = true);
                        brToInsert.add(newBR);
                        System.debug('brToInsert ELSE => '+brToInsert);
                    }
                }
            }
        }
        if(brToInsert.size() > 0) {
            insert brToInsert;
        }
        if(brToUpdate.size() > 0) {
            update brToUpdate;
            System.debug('brToUpdate => '+brToUpdate);
        }
        if(brToUpdate2.size() > 0) {
            update brToUpdate2;
            System.debug('brToUpdate2 => '+brToUpdate2);
        }
         AP05_BillingRelationship.fromUpdateAcc = false;
    }*/
    
    //Méthode permettant de créer un History Account à la mise à jour d'un de ses champs
    public static void createHistoryAccOnUpdateAcc(Map<Id,Account> oldMap, Map<Id,Account> newMap) {
        System.debug('AP04_Account::createHistoryAccOnUpdateAcc::Begin');
        if(fromUpdateHA == false) {
            List<string> LstChamp = new List<string>{'BillingCity','BillingStreet','BillingCountry','BillingPostalCode','VatLimitDate__c',
                'LegalStatus__c','OwnerId','nbOfShares__c','CommercialName__c','Name','TaxSystem__c','VatSystem__c', 'Siret__c', 'TaxingType__c', 'Status__c'};  //,'AccountHasVat__c'
      List<HistoryAccount__c> HAToInsert = new List<HistoryAccount__c>();
            boolean siretOk = true;
            
            Map<Id, Map<Id, HistoryAccount__c>> mapHAbyAccIds = new Map<Id, Map<Id, HistoryAccount__c>>();
            for(HistoryAccount__c ha : [SELECT id, oldValue__c, newValue__c, EffectiveDate__c, lastModifiedDate, Entreprise__c, Field__c FROM HistoryAccount__c WHERE Entreprise__c IN :newMap.keySet()]) {
                Map<Id, HistoryAccount__c> mapHa = mapHAbyAccIds.get(ha.Entreprise__c);
                if(mapHa == null) {
                    mapHa = new Map<id, HistoryAccount__c>();
                    mapHAbyAccIds.put(ha.Entreprise__c, mapHa);
                }
                mapHa.put(ha.Id, ha);
            }
            
            List<HistoryAccount__c> listHAToUpdate = new List<HistoryAccount__c>();
            for(id accId : newMap.keySet()) {
                // Initialisation des objets pour comparaison
                Account accOld = oldMap.get(accId);
                Account accNew = newMap.get(accId);
                //Vérification pour la création d'un HistoryAccount
                for(string champ: LstChamp){
                    //Vérification de la nouvelle valeur du Siret afin de ne pas créer 2 HistoryAccount à cause du workflow qui supprime les espaces.
                    if(champ == 'Siret__c' && accNew.get(champ) != null && ((String)accNew.get(champ)).containsWhitespace() == true) {
                        siretOk = false;
                    }
                    if(accOld.get(champ)!=accNew.get(champ) && siretOk == true) {
                        String typeChamp = getType(champ).toLowerCase();
                        System.debug('DEBUG::AP04::TypeDuChamp => '+typeChamp);
                        String oldValue = '';
                        String newValue = '';
                        //null object sur le oldValue vérifier la que la valeur est différente de null avant de tenter de parser en string!
                        if(typeChamp.equals('double')) {
                            if(accOld.get(champ) != null) {
                                oldValue = ((Decimal)accOld.get(champ)).toPlainString();
                            }
                            if(accNew.get(champ) != null) {
                                newValue = ((Decimal)accNew.get(champ)).toPlainString();
                            }
                        }
                        else if(typeChamp.equals('date')) {
                            if(accOld.get(champ) != null) {
                                oldValue = ((Date)accOld.get(champ)).format();
                            }
                            if(accNew.get(champ) != null) {
                                newValue = ((Date)accNew.get(champ)).format();
                            }
                        }
                        else {
                            if(accOld.get(champ) != null) {
                              oldValue = (String)accOld.get(champ);
                            }
                            if(accNew.get(champ) != null) {
                              newValue = (String)accNew.get(champ);
                            }
                        }
                        HistoryAccount__c historyAcc = new HistoryAccount__c(Name = 'HistoryAccount', Entreprise__c = accNew.Id, Field__c = champ, OldValue__c = oldValue,
                                                                             NewValue__c = newValue, EffectiveDate__c = Date.today(), Type__c = typeChamp, FieldName__c = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().get(champ).getDescribe().getLabel());
                        System.debug('DEBUGG::createAccountHistory = '+historyAcc);
                        HAToInsert.add(historyAcc);
                        HistoryAccount__c closestHaAfter;
                        if(mapHAbyAccIds.get(historyAcc.Entreprise__c) != null) {
                            for(Id idHa : mapHAbyAccIds.get(historyAcc.Entreprise__c).keySet()) {
                                HistoryAccount__c tmpHa = mapHAbyAccIds.get(historyAcc.Entreprise__c).get(idHa);
                                if(tmpHa.Field__c == historyAcc.Field__c && tmpHA.EffectiveDate__c > historyAcc.EffectiveDate__c) {
                                    if(closestHaAfter == null) {
                                        closestHaAfter = tmpHA;
                                    }
                                    if(tmpHA.EffectiveDate__c <= closestHaAfter.EffectiveDate__c){
                                        closestHaAfter = tmpHA;
                                    }
                                }
                            }
                            if(closestHaAfter != null) {
                                closestHaAfter.OldValue__c = historyAcc.NewValue__c;
                                listHAToUpdate.add(closestHaAfter);
                            }
                            System.debug('AP04_Account::createHistoryAccOnUpdateAcc::listHAToUpdate => '+listHAToUpdate);
                        }
                    }
                    siretOk = true;
                }
            }
            System.debug('AP04_Account::createHistoryAccOnUpdateAcc:: => Avant Insert HA => '+listHAToUpdate);
            if(HAToInsert.size() > 0) {
                insert HAToInsert;
            }
            System.debug('AP04_Account::createHistoryAccOnUpdateAcc:: => Avant update list HA => '+ listHAToUpdate);
            if(listHAToUpdate.size() > 0) {
                System.debug('ZEDRFGHJKLM => '+listHAToUpdate);
                update listHAToUpdate;
            }
        }
        fromUpdateHA = false;
    }
    
    private static String getType(String field) {
        String typeObject='Account';
    //Création d'une MAP avec tous les objets et leur schéma
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        //Récupération du schéma de l'objet spécifié
        Schema.SObjectType leadSchema = schemaMap.get(typeObject);
        //Création de la MAP du schéma de l'objet spécifié (id => nom d'un champ, valeur => son type)
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        Schema.DisplayType fieldDataType = fieldMap.get(field).getDescribe().getType();
        String type = String.ValueOf(fieldDataType);
        return type;
    }
    
     //Met à jour la oldValue du/des HA dont on modifie la date effective. On prend la new value du HA qui le précède. En BEfore update car impossible à mettre à jour en after (ressource verouillée)
    public static void onBeforeUpdateHistoryAcc(Map<Id,HistoryAccount__c> oldMap, Map<Id,HistoryAccount__c> newMap) {
        System.debug('AP04_Account::onBeforeUpdateHistoryAcc::Begin');
        List<String> listChamp = new List<String>{'NewValue__c', 'EffectiveDate__c'};
    
        Set<Id> setAccids = new Set<Id>();
        for(Id HAId : newMap.keyset()) {
            HistoryAccount__c HAnew = newMap.get(HAId);
            setAccids.add(HAnew.Entreprise__c);
        }
        
        Map<Id, Map<Id, HistoryAccount__c>> mapHAbyAccIds = new Map<Id, Map<Id, HistoryAccount__c>>();
        for(HistoryAccount__c ha : [SELECT id, oldValue__c, newValue__c, EffectiveDate__c, lastModifiedDate, Entreprise__c, Field__c FROM HistoryAccount__c WHERE Entreprise__c IN :setAccIds]) {
            Map<Id, HistoryAccount__c> mapHa = mapHAbyAccIds.get(ha.Entreprise__c);
            if(mapHa == null) {
                mapHa = new Map<id, HistoryAccount__c>();
                mapHAbyAccIds.put(ha.Entreprise__c, mapHa);
            }
            mapHa.put(ha.Id, ha);
        }
        
        for(Id HAId : newMap.keyset()) {
            HistoryAccount__c HAold = oldMap.get(HAId);
            HistoryAccount__c HAnew = newMap.get(HAId);
            for(string champ: listChamp){
                if(HAold.get(champ) != HAnew.get(champ)) {
                    if(champ.equals('EffectiveDate__c')) {
                        HistoryAccount__c closestHa;
                        for(Id idHa : mapHAbyAccIds.get(HAnew.Entreprise__c).keySet()) {
                            if(idHa != HAnew.Id) {
                                HistoryAccount__c tmpHa = mapHAbyAccIds.get(HAnew.Entreprise__c).get(idHa);
                                if(tmpHa.Field__c == HAnew.Field__c && tmpHA.EffectiveDate__c <= HAnew.EffectiveDate__c) {
                                    if(closestHa == null) {
                                        closestHa = tmpHA;
                                    }
                                    if(tmpHA.EffectiveDate__c >= closestHa.EffectiveDate__c){
                                        closestHa = tmpHA;
                                    }
                                }
                            }
                        }
                        System.debug('closestHa => '+closestHa);
                        fromUpdateHA = true;
                        if(closestHa != null) {
                            HAnew.OldValue__c = closestHa.NewValue__c;
                        }
                    }
                }
            }
        }
    }
    
    //Méthode permettant de mettre à jour les HA qui entourent le HA que l’on vient de modifier. Applique les bonnes valeurs au compte si besoin est (dans le cas de la modification de la date effective d’un HA il se peut que la valeur d’un champ d’un compte change.
    public static void onAfterUpdateHistoryAcc(Map<Id,HistoryAccount__c> oldMap, Map<Id,HistoryAccount__c> newMap) {
        System.debug('AP04_Account::onAfterUpdateHistoryAcc::Begin');
        List<String> listChamp = new List<String>{'NewValue__c','EffectiveDate__c'};
        
        Set<Id> setAccids = new Set<Id>();
        for(Id HAId : newMap.keyset()) {
            HistoryAccount__c HAnew = newMap.get(HAId);
            setAccids.add(HAnew.Entreprise__c);
        }    
        
        Map<Id, Map<Id, HistoryAccount__c>> mapHAbyAccIds = new Map<Id, Map<Id, HistoryAccount__c>>();
        for(HistoryAccount__c ha : [SELECT id, oldValue__c, newValue__c, EffectiveDate__c, lastModifiedDate, Entreprise__c, Field__c FROM HistoryAccount__c WHERE Entreprise__c IN :setAccIds]) {
            Map<Id, HistoryAccount__c> mapHa = mapHAbyAccIds.get(ha.Entreprise__c);
            if(mapHa == null) {
                mapHa = new Map<id, HistoryAccount__c>();
                mapHAbyAccIds.put(ha.Entreprise__c, mapHa);
            }
            mapHa.put(ha.Id, ha);
        }
        
       Map<Id, Account> mapAccountById = new Map<Id, Account>([SELECT BillingCity, BillingStreet, BillingCountry, BillingPostalCode, VatLimitDate__c,
                LegalStatus__c, OwnerId, nbOfShares__c, CommercialName__c, Name, TaxSystem__c, VatSystem__c, Siret__c, TaxingType__c, Status__c, id FROM Account]);


        
        List<HistoryAccount__c> listHAToUpdate = new List<HistoryAccount__c>();
        List<Account> listAccToUpdate = new List<Account>();
      for(Id HAId : newMap.keyset()) {
            HistoryAccount__c HAold = oldMap.get(HAId);
            HistoryAccount__c HAnew = newMap.get(HAId);

            String soqlQuery = 'SELECT Id, '+HAnew.Field__c+' FROM Account WHERE Id = \''+HAnew.Entreprise__c+'\'';
      Account accountLinked = database.query(soqlQuery);
            for(string champ: listChamp){
                if(HAold.get(champ) != HAnew.get(champ)) {
                    if(champ.equals('EffectiveDate__c')) {
                        HistoryAccount__c closestHaAfter;
                        //On cherche le HA le plus proche dans le futur correspondant au même champ pour la même entreprise afin de changer la valeur de son oldvalue par celle de la newvalue du SH dont on vient de changer la date effective.
                        for(Id idHa : mapHAbyAccIds.get(HAnew.Entreprise__c).keySet()) {
                            if(idHa != HAnew.Id) {
                                HistoryAccount__c tmpHa = mapHAbyAccIds.get(HAnew.Entreprise__c).get(idHa);
                                if(tmpHa.Field__c == HAnew.Field__c && tmpHA.EffectiveDate__c >= HAnew.EffectiveDate__c) {
                                    if(closestHaAfter == null) {
                                        closestHaAfter = tmpHA;
                                    }
                                    if(tmpHA.EffectiveDate__c <= closestHaAfter.EffectiveDate__c){
                                        closestHaAfter = tmpHA;
                                    }
                                }
                            }
                        }
                        if(closestHaAfter != null) {
                                System.debug('closestHaAfter => '+closestHaAfter);
                                closestHaAfter.OldValue__c = HAnew.NewValue__c;
                                listHAToUpdate.add(closestHaAfter);
                        }
                        if((Date)HAnew.get(champ) <= Date.today()) {
                            fromUpdateHA = true;
                            HistoryAccount__c HAToApply;
                            for(Id idHa : mapHAbyAccIds.get(HAnew.Entreprise__c).keySet()) {
                                if(idHa != HAnew.Id) {
                                    HistoryAccount__c tmpHa = mapHAbyAccIds.get(HAnew.Entreprise__c).get(idHa);
                                    if(tmpHa.Field__c == HAnew.Field__c && tmpHA.EffectiveDate__c >= HAnew.EffectiveDate__c) {
                                        //On cherche un HA entre celui que l'on vient de modifier et la date d'aujourd'hui pour changer la valeur du champ dans le compte.
                                        if(tmpHA.EffectiveDate__c <= Date.today()) {
                                            if(HAToApply == null) {
                                                HAToApply = tmpHA;
                                            }
                                            if(tmpHA.EffectiveDate__c >=  HAToApply.EffectiveDate__c) {
                                                HAToApply = tmpHA;
                                            }
                                        }
                                    }
                                }
                            }
                            if(HAToApply != null) {
                                Account acc = mapAccountById.get(HAToApply.Entreprise__c);
                                if(acc != null) {
                                    acc.put(HaToApply.Field__c, HAToApply.NewValue__c);
                                    listAccToUpdate.add(acc);
                                }
                            }
                            else {
                                Account acc = mapAccountById.get(HAnew.Entreprise__c);
                                if(acc != null) {
                                    acc.put(HAnew.Field__c, HAnew.NewValue__c);
                                    listAccToUpdate.add(acc);
                                }
                            }
                        }
                        else {
                            if((Date)HAold.get(champ) <= Date.today()) {
                                fromUpdateHA = true;
                                HistoryAccount__c HAToApply;
                                for(Id idHa : mapHAbyAccIds.get(HAold.Entreprise__c).keySet()) {
                                    if(idHa != HAold.Id) {
                                        HistoryAccount__c tmpHa = mapHAbyAccIds.get(HAold.Entreprise__c).get(idHa);
                                        if(tmpHa.Field__c == HAold.Field__c) {
                                            if(tmpHA.EffectiveDate__c <= Date.today() && HAold.EffectiveDate__c >= tmpHA.EffectiveDate__c) {
                                                if(HAToApply == null) {
                                                    HAToApply = tmpHA;
                                                }
                                                if(tmpHA.EffectiveDate__c >=  HAToApply.EffectiveDate__c) {
                                                    HAToApply = tmpHA;
                                                }
                                                System.debug('HaToApply => '+HAToApply);
                                            }
                                        }
                                    }
                                }
                                if(HAToApply != null) {
                                    Account acc = mapAccountById.get(HAToApply.Entreprise__c);
                                    if(acc != null) {
                                        acc.put(HaToApply.Field__c, HAToApply.NewValue__c);
                                        listAccToUpdate.add(acc);
                                    }
                                }
                            }
                            fromUpdateHA = true;
                            
                        }
                    }
                    //Fin verif modif date effective
                    else {
                        if(champ.equals('NewValue__c')) {
                            System.debug('DANS LE ELSE');
                            fromUpdateHA = true;
                            HistoryAccount__c closestHaAfter;
                            HistoryAccount__c HAToUpdate;
                            boolean updateAcc = true;
                            for(Id idHa : mapHAbyAccIds.get(HAold.Entreprise__c).keySet()) {
                                if(idHa != HAnew.Id) {
                                    HistoryAccount__c tmpHa = mapHAbyAccIds.get(HAnew.Entreprise__c).get(idHa);
                                    if(tmpHa.Field__c == HAnew.Field__c) {
                                        if(HAnew.EffectiveDate__c < tmpHA.EffectiveDate__c) {
                                            if(HAToUpdate == null) {
                                                HAToUpdate = tmpHA;
                                            }
                                            if(tmpHA.EffectiveDate__c <=  HAToUpdate.EffectiveDate__c) {
                                                HAToUpdate = tmpHA;
                                            }
                                        }
                                        if(HAnew.EffectiveDate__c > Date.today()) {
                                            updateAcc = false;
                                        } 
                                        else if(HAnew.EffectiveDate__c <= Date.today() && tmpHa.EffectiveDate__c >= HAnew.EffectiveDate__c) {
                                            updateAcc = false;
                                        }
                                    }
                                }
                            }
                            if(HAToUpdate != null) {
                                HAToUpdate.OldValue__c = HAnew.NewValue__c;
                                listHAToUpdate.add(HAToUpdate);
                            }
                            if(updateAcc == true) {
                                Account acc = mapAccountById.get(HAnew.Entreprise__c);
                                if(acc != null) {
                                    acc.put(Hanew.Field__c, HAnew.NewValue__c);
                                    listAccToUpdate.add(acc);
                                }
                            }
                        }
                    }
                }
            }
        }
        if(listHAToUpdate.size() > 0) {
            update listHAToUpdate;
        }
        if(listAccToUpdate.size() > 0) {
            update listAccToUpdate;
        }
    }
}