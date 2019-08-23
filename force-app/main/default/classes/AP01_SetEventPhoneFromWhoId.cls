//createdby : pascal GUILLEN
//createddate : 22/05/2018
//Description : mettre à jour PhoneWhoID__c de l'event avec le phone du contact ou lead liée via le champ whoID.
public class AP01_SetEventPhoneFromWhoId {
    public static void EventChanging(List<event> events){
        set<id> WhoIDs = new set<id>();
        for(event evt:events){
            if(evt.whoid!=null){
                WhoIDs.add(evt.whoid);
            }
        }
        Map<id,contact> mapContact = new Map<id,contact>([Select id,Mobilephone from contact where id in:WhoIDs]);
        Map<id,lead> maplead = new Map<id,lead>([Select id,Mobilephone from lead where id in:WhoIDs]);
        
        for(event evt:events){
            string phone = null;
            if(evt.whoid!=null){
                contact ctt = mapContact.get(evt.whoid);
                system.debug('contact='+ctt);
                if(ctt!=null){
                    phone = ctt.Mobilephone;
                }
                lead ld = maplead.get(evt.whoid);
                system.debug('lead='+ld);
                if(ld!=null){
                    phone = ld.Mobilephone;
                }
            }
            evt.PhoneWhoID__c = phone;
        }
    }
}