trigger trLeadAfterUpdate on Lead (after update) {
    if (PAD.canTrigger('AP06_SendEmailFromLead')) {
    	AP06_SendEmailFromLead.sendEmailIfAppointmentSet(Trigger.new, Trigger.oldMap);
	}
}