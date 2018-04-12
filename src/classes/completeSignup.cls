public with sharing class completeSignup {

	public class SaveAdwordsDetailsResult {
		Boolean status;
		Account_Product__c result;
		String message;
	}

	/*
	*	Save Adwords id and email into the correct recurring product
	*	@param Id signup_id
	*	@param String google_id
	*	@param String google_email
	*	@return SaveAdwordsDetailsResult
	*/
	public SaveAdwordsDetailsResult saveAdwordsDetails(Id signup_id, String adwords_id, String adwords_email) {
		SaveAdwordsDetailsResult return_result = new SaveAdwordsDetailsResult();
		List<Account_Product__c> account_products = [SELECT Name, Description__c, Adwords_ID__c, Adwords_Email__c, Account__c, Recurring_Period__c, Recurring_Frequency__c, Product_Status__c, Product_Category__c, SLX_Product__c, Product_Category__r.Name, SLX_Product__r.Name FROM Account_Product__c WHERE Sign_Up_del__c =: signup_id];

		if(account_products.size() > 0) {
			System.debug('Found some account products');
			// loop for each account products related to current signup
			for (Account_Product__c account_product : account_products) {
				System.debug('Account product: ' + account_product);
				// check if current product is a recurring and adwords related
				if(account_product.Recurring_Frequency__c > 0) {
					System.debug('This account product is Recurring');
					Boolean valid = false;
					List<Product_Category__c> categories = [SELECT Id, Name FROM Product_Category__c WHERE Id =: account_product.Product_Category__c];
					Product_Category__c category;
					List<SLX_Product__c> products = [SELECT Id, Name FROM SLX_Product__c WHERE Id =: account_product.SLX_Product__c];
					SLX_Product__c product;

					// first check category of this product
					if(categories.size() > 0) {
						category = categories[0];
						if(category.Name == 'Adwords Management') {
							valid = true;
							System.debug('This account product is in Adwords category');
						}
					}
					// or second check if current product has correct slxproduct
					else if(products.size() > 0) {
						product = products[0];
						if(product.Name == 'Adwords Standard Management' || product.Name == 'Adwords Optimised Management' || product.Name == 'Adwords Premium Management') {
							valid = true;
							System.debug('This account product has a link to Adwords in SLXProduct');
						}
					}

					if(valid) {
						System.debug('Account product SLX Product name: ' + account_product);
						// now we know if this account products is for recurring adwords
						// we check if it's active. then save the adwords details, before
						// setting the return object.
						if(account_product.Product_Status__c == 'Active') {
							System.debug('Found active adwords account product: ' + account_product.Name);
							try {
								account_product.Adwords_ID__c = adwords_id;
								account_product.Adwords_Email__c = adwords_email;
								update account_product;
								System.debug('Account Product UPDATED');
								return_result.status = true;
								return_result.result = account_product;
								return_result.message = 'Found adwords-related account product and Adwords details have been saved';
								return return_result;
							}
							catch (Exception e) {
								return_result.status = false;
								return_result.result = null;
								return_result.message = 'Failed updating account product: ' + e;
								System.debug('Exception: ' + e);
								return return_result;
							}
						}
					}
					else {
						System.debug('This product is not related to Adwords: ' + product);
					}
				}
			}
		}

		// if there is no correct account product we set the error message
		return_result.status = false;
		return_result.result = null;
		return_result.message = 'Can not find a correct account product to this signup';
		System.debug('Can not find a suitable account product');

		return return_result;
	}
	public static testMethod void completeSignupTest() {
		Test.StartTest();
		
		Account acc = new Account(name='test',company__c='test',username__c='test',password__c='test');
		insert acc;
		
		Contact con = new Contact(FirstName='test',LastName='test',Title='Billing',AccountId=acc.id);
		con.MailingStreet='sdfsadfsa\r\ndfsafa\r\nsfsdfsdfs\r\ndfsdfs\r\ndfsdf';
		con.MailingCity='Brisbane';
		con.MailingState='queensland';
		con.MailingPostalCode='4444';
		con.MailingCountry='Australia';
		insert con;
		
		SLX_Product__c product = new SLX_Product__c(Name='Adwords Standard Management', Product_Price__c = 79.00);
		insert product;
		
		Product_Category__c category1 = new Product_Category__c(Name='Adwords Management');
		insert category1;
		
		Sign_Up__c signup = new Sign_Up__c(Account__c = acc.Id, Name = 'test Signup');
		insert signup;
		
		Account_Product__c ap1 = new Account_Product__c(Account__c = acc.Id, Name = 'Adwords Optimised Management',Recurring_Frequency__c=2, SLX_Product__c = product.Id, Product_Category__c = category1.Id, Recurring_Period__c='Weekly', Product_Status__c='Active', Product_Price__c = 76.00, Sign_Up_del__c = signup.Id);
		insert ap1;
		
		completeSignup cs = new completeSignup();
		System.debug(cs.saveAdwordsDetails(signup.Id, '345345', 'test@test.com'));
			
		Test.stopTest();
	}
	
	public static testMethod void completeSignupTest1() {
		Test.StartTest();
		
		Account acc = new Account(name='test',company__c='test',username__c='test',password__c='test');
		insert acc;
		
		Contact con = new Contact(FirstName='test',LastName='test',Title='Billing',AccountId=acc.id);
		con.MailingStreet='sdfsadfsa\r\ndfsafa\r\nsfsdfsdfs\r\ndfsdfs\r\ndfsdf';
		con.MailingCity='Brisbane';
		con.MailingState='queensland';
		con.MailingPostalCode='4444';
		con.MailingCountry='Australia';
		insert con;
		
		Sign_Up__c signup = new Sign_Up__c(Account__c = acc.Id, Name = 'test Signup');
		insert signup;
		
				
		completeSignup cs = new completeSignup();
		System.debug(cs.saveAdwordsDetails(signup.Id, '345345', 'test@test.com'));
			
		Test.stopTest();
	}
}