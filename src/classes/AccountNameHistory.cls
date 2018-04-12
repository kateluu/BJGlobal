public with sharing class AccountNameHistory {
	// No longer used
	//public List<AccountHistory> accounts {get; set;}	
	//public Payment__c fromDate {get; set;}	
	//public Payment__c toDate {get; set;}	
	
	
	//public AccountNameHistory () {
	//	this.fromDate = new Payment__c();
	//	this.toDate = new Payment__c();
		
	//}
	//public void ShowAccounts () {
	//	this.accounts = new List<AccountHistory>();
	//	List<AccountHistory> accounts = [SELECT AccountId, 
	//										Account.Name, 
	//										CreatedBy.Name,
	//										CreatedDate,
	//										Field, 
	//										OldValue,
	//										NewValue 
	//								FROM AccountHistory 
	//								where CreatedDate >=: fromDate.Payment_Date__c
	//								And   CreatedDate <=: toDate.Payment_Date__c.addDays(1) ];
		
	//	User salesManager = [select name from user where user.profile.name = 'BJB Sales Manager' and IsActive = true limit 1];
			
	//	for(AccountHistory account : accounts){
	//		if(account.NewValue == salesManager.name){
	//			this.accounts.add(account);
	//		}
	//	}
	//}
	
	//@isTest(SeeAllData=true)
	//static void test() {
	//	AccountNameHistory anh = new AccountNameHistory();
	//	anh.fromDate.Payment_Date__c = Date.newInstance(2013, 9, 1);
	//	anh.toDate.Payment_Date__c = Date.newInstance(2013, 11, 1);
	//	anh.ShowAccounts();
	//}
}