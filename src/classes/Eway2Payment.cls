/*
 * Eway Rapid payment gateway.
 * This is the newer Eway API, integrated 2018, more secure than the original API in EwayPayment.cls.
 * Documentation: https://eway.io/api-v3/
 */
public with sharing class Eway2Payment {
  //**********
  //Constants
  //**********
  private static String API_VERSION     = '31';


  //**********
  //Properties
  //**********
  private Map<String, String> requestParams;
  private Eway2Response response;
  private String merchantName;
  private String gatewayUrl;
  private String merchTxnRef;
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
  private String transactionNo;
  private String customerCompanyName;
    private String customerFirstName;
    private String customerLastName;
    private String customerEmail;
    private String customerStreet;
    private String customerCity;
    private String customerState;
    private String customerPostcode;
    private String customerCountrycode;
    private String customerIP;
    public String customerToken;

  public String requestBody;

  //***********
  //Constructor
  //***********
  public Eway2Payment() {
    this.response = new Eway2Response();

    this.currencyCode     = 'AUD';
  }

    public static Eway2Payment loadFromGateway(paymentGateway gateway){
        Eway2Payment eway = new Eway2Payment();

        if (gateway.bjbCompany.Name == 'Get More Traffic') {
            eway.setMerchant('Eway Rapid GMT AU');
        } else if (gateway.bjbCompany.Name == 'SponsoredLinX') {
            eway.setMerchant('Eway Rapid SLX AU');
        } else {
          throw new customException('Unrecognised merchant');
        }

        Integer amountInCents = Integer.valueOf((gateway.amount.setScale(2) * 100).setScale(0));

        eway.setAmount(amountInCents, gateway.currencyIsoCode);
        eway.setMerchTxnRef(gateway.customerInvoiceRef);
        eway.setOrderInfo(gateway.customerInvoiceDescription);
        eway.setCardNum(gateway.cardNumber);
        eway.setCardExpiry(gateway.cardExpiryMonth, gateway.cardExpiryYear);
        eway.setCardName(gateway.cardHoldersName);
        eway.setCardCvc(gateway.cardCVN);
        eway.setCustomerCompanyName(gateway.customerCompanyName);
        eway.setCustomerFirstName(gateway.customerFirstName);
        eway.setCustomerLastName(gateway.customerLastName);
        eway.setCustomerEmail(gateway.customerEmail);
        eway.setCustomerStreet(gateway.customerStreet);
        eway.setCustomerCity(gateway.customerCity);
        eway.setCustomerState(gateway.customerState);
        eway.setCustomerPostcode(gateway.customerPostcode);
        eway.setCustomerCountrycode(gateway.customerCountrycode);
    eway.setTransactionNo(gateway.transactionNo);
    eway.customerToken = gateway.customerToken;

        // Customer's IP address, for fraud detection. We would only want this if it was the customer processing the transaction,
        // not recurring payments, make a payment, or signups processed by sales rep.
        eway.setCustomerIP(gateway.customerIP);

        if (gateway.testGateway > 0) {
            eway.setTestMode(gateway.testGateway, gateway.testType);
        }

        return eway;
    }


  // Set which merchant credentials to use. Stored in custom settings.
  public void setMerchant(String merchantName) {

    PaymentGateway__c merchantConfig = PaymentGateway__c.getValues(merchantName);

    if (merchantConfig == null){
      throw new customException('No merchant configuration for '+merchantName);
    }

    this.merchantName   = merchantName;
    this.gatewayUrl   = merchantConfig.MerchantURL__c;
    this.merchantId     = merchantConfig.Access_Code__c;
    this.password       = merchantConfig.Password__c;
  }

  // Set test mode (test|mock|local|live) and test response ('success'|'failure'|'decline')
  public void setTestMode(Integer testGateway, Integer testResponse) {
    this.testGateway   = testGateway;
    this.testResponse  = testResponse;
  }

  // Make a customer token
  public Eway2Response createToken() {
    // Validate required/min/max length of data
    this.validate();

    if (this.response.getErrorMessage() != null){
      system.debug('validation errors: ' + this.response.getErrorMessage());
      return this.response;
    }

    // Build request
    requestParams = new Map<String, String>();
    requestParams.put('TransactionType', 'Purchase');

    if ( String.isEmpty(this.customerToken) ){
      // Create a new token
      requestParams.put('Method', 'CreateTokenCustomer');
    } else {
      // Update the existing token with new details
      requestParams.put('Method', 'UpdateTokenCustomer');
      requestParams.put('Customer.TokenCustomerID', this.customerToken);
    }

    requestParams.put('Payment.TotalAmount', '0'); // Must be 0 for CreateTokenCustomer

    // If passing card details, the Card Number is optional if it is not being updated. Eg we may just be updating the expiry date.
    // need keeping 2 first digit of cardnumber
    //if ( !String.isEmpty(this.cardNum) && !this.cardNum.contains('XXXX-XXXX-XXXX-') ){
	if ( !String.isEmpty(this.cardNum) && !this.cardNum.contains('XX-XXXX-XXXX-') ){    	
      requestParams.put('Customer.CardDetails.Number', this.cardNum);
    }

    requestParams.put('Customer.CardDetails.Name', this.cardName);
    requestParams.put('Customer.CardDetails.ExpiryMonth', this.cardExpiryMonth);
    requestParams.put('Customer.CardDetails.ExpiryYear', this.cardExpiryYear);
    requestParams.put('Customer.CardDetails.CVN', this.cardCvc);

    requestParams.put('Customer.FirstName', this.customerFirstName);
    requestParams.put('Customer.LastName', this.customerLastName);
    requestParams.put('Customer.CompanyName', this.customerCompanyName);
    requestParams.put('Customer.Email', this.customerEmail);
    requestParams.put('Customer.Street1', this.customerStreet);
    requestParams.put('Customer.City', this.customerCity);
    requestParams.put('Customer.State', this.customerState);
    requestParams.put('Customer.PostalCode', this.customerPostcode);
    requestParams.put('Customer.Country', this.customerCountrycode);

    if (this.customerIP != null){
      requestParams.put('CustomerIP', this.customerIP);
    }

    // Simulate test transaction
    if (this.testGateway == paymentGateway.GATEWAY_LOCAL) {
      // Return a test response without contacting the gateway
      String respStr = '';

      if (this.testResponse == paymentGateway.TEST_SUCCESS) {
        respStr += '{"AuthorisationCode":null,"ResponseCode":"00","ResponseMessage":"A2000","TransactionID":null,"TransactionStatus":false,"TransactionType":"Purchase","BeagleScore":null,"Verification":{"CVN":0,"Address":0,"Email":0,"Mobile":0,"Phone":0},"Customer":{"CardDetails":{"Number":"444433XXXXXX1111","Name":"Dion Panossian","ExpiryMonth":"10","ExpiryYear":"20","StartMonth":null,"StartYear":null,"IssueNumber":null},"TokenCustomerID":910160256661,"Reference":"","Title":"Mr.","FirstName":"Dion Panossian","LastName":"Dion Panossian","CompanyName":"","JobDescription":"","Street1":"","Street2":"","City":"","State":"","PostalCode":"","Country":"au","Email":"","Phone":"","Mobile":"","Comments":"","Fax":"","Url":""},"Payment":{"TotalAmount":0,"InvoiceNumber":"","InvoiceDescription":"","InvoiceReference":"","CurrencyCode":"AUD"},"Errors":null}';
      } else {
        respStr += '{"AuthorisationCode":null,"ResponseCode":null,"ResponseMessage":null,"TransactionID":null,"TransactionStatus":null,"TransactionType":"Purchase","BeagleScore":null,"Verification":null,"Customer":{"CardDetails":{"Number":"444433XXXXXX1188","Name":"Joe Smith","ExpiryMonth":"10","ExpiryYear":"20","StartMonth":null,"StartYear":null,"IssueNumber":null},"TokenCustomerID":null,"Reference":null,"Title":null,"FirstName":"Dion Panossian","LastName":"Dion Panossian","CompanyName":null,"JobDescription":null,"Street1":null,"Street2":null,"City":null,"State":null,"PostalCode":null,"Country":"au","Email":null,"Phone":null,"Mobile":null,"Comments":null,"Fax":null,"Url":null},"Payment":{"TotalAmount":0,"InvoiceNumber":null,"InvoiceDescription":null,"InvoiceReference":null,"CurrencyCode":"AUD"},"Errors":"V6110"}';
      }

      HTTPResponse testRes = new HTTPResponse();
      testRes.setBody(respStr);

      this.response.loadResponse(testRes);
    } else {
      // Make request
      this.sendRequest();
    }

    // Store the customer token for subsequent payments
    Map<String, Object> customer = (Map<String, Object>) this.response.params.get('Customer');

    this.customerToken = (String) String.valueOf(customer.get('TokenCustomerID'));

    return this.response;
  }

  // Make a payment
  public Eway2Response makePayment() {
    this.command = 'ProcessPayment';

    // Validate required/min/max length of data
    this.validate();

    if (this.response.getErrorMessage() != null){
      system.debug('validation errors: ' + this.response.getErrorMessage());
      return this.response;
    }

    // Build request
    requestParams = new Map<String, String>();
    requestParams.put('Method', this.command);
    requestParams.put('Payment.TotalAmount', string.valueof(this.amount)); // Amount in cents
    requestParams.put('Payment.CurrencyCode', this.currencyCode);
    requestParams.put('Payment.InvoiceNumber', this.merchTxnRef);
    requestParams.put('Payment.InvoiceDescription', this.orderInfo);
    requestParams.put('Payment.InvoiceReference', this.merchTxnRef);

    if (this.customerToken != null && this.customerToken != '' ){
      // Payment using customer token
      requestParams.put('TransactionType', 'Recurring');
      requestParams.put('Customer.TokenCustomerID', this.customerToken);
    } else {
      // Payment using card details
      requestParams.put('TransactionType', 'Purchase');
      requestParams.put('Customer.CardDetails.Name', this.cardName);
      requestParams.put('Customer.CardDetails.Number', this.cardNum);
      requestParams.put('Customer.CardDetails.ExpiryMonth', this.cardExpiryMonth);
      requestParams.put('Customer.CardDetails.ExpiryYear', this.cardExpiryYear);
      requestParams.put('Customer.CardDetails.CVN', this.cardCvc);
      requestParams.put('Customer.FirstName', this.customerFirstName);
      requestParams.put('Customer.LastName', this.customerLastName);
      requestParams.put('Customer.Email', this.customerEmail);
      requestParams.put('Customer.Street1', this.customerStreet);
      requestParams.put('Customer.City', this.customerCity);
      requestParams.put('Customer.State', this.customerState);
      requestParams.put('Customer.PostalCode', this.customerPostcode);
      requestParams.put('Customer.Country', this.customerCountrycode);
    }

    if (this.customerIP != null){
      requestParams.put('CustomerIP', this.customerIP);
    }

    // Simulate test transaction
    if (this.testGateway == paymentGateway.GATEWAY_LOCAL) {
      // Return a test response without contacting the gateway
      String respStr = '';

      if (this.testResponse == paymentGateway.TEST_SUCCESS) {
        respStr += '{"Errors":null,"AuthorisationCode":"839520","ResponseCode":"00","ResponseMessage":"A2000","TransactionID":17841076,"TransactionStatus":true,"TransactionType":"Purchase","BeagleScore":-1,"Verification":{"CVN":0,"Address":0,"Email":0,"Mobile":0,"Phone":0},"Customer":{"CardDetails":{"Number":"444433XXXXXX1111","Name":"Joe Smith","ExpiryMonth":"06","ExpiryYear":"20","StartMonth":null,"StartYear":null,"IssueNumber":null},"TokenCustomerID":null,"Reference":"","Title":"Mr.","FirstName":"","LastName":"","CompanyName":"","JobDescription":"","Street1":"","Street2":"","City":"","State":"","PostalCode":"","Country":"","Email":"","Phone":"","Mobile":"","Comments":"","Fax":"","Url":""},"Payment":{"TotalAmount":100,"InvoiceNumber":"INV123","InvoiceDescription":"INV123","InvoiceReference":"INV123","CurrencyCode":"AUD"}}';
      } else {
        respStr += '{"Errors":"V6102","AuthorisationCode":null,"ResponseCode":null,"ResponseMessage":null,"TransactionID":null,"TransactionStatus":null,"TransactionType":"Purchase","BeagleScore":null,"Verification":null,"Customer":{"CardDetails":{"Number":"444433XXXXXX1111","Name":"Joe Smith","ExpiryMonth":"06","ExpiryYear":"14","StartMonth":null,"StartYear":null,"IssueNumber":null},"TokenCustomerID":null,"Reference":null,"Title":null,"FirstName":null,"LastName":null,"CompanyName":null,"JobDescription":null,"Street1":null,"Street2":null,"City":null,"State":null,"PostalCode":null,"Country":null,"Email":null,"Phone":null,"Mobile":null,"Comments":null,"Fax":null,"Url":null},"Payment":{"TotalAmount":100,"InvoiceNumber":"INV123","InvoiceDescription":"INV123","InvoiceReference":"INV123","CurrencyCode":"AUD"}}';
      }

      HTTPResponse testRes = new HTTPResponse();
      testRes.setBody(respStr);

      this.response.loadResponse(testRes);
    } else {
      // Make request
      this.sendRequest();
    }

    return this.response;
  }

  // Make a refund
  // Unfinished
  public Eway2Response makeRefund() {
    this.command = 'REFUND';

    // Validate required/min/max length of data
    this.validate();

    this.gatewayUrl += '/'+transactionNo+'/Refund';
    system.debug('this.gatewayUrl = ' + this.gatewayUrl);

    // Build request
    requestParams = new Map<String, String>();
    requestParams.put('Refund.TotalAmount', string.valueof(this.amount)); // Amount in cents
    requestParams.put('Refund.CurrencyCode', this.currencyCode);
    requestParams.put('Refund.InvoiceNumber', this.merchTxnRef);
    requestParams.put('Refund.InvoiceDescription', this.orderInfo);
    requestParams.put('Refund.InvoiceReference', this.merchTxnRef);
    requestParams.put('Refund.TransactionID', this.transactionNo);

    //requestParams.put('Customer.CardDetails.Name', this.cardName);
    //requestParams.put('Customer.CardDetails.Number', this.cardNum);
    requestParams.put('Customer.CardDetails.ExpiryMonth', this.cardExpiryMonth);
    requestParams.put('Customer.CardDetails.ExpiryYear', this.cardExpiryYear);
    //requestParams.put('Customer.CardDetails.CVN', this.cardCvc);


    system.debug('string.valueof(this.amount) = ' + string.valueof(this.amount));
    system.debug('Refund.CurrencyCode = ' + this.currencyCode);
    system.debug('Refund.InvoiceNumber' + this.merchTxnRef);
    system.debug('Refund.InvoiceDescription' + this.orderInfo);
    system.debug('Refund.InvoiceReference' + this.merchTxnRef);
    system.debug('Refund.TransactionID' +  this.transactionNo);

    system.debug('Customer.CardDetails.Name' + this.cardName);
    system.debug('Customer.CardDetails.Number' + this.cardNum);
    system.debug('Customer.CardDetails.ExpiryMonth' + this.cardExpiryMonth);
    system.debug('Customer.CardDetails.ExpiryYear' + this.cardExpiryYear);
    system.debug('Customer.CardDetails.CVN' + this.cardCvc);
    

    if (this.customerIP != null){
        requestParams.put('CustomerIP', this.customerIP);
    }

    // Make request
    return this.sendRequest();
  }

  public void setMerchTxnRef(String merchTxnRef) {
    this.merchTxnRef = merchTxnRef;
  }

  public void setOrderInfo(String OrderInfo) {
    this.orderInfo = orderInfo;
  }

  // Amount in cents
  public void setAmount(Integer amount, String currencyCode) {
    this.amount       = amount;
    this.currencyCode   = currencyCode;
  }

  public void setCustomerToken(String customerToken) {
    this.customerToken = customerToken;
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

  public void setCardExpiry(String month, String year) {
    // Pad month to two digits with left-side zeros
    if ( month != null && month.length()>2){
      month = month.trim().leftPad(2).replaceAll(' ', '0');
    }

    if (year != null && year.length() > 2){
      year = year.trim().substring(2,4);
    }

    this.cardExpiryMonth   = month;
    this.cardExpiryYear   = year;
  }

  public void setTransactionNo(String transNo) {
    this.transactionNo = transNo;
  }

  public void setCustomerCompanyName(String customerCompanyName) {
    this.customerCompanyName = Utility.ifnull(customerCompanyName, '').abbreviate(50);
  }

  public void setCustomerFirstName(String customerFirstName) {
    this.customerFirstName = Utility.ifnull(customerFirstName, '').abbreviate(50);
  }

  public void setCustomerLastName(String customerLastName) {
    this.customerLastName = Utility.ifnull(customerLastName, '').abbreviate(50);
  }

  public void setCustomerEmail(String customerEmail) {
    this.customerEmail = Utility.ifnull(customerEmail, '').abbreviate(50);
  }

  public void setCustomerStreet(String customerStreet) {
    this.customerStreet = Utility.ifnull(customerStreet, '').abbreviate(50);
  }

  public void setCustomerCity(String customerCity) {
    this.customerCity = Utility.ifnull(customerCity, '').abbreviate(50);
  }

  public void setCustomerState(String customerState) {
    this.customerState = Utility.ifnull(customerState, '').abbreviate(50);
  }

  public void setCustomerPostcode(String customerPostcode) {
    this.customerPostcode = Utility.ifnull(customerPostcode, '').abbreviate(30);
  }

  public void setCustomerCountrycode(String customerCountrycode) {
    this.customerCountrycode = customerCountrycode.toLowerCase();
  }

  public void setCustomerIP(String customerIP) {
    this.customerIP = customerIP;
  }

  // Validate all data
  public boolean validate(){
    // Documentation says InvoiceNumber is max 12 digits, but it actually allows much longer. We'll use 40 as the limit.
    this.checkValue('merchTxnRef', this.merchTxnRef, 40, false);
    this.checkValue('orderInfo', this.orderInfo, 64, false);

    if ( String.isEmpty(this.customerToken) ){
      this.checkValue('cardName', this.cardName, 256, true);
      //this.checkValue('cardNum', this.cardNum, 20, true);
      //this.checkValue('cardCvc', this.cardCvc, 4, true);
      //this.checkValue('cardExpiryMonth', this.cardExpiryMonth, 2, true);
      //this.checkValue('cardExpiryYear', this.cardExpiryYear, 2, true);
    }

    if (this.command == 'Refund'){
        this.checkValue('transactionNo', this.transactionNo, 40, true);
    }

    return (this.response.getErrorMessage() == null);
  }

  // Check that a single field is valid
  private String checkValue(String field, String value, Integer length, Boolean required) {
    String error;

    try {
      value = value.trim();

      if (required == true) {
        if (value == null || value.length()==0) {
          error = field+' can not be empty';
        }
      }

      if (value.length() > length) {
        error = field+' can not be longer than '+length;
      }
    } catch (Exception e) {
      error = field+' is invalid';
    }

    this.response.setErrors(error);

    return error;  
  }

  // Send the request to the merchant server
  private Eway2Response sendRequest() {
    // Build request body
    this.requestBody = Utility.createQueryStringFromMap(this.requestParams);

    if (utility.runningInASandbox()){
      system.debug('sendRequest :: Eway2 request: ' + this.requestBody);
    }

    // Make the request
    HttpRequest req = new HttpRequest();
    req.setEndpoint(this.gatewayUrl);
    req.setMethod('POST');
    req.setHeader('Authorization', 'BASIC ' + EncodingUtil.base64Encode(Blob.valueOf(this.merchantId + ':' + this.password)));
    req.setHeader('X-EWAY-APIVERSION', API_VERSION);
    req.setBody(this.requestBody);
    req.setTimeout(60000);

    // Send the request
    Http h = new Http();
    HTTPResponse res = h.send(req);

    system.debug('Eway2 Response: ' + EncodingUtil.urlDecode(res.getBody(), 'UTF-8'));

    this.response.loadResponse(res);

    system.debug('Eway2 error message: ' + this.response.getErrorMessage());

    return this.response;
  }
}