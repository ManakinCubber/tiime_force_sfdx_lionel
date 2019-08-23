trigger trAccountAfterUpdate on Account (after update) {
	/*
	AP04_Account.onUpdateAccount(Trigger.oldMap, Trigger.newMap);*/
	if (PAD.canTrigger('AP04_Account')) {
		AP04_Account.createHistoryAccOnUpdateAcc(Trigger.oldMap, Trigger.newMap);
	}
}