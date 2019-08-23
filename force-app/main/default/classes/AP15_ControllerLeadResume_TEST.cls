@isTest
public with sharing class AP15_ControllerLeadResume_TEST {

	@isTest 
	static void testLabels() {
		Map<String, String> labels = AP15_ControllerLeadResume.getLabels();
		System.assertEquals(9, labels.size());
	}
	
	@isTest 
	static void testPickListOptions() {
		List<String> fieldNames = new List<String>();
		fieldNames.add('Evaluation_a_priori__c');
		fieldNames.add('Activity__c');
		fieldNames.add('Branding__c');
		List<Map<String, String>> res = AP15_ControllerLeadResume.getPicklistOptions(fieldNames);
		System.assertEquals(3, res.size());
		for(Map<String, String> field : res){
			System.assertEquals(false, field.isEmpty());
		}
	}
	
	@isTest
	static void testNextCallWithBranding(){
		User user = AP04_Factory.UserStandardFactory(1, 'nomPourTes', 'PrenomDeTest' , 'userTest@test.fr')[0];
        insert user;

        System.runAs(user){
            Lead c = AP04_Factory.newWebLeadsFactory(1)[0];
            insert c;
        }
        
		Lead oldLead = [SELECT Id,Status FROM Lead WHERE OwnerId=:user.Id][0];
        String newStatus='';
		Test.startTest();
		newStatus = AP15_ControllerLeadResume.nextCall(oldLead.Id, 'Call 1','Tiime');

		        
        System.debug('Avant : '+oldLead.Status+' , Après : '+newStatus);

        System.assertNotEquals(oldLead.Status, newStatus);
	}
	
	@isTest
	static void testNextCallWithoutBranding(){
		User user = AP04_Factory.UserStandardFactory(1, 'nomPourTes', 'PrenomDeTest' , 'userTest@test.fr')[0];
        insert user;

        System.runAs(user){
            Lead c = AP04_Factory.newWebLeadsFactory(1)[0];
            insert c;
        }
        
		Lead lead = [SELECT Id,Status FROM Lead WHERE OwnerId=:user.Id][0];
        String newStatus='';
        Boolean flag=false;
        try{
			Test.startTest();
			newStatus = AP15_ControllerLeadResume.nextCall(lead.Id, 'Call 1',null);
			Test.stopTest();
        }catch(Exception e){
        	flag=true;
        }
        finally{
        	System.AssertEquals(true,flag);
        }
		
	}
	
	@isTest
	static void testGetStatus(){
		User user = AP04_Factory.UserStandardFactory(1, 'nomPourTes', 'PrenomDeTest' , 'userTest@test.fr')[0];
        insert user;

        System.runAs(user){
            Lead c = AP04_Factory.newWebLeadsFactory(1)[0];
            insert c;
        }
        
		Lead laLead = [SELECT Id,Status FROM Lead WHERE OwnerId=:user.Id][0];
        System.debug(laLead.Status);
        
		Test.startTest();
		String status = AP15_ControllerLeadResume.getStatus(laLead.Id);
		Test.stopTest();
		
		System.assertNotEquals(status, null);
        System.assertEquals(laLead.Status, status);
	}
	
	@isTest
    static void testGetContactPartenariat(){
        Account acc = AP04_factory.partnerAccountsFactory(1)[0];
        insert acc;
        List<Contact> contacts = AP04_factory.partnerContactsFactory(3,acc.Id);
        insert contacts;
        
        contacts = [SELECT Id FROM Contact WHERE AccountId = :acc.Id];
        
        Test.startTest();
        List<Contact> contactsReturned = AP15_ControllerLeadResume.getContactPartenariat(acc.Id);
        Test.stopTest();
        
        System.assertEquals(contacts.size(), contactsReturned.size());
  }
    
    @isTest
    static void testGetLeadEnAttenteId (){
        System.assert(AP15_ControllerLeadResume.getLeadEnAttenteId() != null);
    }
}