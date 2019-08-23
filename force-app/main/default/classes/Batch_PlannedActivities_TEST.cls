@isTest
public with sharing class Batch_PlannedActivities_TEST {
    
    @TestSetup
    static void dataSetup() {
    	AP04_Factory.createGenericDataSample();
    	
    	List<Lead> leads = [SELECT Id FROM Lead];
    	Start__c start = new Start__c(Name = 'Test', Crea__c = leads.get(0).Id);
    	insert start;
    	
    	Event event = new Event(StartDateTime = DateTime.now() - 5, EndDateTime =  DateTime.now() - 4, Subject = 'Test', WhatId = start.Id);
    	insert event;
    	
    	Task task = new Task(ActivityDate = Date.today() - 5, Subject = 'Test', WhatId = start.Id);
    	insert task;
    }
    
    @isTest
    static void testBatch() {
    	List<Start__c> starts = [SELECT Id, NoPlannedActivity__c FROM Start__c WHERE NoPlannedActivity__c = true];
    	System.assert(starts.isEmpty());
    	
    	Test.startTest();
    	Batch_PlannedActivities batch = new Batch_PlannedActivities();
      	Database.executeBatch(batch);
    	Test.stopTest();
    	
    	starts = [SELECT Id, NoPlannedActivity__c FROM Start__c WHERE NoPlannedActivity__c = true];
    	System.assert(starts.size() == 1);
    }
    
    @isTest
    static void testScheduler() {
    	
    	List<CronTrigger> cts = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :Sched_PlannedActivities.PLANNED_TASK_NAME];
    	if(!cts.isEmpty()) {
    		System.abortJob(cts.get(0).Id);
    	}
    	Test.startTest();
    	Sched_PlannedActivities.scheduleMe();
    	Test.stopTest();
    }
    
    @isTest
    static void testBatchWithNewEvent() {
    	List<Start__c> starts = [SELECT Id, NoPlannedActivity__c FROM Start__c];
    	System.assert(starts.size() == 1);
    	
    	Event event = new Event(StartDateTime = DateTime.now() + 2, EndDateTime =  DateTime.now() + 3, Subject = 'Test', WhatId = starts.get(0).Id);
    	insert event;
    	
    	Test.startTest();
    	Batch_PlannedActivities batch = new Batch_PlannedActivities();
      	Database.executeBatch(batch);
    	Test.stopTest();
    	
    	starts = [SELECT Id, NoPlannedActivity__c FROM Start__c WHERE NoPlannedActivity__c = true];
    	System.assert(starts.isEmpty());
    }
    
    @isTest
    static void testBatchWithNewTask() {
    	List<Start__c> starts = [SELECT Id, NoPlannedActivity__c FROM Start__c];
    	System.assert(starts.size() == 1);
    	
    	Task task = new Task(ActivityDate = Date.today() + 5, Subject = 'Test', WhatId = starts.get(0).Id);
    	insert task;
    	
    	Test.startTest();
    	Batch_PlannedActivities batch = new Batch_PlannedActivities();
      	Database.executeBatch(batch);
    	Test.stopTest();
    	
    	starts = [SELECT Id, NoPlannedActivity__c FROM Start__c WHERE NoPlannedActivity__c = true];
    	System.assert(starts.isEmpty());
    }
    
    @isTest
    static void testBatchWhenBeforeWasTrueNewTask() {
    	 List<Start__c> starts = [SELECT Id, NoPlannedActivity__c FROM Start__c];
    	 System.assert(starts.size() == 1);
         for(Start__c s: starts){
            s.NoPlannedActivity__c = true;
        }
        update starts;
        
        starts = [SELECT Id, NoPlannedActivity__c FROM Start__c WHERE NoPlannedActivity__c = true];
    	System.assert(starts.size() == 1);
        
        Task task = new Task(ActivityDate = Date.today() + 5, Subject = 'Test', WhatId = starts.get(0).Id);
    	insert task;
    	
    	Test.startTest();
    	Batch_PlannedActivities batch = new Batch_PlannedActivities();
      	Database.executeBatch(batch);
    	Test.stopTest();
    	
    	starts = [SELECT Id, NoPlannedActivity__c FROM Start__c WHERE NoPlannedActivity__c = true];
    	System.assert(starts.isEmpty());
    }
    
    @isTest
    static void testBatchWhenBeforeWasTrueNewEvent() {
    	 List<Start__c> starts = [SELECT Id, NoPlannedActivity__c FROM Start__c];
    	 System.assert(starts.size() == 1);
         for(Start__c s: starts){
            s.NoPlannedActivity__c = true;
        }
        update starts;
        
        starts = [SELECT Id, NoPlannedActivity__c FROM Start__c WHERE NoPlannedActivity__c = true];
    	System.assert(starts.size() == 1);
        
    	Event event = new Event(StartDateTime = DateTime.now() + 2, EndDateTime =  DateTime.now() + 3, Subject = 'Test', WhatId = starts.get(0).Id);
    	insert event;
    	
    	Test.startTest();
    	Batch_PlannedActivities batch = new Batch_PlannedActivities();
      	Database.executeBatch(batch);
    	Test.stopTest();
    	
    	starts = [SELECT Id, NoPlannedActivity__c FROM Start__c WHERE NoPlannedActivity__c = true];
    	System.assert(starts.isEmpty());
    }
}