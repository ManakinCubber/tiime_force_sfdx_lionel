public class PicklistController {
    
    //Récupère les champs de picklist d'un objet pour les afficher sur le composant
    @AuraEnabled    
    public static List<String> getPickListValuesIntoList(String objectType, String selectedField){
        List<String> pickListValuesList = new List<String>();
        system.debug(objectType +'\n'+ selectedField);
        system.debug(Schema.getGlobalDescribe());
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        system.debug(convertToObj);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        pickListValuesList.add(' ');
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        } 
        return pickListValuesList;
    }
    
}