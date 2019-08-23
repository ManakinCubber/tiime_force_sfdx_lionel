public with sharing class LTC35_RequestBackToSupportTiime {
	@AuraEnabled
    public static void sendToSupportTiime(Id requestId) {
		List<Case> caseList = [SELECT Id, OwnerId FROM Case WHERE Id = :requestId];

		if(caseList.size() > 0) {
			Case requete = caseList.get(0);
			requete.OwnerId = [SELECT Id FROM Group WHERE Type = :Constants.FILE_ATTENTE_OBJECT_TYPE AND DeveloperName = :Constants.FILE_ATTENTE_SUPPORT_TIIME].Id;
			update requete;
		} else {
			throw new AuraHandledException('Aucune lead trouvée.');
		}
    }
}