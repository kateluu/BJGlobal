public with sharing class ContactForProjectController {
	private List<Contact> cs;
	private SFDC_Projects__c project {get; set;}
	
	public ContactForProjectController(ApexPages.StandardController controller) {
		this.project = (SFDC_Projects__c)controller.getRecord();
	}
	
	public List<Contact> getCs() {
		SFDC_Projects__c project = [select id, Account__c from SFDC_Projects__c where id = :project.id];
		if(project.Account__c == null) return null;
		cs = [select Name, Department, Phone, MobilePhone, Email, Title from Contact where AccountId = :project.Account__c];
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
    	
    	SFDC_Projects__c p = new SFDC_Projects__c();
    	p.account__c = account.id;
    	p.name = 'name';
    	p.Sold_by__c = 'ss';
    	p.Phone_Number__c = '123456789';
    	p.Email__c = 'fdas@jlkdfs.com';
    	insert p;
    	
    	ApexPages.standardController sc = new ApexPages.standardController(p);
    	ContactForProjectController con = new ContactForProjectController(sc);
    	List<Contact> cs = con.getCs(); 
    	
    	
    	
	} 
}