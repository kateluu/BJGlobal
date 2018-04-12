global class processGMTPaymentSchedule implements Schedulable {

	public static boolean isTest = false;

	global void execute(SchedulableContext sc) {
		String[] periods = new list<String> {'Today', '3 Day', '5 Day', '9 Day', '13 Day'};
				
		for(string period : periods) {
			//GMTPaymentBatch batch = new GMTPaymentBatch(period); // Old, eway only
			batchPaymentsProcess batch = new batchPaymentsProcess(period, 'Get More Traffic'); // New, generic paymentGateway (for eway2)
			ID GMTBatchId = Database.executeBatch(batch,1);
			System.debug(batch);
			System.debug(GMTBatchId);
		}
	}

	public static testMethod void test() {
        // Setup companies
        Company__c company = new Company__c(
            Name = 'Get More Traffic',
            Business_Name__c = 'GMT',
            Checkout_Site__c = 'checkout_GMT',
            Payment_Gateway__c = 'Eway2',
            CurrencyIsoCode  = 'NZD'
        );
        insert company;

		
		Test.startTest();

		datetime time1 = Datetime.now();
		datetime time2 = time1.addSeconds(5);
		String seconds = String.valueOf(time2.second());
		String minutes = String.valueOf(time2.minute());
		String hours = String.valueOf(time2.hour());

		String sch = seconds + ' ' + minutes + ' ' + hours + ' ? * MON-SUN';

		System.schedule('Process Eway Payments test', sch, new processGMTPaymentSchedule());

		Test.stopTest();
	}
}