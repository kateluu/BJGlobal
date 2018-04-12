trigger scheduleBeforeInsert on SEO_Report_Schedule__c (before insert) {
	List<SEO_Report_Schedule__c> old_schedules=[Select Schedule_Date__c From SEO_Report_Schedule__c];
	System.debug('OLD SCHEDULES:' + old_schedules);

	SEO_Report_Schedule__c new_schedule = Trigger.new[0];
	System.debug('NEW SCHEDULE:' + new_schedule);
	
	boolean flag = true;
	for(SEO_Report_Schedule__c old_schedule: old_schedules){
		
		Long diff = new_schedule.Schedule_Date__c.getTime() - old_schedule.Schedule_Date__c.getTime();
		diff = diff/(1000*60*60*24);
		System.debug('TIME DIFFERENCE:' +diff);
		if(diff <= 7){
				flag = false;
		}
	}
	
	if(!flag){
		new_schedule.addError('SEO Report\'s interval should be two weeks.');
	}
	
}