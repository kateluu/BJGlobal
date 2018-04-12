@isTest
public class MonthlyKPItest{
	static testMethod void MonthlyKPItest() {
		Test.StartTest();
		
		User user_a = new User(FirstName='test', LastName='test', UserRoleId='00E900000013963', email='testa@sponsoredlinx.com', 
								Username='test.test@sponsoredlinx.com', Alias='test',CommunityNickname='testa', 
								TimeZoneSidKey='Australia/Brisbane', LanguageLocaleKey= 'en_US', LocaleSidKey='en_AU', 
								ProfileId='00e90000000bbgXAAQ',EmailEncodingKey='ISO-8859-1');
		insert user_a;
		
		System.runAs ( user_a ) {
		
			Account acc = new Account(name='test',company__c='test',username__c='test',password__c='test');
			insert acc;
			
			Contact con = new Contact(FirstName='test',LastName='test',Title='Billing',AccountId=acc.id);
			con.MailingStreet='sdfsadfsa\r\ndfsafa\r\nsfsdfsdfs\r\ndfsdfs\r\ndfsdf';
			con.MailingCity='Brisbane';
			con.MailingState='queensland';
			con.MailingPostalCode='4444';
			con.MailingCountry='Australia';
			insert con;
			
			Account_Product__c ap1 = new Account_Product__c(Account__c = acc.Id, Name = 'Adwords Optimised Management',Recurring_Frequency__c=2,  Recurring_Period__c='Weekly', Product_Status__c='Active', Product_Price__c = 76.00);
			insert ap1;
			
		}
		
		User user_c = new User(FirstName='tesct', LastName='testc', UserRoleId='00E90000000NS9W', email='testb@sponsoredlinx.com', 
								Username='test.testb@sponsoredlinx.com', Alias='testb',CommunityNickname='testb', 
								TimeZoneSidKey='Australia/Brisbane', LanguageLocaleKey= 'en_US', LocaleSidKey='en_AU', 
								ProfileId='00e90000000bbgXAAQ',EmailEncodingKey='ISO-8859-1');
		insert user_c;
		
		System.runAs ( user_c ) {
		
			Account acc = new Account(name='testb',company__c='testb',username__c='testb',password__c='testb');
			insert acc;
			
			Contact con = new Contact(FirstName='testb',LastName='testb',Title='Billing',AccountId=acc.id);
			con.MailingStreet='sdfsadfsa\r\ndfsafa\r\nsfsdfsdfs\r\ndfsdfs\r\ndfsdf';
			con.MailingCity='Brisbane';
			con.MailingState='queensland';
			con.MailingPostalCode='4444';
			con.MailingCountry='Australia';
			insert con;
			
			Date today_last_month = Date.today().addMonths(-1);
			Date active_date = Date.today();
			Account_Product__c ap1 = new Account_Product__c(Account__c = acc.Id, Name = 'Adwords Optimised Management',Recurring_Frequency__c=2,  Recurring_Period__c='Weekly', Product_Status__c='Active', pauseat__c = today_last_month, activeat__c = active_date, Product_Price__c = 76.00);
			insert ap1;
			
			Invoice__c invoice1 = new Invoice__c(Account__c = acc.Id, Name = 'Adwords Management', Account_Product__c = ap1.Id, Invoice_Number__c = '00112233',Status__c = 'AUTHORISED',Issue_Date__c=today_last_month, Invoice_Total__c = 100, Amount_Paid__c = 0, Amount_Due__c=100);
			insert invoice1;
			
			Invoice__c invoice2 = new Invoice__c(Account__c = acc.Id, Name = 'Adwords Management', Account_Product__c = ap1.Id, Invoice_Number__c = '00112234',Status__c = 'Paid');
			insert invoice2;
			
			Payment__c payment = new Payment__c(Payment_Date__c = today_last_month, Payment_Type__c = 'Payment', Account__c = acc.Id, Payment_Amount__c = 100, Invoice__c = invoice2.Id);
			insert payment;
			
			Sign_Up__c signup = new Sign_Up__c(Account__c = acc.Id, Completed_Date__C = today_last_month);
			insert signup;
		}		
		
		MonthlyKPI kpi = new MonthlyKPI();	
		Test.stopTest();	
	}
	
	
}