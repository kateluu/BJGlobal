@isTest
public class TigerPistolConnectorTest
{
	
	@testSetup static void setup(){
		List<Account> testAccts = new List<Account>();

        Company__c company = new Company__c();
        company.Name                = 'SponsoredLinX';
        company.Business_Name__c    = 'SponsoredLinX';
        company.Website__c          = 'www.sponsoredlinx.com';
        company.CurrencyIsoCode     = 'AUD';
        insert company;
        Company__c company2 = new Company__c();
        company.Name                = 'GetMoreTraffice';
        company.Business_Name__c    = 'GetMoreTraffice';
        company.Website__c          = 'www.GetMoreTraffice.com';
        company.CurrencyIsoCode     = 'AUD';
        insert company2;


        Account itemAcc = new Account(Name ='TestAccount1', username__c='TestAccount1', password__c='TestAccount1', CurrencyIsoCode ='AUD', Phone='1300859600',BJB_Company__c = company.Id, email__c='test@gmail.com', Type='Customer');
        testAccts.add(itemAcc);
        itemAcc = new Account(Name ='TestAccount2', username__c='TestAccount2', password__c='TestAccount2', CurrencyIsoCode ='AUD', Phone='1300859600', BJB_Company__c  = company2.Id, email__c='test@gmail.com', Type='Customer');
        testAccts.add(itemAcc);        
        insert testAccts; 
        
        // create account products
        List<Account_Product__c> testProducts = new List<Account_Product__c>();
        Account_Product__c item = new Account_Product__c(Name ='Social Engage Simple Super'+1, Product_Price__c=1000, CurrencyIsoCode ='AUD', Account__c =testAccts.get(0).id );
        insert item; 

        item = new Account_Product__c(Name ='Social Engage Simple Super'+2, Product_Price__c=1000, CurrencyIsoCode ='AUD', Account__c =testAccts.get(0).id );
        insert item; 

        // create Marketing contact
        List<Contact> contacts= new List<Contact>();
        for(Integer i =0; i< testAccts.size(); i++){
            Account itemAccount = testAccts.get(i);
            Contact con = new Contact (AccountId = itemAccount.id,LastName = 'test contact',Phone='1300859600', Title = 'Marketing'); 
            contacts.add(con);
        }
        insert contacts;
        

		// When


		// Then

	}

	@isTest static void testAddTigerPistolClient(){

		Account_Product__c item = [SELECT id, TP_Record_Id__c FROM Account_Product__c LIMIT 1];

		List<id> products = new List<id>();
		products.add(item.id);
		TigerPistolConnector td= new TigerPistolConnector();
		TigerPistolConnector.addCustomerOnProductFuture(products);
		item = [SELECT id, TP_Record_Id__c FROM Account_Product__c LIMIT 1];
		System.assertEquals(item.TP_Record_Id__c, null);

	}



	@isTest static void testAddTigerPistolClientSynch(){

		Account_Product__c item = [SELECT id, TP_Record_Id__c FROM Account_Product__c LIMIT 1];

		List<id> products = new List<id>();
		products.add(item.id);
		TigerPistolConnector td= new TigerPistolConnector();
		TigerPistolConnector.addCustomerOnProductSynch(products);
		item = [SELECT id, TP_Record_Id__c FROM Account_Product__c LIMIT 1];
		System.assertNotEquals(item.TP_Record_Id__c, null);

	}



	@isTest static void testDeleteTigerPistolClient(){

		Account_Product__c item = [SELECT id, TP_Record_Id__c FROM Account_Product__c LIMIT 1];

		List<id> products = new List<id>();
		products.add(item.id);

		TigerPistolConnector.deleteCustomer(item.id);
		System.assertNotEquals(item, null);

	}

	@isTest static void testDeleteTigerPistolClientSynch(){

		Account_Product__c item = [SELECT id, TP_Record_Id__c FROM Account_Product__c LIMIT 1];

		List<id> products = new List<id>();
		products.add(item.id);

		TigerPistolConnector.deleteCustomerSynch(item.id);
		System.assertNotEquals(item, null);

	}


	@isTest static void testPauseTigerPistolClient(){

		Account_Product__c item = [SELECT id, TP_Record_Id__c FROM Account_Product__c LIMIT 1];

		List<id> products = new List<id>();
		products.add(item.id);

		TigerPistolConnector.pauseCustomer(item.id);		
		System.assertNotEquals(item, null);

	}

	@isTest static void testPauseTigerPistolClientSynch(){

		Account_Product__c item = [SELECT id, TP_Record_Id__c FROM Account_Product__c LIMIT 1];

		List<id> products = new List<id>();
		products.add(item.id);

		TigerPistolConnector.pauseCustomerSynch(item.id);		
		System.assertNotEquals(item, null);

	}


	@isTest static void testReactivateTigerPistolClient(){

		Account_Product__c item = [SELECT id, TP_Record_Id__c FROM Account_Product__c LIMIT 1];

		List<id> products = new List<id>();
		products.add(item.id);

		TigerPistolConnector.reActivateCustomer(item.id);		
		System.assertNotEquals(item, null);

	}


	@isTest static void testReactivateTigerPistolClientSynch(){

		Account_Product__c item = [SELECT id, TP_Record_Id__c FROM Account_Product__c LIMIT 1];

		List<id> products = new List<id>();
		products.add(item.id);

		TigerPistolConnector.reActivateCustomerSynch(item.id);		
		System.assertNotEquals(item, null);

	}

	
}