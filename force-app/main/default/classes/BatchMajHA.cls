global class BatchMajHA implements Database.Batchable<sObject> {
    global List<HistoryAccount__c> listHA;
    
    global BatchMajHA() {
         this.listHA = [SELECT id, Field__c, newValue__c, Entreprise__c, Type__c FROM HistoryAccount__c WHERE EffectiveDate__c = :Date.today() ORDER BY LastModifiedDate ASC];
    }
    
    global List<HistoryAccount__c> start(Database.BatchableContext bc) {
        return this.listHA;
    }
    
    global void execute(Database.BatchableContext bc, List<HistoryAccount__c> listHA) {
        if(!listHA.isEmpty()) {
            //Initialisation de la Map des comptes
            Map<Id,Account> mapAcc = new Map<Id,Account>();
            //Pour chaque HA on crée un objet de type compte en lui donnant l'id du compte au quel est rattaché
            for(HistoryAccount__c unHA : listHA) {
             	//On Vérifie si le compte qui doit être maj est dans la map, si il n'y est pas, on crée un objet de type compte et on l'ajoute à la map.
             	//Si il existe dans la map on met à jour l'attribut du compte.
                if(mapAcc.containsKey(unHA.Entreprise__c)) {
                    //On vérifie le type du champ afin d'éviter les erreurs des types (String dans le HA mais peut être un double ou une date dans le compte en fonction du champ)
                    if(unHA.Type__c == 'double') {
                        mapAcc.get(unHA.Entreprise__c).put(unHA.Field__c, decimal.valueOf(unHA.NewValue__c));
                    }
                    else if(unHA.Type__c == 'date') {
                    	mapAcc.get(unHA.Entreprise__c).put(unHA.Field__c, date.valueOf(unHA.NewValue__c));
                	}
                    else {
                        mapAcc.get(unHA.Entreprise__c).put(unHA.Field__c, unHA.NewValue__c);
                    }
                }
                else {
                    Account unAcc = new Account(Id = unHA.Entreprise__c);
                    if(unHA.Type__c == 'double') {
                        unAcc.put(unHA.Field__c, decimal.valueOf(unHA.NewValue__c));
                    }
                    else if(unHA.Type__c == 'date') {
                    	unAcc.put(unHA.Field__c, date.valueOf(unHA.NewValue__c));
                	}
                    else {
                        unAcc.put(unHA.Field__c, unHA.NewValue__c);
                    }
                    mapAcc.put(unHA.Entreprise__c, unAcc);
                }
            }
            update mapAcc.values();
            System.debug('MAP DES MAJ => ' + mapAcc);
        }
    }
    
    global void finish(Database.BatchableContext bc) {
    }
}