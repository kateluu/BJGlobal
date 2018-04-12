public with sharing class generateCreditNotePDF {
	public Credit__c credit {set;get;}
	public Payment__c[] ps {set;get;}
	
	public generateCreditNotePDF(ApexPages.StandardController controller){
		Credit__c cr = (Credit__c)controller.getRecord();
		this.credit = [select Id, Name, Account_Product_Number__c, Amount__c, Credit_Left__c, Credit_Name__c, 
						Credit_Used__c, Invoice__c, Reference__c, Valid_From__c, Processed__c, Account_Product__r.Name, 
						Account_Product__r.Description__c, Account__r.Name, Account__r.Unique_Id__c,
						Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingPostalCode,
						Account__r.BillingCountry from Credit__c where Id=:cr.Id];
		this.ps = [select Name, Payment_Amount__c, Invoice__r.Invoice_Number__c from Payment__c where Credit__c =: cr.Id];
	}
	
	public static testMethod void test(){
		Test.startTest();
		Account acc = new Account(name='test',company__c='test',username__c='test',password__c='test');
		insert acc;
		Contact con = new Contact(FirstName='test',LastName='test',Title='Billing',AccountId=acc.id);
		con.MailingStreet='sdfsadfsa\r\ndfsafa\r\nsfsdfsdfs\r\ndfsdfs\r\ndfsdf';
		con.MailingCity='Brisbane';
		con.MailingState='queensland';
		con.MailingPostalCode='4444';
		con.MailingCountry='Australia';
		insert con;
		Credit__c credit = new Credit__c(Account__c = acc.Id, valid_From__c = Date.today(), Amount__c = 100);
		insert credit;
		ApexPages.standardController controller = new ApexPages.standardController(credit);
		generateCreditNotePDF creditController =  new generateCreditNotePDF(controller);
		Test.stopTest();
	}
}