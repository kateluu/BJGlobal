public with sharing class paymentGateway {

    // Constants
    public static final Integer TEST_SUCCESS = 3; // Get a dummy success response from the gateway.
    public static final Integer TEST_FAILURE = 4; // Get a dummy failure response from the gateway.
    public static final Integer TEST_DECLINE = 5;
    public static final Integer TEST_EXPIRED = 6;
    public static final Integer TEST_TIMEOUT = 7;

    public static final Integer GATEWAY_REAL = 0; // Communicate with real gateway.
    public static final Integer GATEWAY_MOCK = 1; // Communicate with mock gateway.
    public static final Integer GATEWAY_LOCAL = 2; // Don't communicate with gateway, just fake a response.

    // Properties
    public Company__c bjbCompany { get; set; }
    public String gateway { get; set; }
    public Boolean isRefund { get; set; }
    public Integer testType { get; set; }
    public Integer testGateway { get; set; }

    public Decimal amount = 0.00;
    public String currencyIsoCode = 'AUD';
    public String customerFirstName = '';
    public String customerLastName = '';
    public String customerEmail = '';
    public String customerIP;
    public String customerStreet = '';
    public String customerCity = '';
    public String customerState = '';
    public String customerPostcode = '';
    public String customerCountrycode = '';
    public String customerInvoiceDescription = '';
    public String customerInvoiceRef = '';
    public String uniqueAttemptId = '';
    public String transactionNo = '';


    public String cardHoldersName = '';
    public String cardNumber = '';
    public String cardExpiryMonth = '';
    public String cardExpiryYear = '';
    public String cardCVN = '';

    private transient Payment_Attempt__c paymentAttempt;

    // Classes
    public class paymentException extends Exception {
    }

    public class paymentResponse {
        String status;
        String response;
        String errorCode;
        String errorMessage;
    }

    // Constructor
    public paymentGateway() {
        this.isRefund = false;
        this.testType = null;
        this.testGateway = GATEWAY_REAL;
        //this.testGateway 	= GATEWAY_MOCK; // turn to test mode , make payment button
    }

    // Set the company that this payment is for
    public void setBjbCompany(Company__c company) {
        this.bjbCompany = company;

        this.currencyIsoCode = company.currencyIsoCode;

        // Use the default gateway and merchant for this company
        this.gateway = this.bjbCompany.Payment_Gateway__c;
    }

    // Process the payment
    public Payment_Attempt__c pay() {
        system.debug('submitTestPayment :pay :pay');
        // Each time this method is called, it must log a Payment_Attempt__c record
        this.paymentAttempt = new Payment_Attempt__c();

        try {
            // Error checking
            validate();

            // Create a this.paymentAttempt__c record to track this payment attempt
            // Note: We can't insert the payment attempt before using the payment gateway webservice because we'll get the error "You have uncommitted
            // work pending. Please commit or rollback before calling out"
            this.paymentAttempt.Status__c = 'IN PROGRESS';
            this.paymentAttempt.Payment_Amount__c = this.amount;
            this.paymentAttempt.CurrencyIsoCode = this.currencyIsoCode;
            this.paymentAttempt.Payment_Name__c = this.customerFirstName + ' ' + this.customerLastName;
            this.paymentAttempt.Payment_Email__c = this.customerEmail;
            this.paymentAttempt.Payment_Option__c = this.gateway;
            this.paymentAttempt.Payment_Type__c = this.isRefund ? 'Refund' : 'Payment';
            this.paymentAttempt.Request_Time__c = datetime.now();
            this.paymentAttempt.Invoice_Number__c = this.customerInvoiceRef;

            // Process using the method for the selected gateway
            if (this.gateway == 'Eway') {
                this.payEway();
            } else if (this.gateway == 'Eway2') {
                this.payEway2();
            } else if (this.gateway == 'Commweb') {
                this.payCommWeb();
            } else if (this.gateway == 'Commweb2') {
                this.payCommWeb2();
            } else {
                throw new paymentException('Unrecognised gateway');
            }
        } catch (Exception e) {
            this.paymentAttempt.Status__c = 'FAILURE';
            //this.paymentAttempt.Response_Code__c = '0';
            this.paymentAttempt.Response_Message__c = e.getMessage();

            system.debug('Error: ' + e.getMessage() + ' on ' + e.getStackTraceString());
        }

        return this.paymentAttempt;
    }

    // Process the refund
    public Payment_Attempt__c refund() {
        system.debug('paymentgetway:refund method');
        // Each time this method is called, it must log a Payment_Attempt__c record
        this.paymentAttempt = new Payment_Attempt__c();

        try {
            // Error checking
            // validate();

            // Create a this.paymentAttempt__c record to track this payment attempt
            // Note: We can't insert the payment attempt before using the payment gateway webservice because we'll get the error "You have uncommitted
            // work pending. Please commit or rollback before calling out"
            this.paymentAttempt.Status__c = 'IN PROGRESS';
            this.paymentAttempt.Payment_Amount__c = this.amount;
            this.paymentAttempt.CurrencyIsoCode = this.currencyIsoCode;
            this.paymentAttempt.Payment_Name__c = this.customerFirstName + ' ' + this.customerLastName;
            this.paymentAttempt.Payment_Email__c = this.customerEmail;
            this.paymentAttempt.Payment_Option__c = this.gateway;
            this.paymentAttempt.Payment_Type__c = 'Refund' ;
            this.paymentAttempt.Request_Time__c = datetime.now();
            this.paymentAttempt.Invoice_Number__c = this.customerInvoiceRef;

            // Process using the method for the selected gateway
            if (this.gateway == 'Eway2') {
                this.isRefund = true;
                this.payEway2();
            } else if (this.gateway == 'Commweb') {
                this.refundCommWeb();
            } else if (this.gateway == 'Commweb2') {
                this.refundCommWeb2();
            } else {
                throw new paymentException('Unrecognised gateway');
            }
        } catch (Exception e) {
            this.paymentAttempt.Status__c = 'FAILURE';
            this.paymentAttempt.Response_Code__c = '0';
            this.paymentAttempt.Response_Message__c = e.getMessage();

            system.debug('Error: ' + e.getMessage() + ' on ' + e.getStackTraceString());
        }

        return this.paymentAttempt;
    }

    // Check whether we have all the data required to make the payment
    public boolean validate() {
        // Clean the data
        // TODO: This should really be done when the data is originally set
        
        // strip non-numeric
        if (this.cardCVN != null){
            this.cardCVN    = this.cardCVN.replaceAll('[^0-9]', '');
        }

        // strip non-numeric
        if (this.cardNumber != null){
            this.cardNumber = this.cardNumber.replaceAll('[^0-9]', '');
        }

        // Validate
        if (this.amount <= 0.00) {
            throw new paymentException('Amount must be a positive decimal');
        }

        return true;
    }

    // Pay via Eway
    private void payEway() {
        ewayPayment eway = new ewayPayment();
        ewayResponse ewayRep;

        if (this.bjbCompany.Name == 'Get More Traffic') {
            eway.setMode('Get More Traffic');
        } else {
            eway.setMode('SponsoredLinx');
        }

        // Simulate eway test if required
        if (this.testType == TEST_SUCCESS) {
            eway.setMode('test');
            this.cardNumber = '4444333322221111';
            this.amount = 40.00; // Success
        } else if (this.testType == TEST_FAILURE) {
            eway.setMode('test');
            this.cardNumber = '4444333322221111';
            this.amount = 44.44; // Failure
        }

        Integer amountInCents = Integer.valueOf((this.amount.setScale(2) * 100).setScale(0));

        eway.setewayTotalAmount(String.valueOf(amountInCents));
        eway.setewayCustomerFirstName(this.customerFirstName);
        eway.setewayCustomerLastName(this.customerLastName);
        eway.setewayCustomerEmail(this.customerEmail);
        eway.setewayCustomerAddress(this.customerStreet + ' ' + this.customerCity);
        eway.setewayCustomerPostcode(this.customerPostcode);

        eway.setewayCustomerInvoiceDescription(this.customerInvoiceDescription);
        eway.setewayCustomerInvoiceRef(this.customerInvoiceRef);
        eway.setewayCardHoldersName(this.cardHoldersName);
        eway.setewayCardNumber(this.cardNumber);
        eway.setewayCardExpiryMonth(this.cardExpiryMonth);
        eway.setewayCardExpiryYear(this.cardExpiryYear.substring(2, 4));
        eway.setewayCVN(this.cardCVN);

        // Only store the request for Dev. We can't store it on live request becacuse it includes the cardnumber
        if (this.testType != null || utility.runningInASandbox()) {
            this.paymentAttempt.Request__c = JSON.serialize(eway);
        }

        // process eway response
        System.debug('EWAY Payment: ' + eway);
        if (this.testGateway == GATEWAY_LOCAL) {
            // Return a test response without contacting the gateway
            String xml = '';
            xml += '<ewayResponse>';

            if (this.testType == TEST_SUCCESS) {
                xml += '  <ewayTrxnError></ewayTrxnError>';
                xml += '  <ewayTrxnStatus>True</ewayTrxnStatus>';
            } else {
                xml += '  <ewayTrxnError>Test failure response</ewayTrxnError>';
                xml += '  <ewayTrxnStatus>False</ewayTrxnStatus>';
            }

            xml += '  <ewayTrxnNumber>10002</ewayTrxnNumber>';
            xml += '  <ewayTrxnOption1></ewayTrxnOption1>';
            xml += '  <ewayTrxnOption2></ewayTrxnOption2>';
            xml += '  <ewayTrxnOption3></ewayTrxnOption3>';
            xml += '  <ewayReturnAmount>' + String.valueOf(amountInCents) + '</ewayReturnAmount>';
            xml += '  <ewayAuthCode>123456</ewayAuthCode>';
            xml += '  <ewayTrxnReference>987654321</ewayTrxnReference>';
            xml += '</ewayResponse>';

            Dom.Document domDoc = new Dom.Document();
            domDoc.load(xml);

            ewayRep = new ewayResponse();
            ewayRep.loadResponse(domDoc);
        } else {
            if (this.testGateway == GATEWAY_MOCK) {
                eway.setMode('mock');
            }

            ewayRep = eway.makePayment();
        }

        // Update the this.paymentAttempt with the response
        this.paymentAttempt.Response__c = JSON.serialize(ewayRep);

        this.paymentAttempt.Response_Code__c = '';
        this.paymentAttempt.Response_Message__c = ewayRep.getewayTrxnError();
        this.paymentAttempt.Gateway_Transaction_Id__c = ewayRep.getewayTrxnNumber();

        if (ewayRep.getewayTrxnStatus() == 'True') {
            this.paymentAttempt.Status__c = 'SUCCESS';
        } else {
            this.paymentAttempt.Status__c = 'FAILURE';
        }
    }

    // Pay via Eway Rapid API (new)
    private void payEway2() {
        // Load an Eway payment from these details
        Eway2Payment eway = Eway2Payment.loadFromGateway(this);

        Eway2Response ewayResp;

        if (this.isRefund){
            ewayResp = eway.makeRefund();
        } else {
            ewayResp = eway.makePayment();
        }

        // Only store the request for Dev. We can't store it on live request becacuse it includes the cardnumber
        if (utility.runningInASandbox()) {
            this.paymentAttempt.Request__c = eway.requestBody;
        }

        // Update the this.paymentAttempt with the response
        this.paymentAttempt.Response__c = ewayResp.responseBody;
        this.paymentAttempt.Response_Code__c = ewayResp.getErrorCode();
        this.paymentAttempt.Response_Message__c = ewayResp.getErrorMessage();
        this.paymentAttempt.Gateway_Transaction_Id__c = ewayResp.getTrxnNumber();
        this.paymentAttempt.Status__c = ewayResp.isSuccessful() ? 'SUCCESS' : 'FAILURE';
    }


    // Pay via CommWeb (Old - SLX)
    private void payCommWeb() {
        system.debug('submitTestPayment:payCommWeb');
        commwebPayment commweb = new CommwebPayment();
        CommwebResponse commwebResp = new CommwebResponse();

        Integer amountInCents = Integer.valueOf((this.amount.setScale(2) * 100).setScale(0));

        commweb.setAmount(String.valueOf(amountInCents));
        commweb.setCommwebMerchTxnRef(this.customerInvoiceRef);
        commweb.setOrderInfo(this.customerInvoiceDescription);
        commweb.setCardNum(this.cardNumber);

        // Pad month to two digits with left-side zeros
        String monthPadded = this.cardExpiryMonth.leftPad(2).replaceAll(' ', '0').substring(0, 2);

        commweb.setCardExp(this.cardExpiryYear.substring(2, 4) + monthPadded);


        if (this.testGateway == GATEWAY_LOCAL) {
            system.debug('submitTestPayment:payCommWeb: real payment');
            // Return a test response without contacting the gateway
            String respStr = 'vpc_Amount=' + String.valueOf(amountInCents);

            if (this.testType == TEST_SUCCESS) {
                respStr += '&vpc_TxnResponseCode=0';
            } else {
                respStr += '&vpc_TxnResponseCode=1';
                respStr += '&vpc_AcqResponseCode=1';
                respStr += '&vpc_Message=Test failure repsonse';
            }

            commwebResp.loadResponse(respStr);
        } else {
            if (this.testGateway == GATEWAY_MOCK) {
                system.debug('submitTestPayment:payCommWeb: test payment');
                commweb.setTestMode();

                if (this.testType == TEST_SUCCESS) {
                    commweb.setAmount('1000'); // $xx.00 = success
                } else if (this.testType == TEST_FAILURE) {
                    commweb.setAmount('1005'); // $xx.05 = declined
                }
            }

            commwebResp = commweb.makePayment();
        }

        System.debug('Commweb Response: ' + commwebResp);

        // Update the this.paymentAttempt with the response
        this.paymentAttempt.Response__c = JSON.serialize(commwebResp);

        this.paymentAttempt.Response_Code__c = commwebResp.vpc_AcqResponseCode;
        this.paymentAttempt.Response_Message__c = commwebResp.vpc_Message;
        this.paymentAttempt.Gateway_Transaction_Id__c = commwebResp.vpc_TransactionNo;

        if (commwebResp.vpc_TxnResponseCode == '0') {
            this.paymentAttempt.Status__c = 'SUCCESS';
        } else {
            this.paymentAttempt.Status__c = 'FAILURE';
        }
    }


    // Refund via CommWeb (Old - SLX)
    private void refundCommWeb() {
        system.debug('refundCommWeb');
        commwebPayment commweb = new CommwebPayment();
        CommwebResponse commwebResp = new CommwebResponse();

        Integer amountInCents = Integer.valueOf((this.amount.setScale(2) * 100).setScale(0));

        commweb.setAmount(String.valueOf(amountInCents));
        commweb.setCommwebMerchTxnRef(this.customerInvoiceRef);
        
        commweb.setOrderInfo(this.customerInvoiceDescription);
        commweb.setCardNum(this.cardNumber);
        commweb.setTransactionNo(this.transactionNo);


        // Pad month to two digits with left-side zeros
        String monthPadded = this.cardExpiryMonth.leftPad(2).replaceAll(' ', '0').substring(0, 2);

        commweb.setCardExp(this.cardExpiryYear.substring(2, 4) + monthPadded);


        if (this.testGateway == GATEWAY_LOCAL) {
            system.debug('submitTestPayment:payCommWeb: real payment');
            // Return a test response without contacting the gateway
            String respStr = 'vpc_Amount=' + String.valueOf(amountInCents);

            if (this.testType == TEST_SUCCESS) {
                respStr += '&vpc_TxnResponseCode=0';
            } else {
                respStr += '&vpc_TxnResponseCode=1';
                respStr += '&vpc_AcqResponseCode=1';
                respStr += '&vpc_Message=Test failure repsonse';
            }

            commwebResp.loadResponse(respStr);
        } else {
            if (this.testGateway == GATEWAY_MOCK) {
                system.debug('submitTestPayment:payCommWeb: test refund');
                commweb.setTestMode();
            }
            commwebResp = commweb.makeRefund();
        }

        System.debug('Commweb Response: ' + commwebResp);

        // Update the this.paymentAttempt with the response
        this.paymentAttempt.Response__c = JSON.serialize(commwebResp);
        this.paymentAttempt.Response_Code__c = commwebResp.vpc_AcqResponseCode;
        this.paymentAttempt.Response_Message__c = commwebResp.vpc_Message;
        this.paymentAttempt.Gateway_Transaction_Id__c = commwebResp.vpc_TransactionNo;

        if (commwebResp.vpc_TxnResponseCode == '0') {
            this.paymentAttempt.Status__c = 'SUCCESS';
        } else {
            this.paymentAttempt.Status__c = 'FAILURE';
        }
    }


    // Pay via CommWeb (New API)
    private void payCommWeb2() {
        commweb2Payment commweb = Commweb2Payment.loadFromGateway(this);
        Commweb2Response commwebResp;

        commwebResp = commweb.makePayment();

        System.debug('Commweb Response: ' + commwebResp);

        // Only store the request for Dev. We can't store it on live request becacuse it includes the cardnumber

        if (this.testType != null || utility.runningInASandbox()) {
            this.paymentAttempt.Request__c = commweb.requestBody;
        }

        // Update the this.paymentAttempt with the response
        this.paymentAttempt.Response__c = commwebResp.responseBody;
        this.paymentAttempt.Response_Code__c = commwebResp.getErrorCode();
        this.paymentAttempt.Response_Message__c = commwebResp.getErrorMessage();
        this.paymentAttempt.Gateway_Transaction_Id__c = commwebResp.getTrxnNumber();
        this.paymentAttempt.Status__c = commwebResp.isSuccessful() ? 'SUCCESS' : 'FAILURE';
    }


    // Refund via CommWeb (New API)
    private void refundCommWeb2() {
        Commweb2Payment commweb = new Commweb2Payment();
        Commweb2Response commwebResp = new Commweb2Response();

        Integer amountInCents = Integer.valueOf((this.amount.setScale(2) * 100).setScale(0));

        commweb.setAmount(amountInCents, 'NZD');
        commweb.setMerchTxnRef(this.customerInvoiceRef);
        commweb.setOrderInfo(this.customerInvoiceDescription);
        commweb.setUniqueAttemptId(this.uniqueAttemptId);
        commweb.setCardNum(this.cardNumber);
        commweb.setCardExpiry(this.cardExpiryMonth, this.cardExpiryYear.substring(2, 4));
        commweb.setCardName(this.cardHoldersName);
        commweb.setCardCvc(this.cardCVN);
        commweb.setTransactionNo(this.transactionNo);

        if (this.testGateway > 0) {
            commweb.setTestMode(this.testGateway, this.testType);
        }

        commwebResp = commweb.makeRefund();
        
        System.debug('Commweb Response refundCommWeb2: ' + commwebResp);

        // Only store the request for Dev. We can't store it on live request becacuse it includes the cardnumber

        if (this.testType != null || utility.runningInASandbox()) {
            this.paymentAttempt.Request__c = commweb.requestBody;
        }

        // Update the this.paymentAttempt with the response
        this.paymentAttempt.Response__c = commwebResp.responseBody;
        this.paymentAttempt.Response_Code__c = commwebResp.getErrorCode();
        this.paymentAttempt.Response_Message__c = commwebResp.getErrorMessage();
        this.paymentAttempt.Gateway_Transaction_Id__c = commwebResp.getTrxnNumber();
        this.paymentAttempt.Status__c = commwebResp.isSuccessful() ? 'SUCCESS' : 'FAILURE';
    }
}