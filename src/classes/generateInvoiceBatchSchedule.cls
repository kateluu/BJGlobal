global class generateInvoiceBatchSchedule implements Schedulable {

	global void execute(SchedulableContext sc) {
		batchXeroInvoiceCreateBatch batchToday = new batchXeroInvoiceCreateBatch('Today');
		ID batchprocessidtoday = Database.executeBatch(batchToday, 10);
		System.debug(batchToday);
		System.debug(batchprocessidtoday);

		batchXeroInvoiceCreateBatch batch03Day = new batchXeroInvoiceCreateBatch('3 Day');
		ID batchprocessid03day = Database.executeBatch(batch03Day, 10);
		System.debug(batch03Day);
		System.debug(batchprocessid03day);

		batchXeroInvoiceCreateBatch batch05Day = new batchXeroInvoiceCreateBatch('5 Day');
		ID batchprocessid05day = Database.executeBatch(batch05Day, 10);
		System.debug(batch05Day);
		System.debug(batchprocessid05day);

		batchXeroInvoiceCreateBatch batch09Day = new batchXeroInvoiceCreateBatch('9 Day');
		ID batchprocessid09day = Database.executeBatch(batch09Day, 10);
		System.debug(batch09Day);
		System.debug(batchprocessid09day);

		batchXeroInvoiceCreateBatch batch13Day = new batchXeroInvoiceCreateBatch('13 Day');
		ID batchprocessid13day = Database.executeBatch(batch13Day, 10);
		System.debug(batch13Day);
		System.debug(batchprocessid13day);
	}

	public static testMethod void generateInvoiceBatchTest() {
		Test.StartTest();

		datetime time1 = Datetime.now();
		datetime time2 = time1.addSeconds(5);
		String seconds = String.valueOf(time2.second());
		String minutes = String.valueOf(time2.minute());
		String hours = String.valueOf(time2.hour());

		String sch = seconds + ' ' + minutes + ' ' + hours + ' ? * MON-SUN';
		System.debug('sch:' + sch);
		System.schedule('generateInvoiceBatchtest', sch, new generateInvoiceBatchSchedule());

		Test.stopTest();
	}
}