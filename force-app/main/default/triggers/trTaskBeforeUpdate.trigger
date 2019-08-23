trigger trTaskBeforeUpdate on Task (before update) {
    
    if(PAD.canTrigger('AP18_LegalTaskManager')) {
    	AP18_LegalTaskManager.checkTaskOnBeforeUpdate(Trigger.new, Trigger.oldMap);
    }
}