/**
* author:		Kévin Melliand
* date:			14/12/2018
* description:	Classe testant PAD. Couverture du code à 100%.
*/
@isTest
public class PAD_TEST {
    
    private static List<Schema.PicklistEntry> pleList = User.BypassTriggers__c.getDescribe().getPicklistValues();
    
    private static String usernamePad = 'test.pad@tiime.fr';
    private static String usernameAllPad = 'test.allpad@tiime.fr';
    private static String usernameNoPad = 'test.nopad@tiime.fr';
    
    private static Integer startValue = 1;
    private static Integer endValue = 2;
    
    
    
    @TestSetup
    static void dataSetup() {
    	
    	// Créer un utilisateur avec un le champ Bypass renseigné.
    	//Schema.DescribeFieldResult fieldResult = User.BypassTriggers__c.getDescribe();
    	//List<Schema.PicklistEntry> pleList = User.BypassTriggers__c.getDescribe().getPicklistValues();
    	
    	User userWithBypass = AP04_Factory.UserStandardFactory(1, 'Test','WithPAD' , usernamePad).get(0);
    	User userWithAllBypass = AP04_Factory.UserStandardFactory(1, 'Test','WithAllPAD' , usernameAllPad).get(0);
    	User WithoutBypass = AP04_Factory.UserStandardFactory(1, 'Test','WithoutPAD' , usernameNoPad).get(0);
    	
    	userWithBypass.BypassTriggers__c = pleList.get(0).getValue();
    	userWithAllBypass.BypassAllTriggers__c = true;

		insert new List<User> {userWithBypass, userWithAllBypass, WithoutBypass};
    }
    
    @isTest
    static void testNoBypassUserBehaviour() {
    	User user = [SELECT Id FROM User WHERE Username = :usernameNoPad].get(0);
    	
    	Integer result = mockAction(user);
    	
    	// Ce user ne bypassant rien, le résultat doit valoir endValue (2)
    	System.assertEquals(endValue, result);
    }
    
    @isTest
    static void testBypassUserBehaviour() {
    	User user = [SELECT Id FROM User WHERE Username = :usernamePad].get(0);
    	
    	Integer result = mockAction(user);
    	
    	// Ce user ne bypassant rien, le résultat doit valoir startValue (1)
    	System.assertEquals(startValue, result);
    }
    
    @isTest
    static void testAllBypassUserBehaviour() {
    	User user = [SELECT Id FROM User WHERE Username = :usernameAllPad].get(0);
    	
    	Integer result = mockAction(user);
    	
    	// Ce user ne bypassant rien, le résultat doit valoir startValue (1)
    	System.assertEquals(startValue, result);
    }
    
    private static Integer mockAction(User user){
    	Integer returnValue = startValue;
    	System.runAs(user) {
    		if(PAD.canTrigger(pleList.get(0).getValue())) {
    			returnValue = endValue;
    		}
    	}
    	return returnValue;
    }
}