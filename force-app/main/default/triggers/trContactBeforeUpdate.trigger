trigger trContactBeforeUpdate on Contact (before update) {
    
    if(PAD.canTrigger('AP19_MainContact')) {
    	AP19_MainContact.checkBeforeInsertOrUpdate(Trigger.new, Trigger.OldMap);
    }
}