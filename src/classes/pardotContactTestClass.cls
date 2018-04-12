/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class pardotContactTestClass {

    static testMethod void myUnitTest() {
        Test.startTest();
        Account account = new Account();
		account.Name = 'Test Account';
		account.Company__c = 'SponsoredLinX';
		account.username__c = 'test@test12.com';
		account.password__c = 'test';
		insert account;
        
        pardotContactIterable pardotContactIterable = new pardotContactIterable();
        if(pardotContactIterable.hasNext()){
        	Account account1 = pardotContactIterable.next();
        }
        Test.stopTest();
    }
    
    public static testMethod void testpardotContactIterator() {
        Test.startTest();
        Account account = new Account();
		account.Name = 'Test Account';
		account.Company__c = 'SponsoredLinX';
		account.username__c = 'test@test.com';
		account.password__c = 'test';
		insert account;
        
        pardotContactIterator pardotContactIterator = new pardotContactIterator();
        Iterator<Account> aps = pardotContactIterator.Iterator();
        Test.stopTest();
  }
  
  public static testMethod void testpardotContactBatch() {
        Test.startTest();
        pardotContactBatch scriptBatch = new pardotContactBatch();
        Account account = new Account();
		account.Name = 'Test Account11';
		account.Company__c = 'SponsoredLinX';
		account.username__c = 'test11d11@test.com';
		account.password__c = 'test';
		insert account;
		
		Contact testContact = new Contact();
    	testContact.AccountId = account.Id;
    	testContact.Title = 'Marketing';
    	testContact.FirstName = 'test';
    	testContact.LastName = 'test';
    	testContact.MailingStreet = 'test';
    	insert testContact;
        
        Account_Product__c ap = new Account_Product__c();
        ap.Last_Invoice_Date__c = Date.today().addDays(-7);
        ap.Recurring_Frequency__c = 1;
        ap.Name = 'Facebook';
        //ap.pauseat__c = Date.today();
        ap.Product_Price__c = 19.99;
        ap.Recurring_Period__c ='Weekly';
        ap.Payment_Option__c = 'Eway';
        ap.Product_Status__c = 'Paused';
        ap.Account__c = account.Id;
        insert ap;
        
        Account_Product__c fbap = new Account_Product__c();
        fbap.Last_Invoice_Date__c = Date.today().addDays(-7);
        fbap.Recurring_Frequency__c = 1;
        fbap.Name = 'Facebook';
        //ap.pauseat__c = Date.today();
        fbap.Product_Price__c = 19.99;
        fbap.Recurring_Period__c ='Weekly';
        fbap.Payment_Option__c = 'Eway';
        fbap.Product_Status__c = 'Active';
        fbap.Account__c = account.Id;
        insert fbap;
        
        
        
        Account_Product__c ap1 = new Account_Product__c();
        ap1.Last_Invoice_Date__c = Date.today().addDays(-7);
        ap1.Recurring_Frequency__c = 1;
        ap1.Name = 'SEO';
        ap1.Product_Status__c = 'Active';
        ap1.Product_Price__c = 19.99;
        ap1.Recurring_Period__c ='Weekly';
        ap1.Payment_Option__c = 'Eway';
        ap1.Account__c = account.Id;
        insert ap1;
        
        Account_Product__c ap0 = new Account_Product__c();
        ap0.Last_Invoice_Date__c = Date.today().addDays(-7);
        ap0.Recurring_Frequency__c = 1;
        ap0.Name = 'SEO';
        ap0.Product_Status__c = 'Cancelled';
        ap0.Product_Price__c = 19.99;
        ap0.Recurring_Period__c ='Weekly';
        ap0.Payment_Option__c = 'Eway';
        ap0.Account__c = account.Id;
        insert ap0;
        
        Account_Product__c ap10 = new Account_Product__c();
        ap10.Last_Invoice_Date__c = Date.today().addDays(-7);
        ap10.Recurring_Frequency__c = 1;
        ap10.Name = 'Social Media';
        ap10.Product_Status__c = 'Cancelled';
        ap10.Product_Price__c = 19.99;
        ap10.Recurring_Period__c ='Weekly';
        ap10.Payment_Option__c = 'Eway';
        ap10.Account__c = account.Id;
        insert ap10;
        
        Account_Product__c ap11 = new Account_Product__c();
        ap11.Last_Invoice_Date__c = Date.today().addDays(-7);
        ap11.Recurring_Frequency__c = 1;
        ap11.Name = 'Social Media';
        ap11.Product_Status__c = 'Active';
        ap11.Product_Price__c = 19.99;
        ap11.Recurring_Period__c ='Weekly';
        ap11.Payment_Option__c = 'Eway';
        ap11.Account__c = account.Id;
        insert ap11;
        
        Account_Product__c ap2 = new Account_Product__c();
        ap2.Last_Invoice_Date__c = Date.today().addDays(-7);
        ap2.Recurring_Frequency__c = 1;
        ap2.Name = 'Adwords';
        ap2.Product_Status__c = 'Cancelled';
        ap2.Product_Price__c = 19.99;
        ap2.Recurring_Period__c ='Weekly';
        ap2.Payment_Option__c = 'Eway';
        ap2.Account__c = account.Id;
        insert ap2;
       
        Database.batchableContext info;
        scriptBatch.start(info);
        List<Account> scope = [select Id, Name, Owner.Name, Website, infusionsoft_Id__c FROM Account limit 5];
        scriptBatch.execute(info, scope);
        scriptBatch.finish(info);
        
        Test.stopTest();
    }
    public static testMethod void testpardotContactBatch1() {
        Test.startTest();
        pardotContactBatch scriptBatch = new pardotContactBatch();
        Account account = new Account();
		account.Name = 'Test Account11';
		account.Company__c = 'SponsoredLinX';
		account.username__c = 'test11d11@test.com';
		account.password__c = 'test';
		insert account;
		
		Contact testContact = new Contact();
    	testContact.AccountId = account.Id;
    	testContact.Title = 'Billing';
    	testContact.FirstName = 'test';
    	testContact.LastName = 'test';
    	testContact.MailingStreet = 'test';
    	insert testContact;
        
        
        
        Account_Product__c ap10 = new Account_Product__c();
        ap10.Last_Invoice_Date__c = Date.today().addDays(-7);
        ap10.Recurring_Frequency__c = 1;
        ap10.Name = 'Adwords';
        ap10.Product_Status__c = 'Active';
        ap10.Product_Price__c = 89.99;
        ap10.Recurring_Period__c ='Weekly';
        ap10.Payment_Option__c = 'Eway';
        ap10.Account__c = account.Id;
        insert ap10;
        
        Account_Product__c ap2 = new Account_Product__c();
        ap2.Last_Invoice_Date__c = Date.today().addDays(-7);
        ap2.Recurring_Frequency__c = 1;
        ap2.Name = 'SEO';
        ap2.Product_Status__c = 'Cancelled';
        ap2.Product_Price__c = 19.99;
        ap2.Recurring_Period__c ='Weekly';
        ap2.Payment_Option__c = 'Eway';
        ap2.Account__c = account.Id;
        insert ap2;
       
        Database.batchableContext info;
        scriptBatch.start(info);
        List<Account> scope = [select Id, Name, Owner.Name, Website, infusionsoft_Id__c FROM Account limit 5];
        scriptBatch.execute(info, scope);
        scriptBatch.finish(info);
        
        Test.stopTest();
    }
    public static testMethod void testpardotContactBatch2() {
        Test.startTest();
        pardotContactBatch scriptBatch = new pardotContactBatch();
        Account account = new Account();
		account.Name = 'Test Account11';
		account.Company__c = 'SponsoredLinX';
		account.username__c = 'test11d11@test.com';
		account.password__c = 'test';
		insert account;
		
		Contact testContact = new Contact();
    	testContact.AccountId = account.Id;
    	testContact.Title = 'Billing';
    	testContact.FirstName = 'test';
    	testContact.LastName = 'test';
    	testContact.MailingStreet = 'test';
    	insert testContact;
        
        
        
        Account_Product__c ap10 = new Account_Product__c();
        ap10.Last_Invoice_Date__c = Date.today().addDays(-7);
        ap10.Recurring_Frequency__c = 1;
        ap10.Name = 'Adwords';
        ap10.Product_Status__c = 'Active';
        ap10.Product_Price__c = 109.99;
        ap10.Recurring_Period__c ='Weekly';
        ap10.Payment_Option__c = 'Eway';
        ap10.Account__c = account.Id;
        insert ap10;
        
        Account_Product__c ap2 = new Account_Product__c();
        ap2.Last_Invoice_Date__c = Date.today().addDays(-7);
        ap2.Recurring_Frequency__c = 1;
        ap2.Name = 'ConvertoPages';
        ap2.Product_Status__c = 'Paused';
        ap2.Product_Price__c = 19.99;
        ap2.Recurring_Period__c ='Weekly';
        ap2.Payment_Option__c = 'Eway';
        ap2.Account__c = account.Id;
        insert ap2;
        
        Account_Product__c ap3 = new Account_Product__c();
        ap3.Last_Invoice_Date__c = Date.today().addDays(-7);
        ap3.Recurring_Frequency__c = 1;
        ap3.Name = 'ConvertoPages';
        ap3.Product_Status__c = 'Active';
        ap3.Product_Price__c = 19.99;
        ap3.Recurring_Period__c ='Weekly';
        ap3.Payment_Option__c = 'Eway';
        ap3.Account__c = account.Id;
        insert ap3;
        
        Account_Product__c fbap = new Account_Product__c();
        fbap.Last_Invoice_Date__c = Date.today().addDays(-7);
        fbap.Recurring_Frequency__c = 1;
        fbap.Name = 'Facebook';
        //ap.pauseat__c = Date.today();
        fbap.Product_Price__c = 19.99;
        fbap.Recurring_Period__c ='Weekly';
        fbap.Payment_Option__c = 'Eway';
        fbap.Product_Status__c = 'Cancelled';
        fbap.Account__c = account.Id;
        insert fbap;
       
        Database.batchableContext info;
        scriptBatch.start(info);
        List<Account> scope = [select Id, Name, Owner.Name, Website, infusionsoft_Id__c FROM Account limit 5];
        scriptBatch.execute(info, scope);
        scriptBatch.finish(info);
        
        Test.stopTest();
    }
    
    public static testMethod void pardotContactScheduleTest() {
	    Test.StartTest();
	    
	    datetime time1 = Datetime.now();
	    datetime time2 = time1.addSeconds(5);
	    String seconds = String.valueOf(time2.second());
	    String minutes = String.valueOf(time2.minute());
	    String hours = String.valueOf(time2.hour());
	    
	    String sch = seconds+' '+minutes+' '+hours+' ? * MON-SUN';  
	    System.debug('sch:'+sch);
	    System.schedule('infusionsoftScheduletest', sch, new pardotContactScheduler());
	      
	    Test.stopTest();
    }
}