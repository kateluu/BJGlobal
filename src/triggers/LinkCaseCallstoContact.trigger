trigger LinkCaseCallstoContact on TASK (before insert) {
	for (TASK tsk : Trigger.new ){

		if(tsk.whoid == null && tsk.AccountId == null && tsk.CallType == 'Outbound' && tsk.whatId != null) {
			system.debug(tsk);
			try{
				Cases__c ca = [select Id, Account__c, phone__c from Cases__c where id =: tsk.whatId ];
				system.debug(ca);
				if(ca != null){
					Contact contact = [select id from Contact where AccountId =: ca.Account__c and (Phone =: ca.Phone__c or Title = 'Billing') limit 1];
					tsk.whoid = contact.id;
				}
				
			}catch(Exception e){
				system.debug(e.getMessage());
			}

			
		}
	}



}