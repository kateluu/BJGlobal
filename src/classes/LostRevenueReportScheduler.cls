global class LostRevenueReportScheduler implements Schedulable{
	global void execute(SchedulableContext SC) {
		//LostRevenue report = new LostRevenue();
		//report.send();
	}
	
	public static testMethod void LostRevenueReportSchedulerTest() {
		Test.StartTest();

		datetime time1 = Datetime.now();
		datetime time2 = time1.addSeconds(5);
		String seconds = String.valueOf(time2.second());
		String minutes = String.valueOf(time2.minute());
		String hours = String.valueOf(time2.hour());

		String sch = seconds + ' ' + minutes + ' ' + hours + ' ? * MON-SUN';
		System.debug('sch:' + sch);
		System.schedule('Lost Revenue Report Schedule', sch, new LostRevenueReportScheduler());

		Test.stopTest();
	}
}