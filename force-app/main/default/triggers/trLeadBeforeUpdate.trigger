trigger trLeadBeforeUpdate on Lead (before update) {
	if (PAD.canTrigger('AP20_LeadRecordTypeByCanal')) {
		AP20_LeadRecordTypeByCanal.switchRecordTypeCanalPartenariat(Trigger.new, Trigger.oldMap);
	}
}