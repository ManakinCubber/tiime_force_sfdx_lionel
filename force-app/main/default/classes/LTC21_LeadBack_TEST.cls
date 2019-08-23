@isTest
private class LTC21_LeadBack_TEST {
	
	@isTest
    static void horodatageLeadBackT_TEST(){		
    	Lead l = AP04_Factory.newWebLeadsFactory(1)[0];
    	insert l;
		Transfert__c t = new Transfert__c(Name = 'transfertName', Lead__c = l.Id);
		insert t;
		System.assert(t.LeadBackCastingError__c == false && t.DateLeadBackCastingError__c == null);
		System.assert(l.LeadBackCastingError__c == false && l.DateLeadBackCastingError__c == null);
		
		Test.startTest();
		LTC21_LeadBack.horodatageLeadBackT(t.Id,l.Id);
		Test.stopTest();
		
		t = [SELECT Id, LeadBackCastingError__c, DateLeadBackCastingError__c FROM Transfert__c WHERE Id = :t.Id];
		l = [SELECT Id, LeadBackCastingError__c, DateLeadBackCastingError__c FROM Lead WHERE Id = :l.Id];
		
		System.assert(t.LeadBackCastingError__c == true && t.DateLeadBackCastingError__c != null);
		System.assert(l.LeadBackCastingError__c == true && l.DateLeadBackCastingError__c != null);
	}
	
	@isTest
	static void horodatageLeadBackPC_TEST(){
    	Lead l = AP04_Factory.newWebLeadsFactory(1)[0];
        insert l;
		Start__c s = new Start__c(Name = 'startName', Crea__c = l.Id);
        insert s;
        l = [SELECT Id, CreationProject__c FROM Lead WHERE Id = :l.Id];
		l.CreationProject__c = s.Id;
		update l;
		
		System.assert(s.LeadBackTiimeCrea__c == false && s.DateLeadBackTiimeCrea__c == null);
		System.assert(l.LeadBackTiimeCrea__c == false && l.DateLeadBackTiimeCrea__c == null);
		
		Test.startTest();
		LTC21_LeadBack.horodatageLeadBackPC(s.Id,l.Id);
		Test.stopTest();
		
		s = [SELECT Id, LeadBackTiimeCrea__c, DateLeadBackTiimeCrea__c FROM Start__c WHERE Id = :s.Id];
		l = [SELECT Id, LeadBackTiimeCrea__c, DateLeadBackTiimeCrea__c FROM Lead WHERE Id = :l.Id];
		
		System.assert(s.LeadBackTiimeCrea__c == true && s.DateLeadBackTiimeCrea__c != null);
		System.assert(l.LeadBackTiimeCrea__c == true && l.DateLeadBackTiimeCrea__c != null);
	}
	
	@isTest
	static void horodatageLeadBackCastingPC_TEST(){
    	Lead l = AP04_Factory.newWebLeadsFactory(1)[0];
        insert l;
		Start__c s = new Start__c(Name = 'startName', Crea__c = l.Id);
        insert s;
        l = [SELECT Id, CreationProject__c FROM Lead WHERE Id = :l.Id];
		l.CreationProject__c = s.Id;
		update l;
		
		System.assert(s.LeadBackCastingError__c == false && s.DateLeadBackCastingError__c == null);
		System.assert(l.LeadBackCastingError__c == false && l.DateLeadBackCastingError__c == null);
		
		Test.startTest();
		LTC21_LeadBack.horodatageLeadBackCastingPC(s.Id,l.Id);
		Test.stopTest();
		
		s = [SELECT Id, LeadBackCastingError__c, DateLeadBackCastingError__c FROM Start__c WHERE Id = :s.Id];
		l = [SELECT Id, LeadBackCastingError__c, DateLeadBackCastingError__c FROM Lead WHERE Id = :l.Id];
		
		System.assert(s.LeadBackCastingError__c == true && s.DateLeadBackCastingError__c != null);
		System.assert(l.LeadBackCastingError__c == true && l.DateLeadBackCastingError__c != null);
	}
}