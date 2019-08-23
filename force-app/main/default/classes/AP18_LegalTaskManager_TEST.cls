@isTest
public class AP18_LegalTaskManager_TEST {
    
    @TestSetup
    static void prepareData() {
    	AP04_Factory.createGenericDataSample();
    	
    	// Generate an Start__c record
    	List<Lead> leads = [SELECT Id FROM Lead];
    	Start__c start = new Start__c(Crea__c = leads.get(0).Id);
    	insert start;
    	
    	// Generate an Transfert__c record
    	Transfert__c transfert = new Transfert__c(
    		Lead__c = leads.get(0).Id,
    		MobilePhone__c = '0612345789'
    	);
    	insert transfert;
    	
    	// Generate an event on the start record
    	List<Event> events = new List<Event> {
    		new Event(WhatId = start.Id, OwnerId = UserInfo.getUserId(), StartDateTime = DateTime.now(), EndDateTime = Datetime.now().addHours(1)),
    		new Event(WhatId = transfert.Id, OwnerId = UserInfo.getUserId(), StartDateTime = DateTime.now(), EndDateTime = Datetime.now().addHours(1))
    	};
    	insert events;
    }
    
    @isTest
    static void testCreateFirstTaskStart() {
    	List<Start__c> starts = [SELECT Id FROM Start__c];
    	System.assert(starts.size() == 1);
    	List<Event> events = [SELECT Id, NoShow__c FROM Event WHERE WhatId = :starts.get(0).Id];
    	System.assert(events.size() == 1);
    	System.assert(!events.get(0).NoShow__c);
    	
    	// There should be no task
    	List<Task> tasks = [SELECT Id FROM Task];
    	System.assert(tasks.isEmpty());
    	
    	Test.startTest();
    	
    	events.get(0).NoShow__c = true;
    	update events.get(0);
    	
    	Test.stopTest();
    	
    	tasks = [SELECT Id, Subject FROM Task];
    	System.assert(!tasks.isEmpty());
    	System.assert(tasks.get(0).Subject.contains(Constants.TASK_SUBJECT_LEGAL_REMINDER_1));
    }
    
    @isTest
    static void testCreateNextTaskStart() {
    	List<Start__c> starts = [SELECT Id FROM Start__c];
    	System.assert(starts.size() == 1);
    	List<Event> events = [SELECT Id, NoShow__c FROM Event WHERE WhatId = :starts.get(0).Id];
    	events.get(0).NoShow__c = true;
    	update events.get(0);
    	
    	List<Task> tasks = [SELECT Id, Subject, Status, NewTryFail__c FROM Task];
    	
    	Test.startTest();
    	
    	tasks.get(0).NewTryFail__c = true;
    	update tasks.get(0);
    	
    	Test.stopTest();
    	
    	tasks = [SELECT Id, Subject, Status, NewTryFail__c FROM Task ORDER BY Subject DESC];
    	System.assert(tasks.size() == 2);
    	System.assert(tasks.get(0).Subject.contains(Constants.TASK_SUBJECT_LEGAL_REMINDER_2));
    }
    
    @isTest
    static void testCreateFirstTaskTransfert() {
    	List<Transfert__c> transferts = [SELECT Id FROM Transfert__c];
    	System.assert(transferts.size() == 1);
    	List<Event> events = [SELECT Id, NoShow__c FROM Event WHERE WhatId = :transferts.get(0).Id];
    	System.assert(events.size() == 1);
    	System.assert(!events.get(0).NoShow__c);
    	
    	// There should be no task
    	List<Task> tasks = [SELECT Id FROM Task];
    	System.assert(tasks.isEmpty());
    	
    	Test.startTest();
    	
    	events.get(0).NoShow__c = true;
    	update events.get(0);
    	
    	Test.stopTest();
    	
    	tasks = [SELECT Id, Subject, WhatId FROM Task];
    	System.assert(!tasks.isEmpty());
    	System.assert(tasks.get(0).Subject.contains(Constants.TASK_SUBJECT_CAB_REMINDER_1));
    	
    	transferts = [SELECT Id, Etape__c FROM Transfert__c WHERE Id = :tasks.get(0).WhatId];
    	System.assert(transferts.size() == 1);
    	System.assert(transferts.get(0).Etape__c == Constants.TRANSFERT_ETAPE_RDV_ECHOUE);
    }
    
    @isTest
    static void testCreateNextTaskTransfert() {
    	List<Transfert__c> transferts = [SELECT Id FROM Transfert__c];
    	System.assert(transferts.size() == 1);
    	List<Event> events = [SELECT Id, NoShow__c, IssueDeLaRelance__c FROM Event WHERE WhatId = :transferts.get(0).Id];
    	events.get(0).NoShow__c = true;
    	update events.get(0);
    	
    	List<Task> tasks = [SELECT Id, Subject, Status, NewTryFail__c FROM Task];
    	
    	Test.startTest();
    	
    	tasks.get(0).IssueDeLaRelance__c = Constants.TASK_ISSUE_RELANCE_NO_RESPONSE;
    	update tasks.get(0);
    	
    	Test.stopTest();
    	
    	tasks = [SELECT Id, Subject, Status, NewTryFail__c FROM Task ORDER BY Subject DESC];
    	System.assert(tasks.size() == 2);
    	System.assert(tasks.get(0).Subject.contains(Constants.TASK_SUBJECT_CAB_REMINDER_2));
    }
    
    @isTest
    static void testCreateFirstTaskFromOpp() {
    	List<Lead> leads = [SELECT Id FROM Lead];
    	System.assert(!leads.isEmpty());
    	List<Opportunity> opps = [SELECT Id FROM Opportunity];
    	System.assert(opps.isEmpty());
    	
    	Test.startTest();
    	LeadConverterProcessAE converter = new LeadConverterProcessAE(leads.get(0).Id);
    	converter.launchLeadConversion();
    	Test.stopTest();
    	
    	opps = [SELECT Id FROM Opportunity];
    	System.assert(opps.size() == 1);
    	
    	List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :opps.get(0).Id];
    	System.assert(!tasks.isEmpty());
    	
    }
    
    @isTest
    static void testCreateNextTaskNoResponse() {
    	List<Lead> leads = [SELECT Id FROM Lead];
    	System.assert(!leads.isEmpty());
    	LeadConverterProcessAE converter = new LeadConverterProcessAE(leads.get(0).Id);
    	converter.launchLeadConversion();
    	List<Opportunity> opps = [SELECT Id FROM Opportunity];
    	System.assert(opps.size() == 1);
    	List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :opps.get(0).Id AND RecordType.DeveloperName = :Constants.TASK_RECORDTYPE_DEVELOPERNAME_CABINET];
    	System.assert(!tasks.isEmpty());
    	System.debug(tasks.size());
    	
    	Test.startTest();
    	tasks.get(0).IssueDeLaRelance__c = Constants.TASK_ISSUE_RELANCE_NO_RESPONSE;
    	update tasks.get(0);
    	Test.stopTest();
    	
    	tasks = [SELECT Id, Subject FROM Task WHERE WhatId = :opps.get(0).Id ORDER BY Relance__c DESC];
    	System.debug(tasks.size());
    	for(Task t : tasks) {
    		System.debug(t);
    	}
    	System.assert(tasks.size() == 2); // New reminder task + sms task notification => no more sms
    	System.assert(tasks.get(0).Subject == Constants.TASK_SUBJECT_CAB_OPP_NO_RESP_REMINDER_2);
    	
    	opps = [SELECT Id, StageName FROM Opportunity];
    	System.assertEquals(1, opps.size());
    	System.assertEquals(Constants.OPP_STEP_RELANCE_2, opps.get(0).StageName);    	
    }
    
    @isTest
    static void testCreateNextTaskReflexion() {
    	List<Lead> leads = [SELECT Id FROM Lead];
    	System.assert(!leads.isEmpty());
    	LeadConverterProcessAE converter = new LeadConverterProcessAE(leads.get(0).Id);
    	converter.launchLeadConversion();
    	List<Opportunity> opps = [SELECT Id FROM Opportunity];
    	System.assert(opps.size() == 1);
    	List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :opps.get(0).Id AND RecordType.DeveloperName = :Constants.TASK_RECORDTYPE_DEVELOPERNAME_CABINET];
    	System.assert(!tasks.isEmpty());
    	
    	Test.startTest();
    	tasks.get(0).IssueDeLaRelance__c = Constants.TASK_ISSUE_RELANCE_REFLEXION;
    	update tasks.get(0);
    	Test.stopTest();
    	
    	tasks = [SELECT Id, Subject FROM Task WHERE WhatId = :opps.get(0).Id  ORDER BY Relance__c DESC];
    	System.assert(tasks.size() == 2);
    	System.assert(tasks.get(0).Subject == Constants.TASK_SUBJECT_CAB_OPP_REFLEXION_REMINDER_2);
    }
    
    @isTest
    static void testCreateNextTaskWillSign() {
    	List<Lead> leads = [SELECT Id FROM Lead];
    	System.assert(!leads.isEmpty());
    	LeadConverterProcessAE converter = new LeadConverterProcessAE(leads.get(0).Id);
    	converter.launchLeadConversion();
    	List<Opportunity> opps = [SELECT Id FROM Opportunity];
    	System.assert(opps.size() == 1);
    	List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :opps.get(0).Id AND RecordType.DeveloperName = :Constants.TASK_RECORDTYPE_DEVELOPERNAME_CABINET];
    	System.assert(!tasks.isEmpty());
    	
    	Test.startTest();
    	tasks.get(0).IssueDeLaRelance__c = Constants.TASK_ISSUE_RELANCE_WILL_SIGN;
    	update tasks.get(0);
    	Test.stopTest();
    	
    	tasks = [SELECT Id, Subject FROM Task WHERE WhatId = :opps.get(0).Id ORDER BY Relance__c DESC];
    	System.assert(tasks.size() == 2);
    	System.assert(tasks.get(0).Subject == Constants.TASK_SUBJECT_CAB_OPP_WILL_SIGN_REMINDER_2);
    }
    
    @isTest
    static void testUpdateTaskForPostponement() {
    	List<Lead> leads = [SELECT Id FROM Lead];
    	System.assert(!leads.isEmpty());
    	LeadConverterProcessAE converter = new LeadConverterProcessAE(leads.get(0).Id);
    	converter.launchLeadConversion();
    	List<Opportunity> opps = [SELECT Id FROM Opportunity];
    	System.assert(opps.size() == 1);
    	List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :opps.get(0).Id AND RecordType.DeveloperName = :Constants.TASK_RECORDTYPE_DEVELOPERNAME_CABINET];
    	System.assert(!tasks.isEmpty());
    	System.debug(tasks.size());
    	
    	Test.startTest();
    	tasks.get(0).CallBackDate__c = DateTime.now().addDays(7);
    	tasks.get(0).IssueDeLaRelance__c = Constants.TASK_ISSUE_RELANCE_POSTPONED;
    	update tasks.get(0);
    	Test.stopTest();
    	
    	tasks = [SELECT Id, CallBackDate__c, PostponementDate__c, Status FROM Task WHERE WhatId = :opps.get(0).Id ORDER BY Relance__c DESC];
    	
    	System.assert(tasks.size() == 1); // No task created
    	System.assert(tasks.get(0).CallBackDate__c == null);
    	System.assert(tasks.get(0).PostponementDate__c != null);
    	System.assert(tasks.get(0).Status == Constants.TASK_STATUS_OPEN);
    }
    
    @isTest
    static void testTaskClosureWhenNurturingByAE() {
    	List<User> aeUsers = AP04_Factory.userSpecificProfileFactory(1, 'UserTest', 'NomTest', 'UserTest.NomTest@test.com', Constants.PROFILE_NAME_ACCOUNT_EXECUTIVE);
    	insert aeUsers;
    	
    	List<Transfert__c> transferts = [SELECT Id, OwnerId FROM Transfert__c];
    	transferts.get(0).OwnerId = aeUsers.get(0).Id;
    	update transferts.get(0);
    	
    	System.assert(transferts.size() == 1);
    	List<Event> events = [SELECT Id, NoShow__c, IssueDeLaRelance__c, OwnerId FROM Event WHERE WhatId = :transferts.get(0).Id];
    	
    	events.get(0).OwnerId = aeUsers.get(0).Id;
    	update events.get(0);
    	
    	System.runAs(aeUsers.get(0)) {
	    	
	    	
	    	events.get(0).NoShow__c = true;
	    	update events.get(0);
	    	
	    	List<Task> tasks = [SELECT Id, Subject, Status, NewTryFail__c FROM Task];
	    	System.assert(tasks.size() == 1);
	    	
	    	Test.startTest();
	    	tasks.get(0).IssueDeLaRelance__c = Constants.TASK_ISSUE_RELANCE_NURTURING;
	    	update tasks.get(0);
	    	Test.stopTest();
    	
    		tasks = [SELECT Id, Status FROM Task WHERE WhatId = :transferts.get(0).Id ORDER BY CreatedDate DESC];
    	
    		System.assert(tasks.size() == 1); // No task created
    		System.assert(tasks.get(0).Status == Constants.TASK_STATUS_CLOSED);
    	}
    }
    
    @isTest
    static void testTaskUnclosureWhenNurturingByAdmin() {
    	List<Transfert__c> transferts = [SELECT Id FROM Transfert__c];
    	System.assert(transferts.size() == 1);
    	List<Event> events = [SELECT Id, NoShow__c, IssueDeLaRelance__c FROM Event WHERE WhatId = :transferts.get(0).Id];
    	events.get(0).NoShow__c = true;
    	update events.get(0);
    	
    	List<Task> tasks = [SELECT Id, Subject, Status, NewTryFail__c FROM Task];
    	System.assert(tasks.size() == 1);
    	
	    Test.startTest();
	    tasks.get(0).IssueDeLaRelance__c = Constants.TASK_ISSUE_RELANCE_NURTURING;
	    update tasks.get(0);
	    Test.stopTest();
    	
    	tasks = [SELECT Id, Status FROM Task WHERE WhatId = :transferts.get(0).Id ORDER BY CreatedDate DESC];
    	
    	System.assert(tasks.size() == 1); // No task created
    	System.assert(tasks.get(0).Status == Constants.TASK_STATUS_CLOSED);
    }
    
    @isTest
    static void testCloseOppIfLost() {
    	List<Lead> leads = [SELECT Id FROM Lead];
    	System.assert(!leads.isEmpty());
    	LeadConverterProcessAE converter = new LeadConverterProcessAE(leads.get(0).Id);
    	converter.launchLeadConversion();
    	List<Opportunity> opps = [SELECT Id FROM Opportunity];
    	System.assert(opps.size() == 1);
    	List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :opps.get(0).Id AND RecordType.DeveloperName = :Constants.TASK_RECORDTYPE_DEVELOPERNAME_CABINET];
    	System.assert(!tasks.isEmpty());
    	System.debug(tasks.size());
    	
    	Test.startTest();
    	tasks.get(0).IssueDeLaRelance__c = Constants.TASK_ISSUE_RELANCE_LOST_AMONT;
    	update tasks.get(0);
    	Test.stopTest();
    	
    	opps = [SELECT Id, StageName FROM Opportunity WHERE Id = :opps.get(0).Id];
    	System.assert(opps.size() == 1);
    	System.assert(opps.get(0).StageName == Constants.OPP_STAGENAME_LOST);
    	
    	Task task = [SELECT Id, Status FROM Task WHERE Id = :tasks.get(0).Id];
    	System.assert(task.Status == Constants.TASK_STATUS_CLOSED);
    }
}