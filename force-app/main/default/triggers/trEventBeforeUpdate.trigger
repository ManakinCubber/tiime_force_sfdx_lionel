trigger trEventBeforeUpdate on Event (before update) {
	if (PAD.canTrigger('AP01_SetEventPhoneFromWhoId')) {
		AP01_SetEventPhoneFromWhoId.EventChanging(trigger.new);
	}
}