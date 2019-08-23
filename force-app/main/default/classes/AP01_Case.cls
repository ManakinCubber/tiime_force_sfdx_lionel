/**
    This class is used to evaluate the Cumulate Time number
    It could be done by Process Builder because the LastModifiedDate fields is change before the call of the process builder
 */
public class AP01_Case {
    
    public static void manageCumulateTime(Map<Id,Case> oldMap, Map<Id,Case> newMap) {
        for (id caseId : newMap.keySet()){
            // Initialisation des objets pour comparaison
            Case caseOld = oldMap.get(caseId);
            Case caseNew = newMap.get(caseId);
            if (caseOld.Status != caseNew.Status && caseNew.Status == 'Fermé'){
                Long dtNowLong = Datetime.now().getTime();
                Long dtLastDateLong = caseOld.LastModifiedDate.getTime();
                Double diffDate = dtNowLong - dtLastDateLong;
                // Millisecond to hours
                caseNew.CumulateTime__c = caseOld.CumulateTime__c + diffDate / 60 / 60 / 1000;
            }
        }
    }
}