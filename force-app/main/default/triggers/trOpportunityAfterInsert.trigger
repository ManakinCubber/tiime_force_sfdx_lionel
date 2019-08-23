trigger trOpportunityAfterInsert on Opportunity (after insert) {
    
    if(PAD.canTrigger('AP18_LegalTaskManager')) {
    	AP18_LegalTaskManager.createTaskFromNewOpportunity(Trigger.new);
    }
}