public with sharing class CreditListForCase {
	private List<Credit__c> cs;
	private Cases__c ca {get; set;}
	
	public CreditListForCase(ApexPages.StandardController controller) {
		this.ca = (Cases__c)controller.getRecord();
	}
	
	public List<Credit__c> getCs() {
		ca = [select id, Account__c from Cases__c where id = :ca.id];
		if(ca.Account__c == null) return null;
		cs = [select 
				Id, 
				Name, 
				Account_Product__c, 
				Account_Product__r.name, 
				Amount__c, 
				Credit_Left__c, 
				Credit_Used__c, 
				Valid_From__c 
			from 
				Credit__c 
			where 
				Account__c = :ca.Account__c
			order by Valid_From__c DESC];
		return cs;
	}

	public static testMethod void coverageTest () {
		Account account = new Account();
		account.Name = 'Test Account11';
		account.Company__c = 'SponsoredLinX';
		account.username__c = 'test11d11@test.com';
		account.password__c = 'test';
		insert account;
		    	
    	Credit__c cr = new Credit__c();
    	cr.Account__c = account.Id;
    	cr.amount__c = 100;
    	insert cr;
    	    	
    	Cases__c ca = new Cases__c();
    	ca.account__c = account.id;
    	ca.Daily_Budget__c = 10;
    	ca.status__c = 'New';
    	ca.X2012_Action_Taken_to_Save__c = 'NA';
    	insert ca;
    	
    	ApexPages.standardController sc = new ApexPages.standardController(ca);
    	CreditListForCase con = new CreditListForCase(sc);
    	List<Credit__c> cs = con.getCs(); 
	} 
}