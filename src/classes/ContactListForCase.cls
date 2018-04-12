public with sharing class ContactListForCase {
	private List<Contact> cs;
	private Cases__c ca {get; set;}
	
	public ContactListForCase(ApexPages.StandardController controller) {
		this.ca = (Cases__c)controller.getRecord();
	}
	
	public List<Contact> getCs() {
		ca = [select id, Account__c from Cases__c where id = :ca.id];
		if(ca.Account__c == null) return null;
		cs = [select Name, Department, Phone, MobilePhone, Email, Title from Contact where AccountId = :ca.Account__c];
		return cs;
	}
	
	public static testMethod void coverageTest () {
		Account account = new Account();
		account.Name = 'Test Account11';
		account.Company__c = 'SponsoredLinX';
		account.username__c = 'test11d11@test.com';
		account.password__c = 'test';
		insert account;
		
		Contact testContact = new Contact();
    	testContact.AccountId = account.Id;
    	testContact.Title = 'Billing';
    	testContact.FirstName = 'test';
    	testContact.LastName = 'test';
    	insert testContact;
    	
    	Cases__c ca = new Cases__c();
    	ca.account__c = account.id;
    	ca.Daily_Budget__c = 10;
    	ca.status__c = 'New';
    	ca.X2012_Action_Taken_to_Save__c = 'NA';
    	insert ca;
    	
    	ApexPages.standardController sc = new ApexPages.standardController(ca);
    	ContactListForCase con = new ContactListForCase(sc);
    	List<Contact> cs = con.getCs(); 
	} 
}