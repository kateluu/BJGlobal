global class CascadeProgressUpdateScheduler  implements Schedulable {

	//Define the method signature to be implemented in classes that implements the interface
	//Example method
	global void execute(SchedulableContext SC) {
		String isTest = 'false';
		//CascadeConnector casConnector = new CascadeConnector(isTest);
		CascadeConnector.isTest = 'false';
		CascadeConnector.updateProgress();
	}
	
	//@isTest 
	//static void  CascadeProgressUpdateSchedulerTest() {
	//	Test.StartTest();

	//	datetime time1 = Datetime.now();
	//	datetime time2 = time1.addSeconds(5);
	//	String seconds = String.valueOf(time2.second());
	//	String minutes = String.valueOf(time2.minute());
	//	String hours = String.valueOf(time2.hour());

	//	String sch = seconds + ' ' + minutes + ' ' + hours + ' ? * MON-SUN';
	//	System.debug('sch:' + sch);
	//	System.schedule('CascadeProgressUpdateSchedulerTest', sch, new CascadeProgressUpdateScheduler());

	//	Test.stopTest();
	//}

}