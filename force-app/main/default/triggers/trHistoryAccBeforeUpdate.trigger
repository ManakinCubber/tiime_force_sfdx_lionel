trigger trHistoryAccBeforeUpdate on HistoryAccount__c (before update) {
	if(PAD.canTrigger('AP04_Account') && AP04_Account.fireTriggerHA == true) {
		AP04_Account.onBeforeUpdateHistoryAcc(Trigger.oldMap, Trigger.newMap);
	}
}