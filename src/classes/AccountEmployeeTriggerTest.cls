@isTest(seeAllData=true)
private class AccountEmployeeTriggerTest {
	
	// Test account creation trigger
	@isTest static void testInsertSLX() {
		
		Test.startTest();

		// Create company
		Company__c company = new Company__c();
		company.Name 				= 'SponsoredLinX';
		company.Business_Name__c 	= 'SponsoredLinX';
		company.Website__c			= 'www.sponsoredlinx.com';
		company.CurrencyIsoCode		= 'AUD';
		insert company;

		// Create account
		Account account = new Account();
		account.Name					= 'Xavier Xylophone';
		account.username__c				= 'xavier.Xylophone';
		account.password__c				= 'pass1234';
		account.Type					= 'Employee';
		account.Employee_Department__c	= 'Sales';
		account.Phone					= '1300859600';
		account.extension__c			= 123;
		account.email__c				= 'xavier.xylophone@sponsoredlinx.com';
		account.Active__c				= true;
		account.BJB_Company__c 			= company.Id;
		insert account;

		// Assert that account was created
		System.assertNotEquals(null, account.Id, 'Account creation failed');

		// Assert that sales promocodes were created
		List<Promocode__c> promocodes = [SELECT id FROM Promocode__c WHERE Account__c = :account.id];
		System.assert(promocodes.size() >= 1, 'Promocode creation failed');

		Test.stopTest();
	}
	

	// Test account creation trigger
	@isTest static void testInsertGMT() {
		
		Test.startTest();

		// Create company
		Company__c company = new Company__c();
		company.Name 				= 'Get More Traffic';
		company.Business_Name__c 	= 'Get More Traffic';
		company.Website__c			= 'www.getMoretraffic.com.au';
		company.CurrencyIsoCode		= 'AUD';
		insert company;

		// Create account
		Account account = new Account();
		account.Name					= 'Xavier Xylophone';
		account.username__c				= 'xavier.Xylophone';
		account.password__c				= 'pass1234';
		account.Type					= 'Employee';
		account.Employee_Department__c	= 'Sales';
		account.Phone					= '1300859600';
		account.extension__c			= 123;
		account.email__c				= 'xavier.xylophone@sponsoredlinx.com';
		account.Active__c				= true;
		account.BJB_Company__c 			= company.Id;
		insert account;

		// Assert that account was created
		System.assertNotEquals(null, account.Id, 'Account creation failed');

		// Assert that sales promocodes were created
		List<Promocode__c> promocodes = [SELECT id FROM Promocode__c WHERE Account__c = :account.id];
		System.assert(promocodes.size() >= 1, 'Promocode creation failed');

		Test.stopTest();
	}
}