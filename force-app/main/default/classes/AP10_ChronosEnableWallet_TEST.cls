@isTest
public with sharing class AP10_ChronosEnableWallet_TEST {

	@testSetup static void setup() {
		AP04_Factory.generateStakeholderTestCases();
	}

	@isTest static void testEnableWallet() {
		List<Account> accounts = [SELECT Id FROM Account LIMIT 6];
		Account account = null;
		boolean hasError = false;

		for(Integer i = 0 ; i < accounts.size() ; i++) {
			account = accounts.get(i);
			hasError = false;
			switch on i {
			when 0, 1, 2, 3 {
				try {
					AP10_ChronosEnableWallet.enableWallet(String.valueOf(account.Id));
				} catch(Exception e) {
					System.assertEquals('System.AuraHandledException', e.getTypeName());
					System.assertEquals('Aucun stakeholder trouvé.', e.getMessage());
					hasError = true;
				}
				System.assertEquals(true, hasError, 'No exception thrown when no stakeholder found');
			}
			when 4 {
				try {
					AP10_ChronosEnableWallet.enableWallet(String.valueOf(account.Id));
				} catch(Exception e) {
					System.assertEquals('System.AuraHandledException', e.getTypeName());
					System.assertEquals('Plusieurs stakeholder principaux.', e.getMessage());
					hasError = true;
				}
				System.assertEquals(true, hasError, 'No exception thrown when multiple stakeholder found');
			}
			when 5 {
				try {
					AP10_ChronosEnableWallet.enableWallet(String.valueOf(account.Id));
				} catch(Exception e) {
					System.debug(e.getMessage());
					System.debug(e.getStackTraceString());
					hasError = true;
				}
				System.assertEquals(false, hasError, 'Exception thrown');

				// Check chronos ID updated
				Account company = [SELECT Id, ChronosId__c FROM Account WHERE Id = :account.Id];
				Stakeholder__c sh = AP10_ChronosEnableWallet.getMainStakeholder(account.Id);

				System.assertEquals('2', company.ChronosId__c);
				System.assertEquals('1', sh.Contact__r.ChronosId__c);
			}
			}
		}

	}

	@isTest static void testPhoneFormat() {
		System.assertEquals('+33601020304', AP10_ChronosEnableWallet.formatPhoneNumber('0601020304'));
		System.assertEquals('+33601020304', AP10_ChronosEnableWallet.formatPhoneNumber('+33601020304'));

		boolean hasError = false;

		try {
			AP10_ChronosEnableWallet.formatPhoneNumber('1601020304');
		} catch(AP10_ChronosEnableWallet.InvalidPhoneException e) {
			hasError = true;
		}

		System.assertEquals(true, hasError);

		hasError = false;
		try {
			AP10_ChronosEnableWallet.formatPhoneNumber(null);
		} catch(Exception e) {
			hasError = true;
		}

		System.assertEquals(false, hasError);
	}

}