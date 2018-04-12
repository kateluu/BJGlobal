global class batchPaymentsProcess implements Database.batchable<Invoice__c>,Database.AllowsCallouts {

  	global static boolean isTest = false;
  	private String period = 'Today';
  	private String paymentMethod;
  	private String companyName;
  	private Company__c bjbCompany;
  	private String invoice_batch_name = '';
  	private String payment_batch_name = '';
  	private Boolean invoice_batch_exist = false;
  	private Boolean payment_batch_exist = false;
  	private Date batch_date = Date.today();
  	private String PaymentBatchId; 
  	private String InvoiceBatchId; 
  	private String Log = '';

  	global batchPaymentsProcess(String period, String companyName) {
    	this.period = period;
    	this.companyName = companyName;

    	System.debug('Period: ' + period);

    	String companyAbbr = companyName.replace('Get More Traffic', 'GMT').replace('SponsoredLinX', 'SLX').replace('New Zealand', 'NZ');

    	this.invoice_batch_name = companyAbbr + ' ' + DateTime.now().format('EEEE yyyy-MM-dd') + ' ' + this.period + ' Invoice Batch';
    	this.payment_batch_name = companyAbbr + ' ' + DateTime.now().format('EEEE yyyy-MM-dd') + ' ' + this.period + ' Payment Batch';
    	System.debug('Payment Batch Name: ' + this.payment_batch_name);

    	List<Company__c> companies = [SELECT Id, Name, Business_Name__c, Checkout_Site__c, Checkout_Direct_Debit__c, CurrencyIsoCode, Payment_Gateway__c FROM Company__c WHERE Name = :companyName];
    	system.assertNotEquals(0, companies.size(), 'Could not find company ' + companyName);

    	this.bjbCompany = companies[0];

    	// Determine the Payment_Option__c on the invoices, which doesn't specify which version of the API. Eg an Eway invoice is just 'Eway', we then decide from 
    	// the company settings whether we should process Eway invoices with the Eway or Eway2.
	    this.paymentMethod = bjbCompany.Payment_Gateway__c.replace('2', '');

      // Get the target invoice batch
    	List<Invoice_Batch__c> todaysBatches = [
    		SELECT 
    			Id,
    			Name,
    			Batch_Date__c,
    			Batch_Number__c,
    			Batch_Processed__c,
    			status__c,
    			Batch_Type__c 
    		FROM 
    			Invoice_Batch__c 
    		WHERE 
    			Batch_Type__c = 'Invoices' 
    		AND 
    			status__c = 'Batch Approved' 
    		AND 
    			Batch_Processed__c = 'No' 
    		AND 
    			Batch_Date__c =: Date.today() 
    		AND 
    			Name =: this.invoice_batch_name 
    		AND 
    			Batch_Period__c =: this.period
    		];


    	if(todaysBatches.size() > 0) {

	      	Invoice_Batch__c todaysBatch = todaysBatches[0];
	      	this.InvoiceBatchId = todaysBatch.Id;
	            
	      	List<Invoice__c> allInvoices = [
				SELECT 
					Id, 
					Name,
					Payment_Batch__c, 
					Payment_Message__c, 
					Payment_Response__c, 
					Account__c, 
					Account_Product__c, 
					Amount_Credited__c,  
					Amount_Due__c,  
					Amount_Paid__c,  
					Due_Date__c, 
					Invoice_Batch__c,  
					Invoice_Number__c, 
					Invoice_Total__c, 
					Issue_Date__c,  
					Payment_Option__c, 
					Processed__c, 
					Process_Message__c, 
					CurrencyIsoCode,
					Reference__c 
				FROM  
					Invoice__c  
				WHERE  
					Payment_Batch__c = null  
				AND  
					Invoice_Batch__c =: todaysBatch.Id
			];
	
	      	System.debug('All Invoices: ' + allInvoices);
	
          // Create a payment batch
	      	Invoice_Batch__c newpaybatch  = new Invoice_Batch__c();
	      	newpaybatch.name        = this.payment_batch_name;
	      	newpaybatch.status__c      = 'Payments In Progress';
	      	newpaybatch.Batch_Type__c    = 'Payments';
	      	newpaybatch.Batch_Period__c  = this.period;
	      	insert newpaybatch;
	
          // Put all the invoices from this invoice batch into this payment batch
	      	for(Invoice__c inv : allInvoices) {
	        	System.debug('Updating Invoice: ' + inv);
	        	inv.Payment_Batch__c = newpaybatch.Id;
	      	}
	      	update allInvoices;
	      	PaymentBatchID = newpaybatch.Id;
    	}
	}

  global Iterable<Invoice__c> start(Database.batchableContext info) {
    return new GMTPaymentBatchIterator(this.period, this.companyName, this.paymentMethod);
  }

  global void execute(Database.batchableContext info, List<Invoice__c> scope) {
    System.debug('Scope: ' + scope);
    Boolean paymentHalted = false;

    ewayResponse ewayRep = new ewayResponse();
    List<Invoice__c> allInvoices = new List<Invoice__c>();
    List<Invoice_Payments__c> batchPayments = new List<Invoice_Payments__c>();
    List<Payment__c> listPayments = new List<Payment__c>();
    
    List<Credit__c> listUpdateCredit = new List<Credit__c>();
    List<Payment__c> listCreditPayment = new List<Payment__c>();
        
    for(Invoice__c current_invoice : scope) {
      System.debug('Current Invoice: ' + current_invoice);
      Log += 'Current Invoice Number: ' + current_invoice.Invoice_Number__c + ' | ' + current_invoice.Id;
      paymentHalted = false;
      
      //APPLY CREDITS
      list<Credit__c> AvailableCredits = new list<Credit__c>();
      AvailableCredits = [SELECT Id,Name,Account__c,Account_Product__c,Amount__c,Valid_From__c,Credit_Used__c,Credit_Left__c FROM Credit__c WHERE Account_Product__c=:current_invoice.Account_Product__c AND Valid_From__c <=:current_invoice.Issue_Date__c AND Credit_Left__c >:0];
        
      for(Credit__c thisAvailableCredits : AvailableCredits){
        Payment__c creditPayment = new Payment__c();
        creditPayment.Account__c = current_invoice.Account__c;
        creditPayment.Invoice_Reference__c = current_invoice.Invoice_Number__c;
        creditPayment.Payment_Reference__c = 'Credit from Credit ID - '+String.valueOf(thisAvailableCredits.Name);
        CreditPayment.Credit__c = thisAvailableCredits.Id;
        creditPayment.Invoice_Number__c = current_invoice.Invoice_Number__c;
        creditPayment.Payment_Name__c = 'Credit Payment';
        creditPayment.Payment_Date__c = Date.today();
        creditPayment.Invoice__c = current_invoice.Id;
        creditPayment.Payment_Type__c = 'Credit';
        creditPayment.Account_Product__c = current_invoice.Account_Product__c;
        creditPayment.Payment_Owner__c = current_invoice.Account_Product__r.OwnerId;
        
        decimal CreditLeft = thisAvailableCredits.Credit_Left__c;
        decimal InvoiceAmountDue = current_invoice.Amount_Due__c;
        decimal CreditUsed = thisAvailableCredits.Credit_used__c;
        
        decimal InvoiceAmountPaid = current_invoice.Amount_Paid__c;
        decimal InvoiceAmountCredited = current_invoice.Amount_Credited__c;
        
        if(CreditLeft >= InvoiceAmountDue){
          CreditLeft = CreditLeft - InvoiceAmountDue;
          CreditPayment.Payment_Amount__c = InvoiceAmountDue;
          CreditUsed = CreditUsed + InvoiceAmountDue;
          InvoiceAmountDue = 0;
          InvoiceAmountPaid = InvoiceAmountPaid + CreditPayment.Payment_Amount__c;
          InvoiceAmountCredited = InvoiceAmountCredited + CreditPayment.Payment_Amount__c;
          current_invoice.Status__c = 'CREDITED';
        } 
        else {
          InvoiceAmountDue = InvoiceAmountDue - CreditLeft;
          CreditPayment.Payment_Amount__c = CreditLeft;
          CreditUsed = CreditUsed + CreditLeft;
          CreditLeft = 0;
          InvoiceAmountPaid = InvoiceAmountPaid + CreditPayment.Payment_Amount__c;
          InvoiceAmountCredited = InvoiceAmountCredited + CreditPayment.Payment_Amount__c;
          current_invoice.Status__c = 'PARTIALLY CREDITED';
        }
        
        current_invoice.Amount_Due__c = InvoiceAmountDue;
        current_invoice.Amount_Paid__c = InvoiceAmountPaid;
        current_invoice.Amount_Credited__c = InvoiceAmountCredited;
          
        Credit__c updateCredit = new Credit__c();
        updateCredit = [SELECT Id,Credit_Used__c FROM Credit__c WHERE Id=:thisAvailableCredits.Id][0];
        updateCredit.Credit_Used__c = CreditUsed;
        Log += '| adding listUpdateCredit.';
        listUpdateCredit.add(updateCredit);
        Log += '| listUpdateCredit added.';
        
        if(CreditPayment.Payment_Amount__c > 0) {
          Log += '| adding listCreidtPayment..';
          listCreditPayment.add(creditPayment);
          Log += '| listCreidtPayment added.';
        }        
      }
      
      Log += '| Credits Complete';
      
      System.debug('Invoice Payment Option: ' + current_invoice.Payment_Option__c);
      //only pay invoices which are marked for Commweb and not paid fully by Credit
      if (current_invoice.Payment_Option__c == this.paymentMethod && current_invoice.Amount_Due__c > 0) {
        System.debug('This invoice is '+this.paymentMethod);

        Account account = new Account();
        Contact contact = new Contact();
        Account_Product__c accountProduct = new Account_Product__c();
        try {
          //get account and billing information
          account = [
            SELECT
              Id,
              Name,
              Name_On_Card__c,
              Card_Number__c,
              Card_Month_Expiry__c,
              Unique_Id__c,
              Card_Year_Expiry__c,
              Card_CVN__c              
            FROM
              Account
            WHERE
              Id =: current_invoice.Account__c
          ][0];
          Log += '| Account Found';
          
          accountProduct = [SELECT Id, Name, Name_On_Card__c, Card_Number__c, Card_Month_Expiry__c, Card_Year_Expiry__c, Card_CVN__c FROM Account_Product__c WHERE Id =: current_invoice.Account_Product__c][0];
          
          Log += '| AccountProduct Found';
        } catch (Exception e) {
          Log += '| ' + e;
          System.debug('Exception: ' + e + Log);
          current_invoice.Payment_Message__c = 'Could not load the salesforce account for the invoice ' ;
          current_invoice.Payment_Response__c = '--';
          paymentHalted = true;

			Utility.notifySysadmin('Daily Payment Error Log', '1st Catch: - ' + e + Log);
        }

        try {
          contact = [SELECT Id, Name, FirstName, LastName, Email, MailingStreet, MailingCity, MailingPostalCode, MailingState, MailingCountry FROM Contact WHERE AccountId =: account.Id AND Title = 'Billing' LIMIT 1];
          Log += '| Contact Found';
        } catch (Exception e) {
          Log += '| ' + e;
          System.debug('Exception: ' + e);
          current_invoice.Payment_Message__c = 'Could not load the salesforce account contact for the invoice';
          current_invoice.Payment_Response__c = '--';
          paymentHalted = true;

          Utility.notifySysadmin('Daily Payment Error Log', '2nd Catch: - ' + e + Log);
        }

        boolean TimedOut = false;
        Payment_Attempt__c paymentAttempt = new Payment_Attempt__c();
        if (paymentHalted == false || batchPaymentsProcess.isTest == true) {
          try {
            System.debug('Account Response: ' + account);
            System.debug('Contact Response: ' + contact);
            Log += '| Starting Payment';

			// "Mailing country" is not populated, so we will have to assume that their mailing country always matches their currency.
	        String countrycode;
	        if (this.bjbCompany.CurrencyIsoCode == 'NZD'){
	        	countrycode = 'NZ';
	        } else if (this.bjbCompany.CurrencyIsoCode == 'AUD'){
	            countrycode = 'AU';
	        }

            // Transact with the gateway
	        paymentGateway pay = new paymentGateway();
	        pay.setBjbCompany(this.bjbCompany);
	        pay.amount                      = current_invoice.Amount_Due__c;
	        pay.currencyIsoCode             = current_invoice.CurrencyIsoCode;
	        pay.customerFirstName           = contact.FirstName;
	        pay.customerLastName            = contact.LastName;
	        pay.customerEmail               = String.valueOf(contact.Email);
	        pay.customerStreet              = contact.MailingStreet;
	        pay.customerCity                = contact.MailingCity;
	        pay.customerState               = contact.MailingState;
	        pay.customerPostcode            = contact.MailingPostalCode;
	        pay.customerCountrycode         = countrycode;
	        pay.customerIP                  = null; // Because recurring payments aren't triggered by the customer, we don't want to include the user's IP.
	        pay.cardHoldersName             = account.Name_On_Card__c;
	        pay.cardNumber                  = account.Card_Number__c;
	        pay.cardExpiryMonth             = account.Card_Month_Expiry__c;
	        pay.cardExpiryYear              = account.Card_Year_Expiry__c;
	        pay.cardCVN                     = account.Card_CVN__c;
	        pay.customerInvoiceDescription  = current_invoice.Invoice_Number__c;
	        pay.customerInvoiceRef          = current_invoice.Invoice_Number__c;
            pay.uniqueAttemptId             = PaymentBatchID;

	        // Use a test gateway when in the sandbox or running a test method.
            if (batchPaymentsProcess.isTest == true){
            	pay.testGateway                = paymentGateway.GATEWAY_LOCAL;
            	pay.testType                   = paymentGateway.TEST_SUCCESS;
            }

	        try{
	            paymentAttempt = pay.pay();
	        } catch (Exception e) {
	            string errorDetail = 'Error in batchPaymentsProcess: ' + e.getMessage() + '. On ' + e.getStackTraceString();
	            Utility.notifySysadmin('Error in pay.pay', errorDetail);

	            system.debug(errorDetail);
	        }
            
            if (paymentAttempt.Status__c == 'SUCCESS') {
            	current_invoice.Status__c = 'PAID';
            }

            System.debug('Gateway Response: ' + paymentAttempt.Response__c);
            Log += '| Gateway Process Complete | ' + paymentAttempt.Response__c;

          } catch (Exception e) {
            Log += '| Gateway Failed' + e;
            System.debug('Exception: ' + e);
            current_invoice.Payment_Message__c = 'FAILURE: !Check '+this.paymentMethod+'! : API Not Responding : ';
            current_invoice.Payment_Response__c = 'ERROR';
            paymentHalted = true;

            Utility.notifySysadmin('Daily Payment Error Log', e + Log);
            timedOut = true;
          }
        }

        if((paymentHalted == false) || batchPaymentsProcess.isTest == true) {
          try {
            Log += '| Adding Payment Success Message';

            if(batchPaymentsProcess.isTest == true || paymentAttempt.Status__c == 'SUCCESS') {
				current_invoice.Payment_Message__c = 'SUCCESS: ' + paymentAttempt.Response_Message__c;
				current_invoice.Payment_Response__c = paymentAttempt.Gateway_Transaction_Id__c;
				//add payment to payment list
				datetime t = System.now();

				System.debug('Creating Payment Record');

				Log += '| Adding Payment Object';
				Payment__c thisPayment = new Payment__c();
				thisPayment.Payment_Name__c = account.name;
				thisPayment.Invoice__c = current_invoice.Id;
				thisPayment.Payment_Batch__c = current_invoice.Payment_Batch__c;
				thisPayment.Account__c = account.id;
				thisPayment.Payment_Amount__c = current_invoice.Amount_Due__c;

				thisPayment.Payment_Date__c   = Date.today();
				thisPayment.Invoice_Number__c = current_invoice.Invoice_Number__c;
				thisPayment.Account_Product__c = current_invoice.Account_Product__c;
				thisPayment.Payment_Owner__c = current_invoice.Account_Product__r.OwnerId;

				// PaymentAttempt differentiates between Commweb and Commweb2, but payment doesn't.
				if (paymentAttempt.Payment_Option__c == 'Commweb2'){
					thisPayment.Payment_Option__c = 'Commweb';
				} else {
					thisPayment.Payment_Option__c = paymentAttempt.Payment_Option__c;
				}
				thisPayment.CurrencyIsoCode = paymentAttempt.CurrencyIsoCode;

				listPayments.add(thisPayment);

				current_invoice.Amount_Due__c = 0;
				current_invoice.Amount_Paid__c += thisPayment.Payment_Amount__c;
				current_invoice.Process_Message__c = 'Payment Completed'; 
				current_invoice.Status__c = 'Paid';
				Log += '| Payment Object Added ';              
            } else {
              current_invoice.Payment_Message__c = 'FAILURE: ' + paymentAttempt.Response_Message__c;
              current_invoice.Payment_Response__c = paymentAttempt.Gateway_Transaction_Id__c;
              Log += '| Not Paid';
              current_invoice.Process_Message__c = 'UnPaid';
            }


          } catch (Exception e) {
            Log += '| Payment Object Failed ' + e; 
            System.debug('Exception: ' + e + Log);
            
            current_invoice.Payment_Message__c = 'Exception';
            current_invoice.Payment_Response__c = 'ERROR';
            paymentHalted = true;

            Utility.notifySysadmin('Daily Payment Error Log', '3rd Catch: - ' + e + Log);
          }
        } else {
          Log += '| Adding Payment Failure Message';
          current_invoice.Payment_Message__c = 'FAILURE: ' + paymentAttempt.Response_Message__c;
          current_invoice.Payment_Response__c = paymentAttempt.Gateway_Transaction_Id__c;
        }
      } else {
        current_invoice.Payment_Message__c = 'This is not a '+this.paymentMethod+' invoice';
        current_invoice.Payment_Response__c = '--';
      }
      current_invoice.Processed__c = true;

      allInvoices.add(current_invoice);
      Log += '|Invoice Added';
    }
    
    update listUpdateCredit;
    insert listCreditPayment;
        

    System.debug('All Invoices: ' + allInvoices);
    update allInvoices;

    System.debug('All Payments: ' + batchPayments);
    insert listPayments;
    insert batchPayments;
    
    Invoice_Batch__c updateNewPayBatch = [SELECT Id, Name, Batch_Processed__c, status__c FROM Invoice_Batch__c WHERE Id =:PaymentBatchID];
    updateNewPayBatch.Batch_Processed__c = 'Yes';
    updateNewPayBatch.status__c = 'Payments Complete';  
    update updateNewPayBatch;
    
    Invoice_batch__c updateInvoiceBatch = [SELECT Id, Name, Batch_Processed__c, status__c FROM Invoice_Batch__c WHERE Id =:InvoiceBatchId];
    updateInvoiceBatch.Batch_Processed__c = 'Yes'; 
    update updateInvoiceBatch;    
  }


  global void finish(Database.batchableContext info){}
}