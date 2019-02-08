@isTest
public class CascadeConnectorTest {
	
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
	}

	@isTest static void testUpdateProgress(){
		CascadeConnector td= new CascadeConnector('false');
		CascadeConnector.updateProgress();		
	}
}