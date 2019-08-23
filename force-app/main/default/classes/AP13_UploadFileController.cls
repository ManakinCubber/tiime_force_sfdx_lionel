public with sharing class AP13_UploadFileController {

	private static final List<String> START_FIELDS = new List<String> {
		'ID_Registered_Office_Owner__c', 'ID_Registered_Office_Lessee__c',
		'ID_Registered_Office_Hosted__c', 'ID_Lease__c'
	};

	private static final List<String> PARTNER_FIELDS = new List<String> {
		'ID_Id_Card__c', 'ID_Vital_Card__c', 'ID_Kbis__c', 'ID_Status__c'
	};

	@AuraEnabled
	public static void updateDocumentId(Id parentId, String field, Id documentId) {
		Start__c start = getStart(parentId);
		Associate__c partner = getPartner(parentId);
		if(start == null && partner == null)  {
			throw Utils.generateAuraHandledException('Invalid Id provided.');
		}
		if(start != null) {
			if(!START_FIELDS.contains(field)) {
				throw Utils.generateAuraHandledException('Invalid field provided.');
			}

			start.put(field, String.valueOf(documentId));
			update start;
		} else if(partner != null) {
			if(!PARTNER_FIELDS.contains(field))
				throw Utils.generateAuraHandledException('Invalid field provided.');
			partner.put(field, String.valueOf(documentId));
			update partner;
		}
	}

	@AuraEnabled
	public static List<ContentDocumentLink> getFiles(Id record) {
		try {
			Start__c start = getStart(record);
			Associate__c partner = getPartner(record);
			if(start == null && partner == null) return null;

			List<ContentDocumentLink> content = null;
			List<Id> docs                     = new List<Id>();

			if(start != null) {

				for(String field : START_FIELDS)
					docs.add(String.valueOf(start.get(field)));

				content = [SELECT ContentDocument.Title,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :record AND ContentDocumentId IN :docs];
				for(ContentDocumentLink cdl : content) {
					for(String field : START_FIELDS) {
						if(cdl.ContentDocumentId == start.get(field)) {
							cdl.ContentDocument.Title = field;
							break;
						}						
					}
				}
			} else if(partner != null) {

				for(String field : PARTNER_FIELDS)
					docs.add(String.valueOf(partner.get(field)));

				content = [SELECT ContentDocument.Title,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :record AND ContentDocumentId IN :docs];
				for(ContentDocumentLink cdl : content) {
					for(String field : PARTNER_FIELDS) {
						if(cdl.ContentDocumentId == partner.get(field)) {
							cdl.ContentDocument.Title = field;
							break;
						}
					}
				}

			}
			return content;
		} catch(DmlException e) {
			System.debug(e.getStackTraceString());
		}
		return null;
	}

	private static Start__c getStart(Id record) {
		List<Start__c> results = [SELECT Name,ID_Registered_Office_Owner__c,ID_Registered_Office_Lessee__c,ID_Registered_Office_Hosted__c,ID_Lease__c FROM Start__c WHERE Id = :record LIMIT 1];
		return results.size() > 0 ? results[0] : null;
	}

	private static Associate__c getPartner(Id record) {
		List<Associate__c> results = [SELECT FirstName__c,Name,ID_Id_Card__c,ID_Vital_Card__c,ID_Kbis__c,ID_Status__c FROM Associate__c WHERE Id = :record LIMIT 1];
		return results.size() > 0 ? results[0] : null;
	}
}