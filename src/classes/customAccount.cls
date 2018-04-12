public with sharing class customAccount {
	public ID accountid {get;set;}
	public String accname {get;set;}
	public String subscription {get;set;}
	public String subscriptiontype {get;set;}
	public String billingstatus {get;set;}
	public String reportemail {get;set;}
	public String contactperson {get;set;}
	public String contactphone {get;set;} 
	
	public static testMethod void testcustomAccount() {
		Test.startTest();
		Account account = new Account();
		account.Name = 'Test Account';
		account.Company__c = 'SponsoredLinX';
		account.username__c = 'test@test.com';
		account.password__c = 'test';
		insert account;
		
		customAccount ca = new customAccount();
		ca.accountid = account.Id;
		ca.accname = 'test';
		ca.subscription = 'test';
		ca.subscriptiontype = 'test';
		ca.billingstatus = 'test';
		ca.reportemail = 'test';
		ca.contactperson = 'test';
		ca.contactphone = 'test';	
		Test.stopTest();
	}
}