public with sharing class AP18_LegalTaskManager {
    
    public static void createTaskFromNewEvent(List<Event> events, Map<Id, Event> oldEvents) {
    	List<Task> tasksToCreate = new List<Task>();
    	List<Transfert__c> transfertsToUpdate = new List<Transfert__c>();
    	
    	// Potential retrieve of tranfert records
    	Set<String> transfertIdSet = new Set<String>();
    	Set<String> oppIdSet = new Set<String>();
    	String id;
    	for(Event e : events) {
    		id = e.WhatId;
    		if(Utils.isInstanceOf(Constants.TRANSFERT_OBJECT_API_NAME, id)) {
    			transfertIdSet.add(e.WhatId);
    		}
    	}
    	
    	Map<Id, Transfert__c> transfertsMap = null;
    	Map<Id, Opportunity> oppsMap = null;
    	
    	if(transfertIdSet.size() > 0) {
    		transfertsMap = new Map<Id, Transfert__c>([SELECT Id, Name, MobilePhone__c, Etape__c, Lead__c, Lead__r.Name FROM Transfert__c WHERE Id IN :transfertIdSet]);
    	}
    	
    	for(Event e : events) {
    		if(e.NoShow__c && !oldEvents.get(e.Id).NoShow__c) {
    			String whatId = e.WhatId;
    			
    			if(Utils.isInstanceOf(Constants.START_OBJECT_API_NAME, whatId)) {
    				// If event related to a start__c record
    				tasksToCreate.add(generateNewTask(e));
    				
    			} else if(Utils.isInstanceOf(Constants.TRANSFERT_OBJECT_API_NAME, whatId)) {
    				// If event related to a partner record
    				tasksToCreate.add(generateNewTask(e, transfertsMap.get(e.WhatId)));
    				
    				
    				transfertsToUpdate.add(transfertsMap.get(e.WhatId));
    				
    			}
    		}
    	}
    	if(!tasksToCreate.isEmpty()) {
    		insert tasksToCreate;
    	}
    	if(!transfertsToUpdate.isEmpty()) {
    		updateTransfertStatus(transfertsToUpdate);
    	}
    }
    
    public static void createTaskFromNewOpportunity(List<Opportunity> opportunities) {
    	List<Task> tasksToCreate = new List<Task>();
    	for(Opportunity o : opportunities) {
    		tasksToCreate.add(generateNewTask(o));
    	}
    	if(!tasksToCreate.isEmpty()) {
    		insert tasksToCreate;
    	}
    }
    
    public static void createTaskFromTask(List<Task> tasks, Map<Id, Task> oldTasks) {
    	// Potential retrieve of Start__c and Opportunity records
    	Map<Id, Object> globalParentsMap = generateParentObjectMap(tasks);
		
    	Set<Task> tasksToCreate = new Set<Task>();
    	List<Task> tasksToClose = new List<Task>();
    	// In case of reminder postponement, we create an event
    	List<Event> eventToCreate = new List<Event>();
    	// In case of client loss
    	Set<OppToCloseWrapper> oppToCloseIdsSet = new Set<OppToCloseWrapper>();
    	Map<Id, String> oppIdNewTaskStageNameMap = new Map<Id, String>();
    	for(Task t : tasks) {
    		if(t.NewTryFail__c && !oldTasks.get(t.Id).NewTryFail__c) {
    			tasksToCreate.add(manageNewTask(t, globalParentsMap.get(t.WhatId)));
    			
    			if(Utils.isInstanceOf('Opportunity', t.WhatId) && Constants.OLD_TASK_RELANCE_VALUE_NEW_OPP_STEP_MAP.containsKey(t.Relance__c)) {
    				oppIdNewTaskStageNameMap.put(t.WhatId, Constants.OLD_TASK_RELANCE_VALUE_NEW_OPP_STEP_MAP.get(t.Relance__c));
    			}
    			
    		} else if(t.PostponementDate__c != null && oldTasks.get(t.Id).PostponementDate__c == null) {
    			eventToCreate.add(createEventFromTask(t));
    		} else if(Constants.TASK_ISSUE_RELANCE_LOST_VALUE_SET.contains(t.IssueDeLaRelance__c) && 
    		Utils.isInstanceOf('Opportunity', t.WhatId)) {
    			oppToCloseIdsSet.add(new OppToCloseWrapper(t.WhatId,t.IssueDeLaRelance__c));
    		}
    	}
    	tasksToCreate.remove(null);
    	if(!tasksToCreate.isEmpty()) {
    		insert new List<Task>(tasksToCreate);
    	}
    	if(!eventToCreate.isEmpty()) {
    		insert eventToCreate; 
    	}
    	if(!oppIdNewTaskStageNameMap.isEmpty()) {
    		updateOppStep(oppIdNewTaskStageNameMap);
    	}
    	if(oppToCloseIdsSet.size() > 0) {
    		closeOpps(oppToCloseIdsSet);
    	}
    }
    
    public static void checkTaskOnBeforeUpdate(List<Task> tasks, Map<Id, Task> oldTasks) {
    	for(Task t : tasks) {
    		
    		if(t.CallBackDate__c != null && oldTasks.get(t.Id).CallBackDate__c == null) {
    			
    			DateTime dt = t.CallBackDate__c;
    			t.ActivityDate = dt.date();
    			t.TaskHour__c = Time.newInstance(dt.hour(), dt.minute(), 0, 0);//dt.hour();
    			//t.TaskMinutes__c = dt.minute();
    			t.PostponementDate__c = DateTime.now();
    			t.CallBackDate__c = null;
    			
    		} else if(Constants.TASK_ISSUE_RELANCE_NEW_TRY_FAIL.contains(t.IssueDeLaRelance__c) && 
    			oldTasks.get(t.Id).IssueDeLaRelance__c != t.IssueDeLaRelance__c) {
    			
    			t.NewTryFail__c = true;
    		}
    		
    		if(
    			((t.NewTryFail__c && !oldTasks.get(t.Id).NewTryFail__c) || ( 
    				oldTasks.get(t.Id).IssueDeLaRelance__c != t.IssueDeLaRelance__c &&
    				t.IssueDeLaRelance__c != null && 
    				t.IssueDeLaRelance__c != Constants.TASK_ISSUE_RELANCE_POSTPONED/* &&
    				Utils.isConnectedUserProfile(Constants.PROFILE_NAME_ACCOUNT_EXECUTIVE)*/
    			)) 
    			&& t.Status != Constants.TASK_STATUS_CLOSED
    		) {		
    			t.Status = Constants.TASK_STATUS_CLOSED;
    		}
    	}
    }
    
    private static task manageNewTask(Task task, Object parent) {
    	Task newTask = null;
    	String whatId = task.WhatId;
    	if(Utils.isInstanceOf(Constants.START_OBJECT_API_NAME, whatId)) {
    		// If task related to start__c record
	    	if(Constants.TASK_LEGAL_SUBJECT_ORDER.keySet().contains(retrieveReminderTypeFromSubject(task.Subject))) {
	    		
	    		newTask = generateNewTasks(task);
	    		
	    		if(retrieveReminderTypeFromSubject(task.Subject) == Constants.TASK_SUBJECT_LEGAL_REMINDER_2) {
	    			// Send SMS reminder (Waiting Template)
	    			sendSmsReminder((Start__c)parent, Constants.SMS_LEGAL_RELANCE_2);
	    			
	    		} else if(retrieveReminderTypeFromSubject(task.Subject) == Constants.TASK_SUBJECT_LEGAL_REMINDER_3) {
	    			// Send Email reminder (Waiting Template)
	    			sendEmailReminder((Start__c)parent, Constants.EMAIL_TEMPLATE_LEGAL_RELANCE_3);
	    		}
	    	}
    	} else if(Utils.isInstanceOf(Constants.TRANSFERT_OBJECT_API_NAME, whatId)) {
    		// If task related to transfert__c record
    		if(Constants.TASK_CAB_ORDER.keySet().contains(removeContactNameFromSubject(task.Subject))) {
    			
    			newTask = generateNewTasksCabinets(task);
    			
    		}
    	} else if(Utils.isInstanceOf(Constants.OPP_OBJECT_API_NAME, whatId)) {
    		if(Constants.TASK_CAB_OPP_RELANCE.keySet().contains(task.Relance__c)) {
    			
	    		newTask = generateNewTasksCabOpp(task);
	    		
	    		if(task.IssueDeLaRelance__c == Constants.TASK_ISSUE_RELANCE_NO_RESPONSE) {
	    			
	    			if(task.Relance__c == Constants.TASK_RELANCE_1) {
	    				// Send SMS reminder
	    				//sendSmsReminder((Opportunity)parent, Constants.SMS_CAB_OPP_RELANCE_1);
	    				
	    			} else if(task.Relance__c == Constants.TASK_RELANCE_3) {
	    				// Send SMS depending on previous subject
	    				
	    				if(task.subject.containsIgnoreCase(Constants.TASK_ISSUE_RELANCE_REFLEXION)) {
	    					//sendSmsReminder((Opportunity)parent, Constants.SMS_CAB_OPP_RELANCE_3_REFLEXION);
	    				} else if(task.subject.containsIgnoreCase(Constants.TASK_ISSUE_RELANCE_WILL_SIGN)) {
	    					//sendSmsReminder((Opportunity)parent, Constants.SMS_CAB_OPP_RELANCE_3_WILL_SIGN);
	    				} else {
	    					//sendSmsReminder((Opportunity)parent, Constants.SMS_CAB_OPP_RELANCE_3);
	    				}
	    			} else if(task.Relance__c == Constants.TASK_RELANCE_4) {
	    				// Send emails depending on previous subject
	    				
	    				if(task.subject.containsIgnoreCase(Constants.TASK_ISSUE_RELANCE_REFLEXION)) {
	    					sendEmailReminder((Opportunity)parent, Constants.EMAIL_TEMPLATE_PROP_ACC_RELANCE_4_REFLEXION);
	    				} else if(task.subject.containsIgnoreCase(Constants.TASK_ISSUE_RELANCE_WILL_SIGN)) {
	    					sendEmailReminder((Opportunity)parent, Constants.EMAIL_TEMPLATE_PROP_ACC_RELANCE_4_WILL_SIGN);
	    				} else {
	    					sendEmailReminder((Opportunity)parent, Constants.EMAIL_TEMPLATE_PROP_ACC_RELANCE_4);
	    				}
	    			}
	    		}
    		}
    	}
    	
    	return newTask;
    } 
    
    private static task generateNewTasks(Task task) {
    	Task newTask = new Task(
    		Subject = buildSubject(task.Subject),
    		WhatId = task.WhatId,
    		OwnerId = task.OwnerId,
    		ActivityDate = Date.today() + Constants.TASK_LEGAL_NB_DAYS_FOR_NEXT_CALL.get(retrieveReminderTypeFromSubject(task.Subject))
    	);
    	return newTask;
    }
    
    private static task generateNewTasksCabinets(Task task) {
    	Task newTask = new Task(
    		Subject = addContactNameToSubject(Constants.TASK_CAB_ORDER.get(removeContactNameFromSubject(task.Subject)),task.ContactName__c),
    		WhatId = task.WhatId,
    		OwnerId = task.OwnerId,
    		ActivityDate = Date.today() + Constants.TASK_CAB_NB_DAYS_FOR_NEXT_CALL.get(removeContactNameFromSubject(task.Subject)),
    		ContactName__c = task.ContactName__c,
    		PhoneWhoID__c = task.PhoneWhoID__c,
    		Relance__c = Constants.TASK_CAB_RELANCE.get(removeContactNameFromSubject(task.Subject)),
    		RecordTypeId = Utils.getTaskRecordTypeIdByDeveloperName(Constants.TASK_RECORDTYPE_DEVELOPERNAME_TRANSFERT)
    	);
    	return newTask;
    }
    
    private static Task generateNewTasksCabOpp(Task task) {
    	Task newTask = new Task(
    		Subject = buildCabOppSubject(task),
    		WhatId = task.WhatId,
    		OwnerId = task.OwnerId,
    		ActivityDate = Date.today() + buildCabOppWaitDuration(task),
    		ContactName__c = task.ContactName__c,
    		PhoneWhoID__c = task.PhoneWhoID__c,
    		MailAddress__c = task.MailAddress__c,
    		Relance__c = Constants.TASK_CAB_OPP_RELANCE.get(task.Relance__c),
    		RecordTypeId = buildCabOppRecordType(task)
    	);
    	return newTask;
    }
    
    
    private static Task generateNewTask(Event event) {
    	Task task = new Task(
    		Subject = Constants.TASK_SUBJECT_LEGAL_REMINDER_1 + event.Subject,
    		WhatId = event.WhatId,
    		OwnerId = event.OwnerId,
    		ActivityDate = Date.today()
    	);
    	return task;
    }
    
    private static Task generateNewTask(Opportunity opp) {
    	Task task = new Task(
    		Subject = Constants.TASK_SUBJECT_CAB_OPP_REMINDER_1,
    		WhatId = opp.Id,
    		OwnerId = opp.OwnerId,
    		ActivityDate = opp.CreatedDate.date() + 1,
    		ContactName__c = opp.LeadFullName__c,
    		PhoneWhoID__c = opp.MobilePhone__c,
    		MailAddress__c = opp.MailAddress__c,
    		Relance__c = Constants.TASK_RELANCE_1,
    		RecordTypeId = Utils.getTaskRecordTypeIdByDeveloperName(Constants.TASK_RECORDTYPE_DEVELOPERNAME_CABINET)
    	);
    	return task;
    }
    
    private static Task generateNewTask(Event event, Transfert__c transfert) {
    	Task task = new Task(
    		Subject = addContactNameToSubject(Constants.TASK_SUBJECT_CAB_REMINDER_1, transfert.Lead__r.Name),
    		WhatId = event.WhatId,
    		OwnerId = event.OwnerId,
    		ActivityDate = Date.today(),
    		ContactName__c = transfert.Lead__r.Name,
    		PhoneWhoID__c = transfert.MobilePhone__c,
    		Relance__c = Constants.TASK_RELANCE_1,
    		RecordTypeId = Utils.getTaskRecordTypeIdByDeveloperName(Constants.TASK_RECORDTYPE_DEVELOPERNAME_TRANSFERT)
    	);
    	return task;
    }
    
    private static Event createEventFromTask(Task task) {
    	Event event = new Event(
    		Subject = Constants.TASK_EVENT_POSTPONEMENT_PREFIX + task.Subject,
    		ContactName__c = task.ContactName__c,
    		StartDateTime = DateTime.newInstance(task.ActivityDate.year(), task.ActivityDate.month(), task.ActivityDate.day(), task.TaskHour__c.hour()/*intValue()*/, task.TaskHour__c.minute(), 0),
    		EndDateTime = DateTime.newInstance(task.ActivityDate.year(), task.ActivityDate.month(), task.ActivityDate.day(), task.TaskHour__c.hour()/*intValue()*/, task.TaskHour__c.minute(), 0).addMinutes(Constants.TASK_EVENT_DURATION_MINUTES),
    		OwnerId = task.OwnerId,
    		WhatId = task.WhatId
    	);
    	return event;
    }
    
    /*private static Task generateNewTask(Event event, Opportunity opp) {
    	Task task = new Task(
    		Subject = Constants.TASK_SUBJECT_CAB_OPP_REMINDER_1,
    		WhatId = event.WhatId,
    		OwnerId = event.OwnerId,
    		ActivityDate = opp.CreatedDate.date() + 1,
    		ContactName__c = opp.LeadFullName__c,
    		PhoneWhoID__c = opp.MobilePhone__c,
    		MailAddress__c = opp.MailAddress__c,
    		Relance__c = Constants.TASK_RELANCE_1,
    		RecordTypeId = Utils.getTaskRecordTypeIdByDeveloperName(Constants.TASK_RECORDTYPE_DEVELOPERNAME_CABINET)
    	);
    	return task;
    }*/
    
    private static String retrieveReminderTypeFromSubject(String subject) {
    	return subject.substring(0, subject.indexOf('-') +2);
    }
    
    private static String buildSubject(String subject) {
    	String subjectType = retrieveReminderTypeFromSubject(Subject);
    	return Constants.TASK_LEGAL_SUBJECT_ORDER.get(subjectType) + subject.substring(subject.indexOf('-') +2);
    }
    
    private static String addContactNameToSubject(String subject, String contactName) {
    	return subject + Constants.TASK_SUBJECT_AVEC + contactName;
    }
    
    private static String removeContactNameFromSubject(String subject) {
    	return subject.substringBefore(Constants.TASK_SUBJECT_AVEC);
    }
    
    private static String buildCabOppSubject(Task task) {
    	return Constants.TASK_CAB_OPP_ISSUE_SUBJECT_MAPS.get(task.IssueDeLaRelance__c).get(task.Relance__c);
    }
    
    private static Integer buildCabOppWaitDuration(Task task) {
    	return Constants.TASK_CAB_OPP_ISSUE_NB_DAYS_FOR_NEXT_CALL_MAPS.get(task.IssueDeLaRelance__c).get(task.Relance__c);
    }
    
    private static Id buildCabOppRecordType(Task task) {
    	return Utils.getTaskRecordTypeIdByDeveloperName(Constants.TASK_CAB_OPP_RELANCE_RECORDTYPE.get(task.Relance__c));
    }
    
    private static void updateTransfertStatus(List<Transfert__c> transferts) {
    	for(Transfert__c t : transferts) {
    		t.Etape__c = Constants.TRANSFERT_ETAPE_RDV_ECHOUE;
    	}
    	update transferts;
    }
    
    private static Map<Id, Object> generateParentObjectMap(List<Task> tasks) {
    	// Potential retrieve of Start__c and Opportunity records
    	Set<String> projetsCreaIdSet = new Set<String>();
    	Set<String> oppIdSet = new Set<String>();
    	String whatId;
    	for(Task t : tasks) {
    		whatId = t.WhatId;
    		if(Utils.isInstanceOf(Constants.START_OBJECT_API_NAME, whatId)) {
    			projetsCreaIdSet.add(t.WhatId);
    		} else if(Utils.isInstanceOf(Constants.OPP_OBJECT_API_NAME, whatId)) {
    			oppIdSet.add(t.WhatId);
    		}
    	}
    	
    	Map<Id, Start__c> projetsCreaMap = null;
    	Map<Id, Opportunity> oppsMap = null;
    	Map<Id, Object> globalParentsMap = new Map<Id, Object>();
    	
    	if(projetsCreaIdSet.size() > 0) {
    		projetsCreaMap = new Map<Id, Start__c>([SELECT Id, Name, Crea__c, Crea__r.Name, Crea__r.FirstName, Crea__r.Email, Crea__r.Branding__c, Crea__r.MobilePhone FROM Start__c WHERE Id IN :projetsCreaIdSet]);
    		globalParentsMap.putAll(projetsCreaMap);
    	}
    	if(oppIdSet.size() > 0) {
    		oppsMap = new Map<Id, Opportunity>([SELECT Id, Name, CreatedDate, Address__c, MailAddress__c, Branding__c, LeadFullName__c, MobilePhone__c, OwnerId, Owner.FirstName, Owner.MobilePhone, AccountId, Account.IdPdfOffers__c, Account.ContractSignLink__c, Account.MainContact__c, Account.MainContact__r.FirstName FROM Opportunity WHERE Id IN :oppIdSet]);
    		globalParentsMap.putAll(oppsMap);
    	}
    	return globalParentsMap;
    }
    
    private static void updateOppStep(Map<Id, String> oppIdNewTaskStageNameMap) {
    	List<Opportunity> oppToUpdateStageName = new List<Opportunity>();
    	for(Id oppId : oppIdNewTaskStageNameMap.keySet()) {
    		oppToUpdateStageName.add(new Opportunity(Id = oppId, StageName = oppIdNewTaskStageNameMap.get(oppId)));
    	}
    	update oppToUpdateStageName;
    }
    
    private static void closeOpps(Set<OppToCloseWrapper> oppToCloseWrapperSet) {
    	List<Opportunity> oppsToClose = new List<Opportunity>();
    	for(OppToCloseWrapper oppWrapper : oppToCloseWrapperSet) {
    		oppsToClose.add(new Opportunity(Id = oppWrapper.oppId, StageName = Constants.OPP_STAGENAME_LOST, LossReason__c = oppWrapper.lossReason));
    	}
    	update oppsToClose;
    }
    
    private static void sendSmsReminder(Opportunity opportunity, String templateSms) {
    	Utils_CustomEmailTemplateDesigner designer = new Utils_CustomEmailTemplateDesigner(
    		opportunity, 
    		opportunity.Owner, 
    		opportunity.Account, 
    		opportunity.Account.MainContact__r, 
    		templateSms
    	);
    	
    	SMS.sendAsync(opportunity.MobilePhone__c, designer.formatLeadEmailTemplate(), opportunity.Id);
    }
    
    private static void sendEmailReminder(Opportunity opportunity, String templateEmail) {
    	Utils_CustomEmailTemplateDesigner designer = new Utils_CustomEmailTemplateDesigner(
    		opportunity, 
    		opportunity.Owner, 
    		opportunity.Account, 
    		opportunity.Account.MainContact__r, 
    		templateEmail
    	);
    	
    	LTC20_SendProposal.sendEmailProposition(
    		opportunity.Branding__c, 
    		opportunity.MailAddress__c, 
    		opportunity.Account.IdPdfOffers__c.split(Constants.CUSTOM_LABEL_INNER_SEPARATOR), 
    		designer.formatLeadEmailTemplate(),
    		Constants.EMAIL_SUBJECT_SIGN_LINK_REMINDER
    	);
    }
    
    private static void sendSmsReminder(Start__c projetCrea, String templateSms) {
    	Utils_CustomEmailTemplateDesigner designer = new Utils_CustomEmailTemplateDesigner(
    		projetCrea.Crea__r, 
    		null, 
    		templateSms
    	);
    	
    	SMS.sendAsync(projetCrea.Crea__r.MobilePhone, designer.formatLeadEmailTemplate(), projetCrea.Crea__c);
    }
    
    private static void sendEmailReminder(Start__c projetCrea, String templateEmail) {
    	Utils_CustomEmailTemplateDesigner designer = new Utils_CustomEmailTemplateDesigner(
    		projetCrea.Crea__r, 
    		null, 
    		templateEmail
    	);
    	
    	sendLegalReminderEmail(
    		projetCrea.Crea__r.Branding__c, 
    		projetCrea.Crea__r.Email,
    		designer.formatLeadEmailTemplate(),
    		Constants.EMAIL_SUBJECT_LEGAL_RELANCE_3
    	);
    }
    
    private static void sendLegalReminderEmail(String branding, String email, String emailContent, String subject) {
    	
	    Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
	    singleEmail.setBccAddresses(Utils.getEmailAdditionnalAddresses());
	    singleEmail.setOrgWideEmailAddressId(Utils.getOrgWideAddressesByBranding(branding));
	    singleEmail.setToAddresses(new String[] {email});
	    singleEmail.setSubject(subject + branding);
	    singleEmail.setHtmlBody(emailContent);
	    		
	    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>{singleEmail};
	    Messaging.sendEmail(emails);
    }
    
    private class OppToCloseWrapper {
    	private Id oppId;
    	private String lossReason;
    	
    	public OppToCloseWrapper(Id oppId, String lossReason) {
    		this.oppId = oppId;
    		this.lossReason = Constants.TASK_ISSUE_TO_OPP_LOSS_REASON_MAP.get(lossReason);
    	}
    }
}