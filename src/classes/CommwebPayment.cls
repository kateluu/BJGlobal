public with sharing class CommwebPayment {

    //**********
    //Constants
    //**********

    // SponsoredLinx Commmweb Account
    private static String COMMWEB_GATEWAY_URL = 'https://migs.mastercard.com.au/vpcdps';
    private static String COMMWEB_MERCHANT_ID = 'SPOSORMCC01';
    private static String COMMWEB_ACCESSCODE = 'B0A4D610';
    private static String COMMWEB_USERNAME = 'slx' ;
    private static String COMMWEB_PASSWORD = 'v14#UG2(ybX>1ov';


    // GMT Commmweb Account - need to add acc info any update request params
    private static String GMT_COMMWEB_GATEWAY_URL = 'https://migs.mastercard.com.au/vpcdps';
    private static String GMT_COMMWEB_MERCHANT_ID = 'SPOSORMCC01';
    private static String GMT_COMMWEB_ACCESSCODE = 'B0A4D610';

    private static String COMMWEB_MOCK_MERCHANT_ID = 'TESTSPOSORMCC01';
    private static String COMMWEB_MOCK_ACCESSCODE = 'C67770C2'; //C67770C2
    private static String COMMWEB_MOCK_USERNAME = 'sxl_test' ;
    private static String COMMWEB_MOCK_PASSWORD = 'v14#UG2(ybX>1ov';

    //**********
    //Properties
    //**********
    private CommwebResponse response;
    private String commWebGatewayUrl;
    private String commwebMerchTxnRef;
    private String orderInfo;
    private String amount;
    private String cardNum;
    private String cardExp;
    private String request;
    private String merchantId;
    private String accessCode;
    private String currencyCode;
    private String transactionNo;
    private String username;
    private String password;
    private Boolean testMode = false;

    //***********
    //Constructor
    //***********
    public CommwebPayment() {
        this.response = new CommwebResponse();
        this.merchantId = COMMWEB_MERCHANT_ID;
        this.accessCode = COMMWEB_ACCESSCODE;
        this.username = COMMWEB_USERNAME;
        this.password = COMMWEB_PASSWORD;
        this.currencyCode = 'NZD';
    }

    // Set test (mock) mode
    public void setTestMode() {
        this.testMode = true;
    }

    public CommwebResponse makePayment() {
        system.debug('makePayment:');
        this.buildRequest();
        this.sendRequest();

        return this.response;
    }

    public CommwebResponse makeRefund() {
        system.debug('makeRefund:');
        this.buildRefundRequest();
        this.sendRequest();
        return this.response;
    }

    private void buildRequest() {
        if (this.testMode == true) {
            this.cardNum = '5123456789012346';
            this.cardExp = '2105';
            this.merchantId = COMMWEB_MOCK_MERCHANT_ID;
            this.accessCode = COMMWEB_MOCK_ACCESSCODE;

        }


        this.request = 'vpc_Version=1';
        this.request += '&vpc_Command=pay';
        this.request += '&vpc_AccessCode=' + EncodingUtil.urlEncode(this.accessCode, 'UTF-8');
        this.request += '&vpc_Currency=' + EncodingUtil.urlEncode(this.currencyCode, 'UTF-8');
        this.request += '&vpc_MerchTxnRef=' + EncodingUtil.urlEncode(this.commwebMerchTxnRef, 'UTF-8');
        this.request += '&vpc_Merchant=' + EncodingUtil.urlEncode(this.merchantId, 'UTF-8');
        this.request += '&vpc_OrderInfo=' + EncodingUtil.urlEncode(this.orderInfo, 'UTF-8');
        this.request += '&vpc_Amount=' + EncodingUtil.urlEncode(this.amount, 'UTF-8');
        this.request += '&vpc_CardNum=' + EncodingUtil.urlEncode(this.cardNum, 'UTF-8');
        this.request += '&vpc_CardExp=' + EncodingUtil.urlEncode(this.cardExp, 'UTF-8');

        system.debug('request:' + this.request);
    }

    private void buildRefundRequest() {
        if (this.testMode == true) {
            this.cardNum = '5123456789012346';
            this.cardExp = '2105';
            this.merchantId = COMMWEB_MOCK_MERCHANT_ID;
            this.accessCode = COMMWEB_MOCK_ACCESSCODE;
            this.userName = COMMWEB_MOCK_USERNAME;
            this.password = COMMWEB_MOCK_PASSWORD;
        }
        this.request = 'vpc_Version=1';
        this.request += '&vpc_Command=refund';
        this.request += '&vpc_AccessCode=' + EncodingUtil.urlEncode(this.accessCode, 'UTF-8');
        this.request += '&vpc_Currency=' + EncodingUtil.urlEncode(this.currencyCode, 'UTF-8');
        this.request += '&vpc_MerchTxnRef=' + EncodingUtil.urlEncode(this.commwebMerchTxnRef, 'UTF-8');
        this.request += '&vpc_Merchant=' + EncodingUtil.urlEncode(this.merchantId, 'UTF-8');
        this.request += '&vpc_Amount=' + EncodingUtil.urlEncode(this.amount, 'UTF-8');
        this.request += '&vpc_CardNum=' + EncodingUtil.urlEncode(this.cardNum, 'UTF-8');
        this.request += '&vpc_CardExp=' + EncodingUtil.urlEncode(this.cardExp, 'UTF-8');
        this.request += '&vpc_TransNo=' + EncodingUtil.urlEncode(this.transactionNo, 'UTF-8');
        this.request += '&vpc_OrderInfo=' + EncodingUtil.urlEncode(this.orderInfo, 'UTF-8');
        this.request += '&vpc_Currency=NZD' ;
        this.request += '&vpc_User=' + EncodingUtil.urlEncode(this.userName, 'UTF-8') ;
        this.request += '&vpc_Password=' + EncodingUtil.urlEncode(this.password, 'UTF-8');
        //this.request += '&vpc_TransNo=1100000094';
        //this.request += '&vpc_User= sxl_test'    ;
        //this.request += '&vpc_Password=v14#UG2(ybX>1ov'  ;

        system.debug('buildRefundRequest: request:' + this.request);
    }


    public void setCommwebMerchTxnRef(String CommwebMerchTxnRef) {
        // 	50
        this.commwebMerchTxnRef = this.checkValue('CommwebMerchTxnRef', CommwebMerchTxnRef, 50, false);
    }

    public void setOrderInfo(String OrderInfo) {
        // 	50
        this.orderInfo = this.checkValue('OrderInfo', orderInfo, 100, false);
    }

    public void setAmount(String Amount) {
        // 	12
        this.amount = this.checkValue('Amount', Amount, 12, true);
    }

    public void setCardNum(String CardNum) {
        // 	12
        this.cardNum = this.checkValue('CardNum', cardNum, 20, true);
    }

    public void setCardExp(String CardExp) {
        // 	4
        this.cardExp = this.checkValue('CardNum', CardExp, 4, true);
    }

    public void setTransactionNo(String transNo) {
        // 	4
        this.transactionNo = transNo;//this.checkValue('CardNum',CardExp,4,true);
    }


    private String checkValue(String field, String value, Integer length, Boolean required) {
        System.debug('***' + field + ':' + value);
        try {
            value = value.trim();
            if (required == true) {
                if (value == null || value.length() == 0) {
                    if (field.length() > 0) {
                        this.response.setCommWebErrors(field + ' can not be empty');
                    }
                }
            }
            if (value.length() > length) {
                if (field.length() > 0) {
                    this.response.setCommWebErrors(field + ' can not be longer then ' + length);
                }
            }
        } catch (Exception e) {
            if (required == true) {
                if (field.length() > 0) {
                    this.response.setCommWebErrors(field + ' can not be empty');
                }
            }
        }
        return value;
    }


    private void sendRequest() {
        this.commWebGatewayUrl = COMMWEB_GATEWAY_URL;

        HttpRequest req = new HttpRequest();
        Http h = new Http();
        req.setEndpoint(this.commWebGatewayUrl);
        req.setMethod('POST');
        req.setBody(this.request);
        system.debug(req);
        req.setTimeout(20000);
        HTTPResponse res = h.send(req);
        system.debug(res.getBody());
        this.response.loadResponse(res.getBody());
        //this.response ='test';
    }

}