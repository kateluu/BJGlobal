@isTest
private class ActivitySEOReportTest {
	
	@isTest static void test_sendOutEmail() {
        // Create common test accounts
        List<Account> testAccts = new List<Account>();
        try{               
	        	// Implement test code
				Test.startTest();

               
               	Boolean isTestMode = true;
               	Boolean isEmailSend = false;
		        ActivitySEOReport obj = new ActivitySEOReport(isTestMode, isEmailSend);
		            
		        Test.stopTest();
				
        }catch(DMLException e){
            system.debug('retry' + e.getMessage());
        }

	}
	
}