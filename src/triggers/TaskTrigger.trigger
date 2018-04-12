/**
 * Created by Kate on 9/02/2018.
 */

trigger TaskTrigger on Task (before insert) {    
	if((Trigger.isInsert) &&(Trigger.isBefore)){
		TaskHelper helper = new TaskHelper();
		helper.setupContactToReurnCallTasks(Trigger.new);
	}
}