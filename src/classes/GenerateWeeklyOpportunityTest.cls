@isTest(SeeAllData=true)
private class GenerateWeeklyOpportunityTest {
	
	public static testMethod void GenerateOpportunityTest() {

		for (Integer i = 0; i < 15; i++) {
			Account a = new Account();
	        a.Name = 'TestAccount';
		    a.username__c           = 'testusername' + i.format();
		    a.password__c           = 'psw';
		    a.Payment_Option__c     ='Other';
		    a.Card_Year_Expiry__c   ='2014';
		    a.Card_Number__c        ='123456789';
		    a.Card_Month_Expiry__c  ='01';
		    a.Name_On_Card__c       ='Test';
			a.Send_Invoice__c       = true;
			a.Active_Days__c = 100;
			a.Active__c = true;
			a.HasSEOProject__c = false;
			insert a;
			
			Contact contact = new Contact();
	        contact.title = 'Marketing';
	        contact.Email = 'Marketing@13.com';
	        contact.LastName = 'Marketing';
	        contact.FirstName = 'Marketing';
	        contact.AccountId = a.id;        
	        insert contact;
	    }
		
		GenerateWeeklyOpportunity g = new GenerateWeeklyOpportunity();
	}
	
}