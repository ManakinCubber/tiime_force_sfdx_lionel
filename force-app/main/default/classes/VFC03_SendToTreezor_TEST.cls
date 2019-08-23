/*
 * @author Kévin Melliand (kevin.melliand@tiime.fr)
 * @date 04/02/2019 (dd/mm/yyyy)
 * @description Check the class VFC03_SendToTreezor (code coverage : 100%).
 */
@isTest
public class VFC03_SendToTreezor_TEST {
    
    @isTest
    static void testTreezorCall() {
    	Account account = new Account(Name = 'testAccount');
    	insert account;
    	
    	VFC03_SendToTreezor.sendAccountToTreezor(account.Id);
    }
}