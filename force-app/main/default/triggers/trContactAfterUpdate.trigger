trigger trContactAfterUpdate on Contact (after update) {
	if (PAD.canTrigger('AP02_ContactStakeholder')) {
		AP02_ContactStakeholder.onUpdateContact(Trigger.oldMap, Trigger.newMap);
	}
	
	if(PAD.canTrigger('AP19_MainContact')) {
		AP19_MainContact.checkAfterUpdateOrInsert(Trigger.new, Trigger.oldMap);
	}
}