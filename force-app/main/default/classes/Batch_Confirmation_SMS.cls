public class Batch_Confirmation_SMS implements queueable, Database.AllowsCallouts {

	public static void execute(System.QueueableContext queueableContext) {
		// Retrieve events with specificities
		// specificities : Event related to a start__c record, Event with StartDateTime Tomorrow, Event with Confirmation SMS Send checkbox unchecked
		// LIMIT 50
		DateTime todayDateTime = DateTime.now();
		DateTime tomorrowDateTime = DateTime.now().addDays(1);
		DateTime nextFourHours = DateTime.now().addHours(4);
		DateTime nextTwentyThreeHours = DateTime.now().addHours(23);
		List<Event> rawEvents = [SELECT Id, WhatId, WhoId, StartDateTime, OwnerId, Owner.FirstName, Owner.LastName, ConfirmationSmsSend__c FROM Event WHERE StartDateTime < :tomorrowDateTime AND StartDateTime > :todayDateTime AND (StartDateTime > :nextTwentyThreeHours OR StartDateTime < :nextFourHours) AND ConfirmationSmsSend__c = false LIMIT 50];
		
		// Filter records depending on the WhatId Related Object Type, We want Start__c or Transfert__c objects right now. 
		// These two types are treated separatly.
		List<Event> startEvents = new List<Event>();
		List<Event> transfertEvents = new List<Event>();
		Set<String> whatIdSet = new Set<String>();
		String tempWhatId;
		for(Event e : rawEvents) {
			tempWhatId = e.WhatId;
			if(tempWhatId != null) {
				if(tempWhatId.startsWith(Constants.START_OBJECT_PREFIX_ID)) {
					startEvents.add(e);
					whatIdSet.add(e.WhatId);
				} else if(tempWhatId.startsWith(Constants.TRANSFERT_OBJECT_PREFIX_ID)) {
					transfertEvents.add(e);
					whatIdSet.add(e.WhatId);
				}
			}
		}
		
		List<Event> eventsToUpdate = handleStartEvents(startEvents, whatIdSet);
		eventsToUpdate.addAll(handleTransfertEvents(transfertEvents, whatIdSet));
		
		if(!eventsToUpdate.isEmpty()) {
			update eventsToUpdate;
		}
		
		if(!Test.isRunningTest()) {
			System.enqueueJob(new Batch_Confirmation_SMS());
		}
	}
	
	private static List<Event> handleStartEvents(List<Event> startEvents, Set<String> whatIdSet) {
		// Retrieve LeadIds and Data such as Phone numbers
		Map<Id, Start__c> startMap = new Map<Id, Start__c>([SELECT Id, Crea__c, Crea__r.MobilePhone FROM Start__c WHERE Id IN :whatIdSet]);
		
		List<Event> eventsToUpdate = new List<Event>();
		for(Event e : startEvents) {
			if(startMap.containsKey(e.WhatId)) {
				Utils_CustomEmailTemplateDesigner smsDesigner = new Utils_CustomEmailTemplateDesigner(
					new Lead(Id = startMap.get(e.WhatId).Crea__c), 
					new User(Id = e.OwnerId, FirstName = e.Owner.FirstName, LastName = e.Owner.LastName), 
					e,
					null,
					null,
					Constants.EVENT_CREA_TIIME_CONFIRMATION_SMS_CONTENT
				);
				
				if(SMS.sendSMS(startMap.get(e.WhatId).Crea__r.MobilePhone, smsDesigner.formatLeadEmailTemplate(), startMap.get(e.WhatId).Crea__c, false)) {
					e.ConfirmationSmsSend__c = true;
					eventsToUpdate.add(e);
				}
			}
		}
		
		return eventsToUpdate;
	}
	
	private static List<Event> handleTransfertEvents(List<Event> transfertEvents, Set<String> whatIdSet) {
		// Retrieve LeadIds and Data such as Phone numbers
		Map<Id, Transfert__c> transfertMap = new Map<Id, Transfert__c>([SELECT Id, AppointmentType__c, Lead__c, Lead__r.FirstName, Lead__r.MobilePhone, Lead__r.Branding__c,  Partenaire__c, Partenaire__r.BillingStreet, Partenaire__r.BillingCity, Partenaire__r.BillingPostalCode, Partenaire__r.BillingCountry, Partenaire__r.Floor__c, ContactPartenaire__c, ContactPartenaire__r.MobilePhone FROM Transfert__c WHERE Id IN :whatIdSet]);
		
		List<Event> eventsToUpdate = new List<Event>();
		for(Event e : transfertEvents) {
			if(transfertMap.containsKey(e.WhatId)) {
				Utils_CustomEmailTemplateDesigner smsDesigner = new Utils_CustomEmailTemplateDesigner(
					new Lead(
						Id = transfertMap.get(e.WhatId).Lead__c, 
						FirstName = transfertMap.get(e.WhatId).Lead__r.FirstName,
						Branding__c = transfertMap.get(e.WhatId).Lead__r.Branding__c
					), 
					new User(
						Id = e.OwnerId, 
						FirstName = e.Owner.FirstName, 
						LastName = e.Owner.LastName
					), 
					e, 
					new Account(
						BillingStreet = transfertMap.get(e.WhatId).Partenaire__r.BillingStreet,
						BillingCity = transfertMap.get(e.WhatId).Partenaire__r.BillingCity,
						BillingPostalCode = transfertMap.get(e.WhatId).Partenaire__r.BillingPostalCode,
						BillingCountry = transfertMap.get(e.WhatId).Partenaire__r.BillingCountry,
						Floor__c = transfertMap.get(e.WhatId).Partenaire__r.Floor__c
					),
					new Contact(MobilePhone = transfertMap.get(e.WhatId).ContactPartenaire__r.MobilePhone),
					(transfertMap.get(e.WhatId).AppointmentType__c == Constants.LEAD_RDV_TYPE_TELEPHONIQUE ? Constants.EVENT_CAB_ONLINE_CONFIRMATION_SMS_CONTENT : Constants.EVENT_CAB_TIIME_CONFIRMATION_SMS_CONTENT)
				);
				
				if(SMS.sendSMS(transfertMap.get(e.WhatId).Lead__r.MobilePhone, smsDesigner.formatLeadEmailTemplate(), transfertMap.get(e.WhatId).Lead__c, false)) {
					e.ConfirmationSmsSend__c = true;
					eventsToUpdate.add(e);
				}
			}
		}
		
		return eventsToUpdate;
	}
	
}