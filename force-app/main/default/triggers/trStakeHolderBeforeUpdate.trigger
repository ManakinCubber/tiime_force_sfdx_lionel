trigger trStakeHolderBeforeUpdate on Stakeholder__c (before update) {
	if (PAD.canTrigger('AP03_StakeHolder')) {
		AP03_StakeHolder.beforeUpdate(Trigger.oldMap, Trigger.newMap);
	}
}