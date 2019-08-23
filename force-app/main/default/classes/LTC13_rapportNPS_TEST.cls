@isTest
private class LTC13_rapportNPS_TEST {
	
	@isTest
    static void testGetEnquetes() {
        User user = AP04_Factory.UserStandardFactory(1, 'nomPourTest', 'PrenomDeTest' , 'userTest@test.fr')[0];
		insert user;
		Integer nbEnquetes=0;
		System.runAs(user){
			Account acc = AP04_Factory.partnerAccountsFactory(1)[0];
			insert acc;
			Lead l = AP04_Factory.LeadFactory(1, '0605040506', 'lalead', 'leadcorp')[0];
			insert l;
			List<enquetedeSatisfaction__c> enq = AP04_Factory.enqueteFactory(10,acc.Id,l.Id);
			nbEnquetes = enq.size();
			insert enq;
		}
		System.debug(nbEnquetes);
		
		Account acc = [Select Id From Account Where OwnerId=:user.Id][0];
		
		Test.startTest();
		Integer nbEnqFromAcc = LTC13_rapportNPS.getEnquetes(acc.Id).size();
		Test.stopTest();
        
		System.assertNotEquals(nbEnqFromAcc, null);
		System.assertEquals(nbEnqFromAcc, nbEnquetes);
    }
    @isTest 
	static void testLabels() {
		Map<String, String> labels = LTC13_rapportNPS.getLabels();
		System.assertEquals(6, labels.size());
	}
}