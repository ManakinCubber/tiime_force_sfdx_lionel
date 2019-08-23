public class AP02_EventFromLead {

    public static void eventAfterInsert(Map<Id, Event> newMap) {

        if(newMap.size() == 1) {
            string uId = UserInfo.getUserId();
            user u = [select profile.name from user where id = :uId];

            set<Id> leadConverted = new set<Id>();
            Map<Event,Lead> LeadByEvent = new Map<Event,Lead>();

            for(Id eventId : newMap.keySet()) {
                Event newEvent = newMap.get(eventId);
                if(newEvent.WhoId != null) {
                    String objectName = '';
                    String myIdPrefix = String.valueOf(newEvent.WhoId).substring(0,3);
                    //Récupération des schèmas des objets
                    Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe();
                    //On parcourt les schèmas et on récupère celui qui correspond au WhoId rattaché à l'event. Si celui-ci correspond à une lead, on convertit la lead.
                    for(Schema.SObjectType stype : gd.values()){
                        Schema.DescribeSObjectResult r = stype.getDescribe();
                        String prefix = r.getKeyPrefix();

                        if(prefix!=null && prefix.equals(myIdPrefix)){
                            objectName = r.getName();
                            System.debug('Object Name! ' + objectName);
                            break;
                        }
                    }

                    if(objectName == 'Lead') {
                        Database.LeadConvert lc = new database.LeadConvert();
                        lc.setLeadId(newEvent.WhoId);
                        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
                        lc.setConvertedStatus(convertStatus.MasterLabel);
                        Database.LeadConvertResult lcr = Database.convertLead(lc);
                        if(lcr.isSuccess()){
                            system.debug('lead converted');
                            leadConverted.add(newEvent.WhoId);
                        }
                    }
                }
            }
            Map<Id,Lead> leadConvertedMap = New Map<Id, Lead>([select Id, convertedAccountId, convertedOpportunityId, convertedContactId, isConverted from Lead where id IN: leadConverted]);
            List<OpportunityShare> listOppShare = new List<OpportunityShare>();
            for(Id eventId : newMap.keySet()) {
                Event newEvent = newMap.get(eventId);
                Lead l = leadConvertedMap.get(newEvent.WhoId);
                if(l != null) {
                    System.debug('lead => '+l.isConverted);
                    updateFields(l, newEvent.OwnerId, newEvent);
                    //Création des droits en lecture sur les opportunités qui donnent l'accès à l'évenement par hiérarchie. Cela permet à l'utilisateur yant prit le rdv d'y avoir accès.
                    if(UserInfo.getUserId() != newEvent.OwnerId) {
                        OpportunityShare oppShare = new OpportunityShare(OpportunityId = l.convertedOpportunityId, UserOrGroupId = UserInfo.getUserId(), OpportunityAccessLevel = 'Read');
                        listOppShare.add(oppShare);
                    }
                }
            }
            if(listOppShare.size() > 0) {
                insert listOppShare;
            }
        }
    }

    public static void updateFields(Lead l, string OwnerId, event e){
        recordType rtOpp = [select id from recordType where developerName = 'Primary'];
        recordType rtCtc = [select id from recordType where developerName = 'Customer' and sobjectType = 'Contact'];
        RecordType rt = [select id from RecordType where DeveloperName = 'prospect'];
        Account acc = [select id from account where id = :l.convertedAccountId];
        Contact ctc = [select id from contact where id = :l.convertedContactId];
        Opportunity opp = [select id from Opportunity where id = :l.convertedOpportunityId];
        acc.OwnerId = OwnerId;
        acc.RecordTypeId = rt.Id;
        opp.recordTypeId = rtOpp.Id;
        opp.OwnerId = OwnerId;
        opp.CloseDate = e.StartDateTime.date();
        ctc.OwnerId = OwnerId;
        ctc.recordTypeId = rtCtc.Id;
        update acc;
        update opp;
        update ctc;
    }
}