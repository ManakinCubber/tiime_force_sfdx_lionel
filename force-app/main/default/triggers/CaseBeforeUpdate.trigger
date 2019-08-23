trigger CaseBeforeUpdate on Case (before update) {
    //Call to calculate the CumulateTime Field
	if (PAD.canTrigger('AP01_Case')) {
		AP01_Case.manageCumulateTime(Trigger.oldMap, Trigger.newMap);
	}
}