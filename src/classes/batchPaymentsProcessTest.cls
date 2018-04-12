@isTest
private class batchPaymentsProcessTest {
	
	@istest
    public static void testbatchPaymentsProcess() {

        // Load payment gateway config
        // Eway2
        insert new PaymentGateway__c(
            Name                = 'Eway Rapid SLX AU',
            MerchantURL__c      = 'https://example.com',
            Access_Code__c      = 'exampleaccesscode',
            Password__c         = 'examplepassword'
        );

        // Commweb 1
        insert new PaymentGateway__c(
            Name                = 'Sponsoredlinx NZ',
            MerchantURL__c      = 'https://example.com',
            Access_Code__c      = 'exampleaccesscode',
            Operation_ID__c     = 'exampleopid',
            Password__c         = 'examplepassword'
        );

        insert new PaymentGateway__c(
            Name                = 'Sponsoredlinx NZ Test',
            MerchantURL__c      = 'https://example.com',
            Access_Code__c      = 'exampleaccesscode',
            Operation_ID__c     = 'exampleopid',
            Password__c         = 'examplepassword'
        );

        // Commweb2
        insert new PaymentGateway__c(
            Name                = 'Commweb GMT NZ',
            MerchantURL__c      = 'https://example.com',
            Access_Code__c      = 'exampleaccesscode',
            Operation_ID__c     = 'exampleopid',
            Password__c         = 'examplepassword'
        );

        // Setup companies
        Company__c company = new Company__c(
            Name = 'Get More Traffic New Zealand',
            Business_Name__c = 'GMT New Zealand',
            Checkout_Site__c = 'checkout_GMT',
            Payment_Gateway__c = 'Commweb2',
            CurrencyIsoCode  = 'NZD'
        );
        insert company;

		Account a = new Account();
	    a.Name = 'TestAccount';
	    a.username__c           = 'username';
	    a.password__c           = 'psw';
	    a.Payment_Option__c     = 'Other';
	    a.Card_Year_Expiry__c   = '2014';
	    a.Card_Number__c        = '123456789';
	    a.Card_Month_Expiry__c  = '01';
	    a.Card_CVN__c 			= '123';
	    a.Name_On_Card__c       = 'Test';
		a.Send_Invoice__c       = true;
		a.CurrencyIsoCode 		='NZD';
		insert a;

        List<Contact> newContacts = new List<Contact>();
        for (String contact_type : new List<String> {'Billing','Reports','Marketing'}){
            newContacts.add( 
                new Contact(
                    FirstName         = 'Steve',
                    LastName          = 'Existingclient',
                    AccountId         = a.Id,
                    Phone             = '0407040404',
                    Email             = 'test@example.com',
                    Title             = contact_type
                )
            );
        }
        insert newContacts;

		SLX_Product__c p = new SLX_Product__c();
	    p.company_name__c = 'Get More Traffic New Zealand';
	    p.name = 'gmt';
	    p.product_price__c = 100;
	    p.CurrencyIsoCode = 'NZD';
	    insert p;
	    
	    Account_Product__c ap = new Account_Product__c();
	    ap.Recurring_Frequency__c = 1;
	    ap.Product_Price__c = 20;
	    ap.Last_Invoice_Date__c = Date.today().addMonths(-1);
	    ap.Recurring_Period__c ='Weekly';
	    ap.Payment_Option__c = 'CommWeb';
	    ap.Account__c = a.Id;
	    ap.SLX_Product__c = p.id;
	    ap.CurrencyIsoCode ='NZD';
	    insert ap;
	    
	    Credit__c credit = new Credit__c();
	    credit.Account_Product__c = ap.Id;
	    credit.Amount__c = 50;
	    credit.Credit_Used__c = 0;
	    insert credit;
	    
	    Map<String, Integer> dueDays = new Map<String, Integer>();
	    dueDays.put('Today', 0);
	    dueDays.put('3 Day', -3);
	    dueDays.put('5 Day', -5);
	    dueDays.put('9 Day', -9);
	    dueDays.put('13 Day', -13);
	    
	    Invoice__c[] insertInvoices = new List<Invoice__c>();
	    for(String period : dueDays.keyset()) {
	    	Invoice_Batch__c batch = new Invoice_Batch__c();
		    batch.Name = 'GMT NZ ' + DateTime.now().format('EEEE yyyy-MM-dd') + ' ' + period + ' Invoice Batch';
		    batch.Batch_Date__c = Date.today();
		    batch.Batch_Type__c = 'Invoices';
		    batch.Status__c = 'Batch Approved';
		    batch.Batch_Processed__c = 'No';
		    batch.Batch_Period__c = period;
		    insert batch;
		    
		    Invoice__c invoice = new Invoice__c();
	        invoice.Account__c = a.Id;
	        invoice.Account_Product__c = ap.Id;
	        invoice.Amount_Due__c =20;
	        invoice.CurrencyIsoCode ='NZD';
	        invoice.Amount_Paid__c = 0;
	        invoice.Due_Date__c  = Date.today().addDays(dueDays.get(period));
	        invoice.Issue_Date__c  = invoice.Due_Date__c;
	        invoice.Reference__c = String.valueof(dueDays.get(period));
	        invoice.Invoice_Number__c = invoice.Reference__c;
	        invoice.Payment_Option__c = 'Commweb';
	        invoice.Status__c = 'AUTHORISED';
	        invoice.Invoice_Batch__c = batch.Id;
	        insertInvoices.add(invoice);
	    }
	    insert insertInvoices;
	    
	    Test.startTest();
	    // Set to test mode so it doesn't do webservice callouts
	    batchPaymentsProcess.isTest = true;
		for(string period : dueDays.keyset()) {
			batchPaymentsProcess batch = new batchPaymentsProcess(period, 'Get More Traffic New Zealand');
			ID batchId = Database.executeBatch(batch,10);
		}
	    Test.stopTest();
    }
	
}