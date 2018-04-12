global with sharing class pardotContactScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
	    pardotContactBatch scriptBatch = new pardotContactBatch();
	    ID batchprocessid = Database.executeBatch(scriptBatch,50);
	    System.debug(scriptBatch);
	    System.debug(batchprocessid);
	}
	
	
}