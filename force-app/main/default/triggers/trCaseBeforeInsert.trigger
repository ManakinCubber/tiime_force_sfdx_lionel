trigger trCaseBeforeInsert on Case (before insert) {
	if (PAD.canTrigger('AP21_CaseUserAssign')) {
		AP21_CaseUserAssign.beforeInsert(Trigger.New);
	}
}