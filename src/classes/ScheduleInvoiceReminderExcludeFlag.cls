global class ScheduleInvoiceReminderExcludeFlag implements Schedulable {

	/*
	 * This schedule is used to set the exclude invoice reminder flag inside
	 * each invoice created by daily invoice batch. We need this since invoice
	 * batch always creates a new invoice object every time it runs.
	 */

	global void execute(SchedulableContext sc) {
		InvoiceReminder.setInvoiceReminderExcludeFlag();
	}

	public static testMethod void ScheduleInvoiceReminderExcludeFlagTest() {
		Test.StartTest();

		ScheduleInvoiceReminderExcludeFlag sie = new ScheduleInvoiceReminderExcludeFlag();
		String sch = '0 0 2 * * ?';
		system.schedule('Test set invoice reminder exclude flag', sch, sie);
		Test.stopTest();
	}

}