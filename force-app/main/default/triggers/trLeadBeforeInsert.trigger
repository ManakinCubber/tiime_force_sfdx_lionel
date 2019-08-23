trigger trLeadBeforeInsert on Lead (before insert) {
	if (PAD.canTrigger('AP20_LeadRecordTypeByCanal')) {
		AP20_LeadRecordTypeByCanal.switchRecordTypeCanalPartenariat(Trigger.new, null);
	}
}