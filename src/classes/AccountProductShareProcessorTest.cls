@isTest
public without sharing class AccountProductShareProcessorTest
{
	@testSetup	static void setup(){	
		try{ 
                
                //create user with Resolution Manager Profiles
                Profile p = [select Id, name from Profile where Name = 'Resolution Manager' limit 1];        
                List<User> users = new List<User>();
                for(Integer i =0; i<2; i++){
                    User newUser = new User(profileId = p.id,
                                            username = 'myTestUser'+i+'@yahoo.com',
                                            email = 'testUser1@ff.com',
                                            emailencodingkey = 'UTF-8',
                                            localesidkey = 'en_US',
                                            languagelocalekey = 'en_US',
                                            timezonesidkey = 'America/Los_Angeles',
                                            alias='nuser',
                                            lastname='testuser_lastname' + i,
                                            IsActive = true
                                            );
                    users.add(newUser);
                }
                insert users;

                User u = [SELECT id, username FROM USER WHERE profileId = :p.id AND  IsActive = true LIMIT 1];
  				System.runAs(u) {
                   // The following code runs as user 'u'
                   System.debug('Current User: ' + UserInfo.getUserName());
                   System.debug('Current Profile: ' + UserInfo.getProfileId());

     	              // insert test data
					list<Account> testAccts = new list<Account>();
			        Account itemAcc = new Account(Name ='TestAccount1', username__c='TestAccount1', password__c='TestAccount1', CurrencyIsoCode ='AUD', Phone='78456213');
	                testAccts.add(itemAcc);
	                itemAcc = new Account(Name ='TestAccount2', username__c='TestAccount2', password__c='TestAccount2', CurrencyIsoCode ='AUD', Phone='78456213');
	                testAccts.add(itemAcc);        
	                insert testAccts; 
	                
	                
	                List<Contact> contacts= new List<Contact>();
	                for(Account child :testAccts){                    
	                    Contact con = new Contact (AccountId = child.id,LastName = 'test contact'); 
	                    contacts.add(con);
	                }
	                insert contacts;
          		}                
                
        }catch(DMLException e){
            system.debug('AccountProductShareProcessorTest: setup: Retry' + e.getMessage());
        }

	}

	@isTest 
	static void testRecaculateAccountSharing(){
		list<Account> testAccts = [SELECT id FROM Account];

        // create account products
        List<Account_Product__c> testProducts = new List<Account_Product__c>();
        Account_Product__c item = new Account_Product__c(Name ='Social'+1, Product_Price__c=1000, CurrencyIsoCode ='AUD', Account__c =testAccts.get(0).id);
        testProducts.add(item);
        item = new Account_Product__c(Name ='Adwords'+2, Product_Price__c=1000, CurrencyIsoCode ='AUD', Account__c =testAccts.get(1).id);
        testProducts.add(item);
        insert testProducts; 

        list<Account_Product__c> newProducts = [SELECT Account__c , OwnerId FROM Account_Product__c];
        AccountProductShareProcessor processor = new AccountProductShareProcessor(newProducts, null);
        processor.recaculateAccountSharing();

                
        List<AccountShare> accShare = [ SELECT Id, AccountId, UserOrGroupId, RowCause 
        								FROM AccountShare
        								WHERE RowCause= :Schema.AccountShare.RowCause.Manual];
        System.assertEquals(2, accShare.size());
        
    }

    @isTest 
	static void testRemoveAccountSharing(){
                
        List<User> users = [ 	SELECT Id, profileId
								FROM User
        						WHERE IsActive = true AND ProfileId in (select Id from Profile where Name = 'Resolution Manager')];
        list<Account> testAccts = [SELECT id FROM Account];

        // create account products
        List<Account_Product__c> testProducts = new List<Account_Product__c>();
        Account_Product__c item = new Account_Product__c(Name ='Social'+1, Product_Price__c=1000, CurrencyIsoCode ='AUD', Account__c =testAccts.get(0).id);
        testProducts.add(item);
        item = new Account_Product__c(Name ='Adwords'+2, Product_Price__c=1000, CurrencyIsoCode ='AUD', Account__c =testAccts.get(1).id);
        testProducts.add(item);
        insert testProducts; 

        list<Account_Product__c> products = [SELECT Id,Account__c, OwnerID FROM Account_Product__c];
        list<Account_Product__c>  newProducts = new List<Account_Product__c>();

        for(Integer i=0;i<products.size();i++){
			item =  products.get(i);
        	//item.OwnerId = users.get(i).Id;
        	newProducts.add(item);
        }

        AccountProductShareProcessor processor = new AccountProductShareProcessor(newProducts, products);
        processor.removeAccountSharing();

        List<AccountShare> accShare = [ SELECT Id, AccountId, UserOrGroupId, RowCause 
        								FROM AccountShare
        								WHERE RowCause= :Schema.AccountShare.RowCause.Manual];
        System.assertEquals(0, accShare.size());
    }


}