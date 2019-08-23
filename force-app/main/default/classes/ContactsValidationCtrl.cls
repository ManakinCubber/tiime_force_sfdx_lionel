public class ContactsValidationCtrl {
    /*
     * @author Wailly LUA
     * @date 03/10/2018 (dd/mm/yyyy)
     * @description : method launch from ContactsValidation component to fetch all the stakeholders link to the accountId sent from parameters
     * @params :      
     *      accountId : Id of the Account
     */
    @AuraEnabled
    public static Stakeholder__c[] getStakeHolders(Id accountId){
        System.debug('### ContactsValidationCtrl getStakeHolders accountId=='+accountId);
        return [SELECT Id, Company__r.ValidatedForAppWallet__c, Contact__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Birthdate, 
        Contact__r.Salutation, Contact__r.BirthPlace__c, Contact__r.Nationality__c, Contact__r.Email, 
        Contact__r.MobilePhone, Contact__r.NativeCountry__c, Contact__r.IncomPerTranche__c, Contact__r.Networth__c, JobTitleBank__c, ContactType__c, MainStakeholder__c
        //FROM Stakeholder__c];
        FROM Stakeholder__c WHERE (ActualBeneficiary__c = true OR Officer__c = true) AND Company__c = :accountId];
    }

    /*
     * @author Wailly LUA
     * @date 03/10/2018 (dd/mm/yyyy)
     * @description : method launch from ContactsValidation component to update the stakeholder AND the contact linked to the stakeholder (annuaire)
     * @params :      
     *      contact : Id of the Stakeholder to update
     */
    @AuraEnabled
    public static void updateContact(Stakeholder__c contact){
        System.debug('### ContactsValidationCtrl updateContact BEGIN');
        System.debug('### ContactsValidationCtrl updateContact contact=='+contact);
        try{            
        	Stakeholder__c stakeHolder = new Stakeholder__c(Id=contact.Id);
        	stakeHolder.JobTitleBank__c = contact.JobTitleBank__c;
        	stakeHolder.ContactType__c = contact.ContactType__c;

        	Contact annuaire = new Contact(Id = contact.Contact__c);
        	annuaire.FirstName = contact.Contact__r.FirstName; 
        	annuaire.LastName = contact.Contact__r.LastName;
            annuaire.Birthdate = contact.Contact__r.BirthDate;
        	annuaire.BirthPlace__c = contact.Contact__r.BirthPlace__c;
        	annuaire.Nationality__c = contact.Contact__r.Nationality__c;
        	annuaire.Email = contact.Contact__r.Email; 
        	annuaire.MobilePhone = contact.Contact__r.MobilePhone; 
        	annuaire.NativeCountry__c = contact.Contact__r.NativeCountry__c; 
        	annuaire.IncomPerTranche__c = contact.Contact__r.IncomPerTranche__c; 
        	annuaire.Networth__c = contact.Contact__r.Networth__c;
            
            update annuaire;
            update stakeHolder;
            
        }catch(DmlException dmlEx){
            System.debug('### ContactsValidationCtrl updateContact dmlEx.getDmlMessage(0)=='+dmlEx.getDmlMessage(0));
            throw new AuraHandledException(dmlEx.getDmlMessage(0));
        }catch(Exception ex){
        	System.debug('### ContactsValidationCtrl updateContact ex.getDmlMessage(0)=='+ex.getMessage());
    		throw new AuraHandledException(ex.getMessage());
        }
        System.debug('### ContactsValidationCtrl updateContact END');
    }

    /*
     * @author Wailly LUA
     * @date 03/10/2018 (dd/mm/yyyy)
     * @description : generic method to fetch picklist value from specific object
     * @return :
     *      allOptions : Map<Integer,List<String>>, contains values of picklist
     *                   allOptions[0] = picklist values of IncomPerTranche__c
     *                   allOptions[1] = picklist values of Networth__c
     *                   allOptions[2] = picklist values of ContactType__c
     */
    @AuraEnabled
    public static Map<Integer,List<String>> fetchPicklistValues(){
        List<String> incomOptions = getSelectOptions('Contact','IncomPerTranche__c');
        List<String> networthOptions = getSelectOptions('Contact','Networth__c');
        List<String> contactTypeOptions = getSelectOptions('Stakeholder__c','ContactType__c');
        
        System.debug('### incomOptions=='+incomOptions);
        System.debug('### networthOptions=='+networthOptions);
        System.debug('### contactTypeOptions=='+contactTypeOptions);
        Map<Integer,List<String>> allOptions = new Map<Integer, List<String>>();

        allOptions.put(0,incomOptions);
        allOptions.put(1,networthOptions);
        allOptions.put(2,contactTypeOptions);

        return allOptions;
    }

    /*
     * @author Wailly LUA
     * @date 26/09/2018 (dd/mm/yyyy)
     * @description : generic method to fetch picklist value from specific object
     * @params :      
     *      objectType : Type of Object to fetch
     *      fieldName : Picklist field which we want to fetch the values
     * @return :
     *      lst : List of String, contains values of specific picklist sent from parameter
     */
	 public static List<String> getSelectOptions(String objType, string fieldName) {
		List<String> allOpts = new list<String>();

        Schema.DescribeSObjectResult objDescribe = Schema.getGlobalDescribe().get(objType).getDescribe();
		Map<String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
		list<Schema.PicklistEntry> values = fieldMap.get(fieldName).getDescribe().getPickListValues();

		// Add these values to the selectoption list.
		for (Schema.PicklistEntry a: values) {
			allOpts.add(a.getValue());
		}
		System.debug('### ContactsValidationCtrl getSelectOptions allOpts ---->' + allOpts);
		return allOpts;
	 }

     /*
     * @author Jérémy LAMBERT
     * @date 04/12/2018 (dd/mm/yyyy)
     * @description : HTTP Call to Chronos to enable Wallet for the main stakeholder of the given record
     * @params :      
     *      recordId : Account record Id
     */
     @AuraEnabled
     public static void enableWallet(String recordId) {
     	System.debug('### ContatctsValisationCtrl - begin enableWallet');
        List<Account> accounts = [SELECT Id,ValidatedForAppWallet__c FROM Account WHERE Id = :recordId];
        if(accounts.size() <= 0)
            throw new AuraHandledException('L\'entreprise n\'existe pas.');
        AP10_ChronosEnableWallet.enableWallet(recordId);
        
        Account account = accounts.get(0);
        account.ValidatedForAppWallet__c = true;
        update account;
        System.debug('### ContatctsValisationCtrl - end enableWallet');
     }
     
     @AuraEnabled
     public static void changeStatusWallet(Id accountId) {
     	update new Account(Id = accountId, WalletStatus__c = Constants.ACCOUNT_WALLET_STATUS_CGU_PENDING);
     }

     @AuraEnabled
     public static Map<String, Map<String, String>> getCompanyPicklistValues() {
        Map<String, Map<String, String>> result = new Map<String, Map<String, String>>();
        result.put('turnovers', Utils.getPicklistOptions('Account', 'AnnualTurnover__c'));
        result.put('employees', Utils.getPicklistOptions('Account', 'NumberOfEmployees__c'));
        result.put('incomes', Utils.getPicklistOptions('Account', 'LastNetIncome__c'));
        result.put('legalForms', Utils.getPicklistOptionsWithNoneOption('Account', 'LegalStatus__c', true));
        result.put('contactSalutation', Utils.getPicklistOptionsWithNoneOption('Contact','Salutation', true));
        return result;
     }
}