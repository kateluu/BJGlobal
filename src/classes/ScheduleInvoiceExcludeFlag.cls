global class ScheduleInvoiceExcludeFlag implements Schedulable {

	/*
	 * This schedule is used to set the exclude invoice flag inside each invoice
	 * created by daily invoice batch. We need this since invoice batch always
	 * creates a new invoice object every time it runs.
	 */

	global void execute(SchedulableContext sc) {
		Invoice.setInvoiceExcludeFlag();
	}

	public static testMethod void ScheduleInvoiceExcludeFlagTest() {
		Test.StartTest();

		ScheduleInvoiceExcludeFlag sie = new ScheduleInvoiceExcludeFlag();
		String sch = '0 0 2 * * ?';
		system.schedule('Test set invoice exclude flag', sch, sie);
		Test.stopTest();
	}

}