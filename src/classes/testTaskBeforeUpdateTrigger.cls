@isTest
private class testTaskBeforeUpdateTrigger {
	
	static testMethod void testTaskBeforeUpdateTrigger(){
		Test.startTest();

		// Create a task owned by 'Accounts & Admin'
		Profile taskOwnerProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Accounts & Admin' LIMIT 1];
		User taskOwner = [SELECT Id, ProfileId FROM User WHERE ProfileId =: taskOwnerProfile.Id AND isActive = true LIMIT 1];

		Task myTask = new Task();
		myTask.OwnerId = taskOwner.Id;
		myTask.Subject = 'First subject';
		insert myTask;

		// Update the task
		myTask.Subject = 'New subject';
		update myTask;
		
		Test.stopTest();
	}
}