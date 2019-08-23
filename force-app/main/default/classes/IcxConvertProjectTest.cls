@isTest
class IcxConvertProjectTest {
    
    Public Static Lead lead;
    Public Static Account acc;
    Public Static Contact ctc;
    Public Static Opportunity opp;
    Public Static Start__c project;
    Public Static Start__c project2;
    Public Static Associate__c associate;
    Public Static Associate__c associate2;
    
    Static {
        lead = new Lead( Company = 'test acme', email='test@acme.com', MobilePhone = '0607080910', firstName = 'leadName', LastName='leadLastName', Branding__c = 'Novaa');
        Insert lead;
        
        project = new Start__c( Crea__c = lead.Id);
        Insert project;
        
        associate = new Associate__c( firstName__c = 'leadName',  Start__c = project.Id, lead__c = lead.Id, KindShareCapital__c = 500, CashShareCapital__c= 100, City__c = 'Paris');
        Insert associate;
        
        acc = new Account(Name='test cie');
        insert acc;
        
        ctc = new contact(accountId = acc.Id, lastName='Lname', firstName='fname', email='email@gee.com');
        insert ctc;
        
        opp = new Opportunity(Name='test opp', accountId=acc.id, amount=100, closeDate= date.today()+1, stageName=Opportunity.stagename.getDescribe().getPicklistValues()[0].getValue(), LeadFullName__c = lead.FirstName + ' ' + lead.LastName);
        insert opp;
        
        project2 = new Start__c( Opportunity__c  = opp.Id, Crea__c = lead.Id);
        Insert project2;
        
        associate2 = new Associate__c( name= 'Lname', firstName__c = 'fname',  Start__c = project2.Id, Opportunity__c = opp.Id, KindShareCapital__c = 500, CashShareCapital__c= 100, City__c = 'Paris');
        Insert associate2;
    }
    
    static testmethod void convertProject() {
        test.StartTest();
        IcxConvertProject.RequestConversion[] reqs = new IcxConvertProject.RequestConversion[]{};
        IcxConvertProject.RequestConversion reqLead = new IcxConvertProject.RequestConversion();
        reqLead.itemId = lead.Id;        
        reqs.add( reqLead );
            
		IcxConvertProject.convertProject( reqs );        
        test.StopTest();
    }

    static testmethod void convertProject2() {
        test.StartTest();
        IcxConvertProject.RequestConversion[] reqs = new IcxConvertProject.RequestConversion[]{};
        IcxConvertProject.RequestConversion req = new IcxConvertProject.RequestConversion();
        req.itemId = opp.Id;
        reqs.add( req );
            
		IcxConvertProject.convertProject( reqs );      
        test.StopTest();
    }
    
    
}