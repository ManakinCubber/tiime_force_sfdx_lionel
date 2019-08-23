trigger trContactAfterInsert on Contact (after insert) {
	if (PAD.canTrigger('AP02_ContactStakeholder')) {
		AP02_ContactStakeholder.onInsert(Trigger.newMap);
	}
	
	if(PAD.canTrigger('AP19_MainContact')) {
		AP19_MainContact.checkAfterUpdateOrInsert(Trigger.new, null);
	}
}