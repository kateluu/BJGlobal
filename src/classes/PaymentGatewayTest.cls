@isTest
private class PaymentGatewayTest {
    // Initialize records required for test cases
    public static void init(){
    	// Eway2
		insert new PaymentGateway__c(
			Name				= 'Eway Rapid SLX AU',
			MerchantURL__c		= 'https://example.com',
			Access_Code__c		= 'exampleaccesscode',
			Password__c			= 'examplepassword'
		);

		// Commweb 1
		insert new PaymentGateway__c(
			Name				= 'Sponsoredlinx NZ',
			MerchantURL__c		= 'https://example.com',
			Access_Code__c		= 'exampleaccesscode',
			Operation_ID__c		= 'exampleopid',
			Password__c			= 'examplepassword'
		);

		insert new PaymentGateway__c(
			Name				= 'Sponsoredlinx NZ Test',
			MerchantURL__c		= 'https://example.com',
			Access_Code__c		= 'exampleaccesscode',
			Operation_ID__c		= 'exampleopid',
			Password__c			= 'examplepassword'
		);

		// Commweb2
		insert new PaymentGateway__c(
			Name				= 'Commweb GMT NZ',
			MerchantURL__c		= 'https://example.com',
			Access_Code__c		= 'exampleaccesscode',
			Password__c			= 'examplepassword'
		);

		insert new PaymentGateway__c(
			Name				= 'Commweb SLX NZ',
			MerchantURL__c		= 'https://example.com',
			Access_Code__c		= 'exampleaccesscode',
			Password__c			= 'examplepassword'
		);
    }

    // Get basic payment gateway data for text cases
    static PaymentGateway getBasePaymentGateway(){
		PaymentGateway payment = new PaymentGateway();
		payment.testGateway 				= paymentGateway.GATEWAY_LOCAL;
		payment.amount						= 100;
		payment.currencyIsoCode 			='NZD';
		payment.customerFirstName 			='w';		
		payment.customerEmail				='wewew@gmail.com';
		payment.isRefund 					= false;
		payment.customerStreet              = '100 Wickham St';
		payment.customerCity                = 'Fortitude Valley';
		payment.customerState               = 'QLD';
		payment.customerPostcode            = '4006';
		payment.cardHoldersName             = 'Joe Citizen';
		payment.cardNumber                  = '4444333322221111';
		payment.cardExpiryMonth             = '05';
		payment.cardExpiryYear              = '2021';
		payment.cardCVN                     = '123';
		payment.customerInvoiceRef 			= 'INV12345';
		payment.customerInvoiceDescription  = 'Test Invoice';
		payment.testType					= paymentGateway.TEST_SUCCESS;

		return payment;
    }

	// Test payments
	@isTest 
	static void test_pay() {
		init();
		PaymentGateway payment;
		Payment_Attempt__c payAttempt;
		Company__c myCom = new Company__c();
		myCom.Name = 'SponsoredLinX';

		// Eway
		myCom.Payment_Gateway__c = 'Eway';
		payment = getBasePaymentGateway();
		payment.setBjbCompany(myCom);
		payment.testType = paymentGateway.TEST_SUCCESS;
		payAttempt = payment.pay();
		system.assertEquals('SUCCESS', payAttempt.Status__c);

		payment.testType = paymentGateway.TEST_FAILURE;
		payAttempt = payment.pay();
		system.assertEquals('FAILURE', payAttempt.Status__c);

		// Eway2
		myCom.Payment_Gateway__c = 'Eway2';
		payment = getBasePaymentGateway();
		payment.setBjbCompany(myCom);
		payment.testType = paymentGateway.TEST_SUCCESS;
		payAttempt = payment.pay();
		system.assertEquals('SUCCESS', payAttempt.Status__c);

		payment.testType = paymentGateway.TEST_FAILURE;
		payAttempt = payment.pay();
		system.assertEquals('FAILURE', payAttempt.Status__c);
		
		// Commweb
		myCom.Name = 'SponsoredLinX New Zealand';
		myCom.Payment_Gateway__c = 'CommWeb';
		payment = getBasePaymentGateway();
		payment.setBjbCompany(myCom);
		payment.testType = paymentGateway.TEST_SUCCESS;
		payAttempt = payment.pay();
		system.assertEquals('SUCCESS', payAttempt.Status__c);

		payment.testType = paymentGateway.TEST_FAILURE;
		payAttempt = payment.pay();
		system.assertEquals('FAILURE', payAttempt.Status__c);

		// Commweb2
		myCom.Name = 'Get More Traffic New Zealand';
		myCom.Payment_Gateway__c = 'CommWeb2';
		payment = getBasePaymentGateway();
		payment.setBjbCompany(myCom);
		payment.testType = paymentGateway.TEST_SUCCESS;
		payAttempt = payment.pay();
		system.assertEquals('SUCCESS', payAttempt.Status__c);

		payment.testType = paymentGateway.TEST_FAILURE;
		payAttempt = payment.pay();
		system.assertEquals('FAILURE', payAttempt.Status__c);
	}


	// Test updateAccountToken
	@isTest 
	static void test_updateAccountToken() {
		init();
		PaymentGateway payment;
		Company__c myCom = new Company__c();
		myCom.Name = 'SponsoredLinX';
		myCom.Payment_Gateway__c = 'Eway2';
		insert myCom;

		Account existingAccount = new Account();
		existingAccount.Name = 'Joe Smith';
		existingAccount.Name_On_Card__c = 'Joe Smith';
		existingAccount.Card_Month_Expiry__c = '12';
		existingAccount.Card_Year_Expiry__c = '2025';
		existingAccount.currencyIsoCode = 'AUD';
		existingAccount.BJB_Company__c = myCom.Id;
		insert existingAccount;

        // Contacts should be created before Account Products
        List<Contact> newContacts = new List<Contact>();
        for (String contact_type : new List<String> {'Billing','Reports','Marketing'}){
            newContacts.add( 
                new Contact(
                    FirstName         = 'Steve',
                    LastName          = 'Existingclient',
                    AccountId         = existingAccount.Id,
                    Phone             = '0407040404',
                    Email             = existingAccount.username__c,
                    Title             = contact_type
                )
            );
        }
        insert newContacts;

		test.starttest();

		// Eway2
		myCom.Payment_Gateway__c = 'Eway2';
		payment = getBasePaymentGateway();

		payment.updateAccountToken(existingAccount, '4444333322221111', '123');

		// Commweb2
		myCom.Name = 'SponsoredLinX New Zealand';
		myCom.Payment_Gateway__c = 'Commweb2';
		update myCom;
		payment.updateAccountToken(existingAccount, '4444333322221111', '123');

		test.stoptest();
	}


	// Test refunds
	@isTest 
	static void test_refund() {
		init();
		PaymentGateway payment = getBasePaymentGateway();
		payment.isRefund 					= true;

		Payment_Attempt__c payAttempt;
		
		Company__c myCom = new Company__c();
		myCom.Name = 'SponsoredLinX';

		myCom.Payment_Gateway__c = 'Eway';
		payment.setBjbCompany(myCom);
		payAttempt = payment.refund();

		myCom.Payment_Gateway__c = 'Eway2';
		payment.setBjbCompany(myCom);
		payAttempt = payment.pay();
		
		myCom.Payment_Gateway__c = 'CommWeb';
		payment.setBjbCompany(myCom);
		payAttempt = payment.refund();

		myCom.Payment_Gateway__c = 'CommWeb2';
		payment.setBjbCompany(myCom);
		payAttempt = payment.refund();
	}
	
}