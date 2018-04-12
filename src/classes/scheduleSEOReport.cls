global class scheduleSEOReport implements Schedulable{
	
	
	global void execute(SchedulableContext SC){
		SEO_Report_Schedule__c r = new SEO_Report_Schedule__c();
      	r.Name = 'Fortnightly SEO Reports';
      	r.Status__c = 'Pending';
      	datetime scheduledate = datetime.now().addDays(4);
      	r.Schedule_Date__c = scheduledate;
      	insert r;
	}
	
	public static testMethod void scheduleReportTest() {
		
		Test.startTest();
		
		scheduleSEOReport s = new scheduleSEOReport();
		String sch = '0 0 2 * * ?';
		system.schedule('Test set invoice exclude flag', sch, s);
		
		Test.stopTest();
		
	}
	
	
}