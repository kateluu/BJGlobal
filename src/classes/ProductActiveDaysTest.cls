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
private class ProductActiveDaysTest {

    static testMethod void ProductActiveDaysTest() {
        // TO DO: implement unit test
        ProductActiveDaysIterable testIteratble = new ProductActiveDaysIterable();
        Account a = new Account();
        a.Name = 'TestAccount12';
	    a.username__c           = 'user12';
	    a.password__c           = 'psw';
	    a.Payment_Option__c     ='Other';
	    a.Card_Year_Expiry__c   ='2014';
	    a.Card_Number__c        ='123456789';
	    a.Card_Month_Expiry__c  ='01';
	    a.Name_On_Card__c       ='Test';
		a.Send_Invoice__c       = true;
		insert a; 
		
		Contact contact = new Contact();
		contact.AccountId = a.Id;
		contact.title = 'Marketing';
		contact.FirstName = 'bob';
		contact.LastName = 'down';
		contact.Phone = 'down';
		contact.Email = 'down@bob.com';
		contact.MailingStreet='sdfasfsf\r\nsdfsdfdsf\r\nsdfsdfsf\r\ndsdfsdf';
		contact.MailingCity='brisbane';
		contact.MailingPostalCode='4500';
		contact.MailingState='Queensland';
		contact.MailingCountry='Australia';
		insert contact;
		
		
		Account_Product__c ap = new Account_Product__c();
    	ap.name = 'Adwords Management';
    	ap.account__c = a.id;
    	ap.product_price__c = 69;
    	ap.Product_Status__c = 'Active';
    	ap.Recurring_Period__c = 'Weekly';
    	ap.Last_Invoice_Date__c = Date.today().addDays(-7);
    	ap.Payment_Option__c = 'Eway';
    	insert ap;
    	
    	ProductActiveDaysIterable testIteratble1 = new ProductActiveDaysIterable();
        if(testIteratble.hasNext()){
        	Account account = testIteratble1.next();
        }
        
        ProductActiveDaysIterator activeproductIterator = new ProductActiveDaysIterator();
        Iterator<Account> accounts = activeproductIterator.Iterator();
    	
    	ProductActiveDaysBatch active_days_batch = new ProductActiveDaysBatch();
		ID active_days_batch_id = Database.executeBatch(active_days_batch, 1);
		
		datetime time1 = Datetime.now();
		datetime time2 = time1.addSeconds(5);
		String seconds = String.valueOf(time2.second());
		String minutes = String.valueOf(time2.minute());
		String hours = String.valueOf(time2.hour());
		
		String sch = seconds+' '+minutes+' '+hours+' ? * MON-SUN';	
		System.debug('sch:'+sch);
		System.schedule('Product Active Days Scheduler', sch, new ProductActiveDaysScheduler());
    	
    }
}