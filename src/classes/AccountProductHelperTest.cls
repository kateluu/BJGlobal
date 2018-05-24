@isTest
private class AccountProductHelperTest {
	@testSetup static void setup(){
        // Create common test accounts
        List<Account> testAccts = new List<Account>();
        try{               
                Account itemAcc = new Account(Name ='TestAccount1', username__c='TestAccount1', password__c='TestAccount1', CurrencyIsoCode ='AUD', Phone='78456213',Active__c= true);
                testAccts.add(itemAcc);
                itemAcc = new Account(Name ='TestAccount2', username__c='TestAccount2', password__c='TestAccount2', CurrencyIsoCode ='AUD', Phone='78456213', Active__c= true);
                testAccts.add(itemAcc);
                insert testAccts; 
                
                // create account products
                List<Account_Product__c> testProducts = new List<Account_Product__c>();
                for(Integer i=0;i<2;i++) {            
                    Account_Product__c item = new Account_Product__c(Name ='Adword'+1, Product_Price__c=1000, CurrencyIsoCode ='AUD', Account__c =testAccts.get(0).id, Product_Status__c ='Active' );
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

                String userID = ''+ UserInfo.getUserId() ;
                List<Task> tasks = new List<Task>();
				Task tsk1 = new Task(WhatId = testAccts[0].Id, Subject = '→ Email: apex test', ActivityDate = date.today(), Status = 'Completed' , OwnerID = userID );
				tasks.add(tsk1);
				Task tsk2 = new Task(WhatId = testAccts[0].Id, Subject = 'Outbound call: apex test', ActivityDate = date.today(), Status = 'Completed', OwnerID = userID );
				tasks.add(tsk2);				
				Task tsk3 = new Task(WhatId = testAccts[0].Id, Subject = '→ Email: apex test', ActivityDate = date.today().addYears(-2), Status = 'Completed', OwnerID = userID );
				tasks.add(tsk3);
				insert tasks;				
                
        }catch(DMLException e){
            system.debug('retry' + e.getMessage());
        }
    }
    


	@isTest static void test_fetchDailyData() {
		// Implement test code
		AccountProductHelper helper = new AccountProductHelper();
		//helper.fetchDailyData();
		list<Account_Product__c> activeProducts = [SELECT Id, Product_Status__c, Account__c, OwnerId, 
												  Last_14_days_num_of_calls__c, Last_14_days_num_of_emails__c,Last_7_days_num_of_calls__c,Last_7_days_num_of_emails__c 
												FRoM Account_Product__c 
												WHERE Product_Status__c = 'Active' and Account__r.Active__c= true];

		System.assertEquals(activeProducts[0].Last_14_days_num_of_calls__c, 0);
		System.assertEquals(activeProducts[0].Last_14_days_num_of_emails__c, 0);
		System.assertEquals(activeProducts[0].Last_7_days_num_of_calls__c, 0);
		System.assertEquals(activeProducts[0].Last_7_days_num_of_emails__c, 0);
	}

	
}