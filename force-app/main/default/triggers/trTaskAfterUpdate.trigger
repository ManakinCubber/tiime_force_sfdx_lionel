trigger trTaskAfterUpdate on Task (after update) {
    
    if(PAD.canTrigger('AP18_LegalTaskManager')) {
    	AP18_LegalTaskManager.createTaskFromTask(Trigger.new, Trigger.oldMap);
    }
}