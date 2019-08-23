/*
 * @author Jérémy LAMBERT (jeremy.lambert@tiime.fr)
 * @date 08/04/2019 (dd/mm/yyyy)
 * @description Aura controller for lead back quick action
 */
public with sharing class LTC17_LeadBackController {

	@AuraEnabled
	public static void backLeadFromStart(Id startId, String type) {
		List<Start__c> startList = [SELECT Id, Crea__c FROM Start__c WHERE Id = :startId LIMIT 1];

		if(startList.size() > 0) {
			backLead(startList.get(0).Crea__c, type);
		} else {
			throw new AuraHandledException('Aucune créa trouvée ayant l\'ID donné.');
		}
	}

	@AuraEnabled
	public static void backLeadFromTransfer(Id transferId, String type) {
		List<Transfert__c> transferList = [SELECT Id, Lead__c FROM Transfert__c WHERE Id = :transferId LIMIT 1];

		if(transferList.size() > 0) {
			backLead(transferList.get(0).Lead__c, type);
		} else {
			throw new AuraHandledException('Aucun transfert trouvé ayant l\'ID donné.');
		}
	}

	@AuraEnabled
	public static void backLead(Id leadId, String type) {
		List<Lead> leadList = [SELECT Id, OwnerId, Type_de_renvoi__c, Status FROM Lead WHERE Id = :leadId LIMIT 1];

		if(leadList.size() > 0) {
			Lead lead = leadList.get(0);

			switch on type {
				when 'ongoing' {
					lead.Type_de_renvoi__c = Constants.LEAD_TYPE_RENVOI_EN_COURS;
				}
				when 'castingError' {
					lead.Type_de_renvoi__c = Constants.LEAD_TYPE_RENVOI_ERREUR_CASTING;
				}
                when 'horsCible' {
					lead.Type_de_renvoi__c = Constants.LEAD_TYPE_RENVOI_HORS_CIBLE;
				}
			}

			lead.OwnerId = [SELECT Id FROM Group WHERE Type = :Constants.FILE_ATTENTE_OBJECT_TYPE AND DeveloperName = :Constants.FILE_ATTENTE_CALL1_DEV_NAME].Id;

			lead.Status = Constants.LEAD_STATUS_CALL1;

			update lead;
		} else {
			throw new AuraHandledException('Aucune lead trouvée.');
		}
	}
}