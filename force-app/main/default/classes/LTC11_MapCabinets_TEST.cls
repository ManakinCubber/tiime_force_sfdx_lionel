@isTest
public class LTC11_MapCabinets_TEST {
    
    @isTest
    static void testGetCabinets() {
    	List<Account> cabinets = LTC11_MapCabinets.getCabinets();
    	System.assert(cabinets != null);
    }
}