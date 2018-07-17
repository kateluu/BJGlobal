public with sharing class MakeAPayment {

  public boolean isTest {get;set;}
  public boolean generateErrors {get;set;}

  public boolean PageRefresh {get;set;}

  public List<Invoice__c> invoice = new List<Invoice__c>();
  public Invoice__c invoiceObj = new Invoice__c();
  public Account acc {get;set;}
  public List<Invoice__c> checkInvoice = new List<Invoice__c>();
  public Decimal paymentAmount {get;set;}
  public Boolean showPaymentButton {get;set;}
  public Boolean isCardPayment {get;set;}
  public Decimal invoiceTotal {get;set;}
  public String PaymentType {get;set;}
  public String PaymentReference {get;set;}
  public Boolean complete {get;set;}
  public Boolean incomplete {get;set;}
  public Payment__c inputPayment = new Payment__c();
  public String invoiceId {get;set;}
  public String message {get;set;}
  public String AccountProduct {get; set;}
  public list<Payment__c> listOfPayments = new list<Payment__c>();
  public CardDetails cardDetails {get; set;} {cardDetails = new CardDetails();}

  // Constructor
  public MakeAPayment(ApexPages.StandardController controller) {

    String message = '' + ApexPages.CurrentPage().GetParameters().Get('response');
    String pageHeaderReferer = ApexPages.currentPage().getHeaders().get('Referer');
    system.debug(message);
    system.debug(pageHeaderReferer);
    // Use the referrer parameter to only show the message when coming from Make a Payment page
    if(pageHeaderReferer != null && pageHeaderReferer.containsIgnoreCase('makeapayment') && message != 'null'){
      if(message == 'success'){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.CONFIRM,'Transaction Completed');
        ApexPages.addMessage(myMsg);
      }else{
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, message);
        ApexPages.addMessage(myMsg);
      }
    }

    this.acc = (Account)controller.getRecord();
    String id = this.acc.Id;
    this.acc = [SELECT Id,
            Name,
            Card_Token__c,
            Card_Number__c,
            Card_Number_Masked__c,
            Name_On_Card__c,
            Card_Month_Expiry__c,
            Card_Year_Expiry__c,
            Card_CVN__c,
            Unique_Id__c,
            currencyIsoCode,
            BJB_Company__r.Name,
            BJB_Company__r.Payment_Gateway__c,
            BJB_Company__r.currencyIsoCode
    FROM Account
    WHERE ID =: id
    ];

    system.debug(this.acc);
    this.isTest = false;
    this.generateErrors = false;
    this.PageRefresh = false;
    this.inputPayment.Payment_Date__c = date.today();
    this.inputPayment.Payment_Type__c = 'Payment';
    this.isCardPayment = false;
    complete = false;
    incomplete = true;

    this.listOfPayments = [
            SELECT
                    Id,
                    Name,
                    Payment_Type__c,
                    Payment_Option__c,
                    Invoice_Number__c,
                    Payment_Amount__c,
                    Payment_Date__c,
                    CurrencyIsoCode,
                    Account__c
            FROM
                    Payment__c
            WHERE
                    Account__c =:this.acc.Id
            ORDER BY
                    Name desc
            LIMIT 10
    ];

    this.showPaymentButton = true;
  }


  // =============================================================
  // Getters/Setters
  // =============================================================

  public List<Payment__c> getlistOfPayments() {
    return listOfPayments;
  }
  public void setlistOfPayments(list<Payment__c> value) {
    listOfPayments = value;
  }
  public List<Invoice__c> getcheckInvoice() {
    return checkInvoice;
  }
  public void setcheckInvioce(List<Invoice__c> value) {
    checkInvoice = value;
  }
  public List<Invoice__c> getinvoice() {
    return invoice;
  }
  public void setinvioce(List<Invoice__c> value) {
    invoice = value;
  }

  public List<SelectOption> getinvoiceItems() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('','--none--'));
    for(Invoice__c thisInvoice : this.invoice){
      options.add(new SelectOption(thisInvoice.Name,thisInvoice.Name));
    }

    return options;
  }

  public List<Invoice__c> getInvList() {
    return this.invoice;
  }

  public void setInvList(List<Invoice__c> listofinv) {
    this.invoice = listofinv;
  }

  public Payment__c getinputPayment() {
    return inputPayment;
  }

  public void setinputPayment(Payment__c value) {
    inputPayment = value;
  }

  public List<SelectOption> getInvoiceIds() {
    List<SelectOption> options = new List<SelectOption>();
    for(Invoice__c thisInvoice : this.invoice){
      options.add(new SelectOption(thisInvoice.Id, thisInvoice.Invoice_Number__c + ' - ' + thisInvoice.Account_Product__r.Name));
    }
    return options;
  }

  public List<SelectOption> getPaymentTypes() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('','---None---'));

    if ( !String.isEmpty(this.acc.Card_Token__c) && !String.isEmpty(this.acc.Card_Number_Masked__c) ){
      options.add(new SelectOption('CreditCardExisting', 'Credit Card - ' + this.acc.Card_Number_Masked__c + ' ('+this.acc.Card_Month_Expiry__c + '/' + this.acc.Card_Year_Expiry__c +')'));
    }

    options.add(new SelectOption('CreditCardNew','Credit Card - New'));
    options.add(new SelectOption('CreditCardFailure','Credit Card - Failure'));
    options.add(new SelectOption('Cheque','Cheque'));
    options.add(new SelectOption('EFT','EFT'));
    options.add(new SelectOption('Other','Other'));

    return options;
  }

  public Decimal getallInvoiceTotal() {
    Decimal total = 0;
    if(this.invoice.size() > 0) {
      for(Invoice__c listinv : this.invoice) {
        if (listinv.Checked__c == true) {
          total = total + listinv.Amount_Due__c;
        }
      }
    }
    System.debug('total:'+total);
    return total;
  }

  public Decimal getUnpaidInvoiceTotal() {
    Decimal total = 0;
    if(this.invoice.size() > 0) {
      for(Invoice__c listinv : this.invoice) {
        total = total + listinv.Amount_Due__c;
      }
    }
    System.debug('total:'+total);
    return total;
  }

  public Decimal getPaidInvoiceTotal() {
    Decimal total = 0;
    if(this.invoice.size() > 0) {
      for(Invoice__c listinv : this.invoice) {
        total = total + listinv.Amount_Paid__c;
      }
    }
    System.debug('total:'+total);
    return total;
  }


  // =============================================================
  // Actions
  // =============================================================

  // Page load
  public PageReference PageLoad() {
    if(ApexPages.currentPage().getParameters().get('msg') != null) {
      this.message = ApexPages.currentPage().getParameters().get('msg');
    }

    this.invoice = [
            SELECT
                    Id,
                    Name,
                    Amount_Credited__c,
                    Account__r.Payment_Option__c,
                    Account__r.Name_On_Card__c,
                    Account__r.Card_Number__c,
                    Account__r.Card_CVN__c,
                    Account__r.Card_Month_Expiry__c,
                    Account__r.Card_Year_Expiry__c,
                    Account_Product__c,
                    Account_Product__r.Name,
                    Account_Product__r.Payment_Option__c,
                    Account_Product__r.Name_On_Card__c,
                    Account_Product__r.Card_Number__c,
                    Account_Product__r.Card_Month_Expiry__c,
                    Account_Product__r.Card_Year_Expiry__c,
                    Account_Product__r.Card_CVN__c,
                    Account_Product__r.SLX_Product__r.company_name__c,
                    Account_Product__r.OwnerId,
                    Account__c,
                    Checked__c,
                    Invoice_Number__c,
                    Payment_Option__c,
                    Invoice_Total__c,
                    Amount_Paid__c,
                    Amount_Due__c,
                    Due_Date__c,
                    Issue_Date__c,
                    Payment_Response__c,
                    CurrencyIsoCode,
                    Status__c
            FROM
                    Invoice__c
            WHERE
            Account__c=:acc.Id
            AND
            (Status__c = 'PARTIALLY PAID' or Status__c = 'AUTHORISED' or Status__c = 'PARTIALLY CREDITED')
            AND
            Amount_Due__c > 0
            ORDER BY
                    Issue_Date__c DESC
    ];

    try {
      this.checkInvoice = this.invoice;

      for (Invoice__c thisInvoice : this.Invoice){
        this.invoiceId = thisInvoice.Id;
        list<Credit__c> RelatedCredits = new list<Credit__c>();
        System.debug('Date.Today ='+date.today());
        System.debug('thisInvoice.Account_Product__c = '+thisInvoice.Account_Product__c);
        RelatedCredits = [SELECT Id, Name, Account__c, Account_Product__c, Credit_Used__c, Credit_Left__c, Amount__c, Valid_From__c FROM Credit__c WHERE Account_Product__c=:thisInvoice.Account_Product__c AND Valid_From__c <=:thisInvoice.Issue_Date__c AND Credit_Left__c > 0];

        for (Credit__c thisRelatedCredit : RelatedCredits){
          Payment__c CreditPayment = new Payment__c();
          CreditPayment.Account__c = thisInvoice.Account__c;
          CreditPayment.Invoice_Reference__c = thisInvoice.Invoice_Number__c;
          CreditPayment.Payment_Reference__c = 'Credit from Credit ID - '+String.valueOf(thisRelatedCredit.Name);
          CreditPayment.Credit__c = thisRelatedCredit.Id;
          CreditPayment.Invoice_Number__c = thisInvoice.Invoice_Number__c;
          CreditPayment.Payment_Name__c = 'Credit Payment';
          CreditPayment.Payment_Date__c = Date.today();
          CreditPayment.Invoice__c = thisInvoice.Id;
          CreditPayment.Payment_Type__c = 'Credit';
          CreditPayment.CurrencyIsoCode = thisInvoice.CurrencyIsoCode;
          CreditPayment.Account_Product__c = thisInvoice.Account_Product__c;
          CreditPayment.Payment_Owner__c = thisInvoice.Account_Product__r.OwnerId;
          

          decimal CreditLeft = thisRelatedCredit.Credit_Left__c;
          decimal InvoiceAmountDue = thisInvoice.Amount_Due__c;
          decimal InvoiceAmountPaid = thisInvoice.Amount_Paid__c;
          decimal CreditUsed = thisRelatedCredit.Credit_used__c;
          decimal InvoiceAmountCredited = thisInvoice.Amount_Credited__c;


          if (CreditLeft >= InvoiceAmountDue){
            CreditLeft = CreditLeft - InvoiceAmountDue;
            CreditPayment.Payment_Amount__c = InvoiceAmountDue;
            CreditUsed = CreditUsed + InvoiceAmountDue;
            InvoiceAmountDue = 0;
            InvoiceAmountPaid = InvoiceAmountPaid + CreditPayment.Payment_Amount__c;
            InvoiceAmountCredited = InvoiceAmountCredited + CreditPayment.Payment_Amount__c;
            thisInvoice.Status__c = 'CREDITED';
          } else {
            InvoiceAmountDue = InvoiceAmountDue - CreditLeft;
            CreditPayment.Payment_Amount__c = CreditLeft;
            CreditUsed = CreditUsed + CreditLeft;
            CreditLeft = 0;
            InvoiceAmountPaid = InvoiceAmountPaid + CreditPayment.Payment_Amount__c;
            InvoiceAmountCredited = InvoiceAmountCredited + CreditPayment.Payment_Amount__c;
            thisInvoice.Status__c = 'PARTIALLY CREDITED';
          }

          thisInvoice.Amount_Due__c = InvoiceAmountDue;
          thisInvoice.Amount_Paid__c = InvoiceAmountPaid;
          thisInvoice.Amount_Credited__c = InvoiceAmountCredited;

          Credit__c updateCredit = new Credit__c();
          updateCredit = [SELECT Id,Credit_Used__c FROM Credit__c WHERE Id=:thisRelatedCredit.Id][0];
          updateCredit.Credit_Used__c = CreditUsed;
          update updateCredit;

          if (CreditPayment.Payment_Amount__c > 0) {
            insert CreditPayment;
            this.PageRefresh = true;
          }

          System.debug('Before invoice update');
          update thisInvoice;
          System.debug('After invoice update');
        }
      }

      System.debug('Invoice List:'+this.invoice);
    } catch (Exception e) {

    }

    if (this.PageRefresh){
      PageReference MakeAPaymentPage = new PageReference('/apex/MakeAPayment');
      MakeAPaymentPage.getParameters().put('id',this.acc.id);
      MakeAPaymentPage.setRedirect(true);
      return MakeAPaymentPage;
    }

    ChangeInvoice();
    ChangePaymentType();

    return null;
  }

  // Change invoice number
  public void SelectInvoice() {
    this.invoiceId = ApexPages.currentPage().getParameters().get('invoiceId');

    system.debug('in SelectInvoice ' + this.invoiceId);

    ChangeInvoice();
  }

  // Change invoice number
  public void ChangeInvoice() {
    system.debug('in ChangeInvoice ' + this.invoiceId);

    this.PaymentType = '';
    this.invoiceObj = new Invoice__c();
    for (Invoice__c thisInvoice : this.invoice){

      system.debug('Checking against invoice ' + thisInvoice.Id);
      if (thisInvoice.Id == this.invoiceId) {
        this.invoiceObj = thisInvoice;

        system.debug('Found it! ' + thisInvoice.Invoice_Number__c);

        this.invoiceTotal         = thisInvoice.Amount_Due__c;
        this.paymentAmount         = thisInvoice.Amount_Due__c;
        this.PaymentReference     = thisInvoice.Invoice_Number__c;
        this.InvoiceId          = thisInvoice.Id;
        this.AccountProduct       = thisInvoice.Account_Product__c;

        if ( thisInvoice.Account_Product__r.Payment_Option__c == 'Eway' || thisInvoice.Account_Product__r.Payment_Option__c == 'Commweb' ){
          if ( !String.isEmpty(this.acc.Card_Token__c) ){
            this.PaymentType         = 'CreditCardExisting';
          } else {
            this.PaymentType         = 'CreditCardNew';
          }
        } else {
          this.PaymentType         = thisInvoice.Account_Product__r.Payment_Option__c;
        }

        break;
      }
    }

    ChangePaymentType();
  }

  // Submit 'make a payment'
  public PageReference submitTestPayment() {
    this.isTest = true;
    return submitPayment();
  }

    // Submit 'make a payment'
  public PageReference submitPayment() {
    PageReference MakeAPaymentPage = new PageReference('/apex/MakeAPayment');

    Decimal totalSelected   = this.getAllInvoiceTotal();
    Decimal totalUnPaid   = this.getUnpaidInvoiceTotal();
    Decimal payAmount     = this.paymentAmount;
    Contact contact;

    // Error checking
    try {
      contact = [SELECT Id,Name,FirstName, LastName, Email, MailingStreet, MailingCity, MailingPostalCode, MailingState,MailingCountry FROM Contact WHERE AccountId=:acc.Id and Title='Billing' limit 1];
    } catch (Exception e) {
      System.debug('Exception: '+e);
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Unable to load the Billing contact for this account'));
    }

    if (this.invoiceTotal <= 0 || this.generateErrors == true) {
      System.debug('Error: Please select atleast 1 unpaid invoice');
    }

    if (payAmount <= 0) {
      System.debug('Error: Please enter a positive number for payment');
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Please enter a positive number for payment'));
    }

    if (this.PaymentType == 'CreditCardNew' &&  this.cardDetails.Name_On_Card == null){
      System.debug('Error: Please enter the name on the credit card');
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Please enter the name on the credit card'));
    }

    if (this.PaymentType == 'CreditCardNew' && this.cardDetails.Card_Number == null){
      System.debug('Error: Please enter a card number');
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Please enter a card number'));
    }

    if (this.PaymentType == 'CreditCardNew' && this.cardDetails.Card_Month_Expiry == ''){
      System.debug('Error: Please enter the card month expiry');
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Please enter the card month expiry'));
    }

    if (this.PaymentType == 'CreditCardNew' && this.cardDetails.Card_Year_Expiry == ''){
      System.debug('Error: Please enter the card year expiry');
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Please enter the card year expiry'));
    }

    // create card transaction payment
    Payment_Attempt__c paymentAttempt = new Payment_Attempt__c();

    // "this.isCardPayment" indicates that the account for the invoice is marked as Eway or Commweb
    if ( (this.isCardPayment && !ApexPages.hasMessages(ApexPages.Severity.ERROR) ) || this.generateErrors) {
        // New code - use standard paymentGateway class
        // Transact with the gateway
        paymentGateway pay = new paymentGateway();
        pay.setBjbCompany(this.acc.BJB_Company__r);
        pay.amount                      = payAmount;
        pay.currencyIsoCode             = this.acc.CurrencyIsoCode;
        pay.customerCompanyName         = this.acc.Name;
        pay.customerFirstName           = contact.FirstName;
        pay.customerLastName            = contact.LastName;
        pay.customerEmail               = String.valueOf(contact.Email);
        pay.customerStreet              = contact.MailingStreet;
        pay.customerCity                = contact.MailingCity;
        pay.customerState               = contact.MailingState;
        pay.customerPostcode            = contact.MailingPostalCode;

        if (this.PaymentType == 'CreditCardExisting'){
          // Use existing token.
          pay.customerToken               = this.acc.Card_Token__c;
        } else {
          // Use new card details. This is just a one-off, so we won't save these details or update the token.
          pay.cardNumber                  = this.cardDetails.Card_Number;
          pay.cardCVN                     = this.cardDetails.Card_CVN;
          pay.cardHoldersName             = this.cardDetails.Name_On_Card;
          pay.cardExpiryMonth             = this.cardDetails.Card_Month_Expiry;
          pay.cardExpiryYear              = this.cardDetails.Card_Year_Expiry;
        }

        pay.customerInvoiceDescription  = this.acc.Unique_Id__c;
        pay.customerInvoiceRef          = this.PaymentReference;
        pay.uniqueAttemptId             = DateTime.now().format('yyyyMMdd');

        // Use a test gateway when in the sandbox or running a test method.
        //if (this.isTest || this.generateErrors == true || utility.runningInASandbox()) {
        if (this.isTest || this.generateErrors == true){
          pay.testGateway                = paymentGateway.GATEWAY_MOCK;
          pay.testType                   = paymentGateway.TEST_SUCCESS;
        }

        try{
          paymentAttempt = pay.pay();
          insert paymentAttempt;
        } catch (Exception e) {
          string errorDetail = 'Error in MakeAPayment: ' + e.getMessage() + '. On ' + e.getStackTraceString();
          Utility.notifySysadmin('Error in pay.pay', errorDetail);

          system.debug(errorDetail);
        }
    }

    // Create Payment__c record and update invoice
    Boolean createPaymentRecord = (paymentAttempt.Status__c == 'SUCCESS' || this.isCardPayment == false);

    if ((ApexPages.hasMessages(ApexPages.Severity.ERROR) == false && createPaymentRecord == true) || this.generateErrors == true) {
      List<Payment__c> thisPayments = new List<Payment__c>();
      Decimal totalPayAmount = payAmount;
      Decimal invPayment = 0;
      List<Invoice__c> UpdatedInvoices = new List<Invoice__c>();

      System.debug('this.invoice:'+this.invoice);
      System.debug('this.invoice.size():'+this.invoice.size());

      if (this.invoice.size() > 0) {
        // Loop through the invoices and add a payment for each
        for (Invoice__c listinv : this.invoice) {
          System.debug('listinv.url:'+listinv);

          // We only actually want to add a payment for one invoice that matches the selected invoice
          if (listinv.Id == this.invoiceId) {
            Invoice__c inv = [SELECT Id, Name, Amount_Due__c, Amount_Paid__c FROM Invoice__c WHERE id=:listinv.Id];
            Payment__c payment = new Payment__c();

            invPayment = 0;
            System.debug('totalPayAmount:'+totalPayAmount);

            if (totalPayAmount >= listinv.Amount_Due__c) {
              // Paying the full invoice, so mark it as paid
              invPayment = listinv.Amount_Due__c;
              totalPayAmount = totalPayAmount - listinv.Amount_Due__c;

              inv.Amount_Due__c = 0;
              inv.Status__c = 'PAID';
              inv.Amount_Paid__c = listinv.Amount_Paid__c + invPayment;
              inv.Payment_Response__c = paymentAttempt.Gateway_Transaction_Id__c;
              payment.Payment_Amount__c        = invPayment;
            } else if (totalPayAmount > 0 || this.generateErrors == true) {
              // Paying partial amount of the invoice, so update the amount due
              invPayment = totalPayAmount;
              inv.Amount_Due__c = listinv.Amount_Due__c - invPayment;
              inv.Amount_Paid__c = listinv.Amount_Paid__c + invPayment;
              inv.Status__c = 'Partially Paid';
              inv.Payment_Response__c = paymentAttempt.Gateway_Transaction_Id__c;
              payment.Payment_Amount__c        = invPayment;
              totalPayAmount = 0;
            }

            payment.Payment_Reference__c = this.PaymentReference;
            payment.Account__c = this.acc.Id;
            payment.Payment_Amount__c = invPayment;
            payment.CurrencyIsoCode = listinv.CurrencyIsoCode;
            payment.Invoice__c = inv.Id;
            payment.Invoice_Number__c = inv.Name;
            payment.Invoice_Reference__c        = inv.Id;
            payment.Payment_Type__c = this.inputPayment.Payment_Type__c;
            payment.Invoice_Number__c = listinv.Invoice_Number__c;
            payment.Payment_Date__c   = this.inputPayment.Payment_Date__c;
            payment.Payment_Option__c = paymentAttempt.Payment_Option__c ;
            if(paymentAttempt.Payment_Option__c == null){
              payment.Payment_Option__c = this.PaymentType;
            }
            payment.Account_Product__c = listinv.Account_Product__c;
            payment.Payment_Owner__c = listinv.Account_Product__r.OwnerId;
            system.debug(payment);

            inv.Invoice_Number__c    = listinv.Invoice_Number__c;

            if (payment.Payment_Amount__c > 0) {
              thisPayments.add(payment);
            }

            UpdatedInvoices.add(inv);
          }
        }

        // Insert the Payment__c record if it's a non-cardpayment, or a cardpayment that succeeded
        if (createPaymentRecord){
          insert thisPayments;

          // If we've paid more than the invoice total, create credits
          if (payAmount > this.invoiceTotal) {
            Credit__c overpayCredit = new Credit__c();
            overpayCredit.Account__c = this.acc.id;
            overpayCredit.Credit_Used__c = 0;
            overpayCredit.Amount__c = payAmount - this.invoiceTotal;
            overpayCredit.Valid_From__c = date.today();
            overpayCredit.Account_Product__c = this.AccountProduct;
            insert overpayCredit;
          }
        }

        update UpdatedInvoices;
        complete = true;
        incomplete = false;
      }
    }

    MakeAPaymentPage.getParameters().put('id',this.acc.id);
    if (ApexPages.hasMessages(ApexPages.Severity.ERROR)){
      MakeAPaymentPage.getParameters().put('msg','Transaction Failed');
      MakeAPaymentPage.setRedirect(true);
      ApexPages.currentPage().getParameters().put('msg','');
      this.message = null;
      return null;
    } else {
      if (this.isCardPayment == false || paymentAttempt.Status__c == 'SUCCESS'){
        MakeAPaymentPage.getParameters().put('response', 'success');
      } else {
        MakeAPaymentPage.getParameters().put('response', paymentAttempt.Response_Message__c);
      }

      MakeAPaymentPage.setRedirect(true);
      return MakeAPaymentPage;
    }
  }

  // Submit 'make a refund'
  public PageReference submitRefund() {
    PageReference MakeAPaymentPage = new PageReference('/apex/MakeAPayment');

    Decimal totalSelected   = this.getAllInvoiceTotal();
    Decimal totalRefundDecimal = this.getPaidInvoiceTotal();
    Decimal payAmount       = this.paymentAmount;
    Contact contact;

    // Error checking
    Boolean hasError    = false;

    try {
      contact = [SELECT Id,Name,FirstName, LastName, Email, MailingStreet, MailingCity, MailingPostalCode, MailingState,MailingCountry FROM Contact WHERE AccountId=:acc.Id and Title='Billing' limit 1];
    } catch (Exception e) {
      System.debug('Exception: '+e);
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Unable to load the Billing contact for this account'));
      hasError = true;
    }

    // create card transaction payment
    Payment_Attempt__c paymentAttempt = new Payment_Attempt__c();

    // "this.isCardPayment" indicates that the account for the invoice is marked as Eway or Commweb
    if ( (this.isCardPayment && !hasError) || this.generateErrors) {
        // New code - use standard paymentGateway class
        // Transact with the gateway
        paymentGateway pay = new paymentGateway();
        pay.setBjbCompany(this.acc.BJB_Company__r);
        pay.amount                      = payAmount;
        pay.currencyIsoCode             = this.acc.CurrencyIsoCode;
        pay.customerFirstName           = contact.FirstName;
        pay.customerLastName            = contact.LastName;
        pay.customerEmail               = String.valueOf(contact.Email);
        pay.customerStreet              = contact.MailingStreet;
        pay.customerCity                = contact.MailingCity;
        pay.customerState               = contact.MailingState;
        pay.customerPostcode            = contact.MailingPostalCode;
        pay.cardHoldersName             = this.acc.Name_On_Card__c;
        pay.cardNumber                  = this.acc.Card_Number__c;
        pay.cardExpiryMonth             = this.acc.Card_Month_Expiry__c;
        pay.cardExpiryYear              = this.acc.Card_Year_Expiry__c;
        pay.cardCVN                     = this.acc.Card_CVN__c;
        pay.customerInvoiceDescription  = this.acc.Unique_Id__c;
        pay.customerInvoiceRef          = this.PaymentReference;
        pay.uniqueAttemptId             = DateTime.now().format('yyyyMMdd');

        // Use a test gateway when in the sandbox or running a test method.
        //if (this.isTest || this.generateErrors == true || utility.runningInASandbox()) {
        if (this.isTest || this.generateErrors == true){
          pay.testGateway                = paymentGateway.GATEWAY_MOCK;
          pay.testType                   = paymentGateway.TEST_SUCCESS;
        }

        try{
          //for testing paymentAttempt = pay.pay();

          paymentAttempt = pay.refund();
        } catch (Exception e) {
          string errorDetail = 'Error in MakeAPayment: ' + e.getMessage() + '. On ' + e.getStackTraceString();
          Utility.notifySysadmin('Error in pay.pay', errorDetail);

          system.debug(errorDetail);
        }
    }

    // Create Payment__c record and update invoice
    Boolean createPaymentRecord = (paymentAttempt.Status__c == 'SUCCESS' || this.isCardPayment == false);

    if ((hasError == false && createPaymentRecord == true) || this.generateErrors == true) {
      List<Payment__c> thisPayments = new List<Payment__c>();
      Decimal totalPayAmount = payAmount;
      Decimal invPayment = 0;
      List<Invoice__c> UpdatedInvoices = new List<Invoice__c>();

      System.debug('this.invoice:'+this.invoice);
      System.debug('this.invoice.size():'+this.invoice.size());

      if (this.invoice.size() > 0) {
        // Loop through the invoices and add a payment for each
        for (Invoice__c listinv : this.invoice) {
          System.debug('listinv.url:'+listinv);

          // We only actually want to add a payment for one invoice that matches the selected invoice
          if (listinv.Id == this.invoiceId) {
            Invoice__c inv = [SELECT Id, Name, Amount_Due__c, Amount_Paid__c FROM Invoice__c WHERE id=:listinv.Id];
            Payment__c payment = new Payment__c();

            invPayment = 0;
            System.debug('totalPayAmount:'+totalPayAmount);

            if (totalPayAmount >= listinv.Amount_Due__c) {
              // Paying the full invoice, so mark it as paid
              invPayment = listinv.Amount_Due__c;
              totalPayAmount = totalPayAmount - listinv.Amount_Due__c;

              inv.Amount_Due__c = 0;
              inv.Status__c = 'PAID';
              inv.Amount_Paid__c = listinv.Amount_Paid__c + invPayment;
              inv.Payment_Response__c = paymentAttempt.Gateway_Transaction_Id__c;
              payment.Payment_Amount__c        = invPayment;
            } else if (totalPayAmount > 0 || this.generateErrors == true) {
              // Paying partial amount of the invoice, so update the amount due
              invPayment = totalPayAmount;
              inv.Amount_Due__c = listinv.Amount_Due__c - invPayment;
              inv.Amount_Paid__c = listinv.Amount_Paid__c + invPayment;
              inv.Status__c = 'Partially Paid';
              inv.Payment_Response__c = paymentAttempt.Gateway_Transaction_Id__c;
              payment.Payment_Amount__c        = invPayment;
              totalPayAmount = 0;
            }

            payment.Payment_Reference__c = this.PaymentReference;
            payment.Account__c = this.acc.Id;
            payment.Payment_Amount__c = invPayment;
            payment.CurrencyIsoCode = listinv.CurrencyIsoCode;
            payment.Invoice__c = inv.Id;
            payment.Invoice_Number__c = inv.Name;
            payment.Invoice_Reference__c        = inv.Id;
            payment.Payment_Type__c = this.inputPayment.Payment_Type__c;
            payment.Invoice_Number__c = listinv.Invoice_Number__c;
            payment.Payment_Date__c   = this.inputPayment.Payment_Date__c;
            payment.Payment_Option__c = this.PaymentType;
            payment.Account_Product__c = listinv.Account_Product__c;
            payment.Payment_Owner__c = listinv.Account_Product__r.OwnerId;
            system.debug(payment);

            inv.Invoice_Number__c    = listinv.Invoice_Number__c;

            if (payment.Payment_Amount__c > 0) {
              thisPayments.add(payment);
            }

            UpdatedInvoices.add(inv);
          }
        }

        // Insert the Payment__c record if it's a non-cardpayment, or a cardpayment that succeeded
        if (createPaymentRecord){
          insert thisPayments;

          // If we've paid more than the invoice total, create credits
          if (payAmount > this.invoiceTotal) {
            Credit__c overpayCredit = new Credit__c();
            overpayCredit.Account__c = this.acc.id;
            overpayCredit.Credit_Used__c = 0;
            overpayCredit.Amount__c = payAmount - this.invoiceTotal;
            overpayCredit.Valid_From__c = date.today();
            overpayCredit.Account_Product__c = this.AccountProduct;
            insert overpayCredit;
          }
        }

        update UpdatedInvoices;
        complete = true;
        incomplete = false;
      }
    }

    MakeAPaymentPage.getParameters().put('id',this.acc.id);
    if (hasError){
      MakeAPaymentPage.getParameters().put('msg','Transaction Failed');
      MakeAPaymentPage.setRedirect(true);
      ApexPages.currentPage().getParameters().put('msg','');
      this.message = null;
      return null;
    } else {
      if (this.isCardPayment == false || paymentAttempt.Status__c == 'SUCCESS'){
        MakeAPaymentPage.getParameters().put('response', 'success');
      } else {
        MakeAPaymentPage.getParameters().put('response', paymentAttempt.Response_Message__c);
      }

      MakeAPaymentPage.setRedirect(true);
      return MakeAPaymentPage;
    }
  }

  // Return to the account page
  public PageReference returnToAccount() {
    PageReference AccountPage = new ApexPages.StandardController(this.acc).view();
    AccountPage.setRedirect(true);
    return AccountPage;
  }

  // Change payment type
  public PageReference ChangePaymentType() {
    this.isCardPayment = (this.PaymentType == 'CreditCardNew' || this.PaymentType == 'CreditCardExisting') ? true : false;

    return null;
  }


  // =============================================================
  // Test methods
  // =============================================================
  public static testMethod void testMethodBase() {

    // Setup companies
    Company__c slxau = new Company__c(
            Name = 'SponsoredLinX',
            Business_Name__c = 'SponsoredLinX',
            Checkout_Site__c = 'checkout_SLX',
            Payment_Gateway__c = 'Eway2',
            CurrencyIsoCode  = 'AUD'
    );
    insert slxau;

    Account testAc = new Account();
    testAc.BJB_Company__c = slxau.Id;
    testAc.Name = 'testacc';
    insert testAc;

    Test.startTest();
    ApexPages.standardController controller = new ApexPages.standardController(testAc);
    MakeAPayment testClass = new MakeAPayment(controller);
    testClass.getlistOfPayments();
    testClass.setlistOfPayments(new list<Payment__c>{});
    testClass.returnToAccount();
    testClass.changePaymentType();
    testClass.getPaymentTypes();
    testClass.getinvoiceItems();
    testClass.getInvoiceIds();
    testClass.ChangeInvoice();
    Test.stopTest();
  }

  public static testMethod void testMethodEway() {

    // Setup companies
    Company__c slxau = new Company__c(
            Name = 'SponsoredLinX',
            Business_Name__c = 'SponsoredLinX',
            Checkout_Site__c = 'checkout_SLX',
            Payment_Gateway__c = 'Eway2',
            CurrencyIsoCode  = 'AUD'
    );
    insert slxau;

    Account testAc = new Account();
    testAc.BJB_Company__c = slxau.Id;
    testAc.Name = 'testacc';
    insert testAc;

    Account_Product__c testAccPr = new Account_Product__c();
    testAccPr.Payment_Option__c = 'Eway';
    testAccPr.Name_On_Card__c = 'test';
    testAccPr.Card_Number__c = '1234123412341234';
    testAccPr.Card_Month_Expiry__c = '5';
    testAccPr.Card_Year_Expiry__c = '1010';
    testAccPr.Card_CVN__c = '123';
    testAccPr.Product_Price__c = 20;
    insert testAccPr;

    Invoice__c testInv = new Invoice__c();
    testInv.Invoice_Number__c = '1';
    testInv.Amount_Due__c = 50;
    testInv.CurrencyIsoCode = 'AUD';
    testInv.Status__c = 'PARTIALLY PAID';
    testInv.Account__c=testAc.Id;
    testInv.Account_Product__c = testAccPr.Id;
    insert testInv;

    list<Invoice__c> listTestInv = new list<Invoice__c>();
    listTestInv.add(testInv);

    Payment__c testPay = new Payment__c();

    Credit__c testCre = new Credit__c();
    testCre.Amount__c = 100;
    testCre.Credit_Used__c = 10;
    testCre.Account_Product__c = testAccPr.Id;
    testCre.Valid_From__c = date.today().addDays(-1);
    insert testCre;

    Contact testContact = new Contact();
    testContact.AccountId = testAc.Id;
    testContact.Title = 'Billing';
    testContact.FirstName = 'test';
    testContact.LastName = 'test';
    insert testContact;


    Test.startTest();

    List<SelectOption> testSelectOptions = new List<SelectOption>();

    ApexPages.standardController controller = new ApexPages.standardController(testAc);
    MakeAPayment testClass = new MakeAPayment(controller);
    testClass.PageLoad();
    testClass.acc = testAc;
    testClass.isTest = true;
    testClass.generateErrors = true;

    testClass.invoiceId = testInv.Id;

    testClass.setinvioce(listTestInv);
    testClass.Invoice = listTestInv;
    listTestInv = testClass.getinvoice();

    testClass.setcheckInvioce(listTestInv);
    testClass.checkInvoice = listTestInv;
    listTestInv = testClass.getcheckInvoice();

    testClass.setinputPayment(testPay);
    testPay = testClass.getinputPayment();

    testClass.setInvList(listTestInv);
    testClass.getInvList();
    testClass.getAllInvoiceTotal();
    testClass.ChangeInvoice();
    try{
      testClass.getUnpaidInvoiceTotal();
      testClass.paymentAmount = 0;
      testClass.submitPayment();
      testClass.paymentAmount = 20;
      testClass.submitPayment();
      testClass.getPaymentTypes();
      testClass.getInvoiceIds();
      testClass.returnToAccount();
    } catch (Exception E) {}

    Test.stopTest();
  }


}