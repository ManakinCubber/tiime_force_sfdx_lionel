trigger trStakeHolderBeforeInsert on Stakeholder__c (before insert) {
	if (PAD.canTrigger('AP03_StakeHolder')) {
		AP03_StakeHolder.onInsert(Trigger.new);
	}
}