global class scheduleSignupPayments implements Schedulable { 
	global void execute(SchedulableContext SC) {
				
		xeroSignupPaymentsBatch signupPayments = new xeroSignupPaymentsBatch();
		Database.executeBatch(signupPayments,1);
		
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		//String[] toAddresses2  = new String[] { 'accounts@sponsoredlinx.com' };
		String[] toAddresses  = new String[] { 'mathew.carter@sponsoredlinx.com' };
		//String[] bccAddresses2 = new String[] { 'salesforce@sponsoredlinx.com' };
		mail.setToAddresses(toAddresses);
		//mail2.setBccAddresses(bccAddresses2);
		mail.setReplyTo('accounts@sponsoredlinx.com.au');
		mail.setSenderDisplayName('Salesforce Alert');
		mail.setSubject('Signup Payments Script Run');
		mail.setSaveAsActivity(false);
		mail.setUseSignature(false);
		mail.setPlainTextBody('Signup Payments Script Run');
		
		Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail } );
	}
	public static testMethod void testscheduleProductStatusCheck() {
		Test.StartTest();

		scheduleSignupPayments pb1 = new scheduleSignupPayments();
		String sch = '0 0 23 * * ?';
		system.schedule('Test scheduleSignupPayments', sch, pb1);
		
		Test.stopTest();
	}
}