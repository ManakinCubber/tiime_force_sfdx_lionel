/*
* @author Wailly LUA  (Wailly.lua@carrenet.com)
* @date 03/10/2018 (dd/mm/yyyy)
* @description Test class for ContactsValidationCtrl_TEST
*/
@isTest
public class ContactsValidationCtrl_TEST{
    static Account entreprise;
    static Contact contactToUpdate;
    static Stakeholder__c stakeHolder;
    /*
     * @author LUA Wailly (Wailly.lua@carrenet.com)
     * @date 03/10/2018 (dd/mm/yyyy)
     * @description Initialise test environment with datas
     */
    static void initOrg(){ 
        
        Id rtClientId = Utils.getAccountRecordTypeByDeveloperName(Constants.ACCOUNT_RECORDTYPE_DEVELOPERNAME_CLIENT);

        entreprise = new Account(Name = 'Entreprise Contact Validation', RecordTypeId = rtClientId);
        insert entreprise;

        contactToUpdate = new Contact(FirstName = 'Contact FirstName', MobilePhone = '0600000000', LastName = 'Contact Validation', 
                                        AccountId = entreprise.Id);
        insert contactToUpdate;

        stakeHolder = [SELECT Id, JobTitleBank__c, ContactType__c, 
                        Contact__c, Contact__r.LastName, Contact__r.MobilePhone, Contact__r.FirstName, 
                        Contact__r.BirthDate, Contact__r.BirthPlace__c, Contact__r.Nationality__c, Contact__r.Email, 
                        Contact__r.NativeCountry__c, Contact__r.IncomPerTranche__c, Contact__r.Networth__c
                        FROM Stakeholder__c WHERE Company__c = :entreprise.Id AND Contact__c = :contactToUpdate.Id];
        stakeHolder.ActualBeneficiary__c = true;
        update stakeHolder;
    }

    /*
     * @author LUA Wailly (Wailly.lua@carrenet.com)
     * @date 03/10/2018 (dd/mm/yyyy)
     */
    @isTest
    static void getStakeHoldersTest(){    
        initOrg();
        Test.startTest();
            Stakeholder__c[] result = ContactsValidationCtrl.getStakeHolders(entreprise.Id);
            System.assertEquals(1, result.size());
        Test.stopTest();
    }

    /*
     * @author LUA Wailly (Wailly.lua@carrenet.com)
     * @date 03/10/2018 (dd/mm/yyyy)
     */
    @isTest
    static void updateContactTest(){    
        initOrg();
        Test.startTest();
            stakeHolder.JobTitleBank__c = 'Fonctionnaire';
            ContactsValidationCtrl.updateContact(stakeHolder);

            Stakeholder__c stakeHolderToCheck = [SELECT Id,JobTitleBank__c FROM Stakeholder__c WHERE Id = :stakeHolder.Id];
            System.assertEquals('Fonctionnaire', stakeHolderToCheck.JobTitleBank__c);
            
        Test.stopTest();
    }

    /*
     * @author LUA Wailly (Wailly.lua@carrenet.com)
     * @date 03/10/2018 (dd/mm/yyyy)
     */
    /*@isTest
    static void updateAccountTest(){    
        Test.startTest();   
            initOrg();
            ContactsValidationCtrl.updateAccount(entreprise.Id);
            Account entrepriseToCheck = [SELECT Id, ValidatedForAppWallet__c FROM Account WHERE Id = :entreprise.Id];
            System.assertEquals(true, entrepriseToCheck.ValidatedForAppWallet__c);
        Test.stopTest();
    }*/

    /*
     * @author LUA Wailly (Wailly.lua@carrenet.com)
     * @date 03/10/2018 (dd/mm/yyyy)
     */
    @isTest
    static void fetchPicklistValuesTest(){    
        Test.startTest();  
            Map<Integer,List<String>> result = ContactsValidationCtrl.fetchPicklistValues();
            List<String> incomOptions = result.get(0);
            List<String> networthOptions = result.get(1);
            List<String> contactTypeOptions = result.get(2);

            System.assertNotEquals(0, incomOptions.size());
            System.assertNotEquals(0, networthOptions.size());
            System.assertNotEquals(0, contactTypeOptions.size());

        Test.stopTest();
    }

    /*
     * @author LAMBERT Jérémy (jeremy.lambert@tiime.fr)
     * @date 02/01/2019 (dd/mm/yyyy)
     */
    @isTest static void testGetCompanyPicklistValues() {
        Test.startTest();
        Map<String, Map<String, String>> result = ContactsValidationCtrl.getCompanyPicklistValues();

        System.assertEquals(5, result.size());
        System.assertEquals(true, result.containsKey('turnovers'));
        System.assertEquals(true, result.containsKey('employees'));
        System.assertEquals(true, result.containsKey('incomes'));
        System.assertEquals(true, result.containsKey('legalForms'));
        System.assertEquals(true, result.containsKey('contactSalutation'));

        System.assertNotEquals(0, result.get('turnovers').size());
        System.assertNotEquals(0, result.get('employees').size());
        System.assertNotEquals(0, result.get('incomes').size());
        System.assertNotEquals(0, result.get('legalForms').size());
        System.assertNotEquals(0, result.get('contactSalutation').size());
        Test.stopTest();
    }
}