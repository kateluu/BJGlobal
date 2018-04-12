@isTest
private class BJBOpportunityHelperTest {

	@testSetup static void setup(){
			List<Account> testAccts = new List<Account>();
		    //create account
            Account itemAcc = new Account(Name = 'TestAccount1', username__c = 'TestAccount1', password__c = 'TestAccount1', CurrencyIsoCode = 'AUD',Num_of_Escalated_Case__c =10, phone='1300859600');
            testAccts.add(itemAcc);
            itemAcc = new Account(Name = 'TestAccount2', username__c = 'TestAccount2', password__c = 'TestAccount2', CurrencyIsoCode = 'USD',Num_of_Escalated_Case__c =10, phone='1300859600');
            testAccts.add(itemAcc);
            insert testAccts;

            // create account products
            List<Account_Product__c> testProducts = new List<Account_Product__c>();
            for (Integer i = 0; i < 2; i++) {
                Account_Product__c item = new Account_Product__c(Name = 'Adwords Management' + 1, Product_Price__c = 1000, CurrencyIsoCode = 'AUD', Account__c = testAccts.get(0).id, Recurring_Period__c = 'Weekly', Product_Status__c='Active', Adwords_ID__c= '123-456-7890');
                testProducts.add(item);
            }
            insert testProducts;

            List<Contact> contacts = new List<Contact>();
            for (Integer i = 0; i < testAccts.size(); i++) {
                Account item = testAccts.get(i);
                Contact con = new Contact(AccountId = item.id, LastName = 'test contact', Title='Billing');
                contacts.add(con);
            }
            insert contacts;

            //create user with Resolution Manager Profiles
            Profile p = [select Id, name from Profile where Name = 'Resolution Manager' limit 1];
            List<User> users = new List<User>();
            for (Integer i = 0; i < testAccts.size(); i++) {
                User newUser = new User(profileId = p.id,
                        username = 'myTestUser' + i + '@yahoo.com',
                        email = 'testUser1@ff.com',
                        emailencodingkey = 'UTF-8',
                        localesidkey = 'en_US',
                        languagelocalekey = 'en_US',
                        timezonesidkey = 'America/Los_Angeles',
                        alias = 'nuser',
                        lastname = 'testuser_lastname' + i,
                        IsActive = true
                );
                users.add(newUser);
            }
            insert users;

            // create a lead, because of leadStatusChangeOnOpp trigger on SLX opportunity object
            Lead__c myLead = new Lead__c(Name='My Test Lead', Lead_Status__c = 'New');
            insert myLead;


            // create main test object - SLX opp
            SLXOpportunity__c opp = new SLXOpportunity__c(Account__c = testAccts.get(0).id , Name = 'Test Opp 1 ',  Product_Type__c ='Adwords Management',
                                                        Send_to_Salesperson__c='Gretel Phillips', Website__c='abc.com.au',  Adwords_Daily_Budget__c=10, 
                                                        Importance__c='High', Contact_Name__c='abc', Contact_Email__c='abc@gmail.com', SLX_Lead__c = myLead.Id);

            insert opp;



	}

	@isTest static void test_getValidAdwordID() {
		// Implement test code
		//List<Account> accs =  [SELECT id FROM Account ];
        
		SLXOpportunity__c opp = [select Adwords_ID__c FROM SLXOpportunity__c LIMIT 1];
		System.assertEquals('123-456-7890', opp.Adwords_ID__c);
	}
	
}