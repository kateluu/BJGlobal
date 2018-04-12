trigger AmexCheck on Account (before insert, before update) {
	if (Trigger.isInsert) {
		for (Account newAcc : Trigger.new) {
			if(newAcc.Card_Number__c != null && CheckAmex.isAmex(newAcc.Card_Number__c)) {
				newAcc.Amex__c = true;
			} else {
				newAcc.Amex__c = false;
			}
		}
	} else {
		for (Account newAcc : Trigger.new) {
			Account oldAcc = Trigger.oldMap.get(newAcc.ID);
			if(newAcc.Card_Number__c != oldAcc.Card_Number__c) {
				if(newAcc.Card_Number__c != null && CheckAmex.isAmex(newAcc.Card_Number__c)) {
					newAcc.Amex__c = true;
				} else {
					newAcc.Amex__c = false;
				}
			}
			
		}
	}
}