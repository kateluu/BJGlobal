@isTest
private class SEOAccountProductProcessortTest
{
	
	@isTest static void test_pass() {
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
                    Account_Product__c item = new Account_Product__c(Name ='SEO'+1, Product_Price__c=1000, CurrencyIsoCode ='AUD', Account__c =testAccts.get(0).id, Product_Status__c ='Active', Recurring_Period__c = 'Weekly');
                    testProducts.add(item);
                }


                insert testProducts; 
                
                // create project
                String userID = ''+ UserInfo.getUserId() ;
                SFDC_Projects__c project = new SFDC_Projects__c(Name ='SEO' , Project_Stage__c='Ongoing Management', Project_Type__c ='SEO' , Account_Product__c = testProducts[0].id, OwnerID = userID);

                List<Contact> contacts= new List<Contact>();
                for(Integer i =0; i< testAccts.size(); i++){
                    Account item = testAccts.get(i);
                    Contact con = new Contact (AccountId = item.id,LastName = 'test contact'); 
                    contacts.add(con);
                }
                insert contacts;

                //String userID = ''+ UserInfo.getUserId() ;
                List<Task> tasks = new List<Task>();
				Task tsk1 = new Task(WhatId = project.Id, Subject = '→ Email: apex test', ActivityDate = date.today(), Status = 'Completed' , OwnerID = userID , TaskSubtype = 'Email');
				tasks.add(tsk1);
				Task tsk2 = new Task(WhatId = project.Id, Subject = 'Outbound call: apex test', ActivityDate = date.today(), Status = 'Completed', OwnerID = userID , calltype = 'Outbound');
				tasks.add(tsk2);				
				Task tsk3 = new Task(WhatId = project.Id, Subject = '→ Email: apex test', ActivityDate = date.today().addYears(-2), Status = 'Completed', OwnerID = userID , TaskSubtype = 'Email');
				tasks.add(tsk3);
				insert tasks;				

				// Implement test code
				Test.startTest();



		        SEOAccountProductProcessor obj = new SEOAccountProductProcessor('');
		        DataBase.executeBatch(obj, 10); 
		            
		        Test.stopTest();
				list<Account_Product__c> activeProducts = [SELECT Id, Product_Status__c, Account__c, OwnerId, 
														  Last_14_days_num_of_calls__c, Last_14_days_num_of_emails__c,Last_7_days_num_of_calls__c,Last_7_days_num_of_emails__c ,
                                                          Last_21_days_num_of_calls__c,Last_21_days_num_of_emails__c 
														FRoM Account_Product__c 
														WHERE Product_Status__c = 'Active' and Account__r.Active__c= true AND Recurring_Period__c <> 'N/A'];

    //            System.assertEquals(activeProducts[0].Last_21_days_num_of_calls__c, 2);
    //            System.assertEquals(activeProducts[0].Last_21_days_num_of_emails__c, 4);
				//System.assertEquals(activeProducts[0].Last_14_days_num_of_calls__c, 2);
				//System.assertEquals(activeProducts[0].Last_14_days_num_of_emails__c, 4);
				//System.assertEquals(activeProducts[0].Last_7_days_num_of_calls__c, 2);
				//System.assertEquals(activeProducts[0].Last_7_days_num_of_emails__c, 4);
                
        }catch(DMLException e){
            system.debug('retry' + e.getMessage());
        }


	}
}