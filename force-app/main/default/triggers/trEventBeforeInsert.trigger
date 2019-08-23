trigger trEventBeforeInsert on Event (before insert) {
	if (PAD.canTrigger('AP01_SetEventPhoneFromWhoId')) {
		AP01_SetEventPhoneFromWhoId.EventChanging(trigger.new);
	}
}