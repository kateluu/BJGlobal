global class generateEmailInvoice implements Schedulable {

	public static boolean isTest = false;
	
	global void execute(SchedulableContext sc) {
		System.abortJob(sc.getTriggerId());

		//EmailInvoices.sendInvoices();
	}

	public static testMethod void generateEmailInvoiceTest() {
		Test.startTest();

		datetime time1 = Datetime.now();
		datetime time2 = time1.addSeconds(5);
		String seconds = String.valueOf(time2.second());
		String minutes = String.valueOf(time2.minute());
		String hours = String.valueOf(time2.hour());

		String sch = seconds+' '+minutes+' '+hours+' ? * MON-SUN';	

		System.schedule('Generate Email Invoice', sch, new generateEmailInvoice());

		Test.stopTest();
	}
}