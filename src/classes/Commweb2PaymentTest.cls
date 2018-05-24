@isTest
private class Commweb2PaymentTest {
	
	@testSetup	static void setup(){	
		//create custom setting value
		 PaymentGateway__c merchantConfig = new PaymentGateway__c();
		 merchantConfig.name = 'Commweb SLX NZ';
		 merchantConfig.MerchantURL__c = 'https://paymentgateway.commbank.com.au/api/nvp/version/41';
		 merchantConfig.Merchant_Name__c = 'TESTGETMORMCC201';
		 merchantConfig.Password__c = 'c28e3036c25fe5c6e5d0f2e508cccdb2';
		 insert merchantConfig;

	}



	@isTest static void test_payment() {		
		// Implement test code

		Commweb2Payment payment = new Commweb2Payment();
		payment.setTestMode(paymentGateway.GATEWAY_LOCAL,paymentGateway.TEST_SUCCESS);
		payment.setMerchant('Commweb SLX NZ');
		payment.setAmount(10,'NZD');		
		payment.setMerchTxnRef('test refund');
		payment.setUniqueAttemptId('INV123');
		payment.setOrderInfo('dffdd');
		payment.setCardName('dffdd');
		payment.setCardNum('5123450000000008');
		payment.setCardCvc('154');
		payment.setCardExpiry('05','21');
		Commweb2Response response = payment.makePayment();

		payment.setTestMode(paymentGateway.GATEWAY_LOCAL,paymentGateway.TEST_FAILURE);
	 	response = payment.makePayment();


		payment.setTestMode(paymentGateway.GATEWAY_LOCAL,paymentGateway.TEST_EXPIRED);
		 response = payment.makePayment();


		payment.setTestMode(paymentGateway.GATEWAY_LOCAL,paymentGateway.TEST_TIMEOUT);
		 response = payment.makePayment();

	}	

	@isTest static void test_refund() {		
		// Implement test code
		Commweb2Payment payment = new Commweb2Payment();
		payment.setTestMode(paymentGateway.GATEWAY_MOCK,paymentGateway.TEST_SUCCESS);
		payment.setAmount(10,'NZD');		
		payment.setMerchTxnRef('test refund');
		payment.setUniqueAttemptId('INV123');
		payment.setOrderInfo('dffdd');
		payment.setCardName('dffdd');
		payment.setCardNum('5123450000000008');
		payment.setCardCvc('154');
		payment.setCardExpiry('05','21');

		Commweb2Response response = payment.makeRefund();

		payment.setTestMode(paymentGateway.GATEWAY_MOCK,paymentGateway.TEST_FAILURE);
		 response = payment.makeRefund();


		payment.setTestMode(paymentGateway.GATEWAY_MOCK,paymentGateway.TEST_EXPIRED);
		 response = payment.makeRefund();


		payment.setTestMode(paymentGateway.GATEWAY_MOCK,paymentGateway.TEST_TIMEOUT);
		 response = payment.makeRefund();

	}	
}