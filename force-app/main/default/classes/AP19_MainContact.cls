public with sharing class AP19_MainContact {
    
    /**
    * @author 	:	kévin Melliand 
    * @date		:	13/05/2019
    * @description :If no main contact exists on the account, then the new contact is set as main contact
    */
    public static void checkBeforeInsertOrUpdate(List<Contact> contacts, Map<Id, Contact> oldContacts) {
    	Set<String> accountIdSet = new Set<String>();
    	Set<String> contactIdSet = new Set<String>();
    	for(Contact c : contacts) {
    		if((!c.MainContact__c) || (!c.IsActif__c)) {
    			accountIdSet.add(c.AccountId);
    			contactIdSet.add(c.Id);
    		}
    	}
    	
    	if(accountIdSet.size() > 0) {
    		Set<String> accountWithMainContact = new Set<String>();
    		for(Contact c : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountIdSet AND Id NOT IN :contactIdSet AND MainContact__c = true AND IsActif__c = true]) {
    			accountWithMainContact.add(c.AccountId);
    		}
    		
    		for(Contact c : contacts) {
    			if((!accountWithMainContact.contains(c.AccountId)) && contactIdSet.contains(c.Id) ) {
    				if((oldContacts == null || oldContacts.get(c.Id) == null)) {
    					c.MainContact__c = true;
    					accountWithMainContact.add(c.AccountId);
    				} else if(oldContacts.get(c.Id).MainContact__c) {
    					c.addError('Vous devez renseigner le nouveau contact principal du compte');
    				}
    			}
    		}
    	}
    }
    
    
    /**
    * @author 	:	kévin Melliand 
    * @date		:	13/05/2019
    * @description :If a new contact is created as the main contact, the previous main contact, if existing, must be unchecked
    */
    public static void checkAfterUpdateOrInsert(List<Contact> contacts, Map<Id, Contact> oldContacts) {
    	Set<String> accountIdSet = new Set<String>(); 
    	Set<String> contactIdSet = new Set<String>();
    	List<Account> accounts = new List<Account>();
    	for(Contact c : contacts) {
    		if(c.MainContact__c && 
    		(
    			(oldContacts == null || oldContacts.get(c.Id) == null) || 
    			(
    				(!oldContacts.get(c.Id).MainContact__c) || 
    				(c.IsActif__c && (!oldContacts.get(c.Id).IsActif__c))
    			)
    		)) {
    			accountIdSet.add(c.AccountId);
    			contactIdSet.add(c.Id);
    			accounts.add(new Account(Id = c.AccountId, MainContact__c = c.Id));
    		}
    	}
    	if(accountIdSet.size() > 0) {
    		List<Contact> mainContactsToUncheck = [SELECT Id, MainContact__c FROM Contact WHERE AccountId IN :accountIdSet AND Id NOT IN :contactIdSet AND MainContact__c = true AND IsActif__c = true];
    		for(Contact c : mainContactsToUncheck) {
    			c.MainContact__c = false;
    		}
    		update mainContactsToUncheck;
    	}
    	
    	if(!accounts.isEmpty()) {
    		update accounts;
    	}
    }
    
    /**
    * @author 	:	kévin Melliand 
    * @date		:	13/05/2019
    * @description :If a contact is deleted, we ensure there is still a main contact on the account
    */
    public static void checkBeforeDelete(List<Contact> contacts) {
    	Set<String> accountIdSet = new Set<String>();
    	Set<String> contactIdSet = new Set<String>();
    	for(Contact c : contacts) {
    		accountIdSet.add(c.AccountId);
    		contactIdSet.add(c.Id);
    	}
    	Set<String> accountWithMainContact = new Set<String>();
    	for(Contact c : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountIdSet AND Id NOT IN :contactIdSet AND MainContact__c = true AND IsActif__c = true]) {
    		accountWithMainContact.add(c.AccountId);
    	}
    	Map<String, Integer> accountIdToContactNumberMap = new Map<String, Integer>();
    	for(Account a : [SELECT Id, (SELECT Id FROM Contacts) FROM Account WHERE Id IN :accountIdSet]) {
    		accountIdToContactNumberMap.put(a.Id, a.Contacts.size());
    	}
    	
    	for(Contact c : contacts) {
    		if((!accountWithMainContact.contains(c.AccountId)) && accountIdToContactNumberMap.get(c.AccountId) > 1) {
    			c.addError('Vous devez renseigner le nouveau contact principal du compte avant de supprimer ce contact');
    		}
    	}
    }
    
    
    public class MainContactException extends Exception {}
}