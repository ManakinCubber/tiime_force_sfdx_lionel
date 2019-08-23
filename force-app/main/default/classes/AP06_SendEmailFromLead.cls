/**
* author:		Kévin Melliand
* date:			13/12/2018
* description:	Classe appelée par les triggers trLeadAfterInsert et trLeadAfterUpdate. En cas de RDV planifé pour la Lead, un email
* 				est envoyé au client ainsi qu'au contact partenaire.
* test:			AP06_SendEmailFromLead_TEST (97%).
*/
public with sharing class AP06_SendEmailFromLead {
    
    @TestVisible
    private static boolean hasBeenCalled;
    @TestVisible
    private static Integer nbEmail;
    
    /**
    * Sélectionne les Leads pour lesquelles le champ 'RDV planifié' vient de passer à true pour envoyer un email de confirmation.
    * Si la Map est nulle, alors cela siginifie que la led provient du Trigger Insert.
    */
    public static void sendEmailIfAppointmentSet(List<Lead> leads, Map<Id, Lead> oldLeads) {
    	if(hasBeenCalled != true) {
	    	List<Lead> leadsToProcess = new List<Lead>();
	    	
	    	for(Lead l : leads) {
	    		if( (oldLeads == null || l.Is_Appointment_Set__c != oldLeads.get(l.Id).Is_Appointment_Set__c) 
	    		&& l.Is_Appointment_Set__c && l.Email_Body__c != null && l.Email != Constants.EMAIL_DEFAULT_FAKE_ADDRESS 
	    		&& String.isBlank(l.EmailBouncedReason)) {
	    			leadsToProcess.add(l);
	    		}
	    	}
	    	
	    	if(!leadsToProcess.isEmpty()) {
	    		sendEmail(leadsToProcess, Constants.SEND_EMAIL_FROM_LEAD_TEMPLATE_EMAIL, false);
	    	}
    	}
    }
    
    public class InvocableParameters {
    	@InvocableVariable(required=true)
    	public String leadId;
    	@InvocableVariable(required=true)
    	public String emailTemplateName;
    }
    /**
    * @author		: Kévin Melliand (kevin.melliand@tiime.fr)
    * @date			: 05/02/2019 (dd/MM/YYYY)
    * @description	: Method called by the process builder when a laed status is changed.
    **/
    @InvocableMethod
    public static void sendEmailToLead(InvocableParameters[] parameters) {
    	System.debug('In sendEmailToLead');
    	System.debug('parameters : ' + parameters);
    	System.debug('parameters size : ' + parameters.size());
    	
    	Map<Id, String> leadIdToEmailTemplateNameMap = new Map<Id, String>();
    	for(InvocableParameters ip : parameters) {
    		leadIdToEmailTemplateNameMap.put(ip.leadId, ip.emailTemplateName);
    	}
    	
    	List<Lead> leadsMap = [SELECT Id, FirstName, LastName, Email, Contact_Partenaire__c, Branding__c, Rendez_vous__c, OrigineWebsite__c, EmailBouncedReason  
    	FROM Lead WHERE ID IN :leadIdToEmailTemplateNameMap.keySet()];
    	
    	
    	Map<String, List<Lead>> emailTemplateToLeadListMap = new Map<String, List<Lead>>();
    	for(Lead l : leadsMap) {
    		if(l.Email != Constants.EMAIL_DEFAULT_FAKE_ADDRESS && String.isBlank(l.EmailBouncedReason)) {
	    		List<Lead> tempLeads = new List<Lead>();
	    		if(leadIdToEmailTemplateNameMap.containsKey(l.Id) && emailTemplateToLeadListMap.containsKey(leadIdToEmailTemplateNameMap.get(l.Id))) {
	    			tempLeads = emailTemplateToLeadListMap.get(leadIdToEmailTemplateNameMap.get(l.Id));
	    		}
	    		tempLeads.add(l);
	    		emailTemplateToLeadListMap.put(leadIdToEmailTemplateNameMap.get(l.Id), tempLeads);
    		}
    	}
    	
    	for(String emailTemplate : emailTemplateToLeadListMap.keySet()) {
    		sendEmail(emailTemplateToLeadListMap.get(emailTemplate), emailTemplate, true);
    	}
    }
    
    /**
    * Préparer la liste des destinataires et contenu de l'email.
    */
    private static void sendEmail(List<Lead> leads, String emailTemplateDevelopName, boolean fromProcessBuilder) {
    	
    	// Récuperation des destinataires
    	Set<String> contactPartenaireSet = new Set<String>();
    	for(Lead l : leads) {
    		contactPartenaireSet.add(l.Contact_Partenaire__c);
    	}
    	contactPartenaireSet.remove(null);
    	Map<Id, Contact> contactsPartenairesMap = new Map<Id, Contact> ([SELECT Id, Name, Email FROM Contact WHERE Id IN :contactPartenaireSet]);
    	
    	// Récupération des destinataires en copie
    	String[] additionnalEmailList = Constants.SEND_EMAIL_FROM_LEAD_ADDITIONNAL_RECIPIENTS.split(Constants.CUSTOM_LABEL_INNER_SEPARATOR);
    	
    	// Récupération du template de l'email
    	EmailTemplate template = [SELECT Id, Subject, DeveloperName FROM EmailTemplate WHERE DeveloperName = :emailTemplateDevelopName];
    	
    	List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    	for(Lead l : leads) {
    		emails.add(prepareEmail(l, contactsPartenairesMap, additionnalEmailList, template, fromProcessBuilder));
    	}
    	
    	nbEmail = emails.size();
    	if(!emails.isEmpty()) {
	    	System.debug('AP06 déclenchée');
	    	hasBeenCalled = true;
	    	System.debug(emails);
	    	if(!Test.isRunningTest()) {
	    		Messaging.sendEmail(emails);
	    	}
    	}
    }
    
    private static Messaging.SingleEmailMessage prepareEmail(Lead lead, Map<Id, Contact> contactsPartenairesMap, String[] additionnalEmailList, EmailTemplate template, boolean fromProcessBuilder) {
    	
    	Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
    	
    	String queryValue = (lead.Branding__c == Constants.LEAD_BRANDING_LEC_LILLE ? Constants.LEAD_BRANDING_LEC : lead.Branding__c);
    	List<OrgWideEmailAddress> owdList = [SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName = :queryValue];
    	if(!owdList.isEmpty()) {
    		singleEmail.setOrgWideEmailAddressId(owdList.get(0).Id);
    	}
    	
    	singleEmail.setToAddresses(new String[] {lead.Email});
    	singleEmail.setBccAddresses(additionnalEmailList);
    	
    	if(fromProcessBuilder) {
    		singleEmail.setSubject(template.Subject);
    		Utils_CustomEmailTemplateDesigner emailDesigner = new Utils_CustomEmailTemplateDesigner(lead, null, Constants.EMAIL_TEMPLATE_TO_CUSTOM_LABEL_MAP.get(template.DeveloperName));
    		singleEmail.setPlainTextBody(emailDesigner.formatLeadEmailTemplate());
    	} else {
    		singleEmail.setPlainTextBody(lead.Email_Body__c);
    		singleEmail.setSubject(Constants.SEND_EMAIL_FROM_LEAD_SUBJECT + contactsPartenairesMap.get(lead.Contact_Partenaire__c).Name);
    	}
    	
    	singleEmail.setTargetObjectId(lead.Id);
    	
    	// KM SF-75 (21/01/2019) 
    	// Ajout d'une pièce jointe ICS
    	if(lead.Rendez_vous__c != null) {
    		String emailForICS = (owdList.isEmpty() ? 'test@test.com' : owdList.get(0).Address);
    		singleEmail.setFileAttachments(AP08_IcsFileGenerator.generateIcsAttachment(lead.Rendez_vous__c, emailForICS, singleEmail.getSubject()));
    	}
    	return singleEmail; 
    }
    
    
    
    
    
}