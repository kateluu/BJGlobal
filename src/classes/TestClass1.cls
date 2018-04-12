@istest
private class TestClass1 {

    @istest
    static void SLXDDInvoiceBatchTest() {
		Test.startTest();

		Account a = new Account();
        a.Name = 'TestAccount';
	    a.username__c           = 'username';
	    a.password__c           = 'psw';
	    a.Payment_Option__c     ='Other';
	    a.Card_Year_Expiry__c   ='2014';
	    a.Card_Number__c        ='123456789';
	    a.Card_Month_Expiry__c  ='01';
	    a.Name_On_Card__c       ='Test';
		a.Send_Invoice__c       = true;
		insert a;
        
        SLX_Product__c p = new SLX_Product__c();
        p.company_name__c = 'SponsoredLinx';
        p.name = 'slx';
        p.product_price__c = 100;
        insert p;
        
        Account_Product__c ap = new Account_Product__c();
        ap.Recurring_Frequency__c = 1;
        ap.Product_Price__c = 19.99;
        ap.Last_Invoice_Date__c = Date.today().addMonths(-1);
        ap.Recurring_Period__c ='Monthly';
        ap.Payment_Option__c = 'Direct Debit';
        ap.Account__c = a.Id;
        ap.SLX_Product__c = p.id;
        insert ap;
        
        Invoice__c invoice = new Invoice__c();
        invoice.Account__c = a.Id;
        invoice.Account_Product__c = ap.Id;
        invoice.Amount_Due__c =10;
        invoice.Amount_Paid__c = 0;
        invoice.Due_Date__c  = Date.today();
        invoice.Issue_Date__c  = Date.today();
        invoice.Reference__c = '12344';
        invoice.Invoice_Number__c = '00000001';
        invoice.Payment_Option__c = 'Direct Debit';
        invoice.Status__c = 'AUTHORISED';
        insert invoice;
		
		SLXDDInvoiceBatch scriptBatch = new SLXDDInvoiceBatch('Today');
		ID batchprocessid = Database.executeBatch(scriptBatch, 10);
		
		Test.stopTest();
	}
	
	@istest
	static void GMTDDInvoiceBatchTest() {
		Test.startTest();
		
		Account a = new Account();
        a.Name = 'TestAccount';
	    a.username__c           = 'username';
	    a.password__c           = 'psw';
	    a.Payment_Option__c     ='Other';
	    a.Card_Year_Expiry__c   ='2014';
	    a.Card_Number__c        ='123456789';
	    a.Card_Month_Expiry__c  ='01';
	    a.Name_On_Card__c       ='Test';
		a.Send_Invoice__c       = true;
		insert a;
		
		SLX_Product__c p = new SLX_Product__c();
        p.company_name__c = 'Get More Traffic';
        p.name = 'gmt';
        p.product_price__c = 100;
        insert p;
        
        Account_Product__c ap = new Account_Product__c();
        ap.Recurring_Frequency__c = 1;
        ap.Product_Price__c = 19.99;
        ap.Last_Invoice_Date__c = Date.today().addMonths(-1);
        ap.Recurring_Period__c ='Monthly';
        ap.Payment_Option__c = 'Direct Debit';
        ap.Account__c = a.Id;
        ap.SLX_Product__c = p.id;
        insert ap;
        
        Invoice__c invoice = new Invoice__c();
        invoice.Account__c = a.Id;
        invoice.Account_Product__c = ap.Id;
        invoice.Amount_Due__c =10;
        invoice.Amount_Paid__c = 0;
        invoice.Due_Date__c  = Date.today();
        invoice.Issue_Date__c  = Date.today();
        invoice.Reference__c = '12344';
        invoice.Invoice_Number__c = '00000001';
        invoice.Payment_Option__c = 'Direct Debit';
        invoice.Status__c = 'AUTHORISED';
        insert invoice;
        
 		GMTDDInvoiceBatch scriptBatch = new GMTDDInvoiceBatch('Today');
		ID batchprocessid = Database.executeBatch(scriptBatch, 10);
		
		Test.stopTest();
	}
	
	@istest
	static void SLXEwayInvoiceBatchTest() {
		Test.startTest();
		
		Account a = new Account();
        a.Name = 'TestAccount';
	    a.username__c           = 'username';
	    a.password__c           = 'psw';
	    a.Payment_Option__c     ='Other';
	    a.Card_Year_Expiry__c   ='2014';
	    a.Card_Number__c        ='123456789';
	    a.Card_Month_Expiry__c  ='01';
	    a.Name_On_Card__c       ='Test';
		a.Send_Invoice__c       = true;
		insert a;
		
		SLX_Product__c p = new SLX_Product__c();
        p.company_name__c = 'SponsoredLinx';
        p.name = 'slx';
        p.product_price__c = 100;
        insert p;
        
        Account_Product__c ap = new Account_Product__c();
        ap.Recurring_Frequency__c = 1;
        ap.Product_Price__c = 19.99;
        ap.Last_Invoice_Date__c = Date.today().addMonths(-1);
        ap.Recurring_Period__c ='Weekly';
        ap.Payment_Option__c = 'Eway';
        ap.Account__c = a.Id;
        ap.SLX_Product__c = p.id;
        insert ap;
        
        Integer[] dueDays = new List<Integer>{0, -3, -5, -9, -13};
        for(integer i : dueDays) {
        	Invoice__c invoice = new Invoice__c();
	        invoice.Account__c = a.Id;
	        invoice.Account_Product__c = ap.Id;
	        invoice.Amount_Due__c =10;
	        invoice.Amount_Paid__c = 0;
	        invoice.Due_Date__c  = Date.today().addDays(i);
	        invoice.Issue_Date__c  = invoice.Due_Date__c;
	        invoice.Reference__c = String.valueof(i);
	        invoice.Invoice_Number__c = invoice.Reference__c;
	        invoice.Payment_Option__c = 'Eway';
	        invoice.Status__c = 'AUTHORISED';
	        insert invoice;
        }
        
        String[] periods = new list<String> {'Today', '3 Day', '5 Day', '9 Day', '13 Day'};
        String[] companyNames = new list<String> {'SponsoredLinX'};
		
		for(string companyName : companyNames) {
			for(string period : periods) {
				batchInvoiceCreateBatch batch = new batchInvoiceCreateBatch(period, companyName);
				ID batchId = Database.executeBatch(batch,10);
			}
		}
		
		Test.stopTest();
	}
	
	@istest
	static void GMTEwayInvoiceBatchTest() {
		Test.startTest();
		
		Account a = new Account();
        a.Name = 'TestAccount';
	    a.username__c           = 'username';
	    a.password__c           = 'psw';
	    a.Payment_Option__c     ='Other';
	    a.Card_Year_Expiry__c   ='2014';
	    a.Card_Number__c        ='123456789';
	    a.Card_Month_Expiry__c  ='01';
	    a.Name_On_Card__c       ='Test';
		a.Send_Invoice__c       = true;
		insert a;
		
		SLX_Product__c p = new SLX_Product__c();
        p.company_name__c = 'Get More Traffic';
        p.name = 'gmt';
        p.product_price__c = 100;
        insert p;
        
        Account_Product__c ap = new Account_Product__c();
        ap.Recurring_Frequency__c = 1;
        ap.Product_Price__c = 19.99;
        ap.Last_Invoice_Date__c = Date.today().addMonths(-1);
        ap.Recurring_Period__c ='Weekly';
        ap.Payment_Option__c = 'Eway';
        ap.Account__c = a.Id;
        ap.SLX_Product__c = p.id;
        insert ap;
        
        Integer[] dueDays = new List<Integer>{0, -3, -5, -9, -13};
        for(integer i : dueDays) {
        	Invoice__c invoice = new Invoice__c();
	        invoice.Account__c = a.Id;
	        invoice.Account_Product__c = ap.Id;
	        invoice.Amount_Due__c =10;
	        invoice.Amount_Paid__c = 0;
	        invoice.Due_Date__c  = Date.today().addDays(i);
	        invoice.Issue_Date__c  = invoice.Due_Date__c;
	        invoice.Reference__c = String.valueof(i);
	        invoice.Invoice_Number__c = invoice.Reference__c;
	        invoice.Payment_Option__c = 'Eway';
	        invoice.Status__c = 'AUTHORISED';
	        insert invoice;
        }
        
        String[] periods = new list<String> {'Today', '3 Day', '5 Day', '9 Day', '13 Day'};
        String[] companyNames = new list<String> {'Get More Traffic', 'Get More Traffic New Zealand'};
				
		for(string companyName : companyNames) {
			for(string period : periods) {
				GMTInvoiceBatch batch = new GMTInvoiceBatch(period, companyName);
				ID batchId = Database.executeBatch(batch,10);
			}
		}
		
		Test.stopTest();
	}
	
	@istest
	static void SLXNZInvoiceBatchTest() {
		Test.startTest();
		
		Account a = new Account();
        a.Name = 'TestAccount';
	    a.username__c           = 'username';
	    a.password__c           = 'psw';
	    a.Payment_Option__c     ='Other';
	    a.Card_Year_Expiry__c   ='2014';
	    a.Card_Number__c        ='123456789';
	    a.Card_Month_Expiry__c  ='01';
	    a.Name_On_Card__c       ='Test';
		a.Send_Invoice__c       = true;
		insert a;
		
		SLX_Product__c p = new SLX_Product__c();
        p.company_name__c = 'SponsoredLinX New Zealand';
        p.name = 'slxnz';
        p.product_price__c = 100;
        p.CurrencyIsoCode = 'NZD';
        insert p;
        
        Account_Product__c ap = new Account_Product__c();
        ap.Recurring_Frequency__c = 1;
        ap.Product_Price__c = 19.99;
        ap.Last_Invoice_Date__c = Date.today().addMonths(-1);
        ap.Recurring_Period__c ='Weekly';
        ap.Payment_Option__c = 'Eway';
        ap.Account__c = a.Id;
        ap.SLX_Product__c = p.id;
        insert ap;
        
        Integer[] dueDays = new List<Integer>{0, -3, -5, -9, -13};
        for(integer i : dueDays) {
        	Invoice__c invoice = new Invoice__c();
	        invoice.Account__c = a.Id;
	        invoice.Account_Product__c = ap.Id;
	        invoice.Amount_Due__c =10;
	        invoice.Amount_Paid__c = 0;
	        invoice.Due_Date__c  = Date.today().addDays(i);
	        invoice.Issue_Date__c  = invoice.Due_Date__c;
	        invoice.Reference__c = String.valueof(i);
	        invoice.Invoice_Number__c = invoice.Reference__c;
	        invoice.Payment_Option__c = 'Eway';
	        invoice.Status__c = 'AUTHORISED';
	        insert invoice;
        }
        
        String[] periods = new list<String> {'Today', '3 Day', '5 Day', '9 Day', '13 Day'};
				
		for(string period : periods) {
			SLXNZInvoiceBatch batch = new SLXNZInvoiceBatch(period);
			ID batchId = Database.executeBatch(batch,10);
		}
		
		Test.stopTest();
	}
	
	@istest
	static void generateSLXDDInvoiceBatchScheduleTest() {
		String scheduleTime = '0 0 0 ? * MON-SUN';
		System.schedule('generateSLXDDInvoiceBatchSchedule', scheduleTime, new generateSLXDDInvoiceBatchSchedule());
	}
	
	@istest
	static void generateGMTDDInvoiceBatchScheduleTest() {
		String scheduleTime = '0 0 0 ? * MON-SUN';
		System.schedule('generateGMTDDInvoiceBatchSchedule', scheduleTime, new generateGMTDDInvoiceBatchSchedule());
	}
	
	@istest
	static void GenerateWeeklyOpportunitySchedulerTest() {
		String scheduleTime = '0 0 0 ? * MON-SUN';
		System.schedule('GenerateWeeklyOpportunityScheduler', scheduleTime, new GenerateWeeklyOpportunityScheduler());
	}
	
	@istest
	static void GenerateDailyStatsSchedulerTest() {
		String scheduleTime = '0 0 0 ? * MON-SUN';
		System.schedule('GenerateDailyStatsScheduler', scheduleTime, new DailyStatsSchedular());
	}
	
	@istest
	static void SLXNZInvoiceBatchScheduleTest() {
		String scheduleTime = '0 0 0 ? * MON-SUN';
		System.schedule('SLXNZInvoiceBatchSchedule', scheduleTime, new SLXNZInvoiceBatchSchedule());
	}

	@istest
	static void CaseUpdateTriggerTest() {
		account acc = new account();
    	acc.name = 'test';
    	insert acc;
    	
    	Cases__c c = new Cases__c();
    	c.Account__c = acc.id;
    	c.Daily_Budget__c = 10;
    	c.status__c = 'New';
    	c.X2012_Action_Taken_to_Save__c = 'NA';
    	insert c;
    	
    	c.Account_Resolution__c = 'Cancellation';
    	c.Status__c = 'Unresolved';
    	c.Have_Confirmed_to_Turn_Off_AdWords_Acct__c = true;
    	c.Cancellation_Date__c = null;
    	update c;
	}
	
	@istest
	public static void testdailyBatchPaymentsProcess() {
		Account a = new Account();
	    a.Name = 'TestAccount';
	    a.username__c           = 'username';
	    a.password__c           = 'psw';
	    a.Payment_Option__c     ='Other';
	    a.Card_Year_Expiry__c   ='2014';
	    a.Card_Number__c        ='123456789';
	    a.Card_Month_Expiry__c  ='01';
	    a.Name_On_Card__c       ='Test';
		a.Send_Invoice__c       = true;
		insert a;
		
		SLX_Product__c p = new SLX_Product__c();
	    p.company_name__c = 'SponsoredLinx';
	    p.name = 'slx';
	    p.product_price__c = 100;
	    insert p;
	    
	    Account_Product__c ap = new Account_Product__c();
	    ap.Recurring_Frequency__c = 1;
	    ap.Product_Price__c = 20;
	    ap.Last_Invoice_Date__c = Date.today().addMonths(-1);
	    ap.Recurring_Period__c ='Weekly';
	    ap.Payment_Option__c = 'Eway';
	    ap.Account__c = a.Id;
	    ap.SLX_Product__c = p.id;
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
	    
	    Invoice__c[] insertInvoices = new LIst<Invoice__c>();
	    for(String period : dueDays.keyset()) {
	    	Invoice_Batch__c batch = new Invoice_Batch__c();
		    batch.Name = 'SLX ' + DateTime.now().format('EEEE yyyy-MM-dd') + ' ' + period + ' Invoice Batch';
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
	        invoice.Amount_Paid__c = 0;
	        invoice.Due_Date__c  = Date.today().addDays(dueDays.get(period));
	        invoice.Issue_Date__c  = invoice.Due_Date__c;
	        invoice.Reference__c = String.valueof(dueDays.get(period));
	        invoice.Invoice_Number__c = invoice.Reference__c;
	        invoice.Payment_Option__c = 'Eway';
	        invoice.Status__c = 'AUTHORISED';
	        invoice.Invoice_Batch__c = batch.Id;
	        insertInvoices.add(invoice);
	    }
	    insert insertInvoices;
	    
	    Test.startTest();
		for(string period : dueDays.keyset()) {
			dailyBatchPaymentsProcess batch = new dailyBatchPaymentsProcess(period, 'SponsoredLinX');
			ID batchId = Database.executeBatch(batch,10);
		}
	    Test.stopTest();
    }
    
    @istest
    public static void testGMTDailyPayments() {
		Account a = new Account();
	    a.Name = 'TestAccount';
	    a.username__c           = 'username';
	    a.password__c           = 'psw';
	    a.Payment_Option__c     ='Other';
	    a.Card_Year_Expiry__c   ='2014';
	    a.Card_Number__c        ='123456789';
	    a.Card_Month_Expiry__c  ='01';
	    a.Name_On_Card__c       ='Test';
		a.Send_Invoice__c       = true;
		insert a;
		
		SLX_Product__c p = new SLX_Product__c();
	    p.company_name__c = 'Get More Traffic';
	    p.name = 'gmt';
	    p.product_price__c = 100;
	    insert p;
	    
	    Account_Product__c ap = new Account_Product__c();
	    ap.Recurring_Frequency__c = 1;
	    ap.Product_Price__c = 20;
	    ap.Last_Invoice_Date__c = Date.today().addMonths(-1);
	    ap.Recurring_Period__c ='Weekly';
	    ap.Payment_Option__c = 'Eway';
	    ap.Account__c = a.Id;
	    ap.SLX_Product__c = p.id;
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
	    
	    Invoice__c[] insertInvoices = new LIst<Invoice__c>();
	    for(String period : dueDays.keyset()) {
	    	Invoice_Batch__c batch = new Invoice_Batch__c();
		    batch.Name = 'GMT ' + DateTime.now().format('EEEE yyyy-MM-dd') + ' ' + period + ' Invoice Batch';
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
	        invoice.Amount_Paid__c = 0;
	        invoice.Due_Date__c  = Date.today().addDays(dueDays.get(period));
	        invoice.Issue_Date__c  = invoice.Due_Date__c;
	        invoice.Reference__c = String.valueof(dueDays.get(period));
	        invoice.Invoice_Number__c = invoice.Reference__c;
	        invoice.Payment_Option__c = 'Eway';
	        invoice.Status__c = 'AUTHORISED';
	        invoice.Invoice_Batch__c = batch.Id;
	        insertInvoices.add(invoice);
	    }
	    insert insertInvoices;
	    
	    Test.startTest();
		for(string period : dueDays.keyset()) {
			GMTPaymentBatch batch = new GMTPaymentBatch(period);
			ID batchId = Database.executeBatch(batch,10);
		}
	    Test.stopTest();
    }
    
    @istest
    public static void testSLXNZDailyPayments() {
		Account a = new Account();
	    a.Name = 'TestAccount';
	    a.username__c           = 'username';
	    a.password__c           = 'psw';
	    a.Payment_Option__c     ='Other';
	    a.Card_Year_Expiry__c   ='2014';
	    a.Card_Number__c        ='123456789';
	    a.Card_Month_Expiry__c  ='01';
	    a.Name_On_Card__c       ='Test';
		a.Send_Invoice__c       = true;
		insert a;
		
		SLX_Product__c p = new SLX_Product__c();
	    p.company_name__c = 'SponsoredLinX New Zealand';
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
	    
	    Invoice__c[] insertInvoices = new LIst<Invoice__c>();
	    for(String period : dueDays.keyset()) {
	    	Invoice_Batch__c batch = new Invoice_Batch__c();
		    batch.Name = 'SLX NZ ' + DateTime.now().format('EEEE yyyy-MM-dd') + ' ' + period + ' Invoice Batch';
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
	        invoice.Amount_Paid__c = 0;
	        invoice.Due_Date__c  = Date.today().addDays(dueDays.get(period));
	        invoice.Issue_Date__c  = invoice.Due_Date__c;
	        invoice.Reference__c = String.valueof(dueDays.get(period));
	        invoice.Invoice_Number__c = invoice.Reference__c;
	        invoice.Payment_Option__c = 'CommWeb';
	        invoice.Status__c = 'AUTHORISED';
	        invoice.Invoice_Batch__c = batch.Id;
	        insertInvoices.add(invoice);
	    }
	    insert insertInvoices;
	    
	    Test.startTest();
		for(string period : dueDays.keyset()) {
			SLXNZPaymentBatch batch = new SLXNZPaymentBatch(period);
			ID batchId = Database.executeBatch(batch,10);
		}
	    Test.stopTest();
    }

	@istest
    public static void testSignUpAssignToTeamTrigger() {
    	account acc = new account();
    	acc.name = 'test';
    	insert acc;
    	
    	Sign_Up__c s = new Sign_Up__c();
		s.Name = 'Fred';
		s.Account__c = acc.Id;
		s.Product_Family__c='AdWords';
		s.Product_Package__c='Standard Package';
		s.Product_Type__c = 'AdWords Management';
		s.Assign_to_Team__c = 'Team A';
 		insert s;
 		
 		Sign_Up_note__c signupnote = new Sign_up_note__c();
 		signupnote.Sign_Up__c = s.id;
 		signupnote.contact_person__c = 'test';
 		signupnote.Agreed_daily_budget__c = 50;
 		signupnote.Agreed_target_locations__c = 'Brisbane';
 		signupnote.Areas_covered_in_healthcheck__c = 'ctr';
 		signupnote.Campaign_start_date__c = Date.today();
 		signupnote.Current_adwords_account__c = '123234234';
 		signupnote.Adwords_Id__c = '000-000-0000';
    	signupnote.Current_daily_budget__c = 40;
    	signupnote.Healthcheck_done__c = true;
    	signupnote.How_would_you_best_describe_the_client__c = 'assertive';
    	signupnote.Industry__c = 'Accounting';
    	signupnote.Position_in_the_company__c = 'gm';
    	signupnote.What_two_areas_are_most_important_to_cli__c = 'More sales and leads';
    	insert signupnote;
    	
    	s.status__c = 'Pending CM Call';
    	update s;
    }
    
    @istest
    static void CheckInvoiceBatchTest() {
		String scheduleTime = '0 0 0 ? * MON-SUN';
		System.schedule('testCheckInvoiceBatch', scheduleTime, new CheckInvoiceBatchScheduler());
	}

	
}