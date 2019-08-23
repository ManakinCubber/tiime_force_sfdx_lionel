/*
 * @author Kévin Melliand (kevin.melliand@tiime.fr)
 * @date 31/01/2019 (dd/mm/yyyy)
 * @description Controler for the lightning Component LT02_SendToTreezor. Calling Chronos for request account KYC with Treezor.
 * 				Covered by the class VFC03_SendToTreezor_TEST (code coverage : 100%).
 */
public class VFC03_SendToTreezor {
    
    @AuraEnabled
    public static void sendAccountToTreezor(String chronosAccountId) {	
    	WS02_Chronos.sendAccountToTreezorViaChronos(chronosAccountId);
    }
    
    @AuraEnabled
    public static void changeAccountStatusAfterSuccessfullCallToTreezor(String accountId) {
    	update new Account(Id = accountId, WalletStatus__c = Constants.ACCOUNT_WALLET_STATUS_KYC_PENDING);
    }
}