trigger trHistoryAccAfterUpdate on HistoryAccount__c (after update) {
	if (PAD.canTrigger('AP04_Account') && AP04_Account.fireTriggerHA == true) {
		AP04_Account.onAfterUpdateHistoryAcc(Trigger.oldMap, Trigger.newMap);
	}
}