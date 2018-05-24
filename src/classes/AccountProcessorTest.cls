@isTest
private class AccountProcessorTest {
	
	@isTest static void test_executebatchjob() {
        // Create common test accounts
        List<Account> testAccts = new List<Account>();
        try{               
	        	// Implement test code
				Test.startTest();

                Account itemAcc = new Account(Name ='TestAccount1', username__c='TestAccount1', password__c='TestAccount1', CurrencyIsoCode ='AUD', Phone='78456213',Active__c= true , card_number__c ='3413551010014590', Card_Number_Masked__c ='34XX-XXXX-XXXX-4590' );
                testAccts.add(itemAcc);
                itemAcc = new Account(Name ='TestAccount2', username__c='TestAccount2', password__c='TestAccount2', CurrencyIsoCode ='AUD', Phone='78456213', Active__c= true , card_number__c ='5413551010014590');
                testAccts.add(itemAcc);
                insert testAccts; 
                
                // create account products
                List<Account_Product__c> testProducts = new List<Account_Product__c>();
                for(Integer i=0;i<2;i++) {            
                    Account_Product__c item = new Account_Product__c(Name ='Adword'+1, Product_Price__c=1000, CurrencyIsoCode ='AUD', Account__c =testAccts.get(0).id, Product_Status__c ='Active', Recurring_Period__c = 'Weekly');
                    testProducts.add(item);
                }
                insert testProducts; 
                
                List<Contact> contacts= new List<Contact>();
                for(Integer i =0; i< testAccts.size(); i++){
                    Account item = testAccts.get(i);
                    Contact con = new Contact (AccountId = item.id,LastName = 'test contact'); 
                    contacts.add(con);
                }
                insert contacts;


				
		        AccountProcessor obj = new AccountProcessor('');
		        DataBase.executeBatch(obj, 10); 
		            
		        Test.stopTest();
				list<Account> accounts = [SELECT Id, card_number__c, Card_Number_Masked__c, Amex__c
										FRoM Account
										WHERE Active__c = true AND Name ='TestAccount1'];

                System.debug('accounts[0].Card_Number_Masked__c = ' + accounts[0].Card_Number_Masked__c);
                System.assertEquals(accounts[0].card_number__c, NULL);                
                System.assertEquals(accounts[0].Card_Number_Masked__c, '34XX-XXXX-XXXX-4590');
				System.assertEquals(true,accounts[0].Amex__c);
				
        }catch(DMLException e){
            system.debug('retry' + e.getMessage());
        }

	}
	
}