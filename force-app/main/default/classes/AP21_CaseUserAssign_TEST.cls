@isTest
private class AP21_CaseUserAssign_TEST {

    static testMethod void testCaseAutoAssign() {
    	/*List<Account> accounts = AP04_Factory.partnerAccountsFactory(1);
    	User u = AP04_Factory.UserStandardFactory(1, 'Jean', 'Michel', 'jean.michel@example.org')[0];
    	
    	insert u;
    	accounts[0].Accounting__c = u.Id;
        
    	insert accounts[0];
    	
    	Test.startTest();
    	Case c = new Case(AccountId = accounts[0].Id, Status = 'Nouveau', Origin = 'Email');
    	insert c;
    	Test.stopTest();
    	
    	c = [SELECT Id, OwnerId FROM Case WHERE Id = :c.Id];
    	System.assert(c.OwnerId == u.Id);*/
    }
}