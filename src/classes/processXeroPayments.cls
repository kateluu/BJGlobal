global class processXeroPayments implements Schedulable {

	public static boolean isTest = false;

	global void execute(SchedulableContext sc) {
		sendXeroPaymentsProcess batchToday = new sendXeroPaymentsProcess('Today');
		ID batchprocessidtoday = Database.executeBatch(batchToday,1);			
		System.debug(batchToday);
		System.debug(batchprocessidtoday);

		sendXeroPaymentsProcess batch03Day = new sendXeroPaymentsProcess('3 Day');
		ID batchprocessid03Day = Database.executeBatch(batch03Day,1);			
		System.debug(batch03Day);
		System.debug(batchprocessid03Day);

		sendXeroPaymentsProcess batch05Day = new sendXeroPaymentsProcess('5 Day');
		ID batchprocessid05Day = Database.executeBatch(batch05Day,1);			
		System.debug(batch05Day);
		System.debug(batchprocessid05Day);

		sendXeroPaymentsProcess batch09Day = new sendXeroPaymentsProcess('9 Day');
		ID batchprocessid09Day = Database.executeBatch(batch09Day,1);			
		System.debug(batch09Day);
		System.debug(batchprocessid09Day);

		sendXeroPaymentsProcess batch13Day = new sendXeroPaymentsProcess('13 Day');
		ID batchprocessid13Day = Database.executeBatch(batch13Day,1);			
		System.debug(batch13Day);
		System.debug(batchprocessid13Day);
	}

	public static testMethod void processXeroPaymentsTest() {
		Test.startTest();

		datetime time1 = Datetime.now();
		datetime time2 = time1.addSeconds(5);
		String seconds = String.valueOf(time2.second());
		String minutes = String.valueOf(time2.minute());
		String hours = String.valueOf(time2.hour());

		String sch = seconds + ' ' + minutes + ' ' + hours + ' ? * MON-SUN';

		System.schedule('Process XERO Payments', sch, new processXeroPayments());

		Test.stopTest();
	}
}