public class RdvController {

   /* public Class Wrapp{
        @AuraEnabled public List<IntraTeamJunction__c> intra {set;get;}
        @AuraEnabled public List<User> Us {set;get;}
    }
    */
    @AuraEnabled
    public static Lead getLead(string leadId){
        Lead l = [select name, Id, MobilePhone, city, street, postalCode, email, Status from Lead where id = :leadId];
        return l;
    }
    
    /*@AuraEnabled
public static List<User> getMembres(string BU){
BU = BU.remove('"');
List<IntraTeamJunction__c > lJunction = [select id, intrapreneur__c, Team__r.BU__c from IntraTeamJunction__c where intrapreneur__r.priseRdvSales__c = true and PrimaryRelationship__c = true and Team__r.BU__c = :BU];
Set<id> setUser = new Set<id>();
system.debug('User '+lJunction);
for(IntraTeamJunction__c lJ : lJunction){
setUser.add(lJ.intrapreneur__c);
}
List<User> membres = [select id, Name, MobilePhone from User where id in :setUser];
return membres;

}*/
   /* @AuraEnabled
    public static List<User> getMembre(string BU){
        BU = BU.remove('"');
        List<IntraTeamJunction__c > lJunction = [select id, intrapreneur__c from IntraTeamJunction__c where intrapreneur__r.priseRdvSales__c = true and PrimaryRelationship__c = true and Team__r.BUnew__c = :BU];
        Set<id> setUser = new Set<id>();
        system.debug('User '+lJunction);
        for(IntraTeamJunction__c lJ : lJunction){
            setUser.add(lJ.intrapreneur__c);
        }
        List<User> membres = [select id, Name, MobilePhone from User where id in :setUser];
        return membres;
    }*/
    
/*    @AuraEnabled
    public static Wrapp getMembres(string BU){
        BU = BU.remove('"');
        Schema.DescribeSObjectResult objDescribe = Schema.getGlobalDescribe().get('Team__c').getDescribe();
		Map<String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
		list<Schema.PicklistEntry> values = fieldMap.get('BUnew__c').getDescribe().getPickListValues();
		System.debug('HOULOULOU => '+values);
        
        for (Schema.PicklistEntry a: values) {
            if(a.getLabel().equals(BU)) {
                System.debug('HOULOULOU => '+a.getValue());
                BU = a.getValue();
            }
		}
        
       // List<IntraTeamJunction__c > lJunction = [select id, intrapreneur__c, Team__r.BUNew__c, Team__r.Street__c, Team__r.City__c, Team__r.PostalCode__c from IntraTeamJunction__c where intrapreneur__r.priseRdvSales__c = true and PrimaryRelationship__c = true and Team__r.BUNew__c = :BU];
        Set<id> setUser = new Set<id>();
        for(IntraTeamJunction__c lJ : lJunction){
            setUser.add(lJ.intrapreneur__c);
        }
        List<User> membres = [select id, Name, MobilePhone from User where id in :setUser];
        Wrapp w = new Wrapp();
      //  w.intra = lJunction;
        w.Us = membres;
        system.debug('membres '+membres);
        return w;
    }
    */
   /* @AuraEnabled
    public static BU__c getBu(string bu){
        system.debug('bu value '+bu);
        BU__c b = [select id, Name from BU__c where Name = :bu];
        return b;
    }
    */
    
   /* @AuraEnabled
    public static List<Event> getEventByBu(string Bu, string chosenDate){
        system.debug('bu '+Bu);
      //  List<User> users = getMembre(Bu);
        system.debug('chosenDate => '+chosenDate);
        Date d = (Date)JSON.deserialize(chosenDate, Date.class);
        List<Event> uEvent = [select id, Subject, ActivityDate, StartDateTime, DurationInMinutes, Who.Name, WhoId, EndDateTime, ActivityDateTime, OwnerId, Owner.Name from Event  where OwnerId in :users and ActivityDate = :d ];
        for(event e : uEvent){
Integer offset = UserInfo.getTimezone().getOffset(e.StartDateTime);
e.StartDateTime = e.StartDateTime.addSeconds(offset/1000);
Integer offset2 = UserInfo.getTimezone().getOffset(e.EndDateTime);
e.EndDateTime = e.EndDateTime.addSeconds(offset2/1000);
}
        return uEvent;
    }
    */
 /*   @AuraEnabled
    public static List<intraTeamJunction__c> getTeam(){
        List<IntraTeamJunction__c> iTJ = [select id, TeamInfoFormulaBUnew__c, TeamInfoFormulaStreet__c, TeamInfoFormulaPostalCode__c, TeamInfoFormulaCity__c, intrapreneur__c from IntraTeamJunction__c where PrimaryRelationship__c = true];
        system.debug('itj '+iTJ);
        return iTJ;
    }
    */
    @AuraEnabled
    public static List<Event> getEventByMember(string User, string chosenDate){
        Date d = (Date)JSON.deserialize(chosenDate, Date.class);
        system.debug('User '+User);
        List<Event> uEvent = [select id, Subject, ActivityDate, StartDateTime, DurationInMinutes, Who.Name, WhoId, EndDateTime, ActivityDateTime, OwnerId, Owner.Name from Event  where OwnerId = :User and ActivityDate = :d ];
        /*for(event e : uEvent){
Integer offset = UserInfo.getTimezone().getOffset(e.StartDateTime);
e.StartDateTime = e.StartDateTime.addSeconds(offset/1000);
Integer offset2 = UserInfo.getTimezone().getOffset(e.EndDateTime);
e.EndDateTime = e.EndDateTime.addSeconds(offset2/1000);
}*/
        return uEvent;
    }
    
    @AuraEnabled
    public static string currentUser(){
        string first = UserInfo.getFirstName();
        string last = UserInfo.getLastName();
        system.debug(first +' '+last);
        return (first +' '+last);
    }
    
    @AuraEnabled
    public static List<Event> getEvent(string s, string chosenDate){  
        Date d = (Date)JSON.deserialize(chosenDate, Date.class);
        User u = (User)JSON.deserialize(s, User.class);
        time debut = Time.newInstance(8, 0, 0, 0);
        time fin = Time.newInstance(20, 0, 0, 0);
        date deb = d.addDays(-14);
        dateTime start = DateTime.newInstance(deb, debut);
        date ed = d.addDays(14);
        dateTime endDate = DateTime.newInstance(ed, fin);
        List<Event> uEvent = [select id, Subject, ActivityDate, StartDateTime, DurationInMinutes, Who.Name, WhoId, EndDateTime, ActivityDateTime from Event  where OwnerId = :u.Id and ActivityDate = :d ];
        /*List<Event> uEvents = [select id, Subject, ActivityDate, StartDateTime, DurationInMinutes, Who.Name, WhoId, EndDateTime, ActivityDateTime from Event  where OwnerId = :u.Id  and startDatetime  > :start ];
List<Event> uEventz = [select id, Subject, ActivityDate, StartDateTime, DurationInMinutes, Who.Name, WhoId, EndDateTime, ActivityDateTime from Event  where OwnerId = :u.Id  and enddateTime < :endDate];
uEvent.addall(uEvents);
uEvent.addall(uEventz);
List<Event> lEvent = new List<Event>();
Set<Event> sEvent = new Set<Event>();
sEvent.addall(uEvent);
lEvent.addAll(sEvent);*/
        system.debug('events '+uEvent);
        for(event e : uEvent){
            Integer offset = UserInfo.getTimezone().getOffset(e.StartDateTime);
            e.StartDateTime = e.StartDateTime.addSeconds(offset/1000);
            Integer offset2 = UserInfo.getTimezone().getOffset(e.EndDateTime);
            e.EndDateTime = e.EndDateTime.addSeconds(offset2/1000);
        }
        return uEvent;
    }

    /*@future(callout=true)
    public static void sendToRGoogleCalendar(Id eventId) {
        //Event event = (Event)JSON.deserialize(eventString, Event.class);
        List<Event> event = [Select Id, StartDateTime, EndDateTime, OwnerId, Owner.Username, Description, Location, Subject FROM Event Where Id =: eventId];
        String dateFinFinale = String.valueOf(event[0].EndDateTime);
        String dateDebutFinale = String.valueOf(event[0].StartDateTime);
        dateFinFinale = dateFinFinale+'+02:00';
        dateFinFinale = dateFinFinale.replaceAll(' ', 'T');
        dateDebutFinale = dateDebutFinale+'+02:00';
        dateDebutFinale = dateDebutFinale.replaceAll(' ', 'T');
        String description = event[0].Description;
        if(description != null) {
          description = description.replace('\n','\\n');
        }
        else {
            description = '';
        }
        System.debug('Owner => '+event[0].Owner.Username);
        if(event[0].Owner.Username == 'test.quentin@tiime.fr') {
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setEndPoint('callout:AuthGoogle/calendars/test.quentin@tiime.fr/events');
            //request.setEndPoint('callout:AuthGoogle/calendars/poirie_n@etna-alternance.net/events');
            String reqBody = '{"end": { "dateTime": "'+dateFinFinale+'"},"start": { "dateTime": "'+dateDebutFinale+'"}, "description": "'+description+'", "summary": "'+event[0].subject+'"}';
            request.setBody(reqBody);
        	system.debug(request.getBody());
            HttpResponse response = new HTTP().send(request);
            System.debug('DEBUT => \n'+dateDebutFinale);
            System.debug('FIN => \n'+dateFinFinale);
            System.debug('RESULTAT REQUÊTE => \n'+response.getBody());
        }
    }*/

    /*@AuraEnabled
    public static void checkSync(Map<id,Event> newMap) {
        for(Id eId : newMap.keySet()) {
            Event e = newMap.get(eId);
            if(e.FromComposant__c == true) {
                Datetime createdDate = e.CreatedDate;
                createdDate = createdDate.addMinutes(5);
                if(CreatedDate >= Datetime.now()) {
                    //e.addError('Synchronisation avec Google calendar en cours. Impossible d\'éditer cet enregistrement.');
                }
            }
        }
    }*/

    @AuraEnabled
    public static List<Id> save(string rdv, string endTime, string startTime, string name){
        system.debug(name);
        Event e = (Event)JSON.deserialize(rdv, Event.class);
		Lead l = new Lead();
        try{
            //RecordType rt = [select id, developerName from RecordType where developerName = 'Sales'];
            system.debug('end '+endTime+ '\nstart '+startTime);
            e.EndDateTime = (DateTime)JSON.deserialize(endTime, DateTime.class);
            e.StartDateTime = (DateTime)JSON.deserialize(startTime, DateTime.class);
            system.debug(e+'\n'+e.enddatetime+'\n'+e.startdatetime);
            long duration = (e.EndDateTime.getTime() - e.StartDateTime.getTime())/60000;
            e.DurationInMinutes = duration.intValue();
            e.firstRDV__c = true;
            //e.RecordTypeId = rt.Id;
            /*Integer offset = UserInfo.getTimezone().getOffset(e.StartDateTime);
            e.StartDateTime = e.StartDateTime.addSeconds(offset/1000);
            Integer offset2 = UserInfo.getTimezone().getOffset(e.EndDateTime);
            e.EndDateTime = e.EndDateTime.addSeconds(offset2/1000);*/
            system.debug('SAVE//DEBUG \n'+e);
            //e.FromComposant__c = true;
            //insert e;
            
        }
        catch(Exception ex){
            system.debug(ex.getMessage()+' '+ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage()+' '+ex.getStackTraceString());
        }
        system.debug('name '+e.Who.Name);
        List<id> whoAndWhat = new List<id>();
        //whoAndWhat.add(l.convertedContactId);
        //whoAndWhat.add(l.convertedOpportunityId);
        //String eventJson = JSON.serialize(e);
        //sendToRGoogleCalendar(e.Id);

    	return whoAndWhat;
        //return created.id;
    }
}