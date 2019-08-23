/*
 * Wrapper for the Account class in order to compare them by distance.
 * See https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_list_sorting_sobject.htm
 */
global with sharing class AP11_AccountWrapper implements Comparable {
	
	@AuraEnabled 
	public Account account;
	
	@AuraEnabled
	public Double distance;
	
	private Location location;

	//Workaround for Apex static context restriction (seriously, why such language design?)
	public static Location getLocation(Account account) {
		return Location.newInstance(account.BillingLatitude, account.BillingLongitude);
	}

	public static Double calculateDistance(Location loc1, Location loc2) {
		Decimal dec = Location.getDistance(loc1, loc2, 'km');
		if(dec == null) return null;
		return dec.setScale(2, RoundingMode.HALF_UP).doubleValue();
	}

	public AP11_AccountWrapper(Account account, Location location) {
		this.account  = account;
		this.location = location;

		this.distance = AP11_AccountWrapper.calculateDistance(location, AP11_AccountWrapper.getLocation(account));
		System.debug('### Distance: ' + distance);
	}

	global Integer compareTo(Object compareTo) {
        AP11_AccountWrapper compareToAccount = (AP11_AccountWrapper)compareTo;
        
        if(this.account.OnlinePartner__c && this.account.BillingLatitude == null) //Online partners appear last
        	return 1;
		else if(this.distance > compareToAccount.distance)
			return 1;
		else if(this.distance < compareToAccount.distance)
			return -1;
		else
			return 0;
    }
}