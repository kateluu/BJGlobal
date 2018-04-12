global with sharing class infusionsoftSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {
	    infusionsoftBatch scriptBatch = new infusionsoftBatch();
	    ID batchprocessid = Database.executeBatch(scriptBatch,40);
	    System.debug(scriptBatch);
	    System.debug(batchprocessid);
	}
	
	public static testMethod void infusionsoftScheduleTest() {
	    Test.StartTest();
	    
	    datetime time1 = Datetime.now();
	    datetime time2 = time1.addSeconds(5);
	    String seconds = String.valueOf(time2.second());
	    String minutes = String.valueOf(time2.minute());
	    String hours = String.valueOf(time2.hour());
	    
	    String sch = seconds+' '+minutes+' '+hours+' ? * MON-SUN';  
	    System.debug('sch:'+sch);
	    System.schedule('infusionsoftScheduletest', sch, new infusionsoftSchedule());
	      
	    Test.stopTest();
    }
}