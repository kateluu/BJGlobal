global class ActivityReportScheduler implements Schedulable{
	global void execute(SchedulableContext SC) {
		Boolean isTest = false;
		Boolean isEmailSend = true;
		ActivityReport ar = new ActivityReport(isTest);
		ActivitySEOReport sr = new ActivitySEOReport(isTest, isEmailSend);		
	}
		
	public static testMethod void ActivityReportSchedulerTest() {
		Test.StartTest();

		datetime time1 = Datetime.now();
		datetime time2 = time1.addSeconds(5);
		String seconds = String.valueOf(time2.second());
		String minutes = String.valueOf(time2.minute());
		String hours = String.valueOf(time2.hour());

		String sch = seconds + ' ' + minutes + ' ' + hours + ' ? * MON-SUN';
		System.debug('sch:' + sch);
		System.schedule('Activity Report Schedule', sch, new ActivityReportScheduler());

		Test.stopTest();
	}
}