@isTest(seealldata=false)
public class VFC_PopFicheContact_test {
    static testMethod void Test () {
        id rtID = [select id from Recordtype where sobjectType='Account' and developerName='Prospect'].id;
        Account acc = new Account(name='test',recordtypeId=rtID);
        insert acc;
        Contact ctt = new Contact(lastname='test',firstname='test',accountID=acc.id,mobilephone='0600000000',phone='0200000000');
        insert ctt;
         lead ld = new lead(lastname='test',firstname='test',company='test',mobilephone='0600000001',phone='0200000001');
        insert ld;
        test.startTest();
        VFC_PopFicheContact vfc = new VFC_PopFicheContact();
        vfc.loadFiche();
        ApexPages.currentPage().getParameters().put('phone','0600000000');
        vfc.loadFiche();
        ApexPages.currentPage().getParameters().put('phone','0600000001');
        vfc.loadFiche();
        ApexPages.currentPage().getParameters().put('phone','0200000000');
        vfc.loadFiche();
        ApexPages.currentPage().getParameters().put('phone','0200000001');
        vfc.loadFiche();
        ApexPages.currentPage().getParameters().put('phone','0000000000');
        vfc.loadFiche();
        test.stopTest();
    }
}