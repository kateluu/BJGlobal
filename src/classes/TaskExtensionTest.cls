@isTest
private class TaskExtensionTest {
	
    // Test methods
    @isTest
    Private Static void testGetCallRecordingURL() {

		// Create a test task
		task testTask = new task();
		testTask.Subject = 'Outbound call to +61061244443333';
		testTask.CallDurationInSeconds = 500;
		testTask.NVMContactWorld__CW_Call_Start_Time__c = datetime.now();
		testTask.NVMContactWorld__CW_Call_End_Time__c = datetime.now();
		insert testTask;


        Test.startTest();

        // Load the controller
        ApexPages.currentPage().getParameters().put('id',testTask.id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(testTask);
        TaskExtension testController = new TaskExtension(stdController);

        String callUrl = testController.getCallRecordingURL();

        System.assertNotEquals(null, callUrl);

        Test.stopTest();
    }
	
}