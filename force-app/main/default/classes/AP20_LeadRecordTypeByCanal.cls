public with sharing class AP20_LeadRecordTypeByCanal {
	
	public static void switchRecordTypeCanalPartenariat(List<Lead> leads, Map<Id,Lead> oldLeads) { 
		Id rtPartenariatID = Utils.getLeadRecordTypeByDeveloperName(Constants.LEAD_RECORDTYPE_DEVELOPERNAME_PARTENARIAT);
		Id rtLeadClientID = Utils.getLeadRecordTypeByDeveloperName(Constants.LEAD_RECORDTYPE_DEVELOPERNAME_LEAD_CLIENT);
		for(Lead lead : leads) {
			if( oldLeads == null || lead.Canal__c != oldLeads.get(lead.Id).Canal__c ){
				if(lead.Canal__c == Constants.LEAD_CANAL_PARTENARIATS && lead.RecordTypeID != rtPartenariatID){
					lead.RecordTypeID = rtPartenariatID;
				} else if(lead.Canal__c != Constants.LEAD_CANAL_PARTENARIATS && lead.RecordTypeID == rtPartenariatID){
					lead.RecordTypeID = rtLeadClientID;
				}
			}
	    }
	}
}