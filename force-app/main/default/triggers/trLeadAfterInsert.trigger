trigger trLeadAfterInsert on Lead (after insert) {
    if (PAD.canTrigger('AP06_SendEmailFromLead')) {
		AP06_SendEmailFromLead.sendEmailIfAppointmentSet(Trigger.new, null);
	}
}