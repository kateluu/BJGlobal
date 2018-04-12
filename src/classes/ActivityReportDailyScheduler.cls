global class ActivityReportDailyScheduler implements Schedulable{
	global void execute(SchedulableContext SC) {
		ActivityReportDaily ar = new ActivityReportDaily();
	}
	
	public static testMethod void ActivityReportDailySchedulerTest() {
		Test.StartTest();

		datetime time1 = Datetime.now();
		datetime time2 = time1.addSeconds(5);
		String seconds = String.valueOf(time2.second());
		String minutes = String.valueOf(time2.minute());
		String hours = String.valueOf(time2.hour());

		String sch = seconds + ' ' + minutes + ' ' + hours + ' ? * MON-SUN';
		System.debug('sch:' + sch);
		System.schedule('Activity Report Schedule12', sch, new ActivityReportDailyScheduler());

		Test.stopTest();
	}
}