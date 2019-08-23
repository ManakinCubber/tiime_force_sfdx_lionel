public with sharing class Utils_CustomEmailTemplateDesigner {
    
    private static final String VARIABLE_CHEVRON_OUVRANT = '!%%';
    private static final String VARIABLE_CHEVRON_FERMANT = '%%!';
    private static final String VARIABLE_ACCOLADE_OUVRANT = '{';
    private static final String VARIABLE_ACCOLADE_FERMANT = '}';
    private static final String CONSTANT_FIELD_LEAD = 'Lead_';
    private static final String CONSTANT_FIELD_ACCOUNT = 'Account_';
    private static final String CONSTANT_FIELD_CONTACT = 'Contact_';
    private static final String CONSTANT_FIELD_OPPORTUNITY = 'Opportunity_';
    private static final String CONSTANT_FIELD_TRANSFERT = 'Transfert__c_';
    private static final String CONSTANT_JOUR = 'jour';
    private static final Set<String> CONSTANT_FIELD_SET = new Set<String> {
    	CONSTANT_FIELD_LEAD,
    	CONSTANT_FIELD_ACCOUNT,
    	CONSTANT_FIELD_CONTACT,
    	CONSTANT_FIELD_OPPORTUNITY,
    	CONSTANT_FIELD_TRANSFERT
    };
    private Map<String, Schema.SObjectField> leadFieldsMap;
    private Map<String, Schema.SObjectField> userFieldsMap;
    private Map<String, Schema.SObjectField> eventFieldsMap;
    private Map<String, Schema.SObjectField> accountFieldsMap;
    private Map<String, Schema.SObjectField> contactFieldsMap;
    private Map<String, Schema.SObjectField> opportunityFieldsMap;
    private Map<String, Schema.SObjectField> transfertFieldsMap;
    
    
    private Lead lead;
    private String emailTemplate;
    private User user;
    private Event event;
    private Account account;
    private Contact contact;
    private Opportunity opportunity;
    private Transfert__c transfert;
    
    public Utils_CustomEmailTemplateDesigner(Lead lead, User user, String emailTemplate) {
    	if(emailTemplate == null) {
    		throw new EmailTemplateDesignerException('Vous devez renseigner un template d\'email valide.');
    	} else if(user == null) {
    		user = retrieveCurrentUser();
    	}
    	this.lead = lead;
    	this.user = user;
    	this.event = null;
    	
    	this.emailTemplate = emailTemplate;
    }
    public Utils_CustomEmailTemplateDesigner(Lead lead, User user, Event event, Account account, Contact contact, String emailTemplate) {
    	if(emailTemplate == null) {
    		throw new EmailTemplateDesignerException('Vous devez renseigner un template d\'email valide.');
    	} else if(user == null) {
    		user = retrieveCurrentUser();
    	}
    	this.lead = lead;
    	this.user = user;
    	this.event = event;
    	this.account = account;
    	this.contact = contact;
    	this.emailTemplate = emailTemplate;
    }
    
    public Utils_CustomEmailTemplateDesigner(Opportunity opportunity, User user, Account account, Contact contact, String emailTemplate) {
    	if(emailTemplate == null) {
    		throw new EmailTemplateDesignerException('Vous devez renseigner un template d\'email valide.');
    	} else if(user == null) {
    		user = retrieveCurrentUser();
    	}
    	this.opportunity = opportunity;
    	this.user = user;
    	this.account = account;
    	this.contact = contact;
    	this.emailTemplate = emailTemplate;
    }
    
    public Utils_CustomEmailTemplateDesigner(User user, Account account, Contact contact, Transfert__c transfert, String emailTemplate) {
    	if(emailTemplate == null) {
    		throw new EmailTemplateDesignerException('Vous devez renseigner un template d\'email valide.');
    	} else if(user == null) {
    		user = retrieveCurrentUser();
    	}
    	this.user = user;
    	this.account = account;
    	this.contact = contact;
    	this.transfert = transfert;
    	this.emailTemplate = emailTemplate;
    }
    
    public String formatLeadEmailTemplate(String emailTemplate) {
    	if(String.isNotBlank(emailTemplate)) {
    		this.emailTemplate = emailTemplate;
    		return formatLeadEmailTemplate();
    	}
    	return null;
    }
    
    public String formatLeadEmailTemplate() {
    	
    	if((this.lead != null || this.contact != null) && this.user != null) {
    		retrieveLeadFields();
    		retrieveUserFields();
    		
    		if(this.event != null) {
    			retrieveEventFields();
    		}
    		
    		if(this.account != null) {
    			retrieveAccountFields();
    		}
    		
    		if(this.contact != null) {
    			retrieveContactFields();
    		}
    		
    		if(this.opportunity != null) {
    			retrieveOpportunityFields();
    		}
    		
    		if(this.transfert != null) {
    			retrieveTransfertFields();
    		}
    		
    		
    		if(this.emailTemplate.contains(VARIABLE_CHEVRON_OUVRANT + CONSTANT_JOUR + VARIABLE_CHEVRON_FERMANT)) {
    			this.emailTemplate = this.emailTemplate.replace(
    				VARIABLE_CHEVRON_OUVRANT + CONSTANT_JOUR + VARIABLE_CHEVRON_FERMANT,
    				(this.event.StartDateTime.isSameDay(Datetime.now()) ? Constants.SMS_TEMPLATE_TODAY : Constants.SMS_TEMPLATE_TOMORROW)
    			);
    		}
    		
    		//System.debug(leadFieldsMap);
    		//System.debug(userFieldsMap);
    		Integer counter = 0;
    		while(this.emailTemplate.contains(VARIABLE_CHEVRON_OUVRANT) && this.emailTemplate.contains(VARIABLE_CHEVRON_FERMANT) && counter < 50) {
    			replaceFieldInTemplate();
    			System.debug(this.emailTemplate);
    			counter++;
    		}
    		
    	} else {
    		throw new EmailTemplateDesignerException('Des éléments essentiels (Lead ou Contact ou User) manquent.');
    	}
    	return this.emailTemplate;
    }
    
    private User retrieveCurrentUser() {
    	return [SELECT Id, FirstName, LastName, AircallPhoneNumber__c, MobilePhone FROM User WHERE Id = :UserInfo.getUserId()];
    }
    
    private void retrieveLeadFields() {
    	this.leadFieldsMap = Schema.SObjectType.Lead.fields.getMap();
    }
    
    private void retrieveAccountFields() {
    	this.accountFieldsMap = Schema.SObjectType.Account.fields.getMap();
    }
    
    private void retrieveContactFields() {
    	this.contactFieldsMap = Schema.SObjectType.Contact.fields.getMap();
    }
    
    private void retrieveUserFields() {
    	this.userFieldsMap = Schema.SObjectType.User.fields.getMap();
    }
    
    private void retrieveEventFields() {
    	this.eventFieldsMap = Schema.SObjectType.Event.fields.getMap();
    }
    
    private void retrieveOpportunityFields() {
    	this.opportunityFieldsMap = Schema.SObjectType.Opportunity.fields.getMap();
    }
    
    private void retrieveTransfertFields() {
    	this.TransfertFieldsMap = Schema.SObjectType.Transfert__c.fields.getMap();
    }
    
    private void replaceFieldInTemplate() {
    	if(this.emailTemplate.indexOf(VARIABLE_CHEVRON_OUVRANT) < this.emailTemplate.indexOf(VARIABLE_CHEVRON_FERMANT)) {
    		String field = getfield();
    		//System.debug(field);
    		
    		SObject obj = searchField(field);
    		//System.debug('obj : ' + obj);
    		if(obj != null ) {
    			//System.debug('field : ' + field);
    			//System.debug('(obj.get(field) : ' + (obj.get(field)));
    			if(obj.get(cleanField(field)) != null) {
    				//System.debug('(obj.get(field) : ' + VARIABLE_CHEVRON_OUVRANT +  field + VARIABLE_CHEVRON_FERMANT);
    				this.emailTemplate = this.emailTemplate.replace(VARIABLE_CHEVRON_OUVRANT +  field + VARIABLE_CHEVRON_FERMANT, castField(obj.get(cleanField(field))));
    			} else {
    				this.emailTemplate = this.emailTemplate.replace(VARIABLE_CHEVRON_OUVRANT +  field + VARIABLE_CHEVRON_FERMANT, 
    					VARIABLE_ACCOLADE_OUVRANT + field + VARIABLE_ACCOLADE_FERMANT);
    			}
    			
    		}
    	} else {
    		throw new EmailTemplateDesignerException('Email template incorrect');
    	}
    }
    
    private String getfield() {
    	return this.emailTemplate.substring(this.emailTemplate.indexOf(VARIABLE_CHEVRON_OUVRANT)+VARIABLE_CHEVRON_OUVRANT.length(), this.emailTemplate.indexOf(VARIABLE_CHEVRON_FERMANT));
    }
    
    private SObject searchField(String field) {
    	SObject objectReturned = null;
    	if(userFieldsMap.containsKey(field)) {	
    		objectReturned = this.user;
    	} else if (event != null && eventFieldsMap.containsKey(field)) {
    		objectReturned = this.event;
    	} else if (lead != null && leadFieldsMap.containsKey(field) || field.contains(CONSTANT_FIELD_LEAD)) {
    		objectReturned = this.lead;
    	} else if (account != null && accountFieldsMap.containsKey(field) || field.contains(CONSTANT_FIELD_ACCOUNT)) {
    		objectReturned = this.account;
    	} else if(contact != null && contactFieldsMap.containsKey(field) || field.contains(CONSTANT_FIELD_CONTACT)) {
    		objectReturned = this.contact;
    	} else if(opportunity != null && opportunityFieldsMap.containsKey(field) || field.contains(CONSTANT_FIELD_OPPORTUNITY)) {
    		objectReturned = this.opportunity;
    	} else if(transfert != null && transfertFieldsMap.containsKey(field) || field.contains(CONSTANT_FIELD_TRANSFERT)) {
    		objectReturned = this.transfert;
    	}
    	return objectReturned;
    }
    
    private String cleanField(String fieldName) {
    	for(String s : CONSTANT_FIELD_SET) {
    		if(fieldName.contains(s)) {
    			fieldName = fieldName.remove(s);
    		}
    	}
    	//System.debug(fieldName);
    	return fieldName;
    }
    
    private String castField(Object objectField) {
    	String fieldValue;
    	try {
    		fieldValue = (String)objectField;
    	} catch (TypeException e) {
    		if(e.getMessage().contains('Datetime')) {
    			DateTime dt = (DateTime)objectField;
    			fieldValue = dt.format('HH\'h\'mm');
    		}
    	}
    	return fieldValue;
    }
    
    private class EmailTemplateDesignerException extends Exception {
    	
    }
}