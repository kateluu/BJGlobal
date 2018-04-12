global class generateInvoiceBatchTestSchedule  implements Schedulable {

	global void execute(SchedulableContext sc) {
		//Sponsored Batch
        String[] periods = new list<String> {'Today', '3 Day', '5 Day', '9 Day', '13 Day'};
		String[] companyNames = new list<String> {'SponsoredLinX'};

		for(string companyName : companyNames) {
	        for(string period : periods) {
				batchInvoiceCreateBatch batch = new batchInvoiceCreateBatch(period, companyName);
				ID batchprocessid = Database.executeBatch(batch, 10);
				System.debug(batch);
				System.debug(batchprocessid);
			}
		}
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
		System.schedule('generateInvoiceBatchtest', sch, new generateInvoiceBatchTestSchedule());

		Test.stopTest();
	}
}