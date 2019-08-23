/*******************************************************
Nom ......... : VFC01_LeadOwner_TEST.apxc
Description	  : Classe de TEST pour le controller 'VFC01_LeadOwner' 
				qui sert à s'attribuer un LEAD en appuyant sur le bouton assigner.
            
Auteur ...... : JEAN-BAPTISTE Félix & LAMBERT Jérémy
********************************************************/
@isTest(SeeAllData = false)
public class VFC01_LeadOwner_TEST {
    
    @isTest static void TestControllerLeadOwner(){
        
		Test.startTest();

        User FuturOwner = AP04_Factory.UserStandardFactory(1,'Smith','Jhon','JohnSmith@tiime.fr')[0];
        insert FuturOwner;

        System.runAs(FuturOwner){
            Lead lead = AP04_Factory.LeadFactory(1,'0658585858','JOJO','toto corp')[0];
            insert lead;

            VFC01_LeadOwner controller = new VFC01_LeadOwner(new ApexPages.StandardController(lead));
            PageReference pageRef =  Page.VF02_LeadOwner;
            Test.setCurrentPage(pageRef);

            System.debug('premier : '+[SELECT id,ownerId from Lead where id=:lead.id].size());

            PageReference pageEnd = controller.assignAndRedirect();//---controller---
            PageReference pageEndVoulu = new ApexPages.StandardController(lead).view();

            Lead newLead = [SELECT id,ownerId from Lead where id=:lead.id limit 1];
            System.debug(UserInfo.getUserId()+' '+newLead.OwnerId);
            System.assertEquals(FuturOwner.id,newLead.OwnerId);     
            System.assertEquals(pageEndVoulu.getUrl(),pageEnd.getUrl());  
        }

        Test.stopTest(); 

     }


    @isTest static void TestControllerSetLeadOwner(){
        Test.startTest();

        User FuturOwner = AP04_Factory.UserStandardFactory(1,'Smith','Marine','MarineSmith@test.fr')[0];

        System.runAs(FuturOwner){
            List<LEAD> leads = AP04_Factory.LeadFactory(5,'0658585858','JOJO','toto corp');
            insert leads;

            ApexPages.StandardSetController scon = new ApexPages.StandardSetController(leads);
            scon.setSelected(leads);
            VFC01_LeadOwner controller = new VFC01_LeadOwner(scon);
            
            PageReference pageRef =  Page.VF02_LeadOwner;
            Test.setCurrentPage(pageRef);

            PageReference pageEnd = controller.assignAndRedirect();//---controller---
 
            List<Lead> newLead = [SELECT id,OwnerId,LastName from Lead where id in :leads];

            for(Lead l: newLead){
                System.assertEquals(FuturOwner.id, l.OwnerId);
            }

            PageReference pageEndVoulu = new PageReference('/lightning/o/Lead/list');
            System.assertEquals(pageEndVoulu.getUrl(),pageEnd.getUrl());
        }

        Test.stopTest();
    }	
    
        @isTest static void TestNoSelected(){
        Test.startTest();

        User FuturOwner = AP04_Factory.UserAdminFactory(1,'Smith','Marine','MarineSmith@test.fr')[0];

        System.runAs(FuturOwner){

            List<LEAD> leads = AP04_Factory.LeadFactory(0,'0658585858','JOJO','toto corp');
            System.debug('nb leads créé : '+leads.size());
            insert leads;

            ApexPages.StandardSetController scon = new ApexPages.StandardSetController(leads);
            scon.setSelected(leads);
            VFC01_LeadOwner controller = new VFC01_LeadOwner(scon);
            
            PageReference pageRef =  Page.VF02_LeadOwner;
            Test.setCurrentPage(pageRef);

        
            PageReference pageEnd = controller.assignAndRedirect();
	
            Test.stopTest();

            System.debug('le message : '+ApexPages.getMessages().get(0).getSummary());
            //System.debug(ApexPages.getMessages().getSeverity());

            PageReference pageEndVoulu = new PageReference('/lightning/o/Lead/list');
            //System.assertEquals(pageEndVoulu.getUrl(),pageEnd.getUrl());
            System.assertEquals('Aucun enregistrement sélectionné.',ApexPages.getMessages().get(0).getSummary());
        }
     }
}