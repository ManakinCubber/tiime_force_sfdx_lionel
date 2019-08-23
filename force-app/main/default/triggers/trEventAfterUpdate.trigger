trigger trEventAfterUpdate on Event (after update) {
    
    if(PAD.canTrigger('AP18_LegalTaskManager')) {
    	AP18_LegalTaskManager.createTaskFromNewEvent(Trigger.new, Trigger.oldMap);
    }
}