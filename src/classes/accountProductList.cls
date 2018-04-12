public with sharing class accountProductList {
	
	public List<Account_Product__c> accountProductList = new List<Account_Product__c>();
	public Boolean renderList {get;set;}
	public Boolean renderMsg {get;set;}
	
	public accountProductList(ApexPages.StandardController controller) {
		Cases__c cases = (Cases__c)controller.getRecord();
		try {
			this.accountProductList = [SELECT Name,Description__c,Product_Number__c,Product_Price__c,Product_Status__c,Recurring_Frequency__c,Payment_Option__c,Recurring_Period__c,Start_Date__c,CreatedDate,activeat__c,pauseat__c,cancelat__c FROM Account_Product__c WHERE Account__c=:cases.Account__c];
			if(this.accountProductList.size()>0){
				this.renderList = true;
				this.renderMsg = false;					
			} else {
				this.renderList = false;
				this.renderMsg = true;
			}		
		} catch(Exception e) {}	
	}

	public List<Account_Product__c> getaccountProductList() {
		return this.accountProductList;
	}
	public static testMethod void testaccountProductList() {
		Test.startTest();
		
		Account account = new Account();
		account.Name = 'Test Account';
		account.Company__c = 'SponsoredLinX';
		account.username__c = 'test@test.com';
		account.password__c = 'test';
		insert account;
		
		ApexPages.standardController controller = new ApexPages.standardController(new Cases__c(Account__c=account.Id,Description__c='dfdfd'));
		
		accountProductList apl = new accountProductList(controller);
		apl.getaccountProductList();
		
		
		Test.stopTest();
	}
}