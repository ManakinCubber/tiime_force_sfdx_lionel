public class AP21_CaseUserAssign {

	public static void beforeInsert(List<Case> newList) {
		Set<Id> accIds = new Set<Id>();
		for(Case c : newList) {
			accIds.add(c.AccountId);
		}

		Map<Id, Account> acc = new Map<Id, Account>([select Id, Accounting__c from Account where id in :accIds]);

		for(Case c : newList) {
			Account a = acc.get(c.AccountId);
			if(a != null && a.Accounting__c != null) {
				c.OwnerId = a.Accounting__c;
			}
		}
	}
}