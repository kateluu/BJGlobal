public class TaskHelper {
	static String TASK_STATUS = 'Completed';
	static String TASK_SUBJECT = 'Outbound call to';
	static String TASK_TYPE = 'Outbound';


	public void TaskHelper(){

	}

	public void setupContactToReurnCallTasks(List<Task> newTasks){
	 	List<Id> voicemailIds = new List<Id>();
	 	Map<ID,ID> contactIds = new Map<ID,ID>();
	 	List<Task> results = new List<Task>();

	 	for(Task item: newTasks){
	 		if(item.Status.equals(TASK_STATUS) && item.Subject.startsWith(TASK_SUBJECT) && (item.WhatId!=null) && item.CallType.equals(TASK_TYPE)){
	 			String voicemailId = '' + item.WhatId;
	 			system.debug('TaskHelper :: setupContactToReurnCallTasks :: item.WhatId' + item.WhatId);
	 			if(voicemailId.startsWith(Voicemail__c.sobjecttype.getDescribe().getKeyPrefix())){
	 				voicemailIds.add(item.WhatId);
	 				//system.debug('TaskHelper :: setupContactToReurnCallTasks :: add to voicemails');
	 			}

	 		}
	 	}

	 	List<Voicemail__c> voicemails = [SELECT Id, Account__c, Contact__c FROM Voicemail__c WHERE id IN :voicemailIds ];
	 	for(Voicemail__c item: voicemails){
	 		contactIds.put(item.id, item.Contact__c);
	 		//system.debug('TaskHelper :: setupContactToReurnCallTasks :: add to voicemails');
	 	}

	 	for(Task item:newTasks){
	 		item.WhoId = contactIds.get(item.WhatId);
	 		//system.debug('TaskHelper :: setupContactToReurnCallTasks ::' + item.WhoId);
	 	}
	 	
	}

}