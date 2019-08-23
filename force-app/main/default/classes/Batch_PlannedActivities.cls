global with sharing class Batch_PlannedActivities implements Database.Batchable<SObject>, Database.Stateful {
	
	public static String OBJECT_REF = Constants.START_OBJECT_API_NAME;
	public static final Map<String, String> OBJECT_REF_TO_QUERY_CONDITION_MAP = new Map<String, String> {
		Constants.START_OBJECT_API_NAME => 'ProjectStatus__c != \'Kbis reçu\' AND ProjectStatus__c != \'Perdu\''
	};
	    
    global static System.Iterable<SObject> start(Database.BatchableContext bc) {
    	System.debug(OBJECT_REF);
    	return Database.query('SELECT Id, NoPlannedActivity__c FROM ' + OBJECT_REF + ' WHERE ' + OBJECT_REF_TO_QUERY_CONDITION_MAP.get(OBJECT_REF));
    }
    
    global static void execute(Database.BatchableContext bc, List<SObject> scope) {
    	Set<String> activityIdSet = new Set<String>();
    	for(Event e : [SELECT Id, WhatId FROM Event WHERE StartDateTime >= :Datetime.now()]) {
    		activityIdSet.add(e.WhatId);
    	}
    	
    	for(Task t : [SELECT Id, WhatId FROM Task WHERE ActivityDate >= TODAY AND Status = :Constants.TASK_STATUS_OPEN]) {
    		activityIdSet.add(t.WhatId);
    	}
    	
    	List<SObject> objectsToUpdate = new List<SObject>();
    	for(SObject s : scope) {
    		if(!activityIdSet.contains((String)s.get('Id'))) {
    			s.put('NoPlannedActivity__c', true);
    			objectsToUpdate.add(s);
    		}
    		else if(s.get('NoPlannedActivity__c') == true) {
    			s.put('NoPlannedActivity__c', false);
    			objectsToUpdate.add(s);
    		}
    	}
    	
    	if(!objectsToUpdate.isEmpty()) {
    		update objectsToUpdate;
    	}
    }
    
    global static void finish(Database.BatchableContext bc) {
    	
    }
}