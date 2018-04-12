@isTest
private class UtilityTest {
	
	@isTest 
	static void getUserIPAddressTest() {
		String ip;

        PageReference pageRef = Page.CheckoutMain_slx;
        pageRef.getHeaders().put('X-Forwarded-For', '11.11.11.11');
        Test.setCurrentPage(pageRef);

		system.assertEquals('11.11.11.11', Utility.getUserIPAddress());
	}
	
	@isTest 
	static void generateRandomStringTest() {
		String random = Utility.generateRandomString(12);
		system.assertEquals(12, random.length());
	}

	@isTest 
	static void zerofyTest() {
	    Integer myInteger;
	    Decimal myDecimal;
	    Long myLong;

		system.assertEquals(0, Utility.zerofy(myInteger));
		system.assertEquals(0, Utility.zerofy(myDecimal));
		system.assertEquals(0, Utility.zerofy(myLong));
	}

	@isTest 
	static void ifnullTest() {
		String myString;
		system.assertEquals('', Utility.ifnull(myString, ''));
	}

	@isTest 
	static void runningInASandboxTest() {
		system.assertNotEquals(null, Utility.runningInASandbox());
	}
}