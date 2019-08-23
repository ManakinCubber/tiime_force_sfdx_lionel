trigger trEventAfterInsert on Event (after insert) {
	if (PAD.canTrigger('AP02_EventFromLead')) {
		AP02_EventFromLead.eventAfterInsert(Trigger.newMap);
	}
}