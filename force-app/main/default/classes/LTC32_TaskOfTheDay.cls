public with sharing class LTC32_TaskOfTheDay{
    
    private static final List<String> fieldsName = new List<String> {'WhatId', 'ActivityDate', 'Status', 'LastModifiedById', 'Priority', 'Subject', 'LastModifiedDate'};
        
    @AuraEnabled
	public static Map<String, String> getLabels() {
		Map<String, String> labels = new Map<String, String>();
        for(String fieldApiName : fieldsName) {
            labels.put(fieldApiName, Utils.getFieldLabel('Task', fieldApiName));
        }
		return labels;
	}
    
	@AuraEnabled
    public static List<Task> getTasks(Boolean isToDay) { 
        try { 
            return isToDay ?
                [SELECT id, WhatId, What.Name, ActivityDate, Status, LastModifiedBy.Name, Priority, Subject, LastModifiedDate  
                                FROM Task 
                                WHERE ActivityDate = :Date.toDay() AND Status = :Constants.TASK_STATUS_OPEN] :
            	[SELECT id, WhatId, What.Name, ActivityDate, Status, LastModifiedBy.Name, Priority, Subject, LastModifiedDate  
                                FROM Task 
                                WHERE ActivityDate < :Date.toDay() AND Status = :Constants.TASK_STATUS_OPEN]; 
         }catch(Exception e){
			throw new AuraHandledException(e.getMessage());
		}
    }
}