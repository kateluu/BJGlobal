public with sharing class MakeARefund {
    public List<Invoice__c> invoices = new List<Invoice__c>();
    public List<RefundInvoice> invoiceList = new List<RefundInvoice>();
    public Account acc { get; set; }
    public boolean PageRefresh { get; set; }
    public String invoiceNumber { get; set; }
    public Decimal invoiceTotal { get; set; }
    public Decimal invoiceAmountDue { get; set; }
    public Decimal invoiceAmountPaid { get; set; }
    public Date invoiceDueDate { get; set; }
    public Date invoiceIssuedDate { get; set; }
    public Decimal amountPaid { get; set; }
    public String PaymentType { get; set; }
    public Decimal partialRefundAmount { get; set; }
    public Decimal singleRefundAmount { get; set; }
    public String PaymentReference { get; set; }
    public Decimal paymentAmount { get; set; }
    public String invoiceId { get; set; }
    public Decimal totalRefund { get; set; }
    public Integer invoicesSelected { get; set; }
    public String message { get; set; }
    public Payment__c inputPayment = new Payment__c();
    public Payment__c inputPaymentPartial = new Payment__c();
    public boolean isTest { get; set; }
    public boolean isCardPayment { get; set; }
    public boolean generateErrors { get; set; }
    //check the correct payment option gateway for each invoice
    public boolean isEway{get;set;}
    public boolean isCommwebSLX{get;set;}
    public boolean isCommwebGMT{get;set;}
    public Boolean showPaymentButton {get;set;}
    
    
    public static String PAYMENT_TYPE = 'Refund';
    public static String PAYMENT_STATUS_REFUNDED = 'REFUNDED';
    public static String PAYMENT_STATUS_PARTIALLY_REFUNDED = 'PARTIALLY REFUNDED';             
    public static String PAYMENTOPTION = 'Commweb';
    public static String REQUEST_REFUND_AMOUNT_IS_OVER_THE_PAID_AMOUNT = 'The requested refund amount is over the paid amount, the operation is rejected';

    public Payment__c getinputPayment() {
        return this.inputPayment;
    }
    public void setinputPayment(Payment__c value) {
        this.inputPayment = value;
    }
    public Payment__c getinputPaymentPartial() {
        return this.inputPaymentPartial;
    }
    public void setinputPaymentPartial(Payment__c value) {
        this.inputPaymentPartial = value;
    }

    public List<Invoice__c> getinvoices() {
        return this.invoices;
    }
    public void setinvoices(list<Invoice__c> value) {
        this.invoices = value;
    }

    public List<RefundInvoice> getInvoiceList() {
        return this.invoiceList;
    }
    public void setInvoiceList(list<RefundInvoice> value) {
        this.invoiceList = value;
    }


    public List<SelectOption> getInvoiceNumbers() {
        List<SelectOption> options = new List<SelectOption>();
        if (this.invoices != null) {
            for (Invoice__c thisInvoice : this.invoices) {
                options.add(new SelectOption(thisInvoice.Invoice_Number__c, thisInvoice.Invoice_Number__c));
            }
        }
        return options;
    }

    public MakeARefund(ApexPages.StandardController controller) {

        //this.PageRefresh = false;
        //this.message = '';

        this.acc = (Account) controller.getRecord();
        String id = this.acc.Id;
        this.acc = [
            SELECT Id,
                    Name,
                    Card_Number__c,
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
            WHERE ID = :id
        ];

        system.debug(this.acc);
        this.isTest = false;
        this.generateErrors = false;
        this.PageRefresh = false;
        this.inputPayment.Payment_Date__c = date.today();
        this.inputPayment.Payment_Type__c = 'Refund';
        this.isCardPayment = false;
        this.showPaymentButton = true;

        String message           ='' + ApexPages.CurrentPage().GetParameters().Get('response');
        String invoiceIds        ='' + ApexPages.CurrentPage().GetParameters().Get('invoiceIds');
        String OKinvoiceIds      ='' + ApexPages.CurrentPage().GetParameters().Get('OKinvoiceIds');
        String NOKinvoiceIds     ='' + ApexPages.CurrentPage().GetParameters().Get('NOKinvoiceIds');
        String pageHeaderReferer = ApexPages.currentPage().getHeaders().get('Referer');

        system.debug(message);
        system.debug(pageHeaderReferer);
        // Use the referrer parameter to only show the message when coming from Make a Payment page
        if (pageHeaderReferer != null && pageHeaderReferer.containsIgnoreCase('makearefund') && message != 'null') {
            if ( ApexPages.CurrentPage().GetParameters().Get('NOKinvoiceIds') == null || NOKinvoiceIds.equals('')) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.CONFIRM, ' Refund Transactions Completed. Successfully Refund Invoice Ids :' + OKinvoiceIds );
                ApexPages.addMessage(myMsg);
            } else {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.CONFIRM, ' Successfully Refund Invoice Ids :' + OKinvoiceIds );
                ApexPages.addMessage(myMsg);
                myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,  'Fail to Refund Invoice Ids : ' + NOKinvoiceIds);
                ApexPages.addMessage(myMsg);
            }
        }
    }

    public PageReference updateInvoices() {
        //this.invoices = this.invoices;
        update this.invoices;
        this.totalRefund = 0;
        this.invoicesSelected = 0;
        for (Invoice__c invoice : this.invoices) {
            if (invoice.Checked__c) {
                this.totalRefund += invoice.Amount_Paid__c;
                this.invoicesSelected += 1;
            }
        }
        return null;
    }

    public void buildRefundInvoiceList(List<Invoice__c> invoices){
            system.debug('this.invoiceList.size = ' + this.invoiceList.size());
            system.debug('this.invoices.size = ' + invoices.size());
            if(this.invoiceList==null || this.invoiceList.size()==0){
                this.invoiceList = new List<RefundInvoice>();
                for(Invoice__c item : invoices){
                    RefundInvoice inv = new RefundInvoice();
                    inv.isSelected = false;
                    inv.invoice  = item;
                    this.invoiceList.add(inv);
                }
            }
    }

    public PageReference updateRefundAmount(){
        this.totalRefund = 0;
        this.invoicesSelected = 0;
        for (RefundInvoice item : this.invoiceList) {
            if (item.isSelected == true) {
                this.totalRefund += item.invoice.Amount_Paid__c;
                this.invoicesSelected += 1;
            }
        }
        return null;
    }

    public PageReference PageLoad() {
        if (ApexPages.currentPage().getParameters().get('msg') != null)
            this.message = ApexPages.currentPage().getParameters().get('msg');
        try{
            this.invoices = [
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
                            Account_Product__r.OwnerId,
                            Account_Product__r.Name,
                            Account_Product__r.Payment_Option__c,
                            Account_Product__r.Name_On_Card__c,
                            Account_Product__r.Card_Number__c,
                            Account_Product__r.Card_Month_Expiry__c,
                            Account_Product__r.Card_Year_Expiry__c,
                            Account_Product__r.Card_CVN__c,
                            Account_Product__r.SLX_Product__r.company_name__c,
                            Account__c,
                            Checked__c,
                            Invoice_Number__c,
                            Invoice_Total__c,
                            Amount_Paid__c,
                            Amount_Due__c,
                            Due_Date__c,
                            Issue_Date__c,
                            Amount_Refunded__c,
                            Payment_Response__c,
                            Payment_Option__c,
                            CurrencyIsoCode
                    FROM
                            Invoice__c
                    WHERE
                    Account__c = :acc.Id
                    AND
                    (Status__c = 'PAID' OR Status__c = 'PARTIALLY PAID' OR Status__c = 'PARTIALLY REFUNDED')
                    order by
                            Issue_Date__c ASC
            ];
        
            for (Invoice__c thisInvoice : this.invoices) {
                thisInvoice.Checked__c = false;
                this.invoiceNumber = thisInvoice.Invoice_Number__c;
            }
    
            updateInvoices();
            updateRefundAmount();
            buildRefundInvoiceList(this.invoices );
            ChangeInvoiceNumber();
        }catch(Exception e){
            ApexPages.currentPage().getParameters().put('msg', e.getMessage());
        }
        return null;
    }

/*--------------------------------------------------------------------------------------------------------------------*/
//    created on : 06/03/2018
//    created by : Kate Luu
//    description : support refund for SLX/GMT NZ company with payment option value is Commweb with test merchant profile
/*--------------------------------------------------------------------------------------------------------------------*/
    public pageReference bulkTestRefund() {
        this.isTest = true;
        return bulkEwayCommwebRefunds();
    }

    // need update validation condition for total value
    public pageReference bulkEwayCommwebRefunds() {
        // Error checking
        Boolean hasError = false;
        String refundInvoices = '';
        // set contact information
        Contact contact;
        try {
            contact = [SELECT Id,Name,FirstName, LastName, Email, MailingStreet, MailingCity, MailingPostalCode, MailingState,MailingCountry FROM Contact WHERE AccountId = :acc.Id and Title = 'Billing' limit 1];
        } catch (Exception e) {
            System.debug('Exception: ' + e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Unable to load the Billing contact for this account'));
            hasError = true;
        }

        List<RefundInvoice> selectedInvoices = new List<RefundInvoice>();
        for (RefundInvoice item : this.invoiceList) {            
            if ((item.isSelected == true) && (item.invoice.payment_Response__c!= null)) {
                selectedInvoices.add(item);
            }
        }
        system.debug('selectedInvoices.size = ' + selectedInvoices.size());

        
        // create card transaction payment
        Payment_Attempt__c paymentAttempt = new Payment_Attempt__c();
        List<Payment__c> refundPayments = new List<Payment__c>();
        List<Invoice__c> updateInvoices = new List<Invoice__c>();
        String successRefundInvoiceIds ='';
        String failedRefundInvoiceIds = '';

        if (!hasError) {
            this.message = '';
            for (RefundInvoice item : selectedInvoices) {

                    if(refundInvoices.length()>0) refundInvoices += ',';
                    refundInvoices += item.invoice.Invoice_Number__c ;
                    // actual refund transaction
                    // New code - use standard paymentGateway class
                    // Transaction with the gateway
                    PaymentGateway refundPaymentGateway = new PaymentGateway();
                    refundPaymentGateway.setBjbCompany(this.acc.BJB_Company__r);
                    refundPaymentGateway.amount = item.invoice.Amount_Paid__c;
                    refundPaymentGateway.currencyIsoCode = this.acc.CurrencyIsoCode;
                    refundPaymentGateway.customerFirstName = contact.FirstName;
                    refundPaymentGateway.customerLastName = contact.LastName;
                    refundPaymentGateway.customerEmail = String.valueOf(contact.Email);
                    refundPaymentGateway.customerStreet = contact.MailingStreet;
                    refundPaymentGateway.customerCity = contact.MailingCity;
                    refundPaymentGateway.customerState = contact.MailingState;
                    refundPaymentGateway.customerPostcode = contact.MailingPostalCode;
                    refundPaymentGateway.cardHoldersName = this.acc.Name_On_Card__c;
                    refundPaymentGateway.cardNumber = this.acc.Card_Number__c;
                    refundPaymentGateway.cardExpiryMonth = this.acc.Card_Month_Expiry__c;
                    refundPaymentGateway.cardExpiryYear = this.acc.Card_Year_Expiry__c;
                    refundPaymentGateway.cardCVN = this.acc.Card_CVN__c;
                    refundPaymentGateway.customerInvoiceDescription = this.acc.Unique_Id__c;
                    refundPaymentGateway.customerInvoiceRef = item.invoice.Invoice_Number__c;        
                    refundPaymentGateway.uniqueAttemptId = DateTime.now().format('yyyyMMdd');
                    refundPaymentGateway.transactionNo = item.invoice.payment_Response__c;

                    // Use a test gateway when in the sandbox or running a test method.
                    //if (this.isTest || this.generateErrors == true || utility.runningInASandbox()) {
                    if (this.isTest || this.generateErrors == true) {
                        system.debug('MakeARefund CLass :: isTest ::GATEWAY_MOCK' +  paymentGateway.GATEWAY_MOCK);
                        refundPaymentGateway.testGateway = paymentGateway.GATEWAY_MOCK;
                        refundPaymentGateway.testType = paymentGateway.TEST_SUCCESS;
                    }

                    try {
                        paymentAttempt = refundPaymentGateway.refund();
                    } catch (Exception e) {
                        string errorDetail = 'Error in MakeARefund: ' + e.getMessage() + '. On ' + e.getStackTraceString();
                        Utility.notifySysadmin('Error in pay.pay', errorDetail);
                        system.debug(errorDetail);
                    }


                    // checking response code value if it is not error code
                    if ((paymentAttempt.Response_Code__c == '00') || (paymentAttempt.Status__c == 'SUCCESS')){

                        // create payment records - transaction infomation , not actually to the refund
                        Payment__c RefundPayment    = new Payment__c();
                        Credit__c RefundCredit      = new Credit__c();

                        Decimal refundAmount                = item.invoice.Amount_Paid__c;                    
                        RefundPayment.Account__c            = acc.Id;
                        RefundPayment.Payment_Type__c       = PAYMENT_TYPE;
                        RefundPayment.Payment_Amount__c     = -refundAmount ;                    
                        RefundPayment.Notes__c              = inputPayment.Notes__c;
                        RefundPayment.Payment_Date__c       = Date.today();

                        RefundPayment.Invoice__c            = item.invoice.Id;
                        RefundPayment.Invoice_Number__c     = item.invoice.Invoice_Number__c;                    
                        RefundPayment.Payment_Option__c     = refundPaymentGateway.gateway ;
                        RefundPayment.CurrencyIsoCode       = item.invoice.CurrencyIsoCode;
                        RefundPayment.Account_Product__c    = item.invoice.Account_Product__c;
                        RefundPayment.Payment_Owner__c      = item.invoice.Account_Product__r.OwnerId;                    
                        RefundPayment.Payment_Reference__c  = paymentAttempt.Gateway_Transaction_Id__c; //capture refund transaction ID
                        RefundPayments.add(RefundPayment);

                        item.invoice.Status__c = PAYMENT_STATUS_REFUNDED;                        
                        item.invoice.Amount_Refunded__c = item.invoice.Amount_Paid__c;
                        item.invoice.Amount_Paid__c = 0;
                        system.debug(item.invoice.Invoice_Total__c);
                        system.debug(item.invoice.Amount_Refunded__c);                        
                        updateInvoices.add(item.invoice);
                        successRefundInvoiceIds += item.invoice.Invoice_Number__c +', ';
                    }else{
                        failedRefundInvoiceIds += item.invoice.Invoice_Number__c + ' : ' +paymentAttempt.Response_Message__c +',\n ';
                    }

                }
        }

        if (RefundPayments.size() > 0) {
            insert RefundPayments;
            //insert RefundCredits;
            update updateInvoices;
            this.invoices = [
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
                            Account_Product__r.OwnerId,
                            Account_Product__r.Name,
                            Account_Product__r.Payment_Option__c,
                            Account_Product__r.Name_On_Card__c,
                            Account_Product__r.Card_Number__c,
                            Account_Product__r.Card_Month_Expiry__c,
                            Account_Product__r.Card_Year_Expiry__c,
                            Account_Product__r.Card_CVN__c,
                            Account__c,
                            Checked__c,
                            Invoice_Number__c,
                            Invoice_Total__c,
                            Amount_Paid__c,
                            Amount_Due__c,
                            Due_Date__c,
                            Issue_Date__c,
                            Amount_Refunded__c,
                            CurrencyIsoCode
                    FROM
                            Invoice__c
                    WHERE
                    Account__c = :acc.Id
                    AND
                    (Status__c = 'PAID' OR Status__c = 'PARTIALLY PAID' OR Status__c = 'PARTIALLY REFUNDED')
                    order by
                            Issue_Date__c
            ];
            //update refund details
            this.totalRefund = 0;
            this.invoicesSelected = 0;
            this.inputPayment = new Payment__c();
            this.inputPaymentPartial = new Payment__c();
            
            //update refund list
            this.buildRefundInvoiceList(this.invoices);
            this.updateRefundAmount();
        }

        PageReference MakeARefundPage = new PageReference('/apex/MakeARefund');
        MakeARefundPage.getParameters().put('id', this.acc.id);
        if (hasError) {
            MakeARefundPage.getParameters().put('msg', 'Transaction Failed');
            MakeARefundPage.setRedirect(true);
            ApexPages.currentPage().getParameters().put('msg', '');
            this.message = null;
            return null;
        }
        
        
        if (paymentAttempt.Status__c == 'SUCCESS') {
            MakeARefundPage.getParameters().put('response', 'success');
            MakeARefundPage.getParameters().put('OKinvoiceIds',successRefundInvoiceIds);
            MakeARefundPage.getParameters().put('NOKinvoiceIds', failedRefundInvoiceIds);
        } else {
            MakeARefundPage.getParameters().put('response', paymentAttempt.Response_Message__c);
            MakeARefundPage.getParameters().put('OKinvoiceIds',successRefundInvoiceIds);
            MakeARefundPage.getParameters().put('NOKinvoiceIds', failedRefundInvoiceIds);
        }

        //MakeARefundPage.getParameters().put('msg', this.message);
        MakeARefundPage.setRedirect(true);
        return MakeARefundPage;
        //return null;
         
    }

    public boolean validate(Invoice__c invoice){
        if (this.singleRefundAmount > invoice.Amount_Paid__c) {
          System.debug('Error: ' + MakeARefund.REQUEST_REFUND_AMOUNT_IS_OVER_THE_PAID_AMOUNT);
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error:'+ MakeARefund.REQUEST_REFUND_AMOUNT_IS_OVER_THE_PAID_AMOUNT));
          return true;
        }
        return false;
    }

    /********************************************************/
    /********************************************************/
    public pageReference refund() {
        System.debug('Refund methods: ');
        Payment_Attempt__c paymentAttempt = new Payment_Attempt__c();
        boolean hasError = false;

        // set contact information
        Contact contact;
        try {
            contact = [SELECT Id,Name,FirstName, LastName, Email, MailingStreet, MailingCity, MailingPostalCode, MailingState,MailingCountry FROM Contact WHERE AccountId = :acc.Id and Title = 'Billing' limit 1];
        } catch (Exception e) {
            System.debug('Exception: ' + e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Unable to load the Billing contact for this account'));
            hasError = true;
        }


        List<Invoice__c> SelectedInvoices = new List<Invoice__c>();
        for (Invoice__c invoice : this.invoices) {
            if (invoice.Invoice_Number__c == this.invoiceNumber) {
                SelectedInvoices.add(invoice);
            }
        }

        List<Payment__c> RefundPayments = new List<Payment__c>();
        List<Credit__c> RefundCredits = new List<Credit__c>();
        List<Invoice__c> updateInvoices = new List<Invoice__c>();
        if(!hasError){
            for (Invoice__c invoice : SelectedInvoices) {
                    hasError = validate( invoice);
                    if (hasError) break;
                    //this.singleRefundAmount = invoice.Amount_Paid__c;
                    //process eway refund
                     System.debug('invoice.Account_Product__r.Payment_Option__c = ' + invoice.Account_Product__r.Payment_Option__c  );

                    // change to use eway2Payment instead ewayrefund
                    // actually refund transaction
                    // New code - use standard paymentGateway class
                    // Transaction with the gateway
                    PaymentGateway refundPaymentGateway = new PaymentGateway();
                    refundPaymentGateway.setBjbCompany(this.acc.BJB_Company__r);
                    refundPaymentGateway.amount = this.singleRefundAmount;
                    refundPaymentGateway.currencyIsoCode = this.acc.CurrencyIsoCode;
                    refundPaymentGateway.customerFirstName = contact.FirstName;
                    refundPaymentGateway.customerLastName = contact.LastName;
                    refundPaymentGateway.customerEmail = String.valueOf(contact.Email);
                    refundPaymentGateway.customerStreet = contact.MailingStreet;
                    refundPaymentGateway.customerCity = contact.MailingCity;
                    refundPaymentGateway.customerState = contact.MailingState;
                    refundPaymentGateway.customerPostcode = contact.MailingPostalCode;

                    refundPaymentGateway.cardHoldersName = this.acc.Name_On_Card__c;
                    refundPaymentGateway.cardNumber = this.acc.Card_Number__c;
                    refundPaymentGateway.cardExpiryMonth = this.acc.Card_Month_Expiry__c;
                    refundPaymentGateway.cardExpiryYear = this.acc.Card_Year_Expiry__c;
                    refundPaymentGateway.cardCVN = this.acc.Card_CVN__c;
                    refundPaymentGateway.customerInvoiceDescription = this.acc.Unique_Id__c;
                    refundPaymentGateway.customerInvoiceRef = this.invoiceNumber;
                    refundPaymentGateway.uniqueAttemptId = DateTime.now().format('yyyyMMdd');
                    refundPaymentGateway.transactionNo = invoice.payment_Response__c;

                    // Use a test gateway when in the sandbox or running a test method.
                    //if (this.isTest || this.generateErrors == true || utility.runningInASandbox()) {
                    if (this.isTest || this.generateErrors == true) {
                        refundPaymentGateway.testGateway = paymentGateway.GATEWAY_MOCK;
                        refundPaymentGateway.testType = paymentGateway.TEST_SUCCESS;
                    }

                    try {
                        paymentAttempt = refundPaymentGateway.refund();
                    } catch (Exception e) {
                        string errorDetail = 'Error in MakeARefund: ' + e.getMessage() + '. On ' + e.getStackTraceString();
                        Utility.notifySysadmin('Error in pay.pay', errorDetail);
                        system.debug(errorDetail);
                    }


                    // Checking response code value if it is not error code
                    // Response_Code__c for commweb
                    // Status__c for Eway
                    System.debug('paymentAttempt.Response_Code__c = ' +  paymentAttempt.Response_Code__c );
                    if ((paymentAttempt.Response_Code__c == '00') || (paymentAttempt.Status__c == 'SUCCESS')){
                        System.debug('Add refund payment ');
                        // create payment records - transaction infomation , not actually to the refund
                        Payment__c RefundPayment = new Payment__c();
                        Credit__c RefundCredit = new Credit__c();

                        Decimal RefundAmount = invoice.Amount_Paid__c;
                        RefundPayment.Account__c = acc.Id;
                        RefundPayment.Payment_Type__c = PAYMENT_TYPE;
                        RefundPayment.Payment_Amount__c = -singleRefundAmount;
                        RefundPayment.Invoice__c = invoice.Id;
                        RefundPayment.Invoice_Number__c = invoice.Invoice_Number__c;
                        RefundPayment.Notes__c = inputPayment.Notes__c;
                        RefundPayment.Payment_Date__c = Date.today();
                        RefundPayment.Payment_Option__c = refundPaymentGateway.gateway ; //invoice.Account_Product__r.Payment_Option__c;
                        RefundPayment.CurrencyIsoCode = invoice.CurrencyIsoCode;
                        RefundPayment.Account_Product__c = invoice.Account_Product__c;
                        RefundPayment.Payment_Owner__c = invoice.Account_Product__r.OwnerId;
                        RefundPayments.add(RefundPayment);

                        if (invoice.Amount_Refunded__c == null) invoice.Amount_Refunded__c = 0;
                        invoice.Amount_Refunded__c = invoice.Amount_Refunded__c + singleRefundAmount;
                        system.debug(invoice.Invoice_Total__c);
                        system.debug(invoice.Amount_Refunded__c);

                        if (invoice.Invoice_Total__c <= invoice.Amount_Refunded__c) invoice.Status__c = PAYMENT_STATUS_REFUNDED;
                        if (invoice.Invoice_Total__c > 0 && invoice.Invoice_Total__c > invoice.Amount_Refunded__c)invoice.Status__c = PAYMENT_STATUS_PARTIALLY_REFUNDED;
                        invoice.Amount_Paid__c = invoice.Amount_Paid__c - singleRefundAmount;
                        updateInvoices.add(invoice);
             
                    }
                
            }

            if(RefundPayments.size()>0) {
                System.debug('Start create refund payment ');                
                insert RefundPayments;
                System.debug('End create refund payment');

                update updateInvoices;
            }            
            

            this.invoices = [
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
                            Account_Product__r.OwnerId,
                            Account_Product__r.Name,
                            Account_Product__r.Payment_Option__c,
                            Account_Product__r.Name_On_Card__c,
                            Account_Product__r.Card_Number__c,
                            Account_Product__r.Card_Month_Expiry__c,
                            Account_Product__r.Card_Year_Expiry__c,
                            Account_Product__r.Card_CVN__c,
                            Account__c,
                            Checked__c,
                            Invoice_Number__c,
                            Invoice_Total__c,
                            Amount_Paid__c,
                            Amount_Due__c,
                            Due_Date__c,
                            Issue_Date__c,
                            Amount_Refunded__c,
                            CurrencyIsoCode
                    FROM
                            Invoice__c
                    WHERE
                    Account__c = :acc.Id
                    AND
                    (Status__c = 'PAID' OR Status__c = 'PARTIALLY PAID' OR Status__c = 'PARTIALLY REFUNDED')
                    order by
                            Issue_Date__c
            ];
            this.totalRefund = 0;
            this.invoicesSelected = 0;
            this.inputPayment = new Payment__c();
            this.inputPaymentPartial = new Payment__c();
        }


        PageReference MakeARefundPage = new PageReference('/apex/MakeARefund');
        MakeARefundPage.getParameters().put('id', this.acc.id);
        if (hasError) {
            MakeARefundPage.getParameters().put('msg', 'Transaction Failed');
            MakeARefundPage.setRedirect(true);
            ApexPages.currentPage().getParameters().put('msg', '');
            this.message = null;
            return null;
        }

                
        if (paymentAttempt.Status__c == 'SUCCESS') {
            MakeARefundPage.getParameters().put('response', 'success');            
            MakeARefundPage.getParameters().put('OKinvoiceIds',this.invoiceNumber);

        } else {
            MakeARefundPage.getParameters().put('response', paymentAttempt.Response_Message__c);            
            MakeARefundPage.getParameters().put('NOKinvoiceIds', this.invoiceNumber);
        }

        MakeARefundPage.setRedirect(true);
        return MakeARefundPage;

    }


    public void ChangeInvoiceNumber() {
        for (Invoice__c thisInvoice : this.invoices) {
            if (thisInvoice.Invoice_Number__c == this.invoiceNumber) {
                this.invoiceNumber = thisInvoice.Invoice_Number__c;
                this.invoiceTotal = thisInvoice.Amount_Due__c;
                this.paymentAmount = thisInvoice.Amount_Due__c;
                this.PaymentReference = thisInvoice.Invoice_Number__c;
                this.PaymentType = thisInvoice.Account_Product__r.Payment_Option__c;
                this.amountPaid = thisInvoice.Amount_Paid__c;
                this.InvoiceId = thisInvoice.Id;
                if (thisInvoice.Amount_Refunded__c == null) {
                    thisInvoice.Amount_Refunded__c = 0;
                }
                //init the refund amount
                singleRefundAmount = thisInvoice.Amount_Paid__c;

                this.partialRefundAmount = thisInvoice.Invoice_Total__c - thisInvoice.Amount_Refunded__c;
                this.invoiceAmountDue = thisInvoice.Amount_Due__c;
                this.invoiceAmountPaid = thisInvoice.Amount_Paid__c;
                this.invoiceDueDate = thisInvoice.Due_Date__c;
                this.invoiceIssuedDate = thisInvoice.Issue_Date__c;
            }
        }
    }

    public PageReference returnToAccount() {
        PageReference AccountPage = new ApexPages.StandardController(this.acc).view();
        AccountPage.setRedirect(true);
        return AccountPage;
    }

    public static testMethod void testMethod1() {
         //create account
            List<Account> testAccts = new List<Account>();
            Account itemAcc = new Account(Name = 'TestAccount1', username__c = 'TestAccount1', password__c = 'TestAccount1', CurrencyIsoCode = 'AUD',Num_of_Escalated_Case__c =10, phone='1300859600' , Card_Month_Expiry__c='05', Card_Year_Expiry__c='21');
            
            insert itemAcc;

            // create account products
            List<Account_Product__c> testProducts = new List<Account_Product__c>();
            Account_Product__c item1 = new Account_Product__c(Payment_Option__c = 'Eway',Name = 'Social' + 1, Product_Price__c = 1000, CurrencyIsoCode = 'AUD', Account__c = itemAcc.id);
            insert item1;            
            Account_Product__c item2 = new Account_Product__c(Payment_Option__c = 'Commweb',Name = 'Social' + 1, Product_Price__c = 1000, CurrencyIsoCode = 'AUD', Account__c = itemAcc.id);
            insert item2;


        //Account testAc = new Account();
        //testAc.Name = 'testacc';
        //insert testAc;
        Test.startTest();
        ApexPages.standardController controller = new ApexPages.standardController(itemAcc);
        MakeARefund testClass = new MakeARefund(controller);
        testClass.invoiceNumber = '1';
        testClass.isTest = true;

        Invoice__c testInv = new Invoice__c();
        testInv.Invoice_Number__c = '1';
        testInv.Amount_Due__c = 0;
        testInv.Amount_Paid__c = 100;
        testInv.Amount_Refunded__c = 0;
        testInv.Invoice_Total__c = 100;
        testInv.Status__c = 'PAID';
        testInv.Account__c = itemAcc.Id;
        testInv.Checked__c = true;
        testInv.Payment_Response__c='123456';
        testInv.Account_Product__c= item1.id;
        insert testInv;

        Payment__c payment = new Payment__c();
        list<Invoice__c> invoices = new list<Invoice__c>();
        invoices.add(testInv);


        testClass.PageLoad();
        testClass.setinvoices(invoices);
        testClass.getinvoices();

        testClass.ChangeInvoiceNumber();
        testClass.getinputPayment();
        testClass.setinputPayment(payment);
        testClass.getinputPaymentPartial();
        testClass.setinputPaymentPartial(payment);


        List<SelectOption> testOp = new List<SelectOption>();
        testOp = testClass.getInvoiceNumbers();
        testClass.bulkEwayCommwebRefunds();
        //testClass.singleRefundAmount = 120;
        //testClass.singleRefund();
        //testClass.singleRefundAmount = 100;
        //testClass.singleRefund();
        testClass.refund();
        testClass.returnToAccount();


        testClass.invoiceNumber = '2';

        
        testInv.Invoice_Number__c = '2';
        testInv.Account_Product__c= item2.id;
        update testInv;

        //testClass.singleRefundAmount = 120;
        //testClass.singleRefund();
        //testClass.singleRefundAmount = 100;
        //testClass.singleRefund();

        Test.stopTest();
    }



    public class RefundInvoice {
        public boolean isSelected {get; set;}
        public Invoice__c invoice {get; set;}

        public RefundInvoice(){

        }
    }
}