/*
 * CommWeb payment gateway.
 * This is the newer CommWeb API, integrated 2017, not to be confused with the "VPC" Commweb integration in CommwebPayment.cls.
 */
public with sharing class Commweb2Payment {
  //**********
  //Properties
  //**********
  private Map<String, String> requestParams;
  private Commweb2Response response;
  private String merchantName;
  private String gatewayUrl;
  private String merchTxnRef;
  private String uniqueAttemptId;
  private String orderInfo;
  private Integer amount;
  private String cardName;
  private String cardNum;
  private String cardExpiryMonth;
  private String cardExpiryYear;
  private String cardCvc;
  private String merchantId;
  private String currencyCode;
  private String command;
  private String originalTrxnNumber;
  private String password;
  private Integer testGateway;
  private Integer testResponse;
  public String requestBody;
  private String transactionNo;
  public String customerToken;

  //***********
  //Constructor
  //***********
  public Commweb2Payment() {
    this.response = new Commweb2Response();

    this.currencyCode     = 'NZD';
    this.uniqueAttemptId   = '1';
    requestParams = new Map<String, String>();
  }



  public static Commweb2Payment loadFromGateway(paymentGateway gateway){
      Commweb2Payment commweb = new Commweb2Payment();

      // process invoice number
      String myCustomerInvoiceRef = gateway.customerInvoiceRef;
      if (myCustomerInvoiceRef.indexOf('-')>-1){
           myCustomerInvoiceRef =  myCustomerInvoiceRef.left(myCustomerInvoiceRef.indexOf('-'));
      }        
    
      if (gateway.bjbCompany.Name == 'Get More Traffic New Zealand') {
          commweb.setMerchant('Commweb GMT NZ');
      } else if (gateway.bjbCompany.Name == 'SponsoredLinX New Zealand') {
          commweb.setMerchant('Commweb SLX NZ');
      } else {
          throw new customException('Unrecognised merchant');
      }

      Integer amountInCents = Integer.valueOf((gateway.amount.setScale(2) * 100).setScale(0));

      commweb.setAmount(amountInCents, 'NZD');
      commweb.setMerchTxnRef(myCustomerInvoiceRef); //gateway.customerInvoiceRef
      commweb.setOrderInfo(gateway.customerInvoiceDescription);
      commweb.setUniqueAttemptId(gateway.uniqueAttemptId);
      commweb.setCardNum(gateway.cardNumber);
      commweb.setCardExpiry(gateway.cardExpiryMonth, gateway.cardExpiryYear);
      commweb.setCardName(gateway.cardHoldersName);
      commweb.setCardCvc(gateway.cardCVN);
      commweb.customerToken = gateway.customerToken;
      // just required for refund
      commweb.setTransactionNo(gateway.transactionNo);

      if (gateway.testGateway > 0) {
          commweb.setTestMode(gateway.testGateway, gateway.testType);
      }

      return commweb;
  }

  // Set which merchant credentials to use. Stored in custom settings.
  public void setMerchant(String merchantName) {

    PaymentGateway__c merchantConfig = PaymentGateway__c.getValues(merchantName);

    if (merchantConfig == null){
      throw new customException('No merchant configuration for '+merchantName);
    }

    this.merchantName   = merchantName;
    this.gatewayUrl     = merchantConfig.MerchantURL__c;
    this.merchantId     = merchantConfig.Merchant_Name__c;
    this.password       = merchantConfig.Password__c;
  }

  // Set test mode (test|mock|local|live) and test response ('success'|'failure'|'decline')
  public void setTestMode(Integer testGateway, Integer testResponse) {
    this.testGateway   = testGateway;
    this.testResponse  = testResponse;
  }

  // Make a customer token
  public Commweb2Response createToken() {
    this.command = 'TOKENIZE';

    // Validate required/min/max length of data
    this.validate();

    if (this.response.getErrorMessage() != null){
      system.debug('validation errors: '+this.response.getErrorMessage());
      return this.response;
    }

    // Build request
    requestParams = new Map<String, String>();
    requestParams.put('merchant', this.merchantId);
    requestParams.put('apiUsername', 'merchant.'+this.merchantId);
    requestParams.put('apiPassword', this.password);
    requestParams.put('apiOperation', this.command);

    if ( !String.isEmpty(this.customerToken) ){
      // Update the existing token with new details
      requestParams.put('sourceOfFunds.token', this.customerToken);
      requestParams.put('token', this.customerToken);
    }

    requestParams.put('sourceOfFunds.type', 'CARD');
    //requestParams.put('sourceOfFunds.provided.card.nameOnCard', this.cardName); // Not included in TOKENIZE requests
    requestParams.put('sourceOfFunds.provided.card.expiry.month', this.cardExpiryMonth);
    requestParams.put('sourceOfFunds.provided.card.expiry.year', this.cardExpiryYear);
    requestParams.put('sourceOfFunds.provided.card.securityCode', this.cardCvc);

    // If passing card details, the Card Number is optional if it is not being updated. Eg we may just be updating the expiry date.
    // need keeping 2 first digit of cardnumber
    //if ( !String.isEmpty(this.cardNum) && !this.cardNum.contains('XXXX-XXXX-XXXX-') ){
    if ( !String.isEmpty(this.cardNum) && !this.cardNum.contains('XX-XXXX-XXXX-') ){
      requestParams.put('sourceOfFunds.provided.card.number', this.cardNum);
    }

    // Simulate test transaction
    if (this.testGateway == paymentGateway.GATEWAY_LOCAL) {
      // Return a test response without contacting the gateway
      String respStr = '';

      if (this.testResponse == paymentGateway.TEST_SUCCESS) {
        respStr += 'repositoryId=TESTGETMORMCC201&response.gatewayCode=BASIC_VERIFICATION_SUCCESSFUL&result=SUCCESS&sourceOfFunds.provided.card.brand=MASTERCARD&sourceOfFunds.provided.card.expiry=1020&sourceOfFunds.provided.card.fundingMethod=CREDIT&sourceOfFunds.provided.card.issuer=BANCO DEL PICHINCHA, C.A.&sourceOfFunds.provided.card.number=512345xxxxxx0008&sourceOfFunds.provided.card.scheme=MASTERCARD&sourceOfFunds.type=CARD&status=VALID&token=9207494076587796&usage.lastUpdated=2018-04-12T22:38:36.326Z&usage.lastUpdatedBy=TESTGETMORMCC201&usage.lastUsed=2018-04-12T22:38:36.326Z&verificationStrategy=BASIC';
      } else {
        respStr += 'error.cause=INVALID_REQUEST&error.explanation=Value 512345xxxxxxxxx8234 is invalid. Invalid number for this card type&error.field=sourceOfFunds.provided.card.number&error.validationType=INVALID&result=ERROR';
      }
      this.response.loadResponse(respStr);
    } else {
      // Make request
      this.sendRequest();
    }

    system.debug('this.response.params: ' + this.response.params);

    // Store the customer token for subsequent payments
    this.customerToken = (String) String.valueOf(this.response.params.get('token'));

    system.debug('Created customerToken: ' + customerToken);

    return this.response;
  }

  // Make a payment
  public Commweb2Response makePayment() {
    this.command = 'PAY';

    // Validate required/min/max length of data
    this.validate();

    system.debug('paying with this.customerToken: '+ this.customerToken);

    if (this.response.getErrorMessage() != null){
      system.debug('validation errors: ' + this.response.getErrorMessage());
      return this.response;
    }

    if (this.testGateway == paymentGateway.GATEWAY_MOCK) {
      this.cardNum   = '5123450000000008'; // Mastercard
//      this.cardNum   = '4005550000000019'; // Visa

      if (this.testResponse == paymentGateway.TEST_SUCCESS) {
        // Test Approved response
        this.cardExpiryMonth   = '5';
        this.cardExpiryYear   = '21';
      } else if (this.testResponse == paymentGateway.TEST_FAILURE) {
        // Test Declined response
        this.cardExpiryMonth   = '5';
        this.cardExpiryYear   = '22';
      } else if (this.testResponse == paymentGateway.TEST_EXPIRED) {
        // Test expired response
        this.cardExpiryMonth   = '4';
        this.cardExpiryYear   = '27';
      } else if (this.testResponse == paymentGateway.TEST_TIMEOUT) {
        // Test timeout response
        this.cardExpiryMonth   = '8';
        this.cardExpiryYear   = '28';
      }
    }

    // Build request
    requestParams.put('merchant', this.merchantId);
    requestParams.put('apiUsername', 'merchant.'+this.merchantId);
    requestParams.put('apiPassword', this.password);
    requestParams.put('apiOperation', this.command);    
    //requestParams.put('order.amount', string.valueof(Decimal.valueOf(this.amount / 100).setScale(2)));
    requestParams.put('order.amount', string.valueof(Decimal.valueOf(this.amount).setScale(2) / 100));
    
    requestParams.put('order.currency', this.currencyCode);
    requestParams.put('order.id', this.merchTxnRef);
    requestParams.put('transaction.id', this.uniqueAttemptId);
    requestParams.put('sourceOfFunds.type', 'CARD');

    if (this.customerToken != null && this.customerToken != '' ){
      requestParams.put('sourceOfFunds.token', this.customerToken);
    } else {
      requestParams.put('sourceOfFunds.provided.card.nameOnCard', this.cardName);
      requestParams.put('sourceOfFunds.provided.card.number', this.cardNum);
      requestParams.put('sourceOfFunds.provided.card.expiry.month', this.cardExpiryMonth);
      requestParams.put('sourceOfFunds.provided.card.expiry.year', this.cardExpiryYear);
      requestParams.put('sourceOfFunds.provided.card.securityCode', this.cardCvc);
    }

    // Simulate test transaction
    if (this.testGateway == paymentGateway.GATEWAY_LOCAL) {
      // Return a test response without contacting the gateway
      String respStr = '';

      if (this.testResponse == paymentGateway.TEST_SUCCESS) {
        respStr += 'authorizationResponse.commercialCard=888&authorizationResponse.commercialCardIndicator=3&authorizationResponse.financialNetworkCode=777&authorizationResponse.processingCode=003000&authorizationResponse.responseCode=00&authorizationResponse.stan=151040&authorizationResponse.transactionIdentifier=123456789&gatewayEntryPoint=WEB_SERVICES_API&merchant=TESTGETMORMCC201&order.amount=699.00&order.creationTime=2017-08-01T05%3A30%3A36.237Z&order.currency=NZD&order.id=INV010817000717&order.status=CAPTURED&order.totalAuthorizedAmount=699.00&order.totalCapturedAmount=699.00&order.totalRefundedAmount=0.00&response.acquirerCode=00&response.acquirerMessage=Approved&response.gatewayCode=APPROVED&result=SUCCESS&risk.response.gatewayCode=ACCEPTED&risk.response.review.decision=NOT_REQUIRED&risk.response.rule%5B0%5D.data=512345&risk.response.rule%5B0%5D.name=MERCHANT_BIN_RANGE&risk.response.rule%5B0%5D.recommendation=NO_ACTION&risk.response.rule%5B0%5D.type=MERCHANT_RULE&risk.response.rule%5B1%5D.name=SUSPECT_CARD_LIST&risk.response.rule%5B1%5D.recommendation=NO_ACTION&risk.response.rule%5B1%5D.type=MERCHANT_RULE&risk.response.rule%5B2%5D.name=TRUSTED_CARD_LIST&risk.response.rule%5B2%5D.recommendation=NO_ACTION&risk.response.rule%5B2%5D.type=MERCHANT_RULE&risk.response.rule%5B3%5D.data=512345&risk.response.rule%5B3%5D.name=MSO_BIN_RANGE&risk.response.rule%5B3%5D.recommendation=NO_ACTION&risk.response.rule%5B3%5D.type=MSO_RULE&sourceOfFunds.provided.card.brand=MASTERCARD&sourceOfFunds.provided.card.expiry.month=5&sourceOfFunds.provided.card.expiry.year=21&sourceOfFunds.provided.card.fundingMethod=CREDIT&sourceOfFunds.provided.card.issuer=BANCO+DEL+PICHINCHA%2C+C.A.&sourceOfFunds.provided.card.nameOnCard=Brendan+West&sourceOfFunds.provided.card.number=512345xxxxxx0008&sourceOfFunds.provided.card.scheme=MASTERCARD&sourceOfFunds.type=CARD&timeOfRecord=2017-08-01T05%3A30%3A36.237Z&transaction.acquirer.batch=20170801&transaction.acquirer.date=0801&transaction.acquirer.id=CBAMCC_S2I&transaction.acquirer.merchantId=353109496853456&transaction.acquirer.settlementDate=2017-08-01&transaction.acquirer.timeZone=%2B1000&transaction.acquirer.transactionId=123456789&transaction.amount=699.00&transaction.authorizationCode=151040&transaction.currency=NZD&transaction.frequency=SINGLE&transaction.id=1&transaction.receipt=721305151040&transaction.source=INTERNET&transaction.terminal=CBAMCC04&transaction.type=PAYMENT&version=41';
      } else {
        respStr += 'authorizationResponse.commercialCard=888&authorizationResponse.commercialCardIndicator=3&authorizationResponse.financialNetworkCode=777&authorizationResponse.processingCode=003000&authorizationResponse.responseCode=54&authorizationResponse.stan=156108&authorizationResponse.transactionIdentifier=123456789&gatewayEntryPoint=WEB_SERVICES_API&merchant=TESTGETMORMCC201&order.amount=350.00&order.creationTime=2017-08-01T05%3A11%3A06.686Z&order.currency=NZD&order.id=INV010817000610&order.status=FAILED&order.totalAuthorizedAmount=0.00&order.totalCapturedAmount=0.00&order.totalRefundedAmount=0.00&response.acquirerCode=54&response.acquirerMessage=Expired+card&response.gatewayCode=EXPIRED_CARD&result=FAILURE&risk.response.gatewayCode=ACCEPTED&risk.response.review.decision=NOT_REQUIRED&risk.response.rule%5B0%5D.data=512345&risk.response.rule%5B0%5D.name=MERCHANT_BIN_RANGE&risk.response.rule%5B0%5D.recommendation=NO_ACTION&risk.response.rule%5B0%5D.type=MERCHANT_RULE&risk.response.rule%5B1%5D.name=SUSPECT_CARD_LIST&risk.response.rule%5B1%5D.recommendation=NO_ACTION&risk.response.rule%5B1%5D.type=MERCHANT_RULE&risk.response.rule%5B2%5D.name=TRUSTED_CARD_LIST&risk.response.rule%5B2%5D.recommendation=NO_ACTION&risk.response.rule%5B2%5D.type=MERCHANT_RULE&risk.response.rule%5B3%5D.data=512345&risk.response.rule%5B3%5D.name=MSO_BIN_RANGE&risk.response.rule%5B3%5D.recommendation=NO_ACTION&risk.response.rule%5B3%5D.type=MSO_RULE&sourceOfFunds.provided.card.brand=MASTERCARD&sourceOfFunds.provided.card.expiry.month=4&sourceOfFunds.provided.card.expiry.year=27&sourceOfFunds.provided.card.fundingMethod=CREDIT&sourceOfFunds.provided.card.issuer=BANCO+DEL+PICHINCHA%2C+C.A.&sourceOfFunds.provided.card.nameOnCard=Brendan+West&sourceOfFunds.provided.card.number=512345xxxxxx0008&sourceOfFunds.provided.card.scheme=MASTERCARD&sourceOfFunds.type=CARD&timeOfRecord=2017-08-01T05%3A11%3A06.686Z&transaction.acquirer.batch=20170801&transaction.acquirer.date=0801&transaction.acquirer.id=CBAMCC_S2I&transaction.acquirer.merchantId=353109496853456&transaction.acquirer.settlementDate=2017-08-01&transaction.acquirer.timeZone=%2B1000&transaction.acquirer.transactionId=123456789&transaction.amount=350.00&transaction.currency=NZD&transaction.frequency=SINGLE&transaction.id=1&transaction.receipt=721305156108&transaction.source=INTERNET&transaction.terminal=CBAMCC04&transaction.type=PAYMENT&version=41';
      }
      this.response.loadResponse(respStr);
    } else {
      // Make request
      this.sendRequest();
    }
    return this.response;
  }

  // Make a refund
  public Commweb2Response makeRefund() {
    this.command = 'REFUND';

    // Validate required/min/max length of data
    this.validate();

    if (this.response.getErrorMessage() != null){
      system.debug('Got an error message: ' + this.response.getErrorMessage());
      return this.response;
    }

    if (this.testGateway == paymentGateway.GATEWAY_MOCK) {
      this.cardNum   = '5123450000000008'; // Mastercard
//      this.cardNum   = '4508750015741019'; // Visa

      if (this.testResponse == paymentGateway.TEST_SUCCESS) {
        // Test Approved response
        this.cardExpiryMonth   = '5';
        this.cardExpiryYear   = '21';
      } else if (this.testResponse == paymentGateway.TEST_FAILURE) {
        // Test Declined response
        this.cardExpiryMonth   = '5';
        this.cardExpiryYear   = '22';
      } else if (this.testResponse == paymentGateway.TEST_EXPIRED) {
        // Test expired response
        this.cardExpiryMonth   = '4';
        this.cardExpiryYear   = '27';
      } else if (this.testResponse == paymentGateway.TEST_TIMEOUT) {
        // Test timeout response
        this.cardExpiryMonth   = '8';
        this.cardExpiryYear   = '28';
      }
    }

    // Build request
    requestParams.put('merchant', this.merchantId);
    requestParams.put('apiUsername', 'merchant.'+this.merchantId);
    requestParams.put('apiPassword', this.password);

    requestParams.put('apiOperation', this.command);
    requestParams.put('order.id', this.merchTxnRef);
    requestParams.put('transaction.id', this.transactionNo);
    //requestParams.put('transaction.amount', string.valueof(Decimal.valueOf(this.amount / 100).setScale(2)));
    requestParams.put('transaction.amount', string.valueof(Decimal.valueOf(this.amount).setScale(2) / 100));    
    requestParams.put('transaction.currency', this.currencyCode);

    // Simulate test transaction
        if (this.testGateway == paymentGateway.GATEWAY_LOCAL) {
          // Return a test response without contacting the gateway
      String respStr = '';

      if (this.testResponse == paymentGateway.TEST_SUCCESS) {
        respStr += 'authorizationResponse.commercialCard=888&authorizationResponse.commercialCardIndicator=3&authorizationResponse.financialNetworkCode=777&authorizationResponse.processingCode=003000&authorizationResponse.responseCode=00&authorizationResponse.stan=151040&authorizationResponse.transactionIdentifier=123456789&gatewayEntryPoint=WEB_SERVICES_API&merchant=TESTGETMORMCC201&order.amount=699.00&order.creationTime=2017-08-01T05%3A30%3A36.237Z&order.currency=NZD&order.id=INV010817000717&order.status=CAPTURED&order.totalAuthorizedAmount=699.00&order.totalCapturedAmount=699.00&order.totalRefundedAmount=0.00&response.acquirerCode=00&response.acquirerMessage=Approved&response.gatewayCode=APPROVED&result=SUCCESS&risk.response.gatewayCode=ACCEPTED&risk.response.review.decision=NOT_REQUIRED&risk.response.rule%5B0%5D.data=512345&risk.response.rule%5B0%5D.name=MERCHANT_BIN_RANGE&risk.response.rule%5B0%5D.recommendation=NO_ACTION&risk.response.rule%5B0%5D.type=MERCHANT_RULE&risk.response.rule%5B1%5D.name=SUSPECT_CARD_LIST&risk.response.rule%5B1%5D.recommendation=NO_ACTION&risk.response.rule%5B1%5D.type=MERCHANT_RULE&risk.response.rule%5B2%5D.name=TRUSTED_CARD_LIST&risk.response.rule%5B2%5D.recommendation=NO_ACTION&risk.response.rule%5B2%5D.type=MERCHANT_RULE&risk.response.rule%5B3%5D.data=512345&risk.response.rule%5B3%5D.name=MSO_BIN_RANGE&risk.response.rule%5B3%5D.recommendation=NO_ACTION&risk.response.rule%5B3%5D.type=MSO_RULE&sourceOfFunds.provided.card.brand=MASTERCARD&sourceOfFunds.provided.card.expiry.month=5&sourceOfFunds.provided.card.expiry.year=21&sourceOfFunds.provided.card.fundingMethod=CREDIT&sourceOfFunds.provided.card.issuer=BANCO+DEL+PICHINCHA%2C+C.A.&sourceOfFunds.provided.card.nameOnCard=Brendan+West&sourceOfFunds.provided.card.number=512345xxxxxx0008&sourceOfFunds.provided.card.scheme=MASTERCARD&sourceOfFunds.type=CARD&timeOfRecord=2017-08-01T05%3A30%3A36.237Z&transaction.acquirer.batch=20170801&transaction.acquirer.date=0801&transaction.acquirer.id=CBAMCC_S2I&transaction.acquirer.merchantId=353109496853456&transaction.acquirer.settlementDate=2017-08-01&transaction.acquirer.timeZone=%2B1000&transaction.acquirer.transactionId=123456789&transaction.amount=699.00&transaction.authorizationCode=151040&transaction.currency=NZD&transaction.frequency=SINGLE&transaction.id=1&transaction.receipt=721305151040&transaction.source=INTERNET&transaction.terminal=CBAMCC04&transaction.type=PAYMENT&version=41';
      } else {
        respStr += 'authorizationResponse.commercialCard=888&authorizationResponse.commercialCardIndicator=3&authorizationResponse.financialNetworkCode=777&authorizationResponse.processingCode=003000&authorizationResponse.responseCode=54&authorizationResponse.stan=156108&authorizationResponse.transactionIdentifier=123456789&gatewayEntryPoint=WEB_SERVICES_API&merchant=TESTGETMORMCC201&order.amount=350.00&order.creationTime=2017-08-01T05%3A11%3A06.686Z&order.currency=NZD&order.id=INV010817000610&order.status=FAILED&order.totalAuthorizedAmount=0.00&order.totalCapturedAmount=0.00&order.totalRefundedAmount=0.00&response.acquirerCode=54&response.acquirerMessage=Expired+card&response.gatewayCode=EXPIRED_CARD&result=FAILURE&risk.response.gatewayCode=ACCEPTED&risk.response.review.decision=NOT_REQUIRED&risk.response.rule%5B0%5D.data=512345&risk.response.rule%5B0%5D.name=MERCHANT_BIN_RANGE&risk.response.rule%5B0%5D.recommendation=NO_ACTION&risk.response.rule%5B0%5D.type=MERCHANT_RULE&risk.response.rule%5B1%5D.name=SUSPECT_CARD_LIST&risk.response.rule%5B1%5D.recommendation=NO_ACTION&risk.response.rule%5B1%5D.type=MERCHANT_RULE&risk.response.rule%5B2%5D.name=TRUSTED_CARD_LIST&risk.response.rule%5B2%5D.recommendation=NO_ACTION&risk.response.rule%5B2%5D.type=MERCHANT_RULE&risk.response.rule%5B3%5D.data=512345&risk.response.rule%5B3%5D.name=MSO_BIN_RANGE&risk.response.rule%5B3%5D.recommendation=NO_ACTION&risk.response.rule%5B3%5D.type=MSO_RULE&sourceOfFunds.provided.card.brand=MASTERCARD&sourceOfFunds.provided.card.expiry.month=4&sourceOfFunds.provided.card.expiry.year=27&sourceOfFunds.provided.card.fundingMethod=CREDIT&sourceOfFunds.provided.card.issuer=BANCO+DEL+PICHINCHA%2C+C.A.&sourceOfFunds.provided.card.nameOnCard=Brendan+West&sourceOfFunds.provided.card.number=512345xxxxxx0008&sourceOfFunds.provided.card.scheme=MASTERCARD&sourceOfFunds.type=CARD&timeOfRecord=2017-08-01T05%3A11%3A06.686Z&transaction.acquirer.batch=20170801&transaction.acquirer.date=0801&transaction.acquirer.id=CBAMCC_S2I&transaction.acquirer.merchantId=353109496853456&transaction.acquirer.settlementDate=2017-08-01&transaction.acquirer.timeZone=%2B1000&transaction.acquirer.transactionId=123456789&transaction.amount=350.00&transaction.currency=NZD&transaction.frequency=SINGLE&transaction.id=1&transaction.receipt=721305156108&transaction.source=INTERNET&transaction.terminal=CBAMCC04&transaction.type=PAYMENT&version=41';
      }

      this.response.loadResponse(respStr);
        } else {
          // Make request
      this.sendRequest();
    }

    return this.response;
  }
  
  public void setMerchTxnRef(String merchTxnRef) {
    this.merchTxnRef = merchTxnRef;
  } 
  
  public void setOrderInfo(String OrderInfo) {
    this.orderInfo = orderInfo;
  }

  // Amount in cents
  public void setAmount(Integer amount, String currencyCode) {
    this.amount     = amount;
    this.currencyCode   = currencyCode;
  }

  public void setCardName(String cardName) {
    this.cardName = cardName;
  } 
  
  public void setCardNum(String CardNum) {
    this.cardNum = cardNum;
  }

  public void setCardCvc(String cardCvc) {
    this.cardCvc = cardCvc;
  } 

  public void setOriginalTrxnNumber(String originalTrxnNumber) { 
     this.originalTrxnNumber = originalTrxnNumber;
  }

  public void setUniqueAttemptId(String uniqueAttemptId) { 
     this.uniqueAttemptId   = uniqueAttemptId;
  }

  public void setCardExpiry(String month, String year) {
    if (month.length() == 2 && month.substring(0,1) == '0'){
      month = month.substring(1,2);
    }

    if (year.length() > 2){
      year = year.substring(2,4);
    }

    this.cardExpiryMonth   = month;
    this.cardExpiryYear   = year;
  }

  public void setTransactionNo(String transNo) {
      //   40
      this.transactionNo = transNo;
  }


  // Validate all data
  public boolean validate(){
    this.checkValue('MerchTxnRef', this.merchTxnRef,50,false);
    this.checkValue('OrderInfo', this.orderInfo,100,false);

    // If not using a token, the other card details are required
    if ( String.isEmpty(this.customerToken) ){
      this.checkValue('cardName', this.cardName, 256, true);
      //this.checkValue('CardNum', this.cardNum, 20, true);
      //this.checkValue('cardCvc', this.cardCvc, 4, true);
      //this.checkValue('cardExpiryMonth', this.cardExpiryMonth, 2, true);
      //this.checkValue('cardExpiryYear', this.cardExpiryYear, 2, true);
    }

    if (this.command == 'Refund'){
        this.checkValue('transaction.id', this.transactionNo, 40, true);
    }

    return (this.response.getErrorMessage() == null);
  }
  
  private String checkValue(String field, String value, Integer length, Boolean required) {
    try {
      value = value.trim();
      if (required == true) {
        if (value == null || value.length()==0) {
          if (field.length() > 0) {
            this.response.setErrors(field+' can not be empty');
          }
        }
      }
      if (value.length() > length) {
        if (field.length() > 0) {
          this.response.setErrors(field+' can not be longer than '+length);
        }
      }
    } catch (Exception e) {
      if (required == true) {
        if (field.length() > 0) {
          this.response.setErrors(field+' can not be empty');
        }
      }
    } 
    return value;  
  }

  // Send the request to the merchant server
  private Commweb2Response sendRequest() {
    // Build request body
    this.requestBody = Utility.createQueryStringFromMap(requestParams);

    if (utility.runningInASandbox()){
      system.debug('Commweb2 request: ' + this.requestBody);
    }
    
    // Make the request
    HttpRequest req = new HttpRequest();
        Http h = new Http();
        req.setEndpoint(this.gatewayUrl);
        req.setMethod('POST');
        req.setBody(this.requestBody); 
        system.debug(req);
        req.setTimeout(60000);
        HTTPResponse res = h.send(req);

    // Load the response
        system.debug('Commweb2 Response: ' + EncodingUtil.urlDecode(res.getBody(), 'UTF-8'));
        this.response.loadResponse(res.getBody());

        return this.response;
  }
}