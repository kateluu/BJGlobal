global class scheduleProductStatusCheck implements Schedulable { 
	global void execute(SchedulableContext SC) {
				
		pauseProductStatusBatch pauseBatch = new pauseProductStatusBatch();
		cancelProductStatusBatch cancelBatch = new cancelProductStatusBatch();
		activateProductStatusBatch activeBatch = new activateProductStatusBatch();
		
		Database.executeBatch(pauseBatch, 1);
		Database.executeBatch(cancelBatch, 1);
		Database.executeBatch(activeBatch, 1);
		
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		//String[] toAddresses2  = new String[] { 'accounts@sponsoredlinx.com' };
		String[] toAddresses  = new String[] { 'devteam@sponsoredlinx.com' };
		//String[] bccAddresses2 = new String[] { 'salesforce@sponsoredlinx.com' };
		mail.setToAddresses(toAddresses);
		//mail2.setBccAddresses(bccAddresses2);
		mail.setReplyTo('accounts@sponsoredlinx.com.au');
		mail.setSenderDisplayName('Salesforce Alert');
		mail.setSubject('Todays Product Status Have Run');
		mail.setSaveAsActivity(false);
		mail.setUseSignature(false);
		mail.setPlainTextBody('Todays Product Status Have Run');
		
		Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail } );
	}
	public static testMethod void testscheduleProductStatusCheck() {
		Test.StartTest();

		scheduleProductStatusCheck pb1 = new scheduleProductStatusCheck();
		String sch = '0 0 23 * * ?';
		system.schedule('Test scheduleProductStatusCheck', sch, pb1);
		
		Test.stopTest();
	}
}