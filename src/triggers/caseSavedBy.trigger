trigger caseSavedBy on Cases__c (before insert, before update) {
	if (Trigger.isUpdate) {
		for(Cases__c c : Trigger.new){
			if(c.Account_Resolution__c == 'Save' && Trigger.oldmap.get(c.id).Account_Resolution__c !='Save'){
				c.Saved_By__c = Userinfo.getUserID();
			}
		}
	} else {
		for(Cases__c c : Trigger.new){
			if(c.Account_Resolution__c == 'Save'){
				c.Saved_By__c = Userinfo.getUserID();
			}
		}
	}
	
}