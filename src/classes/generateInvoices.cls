global class generateInvoices implements Schedulable{
	global void execute(SchedulableContext SC){
		InvoiceCreateTest createInvoices = new InvoiceCreateTest();
		ID batchprocessidtoday = Database.executeBatch(createInvoices, 40);
		System.debug(createInvoices);
		System.debug(batchprocessidtoday);
       													
	}
	
	public static testMethod void generateInvoices() {
		Test.StartTest();
		
		datetime time1 = Datetime.now();
		datetime time2 = time1.addSeconds(5);
		String seconds = String.valueOf(time2.second());
		String minutes = String.valueOf(time2.minute());
		String hours = String.valueOf(time2.hour());
		
		String sch = seconds+' '+minutes+' '+hours+' ? * MON-SUN';	
		System.debug('sch:'+sch);
		System.schedule('generateInvoices', sch, new generateInvoices());
			
		Test.stopTest();
	}
	
	
	
	

}