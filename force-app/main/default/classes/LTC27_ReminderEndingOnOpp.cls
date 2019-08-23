public with sharing class LTC27_ReminderEndingOnOpp {
    
    @AuraEnabled
    public static Task retrieveCurrentTask(Id oppId) {
    	Task currentTask = null;
    	List<Task> currentTasks = [SELECT Id, Subject, AECommentsTask__c, IssueDeLaRelance__c, CallBackDate__c FROM Task WHERE WhatId = :oppId AND Status = :Constants.TASK_STATUS_OPEN];
    	if(!currentTasks.isEmpty()) {
    		currentTask = currentTasks.get(0);
    	}
    	return currentTask;
    }
    
    @AuraEnabled
    public static Task retrievePreviousTask(Id oppId) {
    	Task previousTask = null;
    	List<Task> previousTasks = [SELECT Id, AECommentsTask__c FROM Task WHERE WhatId = :oppId AND Status = :Constants.TASK_STATUS_CLOSED ORDER BY CreatedDate DESC LIMIT 1];
    	if(!previousTasks.isEmpty()) {
    		previousTask = previousTasks.get(0);
    	}
    	return previousTask;
    }
    
    @AuraEnabled
    public static Map<String, String> retrieveIssueRelancePicklistValues() {
    	Map<String, String> tempMap = Utils.getPicklistOptionsWithNoneOption('Task', 'IssueDeLaRelance__c', true);
    	Map<String, String> resultMap = new Map<String, String>();
    	for(String s : tempMap.keySet()) {
    		if(!Constants.TASK_ISSUES_VALUES_NOT_APPLICABLE_ON_CAB_TASK.contains(s)) {
    			resultMap.put(s, tempMap.get(s));
    		}
    	}
    	return resultMap;
    }
    
    @AuraEnabled
    public static void updateTaskRecord(Task task) {
    	update task;
    }
}