@isTest
global class PicklistController_Test {
    
    public static testmethod void testPicklist(){
        String field = 'LocaleSidKey';
        String objecttype = 'User';        
        
        Test.startTest();
        System.assertNotEquals(0, PicklistController.getPickListValuesIntoList(objecttype, field).size());
        Test.stopTest();
    }

}