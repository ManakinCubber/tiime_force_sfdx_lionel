/**
* author:		Kévin Melliand
* date:			13/12/2018
* description:	Classe PAD pour bypasser certaines actions selon le user 
* test:			PAD_TEST (100%).
*/
public class PAD {
    
    private static User currentUser;
    
    private static Set<String> bypassedValuesSet = new Set<String>();
    
    public static boolean canTrigger(String actionValue) {
    	
    	setUpUser();
    	
    	return !(currentUser.BypassAllTriggers__c || bypassedValuesSet.contains(actionValue));
    }
    
    private static void setUpUser() {
    	
    	if(currentUser == null) {
    		
    		currentUser = [SELECT Id, BypassAllTriggers__c, BypassTriggers__c FROM User WHERE Id = :UserInfo.getUserId()];
    		
    		if(String.isNotBlank(currentUser.BypassTriggers__c)) {
    			for(String s : currentUser.BypassTriggers__c.split(Constants.CUSTOM_LABEL_INNER_SEPARATOR)) {
    				bypassedValuesSet.add(s);
    			}
    		}
    	}
    }
}