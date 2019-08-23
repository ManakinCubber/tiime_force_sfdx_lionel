public with sharing class LTC20_SendProposal {
    
    private static final Map<String, Set<String>> objectNameToFieldsNameMap = new Map<String, Set<String>> {
    	'Transfert__c'	=> new Set<String> {'Company__c', 'MailAddress__c', 'MobilePhone__c', 'Address__c'},
    	'Lead'			=> new Set<String> {'FirstName', 'LastName', 'Offres__c', 'Branding__c'}
    };
    
    
    
    @AuraEnabled
	public static Map<String, String> getLabels() {
		//Workaround to get field label in lightning component
		Map<String, String> labels = new Map<String, String>();
		for(String objectName : objectNameToFieldsNameMap.keySet()) {
    		for(String fieldApiName : objectNameToFieldsNameMap.get(objectName)) {
    			labels.put(fieldApiName, Utils.getFieldLabel(objectName, fieldApiName));
    		}
    	}
		return labels;
	}
	
	@AuraEnabled
	public static Map<String, String> getOffreOptions(String branding) {
		
		Map<String, String> offresOptions = Utils.getPicklistOptions('Lead', 'Offres__c');
		Map<String, String> offresOptionsEnabled = new Map<String, String>();
		
		for(String label : offresOptions.keySet()) {
			if(Constants.BRANDING_TO_OFFRES_MAP.containsKey(branding) && 
			Constants.BRANDING_TO_OFFRES_MAP.get(branding).contains(Integer.valueOf(offresOptions.get(label)))) {
					offresOptionsEnabled.put(label, offresOptions.get(label));
			}
		}
		return offresOptionsEnabled;
	}
	
	@AuraEnabled
	public static String getOffreOptionsViaBGI(Id leadId, Id transfertId) {
		WS03_BaseGI_GetOffres ws = new WS03_BaseGI_GetOffres();
		WS03_BaseGI.WsGetOffresResponse resp = ws.getOffresByBranding(leadId);
		System.debug(resp);
		
		Map<Integer, WS03_BaseGI.MissionBGI> missionMap = new Map<Integer, WS03_BaseGI.MissionBGI>();
		for(Mission__c m : [SELECT Id, OfferBgiId__c, MissionBgiId__c, Comment__c, IsMonthly__c, OfferName__c, MissionName__c, Price__c, BasicPrice__c 
		FROM Mission__c WHERE Transfert__c = :transfertId]) {
			missionMap.put(Integer.valueOf(m.MissionBgiId__c), new WS03_BaseGI.MissionBGI(
				m.MissionBgiId__c, 
				m.Price__c, 
				m.BasicPrice__c, 
				m.MissionName__c, 
				m.IsMonthly__c, 
				m.Comment__c, 
				m.OfferName__c, 
				m.OfferBgiId__c
			));
		}
		System.debug(missionMap);
		
		
		
		for(WS03_BaseGI.OffreBGI offre : resp.offres) {
			List<WS03_BaseGI.MissionBGI> missionsExistantes = new List<WS03_BaseGI.MissionBGI>();
			for(WS03_BaseGI.MissionBGI mission : offre.getMissions()) {
				System.debug(mission);
				
				if(missionMap.containsKey(mission.getId())) {
					System.debug('matching');
					missionsExistantes.add(missionMap.get(mission.getId()));
				}
			}
			if(!missionsExistantes.isEmpty()) {
				offre.setMissions(missionsExistantes);
			}
		}
		
		System.debug(resp);
		return JSON.serialize(resp);
	}
	
	@AuraEnabled
	public static String retrieveExistingMissions(Id transfertId) {
		List<Mission__c> missions = [SELECT Id, OfferBgiId__c, MissionBgiId__c, Comment__c, IsMonthly__c, OfferName__c, MissionName__c, Price__c, BasicPrice__c 
		FROM Mission__c WHERE Transfert__c = :transfertId];
		
		Map<String, WS03_BaseGI.OffreBGI> offresMap = new Map<String, WS03_BaseGI.OffreBGI>();
		for(Mission__c m : missions){
			WS03_BaseGI.OffreBGI tempOffre;
			if(offresMap.containsKey(m.OfferBgiId__c)) {
				tempOffre = offresMap.get(m.OfferBgiId__c);
			} else {
				tempOffre = new WS03_BaseGI.OffreBGI(Integer.valueOf(m.OfferBgiId__c), m.OfferName__c, new List<WS03_BaseGI.MissionBGI>());
			}
			tempOffre.addMission(new WS03_BaseGI.MissionBGI(
				m.MissionBgiId__c, 
				m.Price__c, 
				m.BasicPrice__c, 
				m.MissionName__c, 
				m.IsMonthly__c, 
				m.Comment__c, 
				m.OfferName__c, 
				m.OfferBgiId__c
			));
			offresMap.put(m.OfferBgiId__c, tempOffre);
			System.debug(offresMap);
		}
		
		return JSON.serialize(offresMap.values());
	}
	
	@AuraEnabled
	public static List<ContentDocument> getAccountAttachments(Id partnerAccountId) {
		List<ContentDocument> fileTitles = new List<ContentDocument>();
		for(ContentDocumentLink cdl : [
			SELECT Id, LinkedEntityId, ShareType, Visibility, ContentDocumentId, 
			ContentDocument.Title, ContentDocument.ContentSize, ContentDocument.FileType, ContentDocument.SharingPrivacy, ContentDocument.PublishStatus
			FROM ContentDocumentLink WHERE LinkedEntityId  = :partnerAccountId AND ContentDocument.FileType IN :Constants.EMAIL_SEND_PROP_ATTACHMENT_FILE_TYPES
		]) {
			fileTitles.add(cdl.ContentDocument);
		}
		return fileTitles;
	}
	
	@AuraEnabled
	public static void save(Id leadId, Id transfertId, String missions) {
		System.debug('In save');
		System.debug(missions);
		
		update new Lead(Id = leadId, IsLeadConvertedByLT20__c = true);
		
		
		//missions = '{' + missions/*.replace('"', '\'')*/ + '}';
		//System.debug(missions);
		List<WS03_BaseGI.MissionBGI> missionsList = (List<WS03_BaseGI.MissionBGI>) JSON.deserializeStrict(missions, List<WS03_BaseGI.MissionBGI>.class);
		List<Mission__c> missionsSF = new List<Mission__c>();
		for(WS03_BaseGI.MissionBGI mission : missionsList) {
			System.debug(mission);
			missionsSF.add(new Mission__c(
				Comment__c = mission.getCommentaire(),
				MissionBgiId__c = mission.getId().format(),
				OfferBgiId__c = mission.getOfferId().format(),
				IsMonthly__c = (mission.getPeriodicite() == 'M' ? true : false),
				OfferName__c = mission.getOfferName(),
				MissionName__c = mission.getLibelle(),
				Name = mission.getOfferName() + ' ' + mission.getLibelle(),
				Price__c = mission.getTarif(),
				BasicPrice__c = mission.getTarifDeBase(),
				Transfert__c = transfertId
			));
		}
		insert missionsSF;
	}
	
	@AuraEnabled
	public static List<String> leadConversion(Id leadId) {
		
		LeadConverterProcessAE converter = new LeadConverterProcessAE(leadId);
		Database.LeadConvertResult lcr = converter.launchLeadConversion();
		
		List<String> accountContactAndOppIdList = new List<String> {lcr.getAccountId(), lcr.getContactId(), lcr.getOpportunityId()};
		
		return accountContactAndOppIdList;
	}
	
	@AuraEnabled
	public static void saveAccountId(Id transfertId, Id accountId, Id oppId) {
		update new Transfert__c(Id = transfertId, ConvertedAccountId__c = accountId, ConvertedOpportunity__c = oppId);
	}
	
	@AuraEnabled
	public static void linkSurveysOnContact(Id leadId, Id contactId, Id accountId) {
		// In case of contact duplicate, the contact has been deleted
		contactId = findContactId(contactId, accountId);
		List<EnquetedeSatisfaction__c> surveys = [SELECT Id, ContactLead__c FROM EnquetedeSatisfaction__c WHERE Lead__c = :leadId];
		for(EnquetedeSatisfaction__c es : surveys) {
			es.ContactLead__c = contactId;
		}
		update surveys;
	}
	
	@AuraEnabled
	public static void passOnTransfertInfoToAccOpp(Id transfertId, Id accountId, Id oppId) {
		Transfert__c transfert = [SELECT Id, AEComments__c, CreatedDate FROM Transfert__c WHERE Id = :transfertId];
		update new Opportunity(Id = oppId, AEComments__c = transfert.AEComments__c);
		update new Account(Id = accountId, TransfertDate__c = transfert.CreatedDate);
		
		List<Mission__c> missions = [SELECT Id, Opportunity__c FROM Mission__c WHERE Transfert__c = :transfertId];
		for(Mission__c m : missions) {
			m.Opportunity__c = oppId;
		}
		update missions;
	}
	
	@AuraEnabled
	public static void sendToBaseGI(Id accountId, Id oppId, List<Id> filesToAttach) {
		if(filesToAttach != null && (!filesToAttach.isEmpty())) {
			WS03_BaseGI_ConvertLead ws = new WS03_BaseGI_ConvertLead();
			ws.updateBGIAfterLeadConversion(accountId, oppId);
		} else {
    		throw new AuraException('Attention ! Aucun pdf n\'est sélectionné pour l\'envoi de la proposition.');
   		}
	}
	
	@AuraEnabled
	public static void saveOffersOnAccount(Id accountId, String idOffers) {
		update new Account(Id = accountId, IdPdfOffers__c = idOffers);
	}
	
	@AuraEnabled
	public static void changeStatus(Id transfertId) {
		update new Transfert__c(Id = transfertId, Etape__c = Constants.TRANSFERT_ETAPE_PROP_ENVOYEE);
	}
	
	@AuraEnabled
	public static void sendEmailOrSmsToClient(String accountId, String partnerAccountId, boolean sendEmail, List<Id> filesToAttach) {
    	Account account = [SELECT Id, Name, ContractSignLink__c, Owner.FirstName, (SELECT FirstName, Email, MobilePhone FROM Contacts WHERE MainContact__c = true AND IsActif__c = true) FROM Account WHERE Id = :accountId];
    	List<Transfert__c> transferts = [SELECT Id, Branding__c FROM Transfert__c WHERE ConvertedAccountId__c = :accountId];
    	Account partnerAccount = [SELECT Id, Name, BillingStreet, BillingPostalCode, BillingCity, MainPhoneNumber__c FROM Account WHERE Id = :partnerAccountId];
    	
    	account.BillingStreet = partnerAccount.BillingStreet;
    	account.BillingPostalCode = partnerAccount.BillingPostalCode;
    	account.BillingCity = partnerAccount.BillingCity;
    	account.MainPhoneNumber__c = partnerAccount.MainPhoneNumber__c;
    	
    	if((!transferts.isEmpty()) && (!account.Contacts.isEmpty())) {
    		
    		Utils_CustomEmailTemplateDesigner designer = new Utils_CustomEmailTemplateDesigner(
    			account.Owner, 
    			account, 
    			account.Contacts.get(0), 
    			new Transfert__c(Branding__c = transferts.get(0).Branding__c), 
    			Constants.EMAIL_TEMPLATE_SIGN_LINK
    		);
    		if(sendEmail) {
    			sendEmailProposition(transferts.get(0).Branding__c, account.Contacts.get(0).Email, filesToAttach, designer.formatLeadEmailTemplate(), Constants.EMAIL_SUBJECT_SIGN_LINK);
    		} else {
    			SMS.sendSMS(account.Contacts.get(0).MobilePhone, designer.formatLeadEmailTemplate(Constants.TRANSFERT_CAB_SIGN_LINK), transferts.get(0).Id, false);
    		}
    	}
    }
    
    @AuraEnabled 
    public static void updateLead(Id leadId, String firstName, String lastName, String companyName, String email, String mobilePhone, String branding) {
    	update new Lead(
    		Id = leadId,
    		FirstName = firstName, 
    		LastName = lastName, 
    		Company = companyName, 
    		Email = email, 
    		MobilePhone = mobilePhone,
    		Branding__c = branding
    	);
    }
    
    @AuraEnabled
    public static void logAnError(String errorMessage) {
    	Utils.createLogError(errorMessage);
    }
    
    private static Messaging.EmailFileAttachment generateEmailAttachment(ContentVersion cv, String branding) {
    	Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
    	emailAttachment.body = cv.VersionData;
    	//emailAttachment.contenttype = cv.ContentDocument.FileExtension;
    	emailAttachment.filename = (
    		Constants.BRANDING_PDF_OFFER_NAME_MAP.containsKey(branding) ? 
    		Constants.BRANDING_PDF_OFFER_NAME_MAP.get(branding) : cv.ContentDocument.Title) + '.' + cv.ContentDocument.FileExtension;
    	emailAttachment.inline = false;
    	return emailAttachment;
    }
    /*
    * @author : kevin Melliand
    * @description : In case a contact duplicate was found during conversion, the newly converted contact has been deleted and the old one was rattached to 
    * the stakeholder. Thus, the contactId returned by the LeadConvertedResult is false. This method will give the real contact Id.
    */
    private static Id findContactId(Id currentContactId, Id accountId) {
    	Id returnId;
    	List<Contact> contacts = [SELECT Id FROM Contact WHERE Id = :currentContactId];
		if(contacts.isEmpty()) {
			List<Stakeholder__c> stakeholders = [SELECT Id, Contact__c FROM Stakeholder__c WHERE Company__c = :accountId ORDER BY CreatedDate DESC];
			returnId = stakeholders.get(0).Contact__c;
		} else {
			returnId = currentContactId;
		}
		return returnId;
    }
    
    public static void sendEmailProposition(String branding, String email, List<Id> filesToAttach, String emailContent, String subject) {
    	if(filesToAttach != null && (!filesToAttach.isEmpty())) {
	    			Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
	    			singleEmail.setOrgWideEmailAddressId(Utils.getOrgWideAddressesByBranding(branding));
	    			singleEmail.setToAddresses(new String[] {email});
	    			singleEmail.setBccAddresses(Utils.getEmailAdditionnalAddresses());
	    			singleEmail.setSubject(subject + branding);
	    			singleEmail.setHtmlBody(emailContent);
	    			
	    			List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
	    			for(ContentVersion cv : [
						SELECT Id, VersionData, ContentDocumentId, ContentDocument.FileExtension,
						ContentDocument.Title, ContentDocument.ContentSize, ContentDocument.FileType, ContentDocument.SharingPrivacy, ContentDocument.PublishStatus
						FROM ContentVersion WHERE ContentDocumentId  IN :filesToAttach AND ContentDocument.FileType IN :Constants.EMAIL_SEND_PROP_ATTACHMENT_FILE_TYPES
					]) {
	    				emailAttachments.add(generateEmailAttachment(cv, branding));
	    			}
	    			if(!emailAttachments.isEmpty()) {
	    				singleEmail.setFileAttachments(emailAttachments);
	    			}
	    			
	    			List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>{singleEmail};
	    			Messaging.sendEmail(emails);
    			} else {
    				throw new AuraException('Attention ! Aucun pdf n\'est sélectionné pour l\'envoi de la proposition.');
    			}
    }
}