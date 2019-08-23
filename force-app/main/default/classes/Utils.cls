/**
* author:		Kévin Melliand
* date:			13/12/2018
* description:	Classe contenant les méthodes utilitaires pouvant être utilisées dans l'ensemble du code 
* 
*/
public class Utils {
	
	// Leads methods
	
	public static Id getLeadRecordTypeIdByName(String recordTypeName) {
		return Schema.SObjectType.Lead.getRecordTypeInfosByName()
		.get(recordTypeName).getRecordTypeId();
	}
	
	public static Id getLeadRecordTypeByDeveloperName(String recordTypeDeveloperName) {
		return Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
		.get(recordTypeDeveloperName).getRecordTypeId();
	}
	
	// Accounts methods

	public static Id getAccountRecordTypeIdByName(String recordTypeName) {
		return Schema.SObjectType.Account.getRecordTypeInfosByName()
		.get(recordTypeName).getRecordTypeId();
	}
	
	public static Id getAccountRecordTypeByDeveloperName(String recordTypeDeveloperName) {
		return Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
		.get(recordTypeDeveloperName).getRecordTypeId();
	}
	
	// Enquete de satisfaction methods

	public static Id getEnqueteRecordTypeIdByName(String recordTypeName) {
		return Schema.SObjectType.enquetedeSatisfaction__c.getRecordTypeInfosByName()
		.get(recordTypeName).getRecordTypeId();
	}
	
	public static Id getEnqueteRecordTypeByDeveloperName(String recordTypeDeveloperName) {
		return Schema.SObjectType.enquetedeSatisfaction__c.getRecordTypeInfosByDeveloperName()
		.get(recordTypeDeveloperName).getRecordTypeId();
	}

	// Contacts methods

	public static Id getContactRecordTypeIdByName(String recordTypeName) {
		return Schema.SObjectType.Contact.getRecordTypeInfosByName()
		.get(recordTypeName).getRecordTypeId();
	}
	
	public static Id getContactRecordTypeIdByDeveloperName (String recordTypeDeveloperName) {
		return Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
		.get(recordTypeDeveloperName).getRecordTypeId();
	}
	
	// Stakeholder__c methods
	public static Id getStakeholderRecordTypeIdByDeveloperName (String recordTypeDeveloperName) {
		return Schema.SObjectType.Stakeholder__c.getRecordTypeInfosByDeveloperName()
		.get(recordTypeDeveloperName).getRecordTypeId();
	}
	
	// Tasks methods
	public static Id getTaskRecordTypeIdByName(String recordTypeName) {
		return Schema.SObjectType.Task.getRecordTypeInfosByName()
		.get(recordTypeName).getRecordTypeId();
	}
	
	public static Id getTaskRecordTypeIdByDeveloperName (String recordTypeDeveloperName) {
		return Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
		.get(recordTypeDeveloperName).getRecordTypeId();
	}
	
	//LogError__c methods
	public static void createLogError(Exception e) {
		insert new LogError__c(Message__c = e.getTypeName() + ' : ' + e.getMessage(), Trace__c = e.getStackTraceString());
	}
	
	public static void createLogError(String errorMessage) {
		if(errorMessage.length() != 0) {
			insert new LogError__c(Message__c = errorMessage);
		}
	}
	
	// String methods
	public static String removeInvalidCharInFileName(String filename) {
		for(String chr : Constants.INVALID_FILENAME_CHARS) {
			filename = filename.replace(chr, '');
		}
		return filename;
	}
	
	public static String removeLastChar(String srcValue) {
		return srcValue.substring(0, srcValue.length()-1);
	}
	
	public static String getFieldLabel(String objectName, String fieldName) {
		Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
		Schema.SObjectField field = fieldMap.get(fieldName);
		Schema.DescribeFieldResult describe = field.getDescribe();
		return describe.getLabel();
	}
	
	public static List<Schema.PicklistEntry> getPicklistEntries(String objectName, String fieldName) {
		Map<String, String> options = new Map<String, String>();

		Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
		return fieldResult.getPicklistValues();
	}

	public static Map<String, String> getPicklistOptionsWithNoneOption(String objectName, String fieldName, boolean noneOption) {
		Map<String, String> options = new Map<String, String>();
		if(noneOption) {
			options.put(' - Aucun - ', '');
		}
		options.putAll(getPicklistOptions(objectName, fieldName));
		
		return options;
	}
	
	public static Map<String, String> getPicklistOptions(String objectName, String fieldName) {
		Map<String, String> options = new Map<String, String>();
		List<Schema.PicklistEntry> ple = getPicklistEntries(objectName, fieldName);
		
		for(Schema.PicklistEntry f : ple) {
			options.put(f.getLabel(), f.getValue());
		}
		return options;
	}
	
	public static String replaceCodeToSymbol(String str) {
		Map<String, String> toReplace = new Map<String, String>();
		toReplace.put('&#39;','\'');
		for(String key : toReplace.keySet()){
			str = str.replace(key, toReplace.get(key)); 
		}
		return str;
	} 
	
	// Database.SaveResult
	
	public static void checkSaveResults(Database.SaveResult[] saveResults) {
    	String errorMessage = '';
    	for(Database.SaveResult sv : saveResults) {
    		if(!sv.isSuccess()) {
    			errorMessage += sv.getId() +' : ';
    			for(Database.Error e : sv.getErrors()) {
    				errorMessage += e.getFields() + ', ' + e.getStatusCode() +', ' + e.getMessage() + '; ';
    			}
    		}
    	}
    	createLogError(errorMessage);
    }

	// Documents methods
	public static Id generateDocument(String fileName, String documentName, Id parentId, String content) {
		ContentVersion conVer = new ContentVersion();
		conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
		conVer.PathOnClient = fileName; // The files name, extension is very important here which will help the file in preview.
		conVer.Title = documentName; // Display name of the files
		conVer.VersionData = Blob.valueOf(content);
		insert conVer;

		//Get the content document Id from ContentVersion
		Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;

		//Create ContentDocumentLink
		ContentDocumentLink cDe = new ContentDocumentLink();
		cDe.ContentDocumentId = conDoc;
		cDe.LinkedEntityId = parentId;
		cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
		insert cDe;

		return conDoc;
	}

	//Exception helpers
	public static AuraHandledException generateAuraHandledException(String message) {
		AuraHandledException e = new AuraHandledException(message);
		e.setMessage(message);
		return e;
	}
	
	// Profiles methods
	public static boolean isConnectedUserProfile(String profileName) {
		boolean profilNameMatching = false;
		Profile userConnectedProfile = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
		if(userConnectedProfile != null && userConnectedProfile.Name == profileName) {
			profilNameMatching = true;
		}
		return profilNameMatching;
	}
	
	public static boolean isUserProfile(String userId, String profileName) {
		boolean profilNameMatching = false;
		User user = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Id = :userId];
		if(user != null && user.Profile.Name == profileName) {
			profilNameMatching = true;
		}
		return profilNameMatching;
	}
	
	//convert PhoneNumber from +33 to 0..
	public static String convertPhoneNumber(String phoneNumber) {
		if(phoneNumber.length() != Constants.WS_BAGI_PHONE_NUMBER_EXPECTED_SIZE) {
			phoneNumber = phoneNumber.replace(Constants.PHONE_INTERNATIONAL_FRENCH_PREFIX,  '0');
		}
		return phoneNumber;
	}
	
	// Instance of
	public static boolean isInstanceOf(String objectApiName, String id) {
    	boolean isInstanceOf = false;
    	if(String.isNotBlank(id)) {
	    	switch on objectApiName {
	            when 'Transfert__c' {
	    			isInstanceOf = id.startsWith(Constants.TRANSFERT_OBJECT_PREFIX_ID);
	    		}
	    		when 'Start__c' {
	    			isInstanceOf = id.startsWith(Constants.START_OBJECT_PREFIX_ID);
	    		} 
	    		when 'Opportunity' {
	    			isInstanceOf = id.startsWith(Constants.OPP_OBJECT_PREFIX_ID);
	    		}
	    		when 'Lead' {
	    			isInstanceOf = id.startsWith(Constants.LEAD_OBJECT_PREFIX_ID);
	    		}
	    		when else {
	    		}
	    	}
    	}
    	return isInstanceOf;
    }
    
    // Email Organisation addresses
    public static String getOrgWideAddressesByBranding(String branding) {
    	String orgWideId = null;
    	String queryValue = (branding == Constants.LEAD_BRANDING_LEC_LILLE ? Constants.LEAD_BRANDING_LEC : branding);
    	List<OrgWideEmailAddress> owdList = [SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName = :queryValue];
    	if(!owdList.isEmpty()) {
    		orgWideId = owdList.get(0).Id;
    	}
    	return orgWideId;
    }
    
    // Récupération des destinataires additionnels techniques de l'email
    public static String[] getEmailAdditionnalAddresses() {
    	return Constants.SEND_EMAIL_FROM_LEAD_ADDITIONNAL_RECIPIENTS.split(Constants.CUSTOM_LABEL_INNER_SEPARATOR);
    }
}