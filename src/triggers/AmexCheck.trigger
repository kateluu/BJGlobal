trigger AmexCheck on Account (before insert, before update) {

	if (Trigger.isInsert) {
		for (Account newAcc : Trigger.new) {			 
			if(newAcc.Card_Number_Masked__c != null && CheckAmex.isAmex(newAcc.Card_Number_Masked__c)) {
				newAcc.Amex__c = true;
			} else {
				newAcc.Amex__c = false;
			}
			system.debug( '  newAcc.Card_Number_Masked__c  =  ' + newAcc.Card_Number_Masked__c);
			system.debug( '  newAcc.Amex__c  =  ' + newAcc.Amex__c);
		}
	} else {
		for (Account newAcc : Trigger.new) {
			Account oldAcc = Trigger.oldMap.get(newAcc.ID);
			if(newAcc.Card_Number_Masked__c != oldAcc.Card_Number_Masked__c) {
				if(newAcc.Card_Number_Masked__c != null && CheckAmex.isAmex(newAcc.Card_Number_Masked__c)) {
					newAcc.Amex__c = true;
				} else {
					newAcc.Amex__c = false;
				}
			}
			
		}
	}
}