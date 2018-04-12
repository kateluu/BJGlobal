public with sharing class OpportunityContacts {
	
	public List<Contact> contacts {get; set;}
	public SLXOpportunity__c opp {get;set;}
	
	public OpportunityContacts(ApexPages.StandardController controller){
		this.opp = (SLXOpportunity__c)controller.getRecord();
		try{
			this.opp = [select Id, Account__c from SLXOpportunity__c where Id =: this.opp.Id limit 1];
			this.contacts = [select Id, Name, Phone,Department, MobilePhone, Email, Title from Contact where Account.Id =: this.opp.Account__c];
		}catch(Exception e){
			System.debug(e.getMessage());
		}
	}
	
	
	public static testMethod void testoppContacts() {
		Account acc = new Account();
		acc.Employee_Department__c = 'Sales';
		acc.Type = 'Employee';
		acc.Active__c = true;
		acc.username__c = 'test123456';
		acc.password__c = '123';
		acc.Name        = 'test';
		insert acc;
		Contact con = new Contact(FirstName='test',LastName='test',Title='Billing',AccountId=acc.id);
		con.MailingStreet='sdfsadfsa\r\ndfsafa\r\nsfsdfsdfs\r\ndfsdfs\r\ndfsdf';
		con.MailingCity='Brisbane';
		con.MailingState='queensland';
		con.MailingPostalCode='4444';
		con.MailingCountry='Australia';
		con.AccountId = acc.Id;
		insert con;
		SLXOpportunity__c opp = new SLXOpportunity__c();
		ApexPages.standardController controller = new ApexPages.standardController(opp);
		OpportunityContacts a = new OpportunityContacts(controller);
	}
}