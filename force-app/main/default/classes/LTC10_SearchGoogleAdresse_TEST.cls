@isTest
public class LTC10_SearchGoogleAdresse_TEST {
   
    @isTest
    static void testGetSuggestions() {
		
		//Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
		Test.startTest();

		LTC10_SearchGoogleAdresse.getSuggestions('15 Rue Auber 75009 Paris France');


		Test.stopTest();
    }
    
    @isTest
   	static void testGetdetails() {
		
		//Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
		Test.startTest();

		LTC10_SearchGoogleAdresse.getPlaceDetails('ChIJa1DnNlATiIURu9WEWzcrmDU');

		Test.stopTest();
    }
}