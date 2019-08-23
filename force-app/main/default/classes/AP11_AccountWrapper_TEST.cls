@isTest
public with sharing class AP11_AccountWrapper_TEST {
	
	@isTest static void testSort() {

		List<AP11_AccountWrapper> accList = new List<AP11_AccountWrapper>();
		Location leadLocation = Location.newInstance(0, 0);

		accList.add(new AP11_AccountWrapper(new Account(Name = 'Account 2', BillingLatitude = 2, BillingLongitude = 2), leadLocation));
		accList.add(new AP11_AccountWrapper(new Account(Name = 'Account 4', BillingLatitude = 4, BillingLongitude = 4), leadLocation));
		accList.add(new AP11_AccountWrapper(new Account(Name = 'Account 6', OnlinePartner__c = true), leadLocation));
		accList.add(new AP11_AccountWrapper(new Account(Name = 'Account 1', BillingLatitude = 1, BillingLongitude = 1), leadLocation));
		accList.add(new AP11_AccountWrapper(new Account(Name = 'Account 3', BillingLatitude = 3, BillingLongitude = 3), leadLocation));
		accList.add(new AP11_AccountWrapper(new Account(Name = 'Account 5', BillingLatitude = 4, BillingLongitude = 4), leadLocation));

		System.debug('### List before: ' + accList);
		accList.sort();
		System.debug('### List after: ' + accList);

		for(Integer i = 1 ; i <= 6 ; i++) {
			System.assertEquals('Account ' + i, accList[i-1].account.Name);
		}


	}

}