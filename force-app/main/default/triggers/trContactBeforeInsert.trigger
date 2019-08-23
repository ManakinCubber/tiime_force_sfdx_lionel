trigger trContactBeforeInsert on Contact (before insert) {
    
    if(PAD.canTrigger('AP19_MainContact')) {
    	AP19_MainContact.checkBeforeInsertOrUpdate(Trigger.new, null);
    }
    
}