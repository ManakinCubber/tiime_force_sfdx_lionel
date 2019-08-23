public class CloneStakeholderController {
    
    private String recordId;
    private Stakeholder__c SHToClone, lastSH;
    private Date dateDebut, dateFin;
    
    public CloneStakeholderController(ApexPages.StandardController controller) {
        recordId = controller.getRecord().Id;
    }
    
 	public PageReference cloneStakeholder() {
        PageReference pageRef;
        List<Stakeholder__c> laterSHExists;
        
        SHToClone = [SELECT Id, Name, RecordTypeId, Contact__c, Company__c, PrincipalContact__c, StartDate__c, EndDate__c FROM Stakeholder__c WHERE Id = :recordId];
        if(SHToClone.EndDate__c != null) {
            laterSHExists = [SELECT id, PrincipalContact__c, Company__c, Contact__c, StartDate__c, EndDate__c  FROM Stakeholder__c WHERE Company__c =: SHToClone.Company__c
                                               	AND Contact__c =: SHToClone.Contact__c AND RecordTypeId =: SHToClone.RecordTypeId AND Id != :SHToClone.Id
                                              	AND (EndDate__c > :SHToClone.EndDate__c OR EndDate__c = null)
                                               	ORDER BY EndDate__c DESC];
        }
        else {
            laterSHExists = [SELECT id, PrincipalContact__c, Company__c, Contact__c, StartDate__c, EndDate__c  FROM Stakeholder__c WHERE Company__c =: SHToClone.Company__c
                                               	AND Contact__c =: SHToClone.Contact__c AND RecordTypeId =: SHToClone.RecordTypeId AND Id != :SHToClone.Id
                                              	AND EndDate__c = null
                                               	ORDER BY EndDate__c DESC];
        }
        
        
            
        System.debug('SHToClone::'+SHToClone);
        if(SHToClone.EndDate__c == null) {
            if(SHToClone.StartDate__c < Date.today()) {
            	SHToClone.EndDate__c = Date.today();
                dateDebut = Date.today();
           		dateDebut = dateDebut.addDays(1);
            }
            else if(SHToClone.StartDate__c >= Date.today()) {
                
                dateFin = SHToClone.StartDate__c;
                dateFin = dateFin.addDays(1);
                SHToClone.EndDate__c = dateFin;
                System.debug(' SHToClone.EndDate__c '+ SHToClone.EndDate__c);
                dateDebut = dateFin.addDays(1);
                System.debug(' dateDebut '+ dateDebut);
            }
        }
        else {
            dateDebut = SHToClone.EndDate__c;
            dateDebut = dateDebut.addDays(1);
        }
        
        if(laterSHExists.size() > 0) {
            lastSH = laterSHExists[0];
            if(lastSH.EndDate__c == null ) {
                System.debug('SHlater sans EndDate');
                if(lastSH.StartDate__c < Date.today()) {
                    lastSH.EndDate__c = Date.today();
                    dateDebut = Date.today();
           			dateDebut = dateDebut.addDays(1);
                }
                else {
                    System.debug('Dans le Else');
                    System.debug('Date lastSH.StartDate__c :: '+lastSH.StartDate__c);
                    dateFin = lastSH.StartDate__c;
                    dateFin = dateFin.addDays(1);                    
                    lastSH.EndDate__c = dateFin;
                    System.debug('Daate lastSH.EndDate__c :: '+lastSH.EndDate__c);
                    dateDebut = dateFin.addDays(1);
                    System.debug('Date début newSH :: '+dateDebut);
                }
            }
            else {
                System.debug('laterSHExists => '+laterSHExists);
                dateDebut = lastSH.EndDate__c;
            	dateDebut = dateDebut.addDays(1);
            }
        }
        System.debug(' dateDebut2 '+ dateDebut);
        Stakeholder__c newSH = new StakeHolder__c(RecordTypeId = SHToClone.RecordTypeId, Contact__c = SHToClone.Contact__c, Company__c = SHToClone.Company__c, PrincipalContact__c = SHToClone.PrincipalContact__c,
                                                  StartDate__c = dateDebut);
        try{
            Update SHToClone;
            System.debug('lastSH :: '+lastSH);
            if(lastSH != null) {
                Update lastSH;
            }
            System.debug('newSH::'+newSH);
            Insert newSH;
            System.debug('newSH::'+newSH);
        }
        catch(Exception ex){
            System.debug('ERROR INSERT :: ' + ex.getMessage());
            ApexPages.addMessages(ex);
        }

        if(newSH.Id == null) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, 'ERREUR');
            ApexPages.addMessage(msg);
            pageRef = new PageReference('/'+SHToClone.Id);
        }
        else {
            pageRef = new PageReference('/'+newSH.Id);
        }
        pageRef.setRedirect(true);
       	return pageRef;
    }
}