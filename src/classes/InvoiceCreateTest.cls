global class InvoiceCreateTest implements Database.batchable<Account_Product__c>,Database.AllowsCallouts, Database.Stateful {
	global String emailBody= '';
	
	global Iterable<Account_Product__c> start(Database.batchableContext info) {
		System.debug('Start getting Account Products!!!!');
		return new InvoiceCreateIterator();
	}
 
	global void execute(Database.batchableContext info, List<Account_Product__c> scope) {
		System.debug('Scope: ' + scope);
		Integer invoice_count = 0;
		
		//List<Invoice__c> newInvoices  = new List<Invoice__c>();
		List<Account_Product__c> accountproducts = new List<Account_Product__c>();
		for(Account_Product__c accountproduct : scope){
			//recursive account product
			if(accountproduct.Recurring_Period__c != null && accountproduct.Recurring_Period__c != '' 
														 	&& accountproduct.Recurring_Period__c != 'N/A'){
      			System.debug(accountproduct);
      			Date invoice_date = accountproduct.Last_Invoice_Date__c;
      			String recurring_period = accountproduct.Recurring_Period__c;
		      	//create new invoice
	      		if(invoice_date!= null){
	      			//if product was temporailiy paused.
	      			if(accountproduct.activeat__c!=null && invoice_date < accountproduct.activeat__c
	      												&& accountproduct.pauseat__c < Date.today()){
	      				if(recurring_period == 'Weekly'){
	      					invoice_date = accountproduct.activeat__c.addDays(7);
	      				}else{
	      					invoice_date = accountproduct.activeat__c;
	      				}
	      			}else{
		      			if(recurring_period == 'Weekly')            	invoice_date = invoice_date.addDays(7);
			      		else if (recurring_period == 'Fortnightly') 	invoice_date = invoice_date.addDays(14);
			      		else if (recurring_period == 'Monthly')     	invoice_date = invoice_date.addMonths(1);
			      		else if (recurring_period == 'Quarterly')   	invoice_date = invoice_date.addMonths(3);
			      		else if (recurring_period == 'Half Yearly')   	invoice_date = invoice_date.addMonths(6);
			      		else if (recurring_period == 'Yearly')      	invoice_date = invoice_date.addYears(1);
			      		else if (recurring_period == '2 Yearly')    	invoice_date = invoice_date.addYears(2);
		      		}
	      			System.debug('Invoice_date:'+invoice_date);
	      			
	      			if(invoice_date == date.today()){
	      				try{
		      				//generate new invoice
			      			Invoice__c invoice                  = new Invoice__c();
			      			invoice.Issue_Date__c      		    = date.today();			      			
			      			invoice.Invoice_Total__c      		= accountproduct.Product_Price__c;

			      			if(accountproduct.Account__r.Amex__c == true){
			                    Date myDate = Date.newInstance(2018, 8, 1);
				                if (invoice.Issue_Date__c >= myDate){
				                	// Amex charge change from 1st August 2018				                	
				                    invoice.Invoice_Total__c      	= invoice.Invoice_Total__c*(1+ Decimal.valueof(Pardot_Auto_Convert_Add__c.getValues('Amex Surcharge').value__c)); 				                    
				                    
				                }
				                else{				                	
				                    invoice.Invoice_Total__c        = invoice.Invoice_Total__c*(1+ Decimal.valueof(Pardot_Auto_Convert_Add__c.getValues('Old Amex Surcharge').value__c)); 				                    
				                }
				                invoice.Invoice_Total__c		= invoice.Invoice_Total__c.setScale(2);			      				
			      				invoice.Amex__c				= true;
			      			}
			      			//if(accountproduct.Account__r.Website!= null && accountproduct.Account__r.Website.endsWithIgnoreCase('.nz') == true){
			      			//	invoice.Amount_Due__c      	= invoice.Amount_Due__c / 1.1;
			      			//	invoice.Amount_Due__c		= invoice.Amount_Due__c.setScale(2);
			      			//}
			      			invoice.Amount_Due__c 			= invoice.Invoice_Total__c ;
			      			invoice.Amount_Paid__c          = 0.00;
					      	invoice.Amount_Credited__c      = 0.00;
					      	invoice.Amount_Refunded__c		= 0.00;
					      	//invoice.Issue_Date__c      		= date.today();
					      	invoice.CurrencyIsoCode         = accountproduct.CurrencyIsoCode;
			      			if(accountproduct.Payment_Option__c == null) throw new myException('Oops');
			      			else if(accountproduct.Payment_Option__c == 'Eway' || accountproduct.Payment_Option__c == 'Commweb' || accountproduct.Payment_Option__c == 'Direct Debit')      invoice.Due_Date__c = date.today();
			      			else if (accountproduct.Payment_Option__c == 'Cheque')   invoice.Due_Date__c = date.today().addDays(7);
			      			else 													 invoice.Due_Date__c = date.today().addDays(3); 
			      			// populate payment option field when invoice is created. Added on 16/01/2017
			      			invoice.Payment_Option__c       = accountproduct.Payment_Option__c;
			      			invoice.Account__c         		= accountproduct.Account__r.ID;
			      			invoice.Account_Product__c 		= accountproduct.Id;
			      			invoice.Reference__c       		= accountproduct.Account__r.Unique_Id__c;
			      			invoice.Name               		= accountproduct.Account__r.Name;
			      			if(accountproduct.No_Charge__c == true){
			      				invoice.Status__c               = 'NO CHARGE';
			      			}else{
			      				invoice.Status__c               = 'AUTHORISED';
			      			}
			      			//emailBody += 'Invoice Successfully Created';						      			
		      				invoice_count++;
		      				
			      			insert invoice;
			      			//update invoice number
			      			Invoice__c updateInvoice = [SELECT Id, Invoice_Number__c, Salesforce_Invoice_Number__c FROM Invoice__c WHERE Id=:invoice.Id];
	  						String invoice_number    = updateInvoice.Salesforce_Invoice_Number__c;
	  						updateInvoice.Invoice_Number__c = invoice_number;
	  						update updateInvoice;
	  					
	  						
	  						// set account product last invoice date and invoice number
			      			accountproduct.Last_Invoice_Date__c   = date.today();
			      			accountproduct.Last_Invoice_Number__c = invoice_number;
			      			accountproducts.add(accountproduct);
			      			
			      			//Apply credit automatically after an invoice is created
			      			list<Credit__c> RelatedCredits = new list<Credit__c>();
			      			RelatedCredits = [SELECT Id, Name, Account__c, Account_Product__c, Credit_Used__c, Credit_Left__c, Amount__c, Valid_From__c FROM Credit__c WHERE Account_Product__c=:accountproduct.Id AND Valid_From__c <=:invoice.Issue_Date__c  AND Credit_Left__c > 0];
			        		for(Credit__c thisRelatedCredit : RelatedCredits){
			        			Payment__c CreditPayment = new Payment__c();
			        			CreditPayment.Account__c = invoice.Account__c;
								CreditPayment.Invoice_Reference__c = invoice_number;
								CreditPayment.Payment_Reference__c = 'Credit from Credit ID - '+String.valueOf(thisRelatedCredit.Name);
								CreditPayment.Credit__c = thisRelatedCredit.Id;
								CreditPayment.Invoice_Number__c = invoice_number;
								CreditPayment.Payment_Name__c = 'Credit Payment';
								CreditPayment.Payment_Date__c = Date.today();
								CreditPayment.Invoice__c = invoice.Id;
								CreditPayment.Payment_Type__c = 'Credit';
								CreditPayment.Account_Product__c = accountproduct.Id;
								CreditPayment.Payment_Owner__c = accountproduct.OwnerId;
								
								decimal CreditLeft = thisRelatedCredit.Credit_Left__c;
								decimal InvoiceAmountDue = invoice.Amount_Due__c;
								decimal InvoiceAmountPaid = invoice.Amount_Paid__c;
								decimal CreditUsed = thisRelatedCredit.Credit_used__c;
								decimal InvoiceAmountCredited = invoice.Amount_Credited__c;
							
								if(CreditLeft >= InvoiceAmountDue){
									CreditLeft = CreditLeft - InvoiceAmountDue;
									CreditPayment.Payment_Amount__c = InvoiceAmountDue;
									CreditUsed = CreditUsed + InvoiceAmountDue;
									InvoiceAmountDue = 0;
									InvoiceAmountPaid = InvoiceAmountPaid + CreditPayment.Payment_Amount__c;
									InvoiceAmountCredited = InvoiceAmountCredited + CreditPayment.Payment_Amount__c;
									invoice.Status__c = 'CREDITED';
								} 
								else {
									InvoiceAmountDue = InvoiceAmountDue - CreditLeft;
									CreditPayment.Payment_Amount__c = CreditLeft;
									CreditUsed = CreditUsed + CreditLeft;
									CreditLeft = 0;
									InvoiceAmountPaid = InvoiceAmountPaid + CreditPayment.Payment_Amount__c;
									InvoiceAmountCredited = InvoiceAmountCredited + CreditPayment.Payment_Amount__c;
									invoice.Status__c = 'PARTIALLY CREDITED';
								}
							
								invoice.Amount_Due__c = InvoiceAmountDue;
								invoice.Amount_Paid__c = InvoiceAmountPaid;
								invoice.Amount_Credited__c = InvoiceAmountCredited;
								
								Credit__c updateCredit = new Credit__c();
								updateCredit = [SELECT Id,Credit_Used__c FROM Credit__c WHERE Id=:thisRelatedCredit.Id][0];
								updateCredit.Credit_Used__c = CreditUsed;
								update updateCredit;
								if(CreditPayment.Payment_Amount__c > 0) {
									insert CreditPayment;
								}
								System.debug('Before invoice update');
								update invoice;
								System.debug('After invoice update'); 								
			        		}

			      		}catch(Exception e){
	      					System.debug('Exception:'+e.getStackTraceString());
	      					if(e.getMessage()=='Oops'){
	      						emailBody += '<p>[Error] Unable to create invoice, no payment method attached. Please check account product: <a href=https://ap1.salesforce.com/' + accountproduct.Id +'>'+accountproduct.Name+'</a>.</p>';}
	      					else 
	      					 	emailBody += '<p>[Error] Unable to create invoice, please check account product: <a href=https://ap1.salesforce.com/' + accountproduct.Id +'>'+accountproduct.Name+'</a>. Error Message: '+e.getStackTraceString()+ '/' +e.getCause() +'.</p> ';
      					}
		      		}else if(invoice_date < date.today()){
		      			emailBody += '<p>[Notice] Either Last Invoice Date or Product Status is not accurate, please check account product: <a href=https://ap1.salesforce.com/' + accountproduct.Id +'>'+accountproduct.Name+'</a>.</p> ';
      				}
	      		}else{
	      			System.debug('<p>[Error] This account product does not have last invoice date. ID: '+ accountproduct.Id);
	      			emailBody += '<p>[Error] This recurrsive account product does not have last invoice date, please check account product: <a href=https://ap1.salesforce.com/' + accountproduct.Id +'>'+accountproduct.Name+'</a>.</p> ';
      			} 
      		}
      		else{
      			emailBody += '<p>[Notice] Incorrect recurring period, please check account product: <a href=https://ap1.salesforce.com/' + accountproduct.Id +'>'+accountproduct.Name+'</a>.</p>';
      		}
      	}
      	
   		System.debug('Updating account products');
   		try{
			//update account products ;
			update accountproducts;
   		}catch(Exception e){
	   		System.debug('Exception:'+e.getMessage());
	   		emailBody += '[Error] Unable to update batch of account products</a>. Error Message: '+e.getStackTraceString()+ '/' +e.getCause() + '.</p>';
      	}
    }
	

	global void finish(Database.batchableContext info){
		System.debug('EmailBody: '+emailBody);
	 	if(this.emailBody != ''){
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses   = new String[] {'grace.james@sponsoredlinx.com','william.zhang@sponsoredlinx.com'};
			String[] ccAddresses   = new String[] {'kate.luu@sponsoredlinx.com'};
			
			mail.setToAddresses(toAddresses);
			mail.setCCAddresses( ccAddresses);
			mail.setSenderDisplayName(Date.today().format());
			mail.setSubject('Daily Invoice Generation Summary');
			mail.setBccSender(false);
			mail.setUseSignature(false);
			mail.setHtmlBody(emailBody);
	   		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}	
		
	}
	
	
	public static testMethod void testBatch() {
        Test.startTest();
        InvoiceCreateTest scriptBatch = new InvoiceCreateTest();
        //ID batchprocessid = Database.executeBatch(scriptBatch,10);
        
        Account account = new Account();
		account.Name = 'Test Account11';
		account.Company__c = 'SponsoredLinX';
		account.username__c = 'test11d11@test.com';
		account.password__c = 'test';
		insert account;
        
        Account_Product__c ap = new Account_Product__c();
        ap.Last_Invoice_Date__c = Date.today().addDays(-7);
        ap.Recurring_Frequency__c = 1;
        //ap.pauseat__c = Date.today();
        ap.Product_Price__c = 19.99;
        ap.Recurring_Period__c ='Weekly';
        ap.Payment_Option__c = 'Eway';
        ap.Account__c = account.Id;
        insert ap;
        
        Credit__c testCre = new Credit__c();
	    //testCre.Account__c = testAc.Id;
	    testCre.Amount__c = 100;
	    testCre.Credit_Used__c = 10;
	    testCre.Account__c = account.Id;
	    testCre.Account_Product__c = ap.Id;
		testCre.Valid_From__c = date.today().addDays(-1);
		insert testCre;
       
        
        
        scriptBatch.emailBody = 'test email';
        Database.batchableContext info;
        scriptBatch.start(info);
        List<Account_Product__c> scope = [Select a.pauseat__c, a.cancelat__c, a.activeat__c, a.Trial_End_Date__c, a.Start_Date__c, a.SLX_Product__r.product_recurring__c,
                                a.Send_Invoice__c, a.SLX_Product__c, a.Recurring_Period__c, Account__r.ID, a.Account__r.Payment_Option__c, 
                                a.Account__r.Unique_Id__c,a.Account__r.Name,a.Recurring_Frequency__c, a.Product_Status__c, a.Product_Price__c,
                                a.Product_Package__c, a.Product_Number__c,a.Product_Category__c, a.OwnerId, a.Name_On_Card__c, a.Name, a.Account__r.Amex__c,
                                a.Last_Invoice_Number__c, a.Last_Invoice_Date__c,a.LastModifiedDate, a.Id, a.End_Date__c, a.Description__c,a.Create_Invoice__c,
                                a.Company__c, a.Account__c, a.Payment_Option__c From Account_Product__c a where a.Product_Status__c = 'Active' and a.Account__c!=null 
                                and (a.Recurring_Period__c != null and a.Recurring_Period__c!='N/A')];
        scriptBatch.execute(info, scope);
        scriptBatch.finish(info);
        
        
        
        
        Test.stopTest();
    }
    
    
      public static testMethod void testBatch1() {
        Test.startTest();
        InvoiceCreateTest scriptBatch = new InvoiceCreateTest();
        Account testAc = new Account();
		testAc.Name = 'testacc';
		insert testAc;
      
        Account_Product__c ap = new Account_Product__c();
        ap.Recurring_Frequency__c = 1;
        ap.Product_Price__c = 19.99;
        ap.Last_Invoice_Date__c = Date.today().addDays(-7);
        ap.Recurring_Period__c ='Weekly';
        ap.Payment_Option__c = 'Eway';
        
        insert ap;
        
        
        Credit__c testCre = new Credit__c();
		//testCre.Account__c = testAc.Id;
		testCre.Amount__c = 15;
		testCre.Credit_Used__c = 10;
            
		testCre.Account_Product__c = ap.Id;
		testCre.Valid_From__c = date.today().addDays(-1);
		insert testCre;
    
    
    Contact testContact = new Contact();
      testContact.AccountId = testAc.Id;
      testContact.Title = 'Billing';
      testContact.FirstName = 'test';
      testContact.LastName = 'test';
      
      insert testContact;
        
        
        scriptBatch.emailBody = 'test email';
        Database.batchableContext info;
        scriptBatch.start(info);
        List<Account_Product__c> scope = [Select Id,Recurring_Period__c, Product_Price__c,Payment_Option__c, pauseat__c, activeat__c, Last_Invoice_Date__c, Product_Status__c, Name from Account_Product__c];
        scriptBatch.execute(info, scope);
        scriptBatch.finish(info);
        
        
        
        
        Test.stopTest();
    }
    
    
    
    
     public static testMethod void testBatch2() {
        Test.startTest();
        InvoiceCreateTest scriptBatch = new InvoiceCreateTest();
        ID batchprocessid = Database.executeBatch(scriptBatch,10);
        
        Account_Product__c ap = new Account_Product__c();
        ap.Recurring_Frequency__c = 1;
        ap.Product_Price__c = 19.99;
        ap.Last_Invoice_Date__c = Date.today().addDays(-7);
        ap.Recurring_Period__c ='Weekly';
        ap.Payment_Option__c = 'Eway';
        
        insert ap;
        
        
        scriptBatch.emailBody = 'test email';
        Database.batchableContext info;
        scriptBatch.start(info);
        List<Account_Product__c> scope = [Select Id,Recurring_Period__c, Product_Price__c,Payment_Option__c, activeat__c,pauseat__c, Last_Invoice_Date__c, Product_Status__c, Name from Account_Product__c];
        scriptBatch.execute(info, scope);
        scriptBatch.finish(info);
        
        
        
        
        Test.stopTest();
    }
    
     public static testMethod void testBatch3() {
        Test.startTest();
        InvoiceCreateTest scriptBatch = new InvoiceCreateTest();
        ID batchprocessid = Database.executeBatch(scriptBatch,10);
        
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
		a.Amex__c               = true;
		insert a;
        
        Account_Product__c ap = new Account_Product__c();
        ap.Recurring_Frequency__c = 1;
        ap.Product_Price__c = 19.99;
        ap.Last_Invoice_Date__c = Date.today().addMonths(-1);
        ap.Recurring_Period__c ='Monthly';
        ap.Payment_Option__c = 'Cheque';
        ap.Account__c = a.Id;
        
        insert ap;
        
        
        scriptBatch.emailBody = 'test email';
        Database.batchableContext info;
        scriptBatch.start(info);
        List<Account_Product__c> scope = [Select Id,Recurring_Period__c, Product_Price__c,Payment_Option__c, pauseat__c, activeat__c,Last_Invoice_Date__c, Product_Status__c, Name from Account_Product__c];
        scriptBatch.execute(info, scope);
        scriptBatch.finish(info);
        
        
        
        
        Test.stopTest();
    }
    
      public static testMethod void testBatch4() {
        Test.startTest();
        InvoiceCreateTest scriptBatch = new InvoiceCreateTest();
        ID batchprocessid = Database.executeBatch(scriptBatch,10);
        
        Account a = new Account();
        a.Name = 'TestAccount1';
      a.username__c           = 'username';
      a.password__c           = 'psw';
      a.Payment_Option__c     ='Other';
      a.Card_Year_Expiry__c   ='2014';
      a.Card_Number__c        ='123456789';
      a.Card_Month_Expiry__c  ='01';
      a.Name_On_Card__c       ='Test';
    a.Send_Invoice__c       = true;
    insert a;
        
        Account_Product__c ap = new Account_Product__c();
        ap.Recurring_Frequency__c = 1;
        ap.Product_Price__c = 19.99;
        ap.Last_Invoice_Date__c = null;
        ap.Recurring_Period__c ='Yearly';
        ap.Payment_Option__c = 'Bill Buddy';
        ap.Account__c = a.Id;
        
        insert ap;
        
        
        scriptBatch.emailBody = 'test email';
        Database.batchableContext info;
        scriptBatch.start(info);
        List<Account_Product__c> scope = [Select Id,Recurring_Period__c, Product_Price__c,Payment_Option__c, pauseat__c, Last_Invoice_Date__c, Product_Status__c, Name from Account_Product__c];
        scriptBatch.execute(info, scope);
        scriptBatch.finish(info);
        
        
        
        
        Test.stopTest();
    }
    
    
    public static testMethod void testBatch5() {
        Test.startTest();
        InvoiceCreateTest scriptBatch = new InvoiceCreateTest();
        ID batchprocessid = Database.executeBatch(scriptBatch,10);
        
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
	  a.Amex__c               = false;
	  insert a;
        
        Account_Product__c ap = new Account_Product__c();
        ap.Recurring_Frequency__c = 1;
        ap.Product_Price__c = 19.99;
        ap.Last_Invoice_Date__c = Date.today().addMonths(-1);
        ap.Recurring_Period__c ='2 Yearly';
        ap.Payment_Option__c = 'Cheque';
        ap.Account__c = a.Id;
        
        insert ap;
        
        
        scriptBatch.emailBody = 'test email';
        Database.batchableContext info;
        scriptBatch.start(info);
        List<Account_Product__c> scope = [Select Id,Recurring_Period__c, Product_Price__c,Payment_Option__c, pauseat__c, activeat__c,Last_Invoice_Date__c, Product_Status__c, Name from Account_Product__c];
        scriptBatch.execute(info, scope);
        scriptBatch.finish(info);
        
        
        
        
        Test.stopTest();
    }
    
    public static testMethod void FullCreditForWeeklyProductInvoice() {
    	Test.startTest();
        InvoiceCreateTest scriptBatch = new InvoiceCreateTest();
        
    	Account a = new Account();
        a.Name = 'TestAccount1';
	    a.username__c           = 'username';
	    a.password__c           = 'psw';
	    a.Payment_Option__c     ='Other';
	    a.Card_Year_Expiry__c   ='2014';
	    a.Card_Number__c        ='123456789';
	    a.Card_Month_Expiry__c  ='01';
	    a.Name_On_Card__c       ='Test';
		a.Send_Invoice__c       = true;
		insert a;
    	
    	Account_Product__c ap = new Account_Product__c();
    	ap.name = 'test product';
    	ap.account__c = a.id;
    	ap.product_price__c = 69;
    	ap.Product_Status__c = 'Active';
    	ap.Recurring_Period__c = 'Weekly';
    	ap.Last_Invoice_Date__c = Date.today().addDays(-7);
    	ap.Payment_Option__c = 'Eway';
    	insert ap;
    	
    	Credit__c c = new Credit__c();
    	c.account__c = a.id;
    	c.account_product__c = ap.id;
    	c.amount__c = 100;
    	c.Credit_Used__c = 0;
    	c.valid_from__c = date.today().addDays(-30);
    	insert c;
    	
    	
    	scriptBatch.emailBody = 'test email';
        Database.batchableContext info;
        scriptBatch.start(info);
        List<Account_Product__c> scope = [Select Id,Recurring_Period__c, activeat__c, Product_Price__c,Payment_Option__c, pauseat__c, Last_Invoice_Date__c, Product_Status__c,No_Charge__c, Name, Account__r.Amex__c,Account__r.Unique_Id__c,Account__r.Name, Account__r.website from Account_Product__c];
        scriptBatch.execute(info, scope);
        scriptBatch.finish(info);
       
        Invoice__c[] ivs = [select id, status__c from invoice__c];
       // System.assertEquals(ivs[0].status__c, 'CREDITED');
        
        Test.stopTest();
    }
    
    public static testMethod void PartiallyCreditForWeeklyProductInvoice() {
    	Test.startTest();
        InvoiceCreateTest scriptBatch = new InvoiceCreateTest();
        
    	Account a = new Account();
        a.Name = 'TestAccount1';
	    a.username__c           = 'username';
	    a.password__c           = 'psw';
	    a.Payment_Option__c     ='Other';
	    a.Card_Year_Expiry__c   ='2014';
	    a.Card_Number__c        ='123456789';
	    a.Card_Month_Expiry__c  ='01';
	    a.Name_On_Card__c       ='Test';
		a.Send_Invoice__c       = true;
		insert a;
    	
    	Account_Product__c ap = new Account_Product__c();
    	ap.name = 'test product';
    	ap.account__c = a.id;
    	ap.product_price__c = 69;
    	ap.Product_Status__c = 'Active';
    	ap.Recurring_Period__c = 'Weekly';
    	ap.Last_Invoice_Date__c = Date.today().addDays(-7);
    	ap.Payment_Option__c = 'Eway';
    	insert ap;
    	
    	Credit__c c = new Credit__c();
    	c.account__c = a.id;
    	c.account_product__c = ap.id;
    	c.amount__c = 30;
    	c.Credit_Used__c = 0;
    	c.valid_from__c = date.today().addDays(-30);
    	insert c;
    	
    	
    	scriptBatch.emailBody = 'test email';
        Database.batchableContext info;
        scriptBatch.start(info);
        List<Account_Product__c> scope = [Select Id,Recurring_Period__c, activeat__c, Product_Price__c,Payment_Option__c, pauseat__c, Last_Invoice_Date__c, Product_Status__c,No_Charge__c, Name, Account__r.Amex__c,Account__r.Unique_Id__c,Account__r.Name, Account__r.website from Account_Product__c];
        scriptBatch.execute(info, scope);
        scriptBatch.finish(info);
       
        Invoice__c[] ivs = [select id, status__c from invoice__c];
        //System.assertEquals(ivs[0].status__c, 'PARTIALLY CREDITED');
        
        Test.stopTest();
    }
    
    public static testMethod void NZClientTest() {
    	Test.startTest();
        InvoiceCreateTest scriptBatch = new InvoiceCreateTest();
        
    	Account a = new Account();
        a.Name = 'TestAccount1';
	    a.username__c           = 'username';
	    a.password__c           = 'psw';
	    a.Payment_Option__c     ='Other';
	    a.Card_Year_Expiry__c   ='2014';
	    a.Card_Number__c        ='123456789';
	    a.Card_Month_Expiry__c  ='01';
	    a.Name_On_Card__c       ='Test';
		a.Send_Invoice__c       = true;
		a.website = 'http://www.test.com.nz';
		insert a;
    	
    	Account_Product__c ap = new Account_Product__c();
    	ap.name = 'test product';
    	ap.account__c = a.id;
    	ap.product_price__c = 11;
    	ap.Product_Status__c = 'Active';
    	ap.Recurring_Period__c = 'Weekly';
    	ap.Last_Invoice_Date__c = Date.today().addDays(-7);
    	ap.Payment_Option__c = 'Eway';
    	insert ap;
    	
    	scriptBatch.emailBody = 'test email';
        Database.batchableContext info;
        scriptBatch.start(info);
        List<Account_Product__c> scope = [Select Id,Recurring_Period__c, activeat__c, Product_Price__c,Payment_Option__c, pauseat__c, Last_Invoice_Date__c, Product_Status__c,No_Charge__c, Name, Account__r.Amex__c,Account__r.Unique_Id__c,Account__r.Name, Account__r.website from Account_Product__c];
        scriptBatch.execute(info, scope);
        scriptBatch.finish(info);
       
        Invoice__c[] ivs = [select id, status__c, amount_due__c from invoice__c];
        //System.assertEquals(ivs[0].amount_due__c, 10);
        
        Test.stopTest();
    }
    
    public class myException extends Exception {}
}