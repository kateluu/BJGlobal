global class processEwayPayments implements Schedulable {

	public static boolean isTest = false;

	global void execute(SchedulableContext sc) {
		String[] periods = new list<String> {'Today', '3 Day', '5 Day', '9 Day', '13 Day'};
				
		for(string period : periods) {
//			dailyBatchPaymentsProcess batch = new dailyBatchPaymentsProcess(period, 'SponsoredLinX'); // Old, eway only
			batchPaymentsProcess batch = new batchPaymentsProcess(period, 'SponsoredLinX'); // New, generic paymentGateway (for eway2)
			ID batchId = Database.executeBatch(batch,1);
			System.debug(batch);
			System.debug(batchId);
		}
	}

	public static testMethod void processEwayPaymentsTest() {
		Test.startTest();

		datetime time1 = Datetime.now();
		datetime time2 = time1.addSeconds(5);
		String seconds = String.valueOf(time2.second());
		String minutes = String.valueOf(time2.minute());
		String hours = String.valueOf(time2.hour());

		String sch = seconds + ' ' + minutes + ' ' + hours + ' ? * MON-SUN';

		System.schedule('Process Eway Payments test', sch, new processEwayPayments());

		Test.stopTest();
	}
}