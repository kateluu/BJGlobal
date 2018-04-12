// NO LONGER USED. This is the old eway-specific class. Use the generic batchPaymentsProcess instead.
global class dailyBatchPaymentsProcess implements Database.batchable<Invoice__c>,Database.AllowsCallouts {

  global static boolean isTest = false;
  private String period = 'Today';
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


  global dailyBatchPaymentsProcess(String period, String companyName) {
    this.period = period;
    this.companyName = companyName;

    System.debug('Period: ' + period);

    String companyAbbr = companyName.replace('Get More Traffic', 'GMT').replace('SponsoredLinX', 'SLX').replace('New Zealand', 'NZ');

    this.invoice_batch_name = companyAbbr + ' ' + DateTime.now().format('EEEE yyyy-MM-dd') + ' ' + this.period + ' Invoice Batch';

    this.payment_batch_name = companyAbbr + ' ' + DateTime.now().format('EEEE yyyy-MM-dd') + ' ' + this.period + ' Payment Batch';
    System.debug('Payment Batch Name: ' + this.payment_batch_name);

    List<Invoice_Batch__c> todaysBatches = [
	    SELECT Id,Name,Batch_Date__c,Batch_Number__c,Batch_Processed__c,status__c,Batch_Type__c 
	    FROM Invoice_Batch__c 
	    WHERE Batch_Type__c = 'Invoices' 
	    AND status__c = 'Batch Approved' 
	    AND Batch_Processed__c = 'No' 
	    AND Batch_Date__c =: Date.today() 
	    AND Name =: this.invoice_batch_name 
	    AND Batch_Period__c =: this.period
	   ];


    if(todaysBatches.size() > 0) {

      Invoice_Batch__c todaysBatch = todaysBatches[0];
      this.InvoiceBatchId = todaysBatch.Id;
      
      List<Invoice__c> allInvoices = [
        SELECT Id, Name,Payment_Batch__c, Payment_Message__c, Payment_Response__c, Account__c, Account_Product__c, Amount_Credited__c,  Amount_Due__c,  Amount_Paid__c,  
        Due_Date__c, Invoice_Batch__c,  Invoice_Number__c, Invoice_Total__c, Issue_Date__c,  Payment_Option__c, Processed__c, Process_Message__c, 
        Reference__c, Xero_Contact_Id__c, Xero_Invoice_Id__c 
        FROM  Invoice__c  
        WHERE  Payment_Batch__c = null  
        AND  Invoice_Batch__c =: todaysBatch.Id];
              
      System.debug('All Invoices: ' + allInvoices);

      //create new invoice_batch for payments of all unprocessed batches
      Invoice_Batch__c newpaybatch  = new Invoice_Batch__c();
      newpaybatch.name        = this.payment_batch_name;
      newpaybatch.status__c      = 'Payments In Progress';
      newpaybatch.Batch_Type__c    = 'Payments';
      newpaybatch.Batch_Period__c  = this.period;
      newpaybatch.Batch_Date__c  = Date.today();
      insert newpaybatch;

      for(Invoice__c inv : allInvoices) {
        System.debug('Updating Invoice: ' + inv);
        inv.Payment_Batch__c = newpaybatch.Id;
      }
      update allInvoices;
      PaymentBatchID = newpaybatch.Id;
    }
  }

  global Iterable<Invoice__c> start(Database.batchableContext info) {
    return new dailyBatchPayments(this.period);
  }

  global void execute(Database.batchableContext info, List<Invoice__c> scope) {
    System.debug('Scope: ' + scope);
    Boolean paymentHalted = false;

    ewayResponse ewayRep = new ewayResponse();
    List<Invoice__c> allInvoices = new List<Invoice__c>();
    List<Invoice_Payments__c> batchPayments = new List<Invoice_Payments__c>();
    List<Payment__c> listPayments = new List<Payment__c>();
    //List<Salesforce_Payment__c> batchSalesforcePayments = new List<Salesforce_Payment__c>();
    
    List<Credit__c> listUpdateCredit = new List<Credit__c>();
    List<Payment__c> listCreditPayment = new List<Payment__c>();
        
    for(Invoice__c current_invoice : scope) {
      System.debug('Current Invoice: ' + current_invoice);
      Log += 'Current Invoice Number: ' + current_invoice.Invoice_Number__c + ' | ' + current_invoice.Id;
      paymentHalted = false;
      
      
      //APPLY CREDITS
      list<Credit__c> AvailableCredits = new list<Credit__c>();
      //AvailableCredits = [SELECT Id,Name,Account__c,Account_Product__c,Amount__c,Valid_From__c,Credit_Used__c,Credit_Left__c FROM Credit__c WHERE Account_Product__c=:current_invoice.Account_Product__c AND Valid_From__c <=:date.today() AND Credit_Left__c >:0];
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
        
        //update updateCredit;
        if(CreditPayment.Payment_Amount__c > 0) {
          Log += '| adding listCreidtPayment..';
          listCreditPayment.add(creditPayment);
          Log += '| listCreidtPayment added.';
        }
      }
      
      Log += '| Credits Complete';
      
      System.debug('Invoice Payment Option: ' + current_invoice.Payment_Option__c);
      //only pay invoices which are marked for EWAY and not paid fully by Credit
      if (current_invoice.Payment_Option__c == 'Eway' && current_invoice.Amount_Due__c > 0) {
        System.debug('This invoice is EWAY');
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
          
          accountProduct = [SELECT Id, Name, Name_On_Card__c, Card_Number__c,Card_Month_Expiry__c,Card_Year_Expiry__c,Card_CVN__c FROM Account_Product__c WHERE Id =: current_invoice.Account_Product__c][0];
          
          Log += '| AccountProduct Found';
          //Xero_Sync_ID__c
          
          //if (processEwayPayments.isTest == true) { String s; s.toUpperCase(); }
        } catch (Exception e) {
          Log += '| ' + e;
          System.debug('Exception: ' + e + Log);
          //current_invoice.Payment_Message__c = 'Could not load the salesforce account for the invoice ' + Log;
          current_invoice.Payment_Message__c = 'Could not load the salesforce account for the invoice ' ;
          current_invoice.Payment_Response__c = '--';
          paymentHalted = true;
          
          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          String[] toAddresses   = new String[] {'devteam@sponsoredlinx.com.au'};
          //String[] bccAddresses  = new String[] {'william.zhang@sponsoredlinx.com'};
          mail.setToAddresses(toAddresses);
          //mail.setBccAddresses(bccAddresses);
          mail.setSenderDisplayName(Date.today().format());
          mail.setSubject('Daily Payment Error Log');
          mail.setBccSender(false);
          mail.setUseSignature(false);
          mail.setHtmlBody('1st Catch: - ' + e + Log);
             Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }

        try {
          //contact = account.Contact[0];
          contact = [SELECT Id, Name, FirstName,LastName,Email,MailingStreet,MailingCity,MailingPostalCode,MailingState,MailingCountry FROM Contact WHERE AccountId =: account.Id AND Title = 'Billing' limit 1];
          Log += '| Contact Found';
          //if (processEwayPayments.isTest == true) { String s; s.toUpperCase(); }
        } catch (Exception e) {
          Log += '| ' + e;
          System.debug('Exception: ' + e);
          //current_invoice.Payment_Message__c = 'Could not load the salesforce account contact for the invoice' + Log;
          current_invoice.Payment_Message__c = 'Could not load the salesforce account contact for the invoice';
          current_invoice.Payment_Response__c = '--';
          paymentHalted = true;
          
          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          String[] toAddresses   = new String[] {'devteam@sponsoredlinx.com.au'};
          //String[] bccAddresses  = new String[] {'william.zhang@sponsoredlinx.com'};
          mail.setToAddresses(toAddresses);
          //mail.setBccAddresses(bccAddresses);
          mail.setSenderDisplayName(Date.today().format());
          mail.setSubject('Daily Payment Error Log');
          mail.setBccSender(false);
          mail.setUseSignature(false);
          mail.setHtmlBody('2nd Catch: - ' + e + Log);
             Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        boolean TimedOut = false;
        if(paymentHalted == false || dailyBatchPaymentsProcess.isTest == true) {
          try {
            System.debug('Account Response: ' + account);
            System.debug('Contact Response: ' + contact);
            Log += '| Starting Eway Payment';
            //create eway transaction payment
            ewayPayment eway = new ewayPayment();

            // determine of using test eway payment or not.
            // true means test, false means live / production.
            if(dailyBatchPaymentsProcess.isTest == true)            eway.setMode('test');
            else                                eway.setMode('SponsoredLinx');

            String priceInCents = String.valueOf((current_invoice.Amount_Due__c.setScale(2) * 100).setScale(0));
            System.debug('EWAY Invoice Amount in cents: ' + priceInCents);
            eway.setewayTotalAmount(priceInCents);
            eway.setewayCustomerFirstName(contact.FirstName);
            eway.setewayCustomerLastName(contact.LastName); 
            eway.setewayCustomerEmail(String.valueOf(contact.Email));
            eway.setewayCustomerAddress(contact.MailingStreet + ' ' + contact.MailingCity);
            //eway.setewayCustomerPostcode(contact.PostalCode);
            eway.setewayCustomerInvoiceDescription(account.Unique_Id__c);
            eway.setewayCustomerInvoiceRef(current_invoice.Invoice_Number__c);
            eway.setewayCardHoldersName(account.Name_On_Card__c);
            eway.setewayCardNumber(account.Card_Number__c);
            eway.setewayCardExpiryMonth(account.Card_Month_Expiry__c);
            if(account.Card_CVN__c != null){
              eway.setewayCVN(account.Card_CVN__c);
            }
            if(dailyBatchPaymentsProcess.isTest == true) eway.setewayCardExpiryYear('2012');
            else eway.setewayCardExpiryYear(account.Card_Year_Expiry__c.substring(2,4));
            
            //process eway response
            if(dailyBatchPaymentsProcess.isTest == true) {
  
              ewayRep.setewayTrxnStatus('True');
              ewayRep.setewayTrxnError('Payment Successfull');
              ewayRep.setewayAuthCode('23456');
            } else {
              System.debug('EWAY Payment: ' + eway);
              if(current_invoice.Amount_Due__c > 0){
                ewayRep = eway.makePayment();
              }
              else current_invoice.Status__c = 'PAID';
            }
            System.debug('EWAY Response: ' + ewayRep);
            Log += '| Eway Process Complete | ' + ewayRep;

            //if (dailyBatchPaymentsProcess.isTest == true) { String s; s.toUpperCase(); }
          } catch (Exception e) {
            Log += '| Eway Failed' + e;
            System.debug('Exception: ' + e);
            //current_invoice.Payment_Message__c = 'FAILURE: !Check EWAY! : EWAY API Not Responding : '+e + Log;
            current_invoice.Payment_Message__c = 'FAILURE: !Check EWAY! : EWAY API Not Responding : ';
            current_invoice.Payment_Response__c = 'ERROR';
            paymentHalted = true;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses   = new String[] {'devteam@sponsoredlinx.com.au'};
            //String[] bccAddresses  = new String[] {'william.zhang@sponsoredlinx.com'};
            mail.setToAddresses(toAddresses);
            //mail.setBccAddresses(bccAddresses);
            mail.setSenderDisplayName(Date.today().format());
            mail.setSubject('Daily Payment Error Log - ' + e);
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setHtmlBody(e + Log);
               Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            timedOut = true;
          }
        }

        if((paymentHalted == false) || dailyBatchPaymentsProcess.isTest == true) {
          try {
            Log += '| Adding Payment Success Message';
            //if(dailyBatchPaymentsProcess.isTest == false)
            //{
            //if(ewayRep.getewayTrxnStatus() != 'False'){
              
            
            //}
            //}                            
            //if(true == true){

            if(dailyBatchPaymentsProcess.isTest == true || ewayRep.getewayTrxnStatus() != 'False') {
              current_invoice.Payment_Message__c = 'SUCCESS: ' + ewayRep.getewayTrxnError();
              current_invoice.Payment_Response__c = ewayRep.getewayTrxnNumber();
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
           
              listPayments.add(thisPayment);

              current_invoice.Amount_Due__c = 0;
              current_invoice.Amount_Paid__c += thisPayment.Payment_Amount__c;
              current_invoice.Process_Message__c = 'Payment Completed'; 
              current_invoice.Status__c = 'Paid';
              Log += '| Payment Object Added ';              
            } else {
              current_invoice.Payment_Message__c = 'FAILURE: ' + ewayRep.getewayTrxnError();
              current_invoice.Payment_Response__c = ewayRep.getewayTrxnNumber();
              Log += '| Eway Not Paid';
              current_invoice.Process_Message__c = 'EwayUnPaid';
            }

            //if (dailyBatchPaymentsProcess.isTest == true) { String s; s.toUpperCase(); }
          } catch (Exception e) {
            Log += '| Payment Object Failed ' + e; 
            System.debug('Exception: ' + e + Log);
            
            //current_invoice.Payment_Message__c = 'FAILURE: !Check XERO! : unable to add payment to Xero Payment list';
            //current_invoice.Payment_Response__c = 'ERROR';
            //current_invoice.Payment_Message__c = 'Exception: ' + e + Log;
            current_invoice.Payment_Message__c = 'Exception';
            current_invoice.Payment_Response__c = 'ERROR';
            paymentHalted = true;
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses   = new String[] {'devteam@sponsoredlinx.com.au'};
            //String[] bccAddresses  = new String[] {'william.zhang@sponsoredlinx.com'};
            mail.setToAddresses(toAddresses);
            //mail.setBccAddresses(bccAddresses);
            mail.setSenderDisplayName(Date.today().format());
            mail.setSubject('Daily Payment Error Log');
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setHtmlBody('3rd Catch: - ' + e + Log);
               Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
          }
        } else {
          Log += '| Adding Payment Failure Message';
            //if(dailyBatchPaymentsProcess.isTest == false)
            //{
              current_invoice.Payment_Message__c = 'FAILURE: ' + ewayRep.getewayTrxnError();
              current_invoice.Payment_Response__c = ewayRep.getewayTrxnNumber();
        }
      } else {
        current_invoice.Payment_Message__c = 'This is a non eway invoice';
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

    System.debug('All EWAY Payments: ' + batchPayments);
    //insert batchSalesforcePayments; 
    insert listPayments;
    insert batchPayments;  
    
    Invoice_Batch__c updateNewPayBatch = new Invoice_Batch__c();
    updateNewPayBatch = [SELECT Id, Name, Batch_Processed__c, status__c FROM Invoice_Batch__c WHERE Id =:PaymentBatchID];
    updateNewPayBatch.Batch_Processed__c = 'Yes';
    updateNewPayBatch.status__c = 'Payments Complete';  
    update updateNewPayBatch;
    
    Invoice_batch__c updateInvoiceBatch = new Invoice_Batch__c();
    updateInvoiceBatch = [SELECT Id, Name, Batch_Processed__c, status__c FROM Invoice_Batch__c WHERE Id =:InvoiceBatchId];
    updateInvoiceBatch.Batch_Processed__c = 'Yes'; 
    update updateInvoiceBatch;
  }
  
  global void finish(Database.batchableContext info){}

}