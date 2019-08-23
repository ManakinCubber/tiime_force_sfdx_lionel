trigger trContactBeforeDelete on Contact (before delete) {
    
	if(PAD.canTrigger('AP19_MainContact')) {
		AP19_MainContact.checkBeforeDelete(Trigger.old);
	}
}