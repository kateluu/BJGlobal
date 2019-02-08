trigger SignupNoteAfterInsert on Sign_Up_Note__c (after insert) {
	for (Sign_Up_Note__c signup_note: Trigger.new) {
		Sign_Up__c signup = [select Note_Created__c, Daily_budget__c from Sign_Up__c where id =: signup_note.Sign_Up__c];
		signup.Note_Created__c = true;
		signup.Daily_budget__c = signup_note.Agreed_Daily_Budget__c;
		update signup;
	}

	//callout tiger
	system.debug('dfsdfdf');
	Sign_Up_Note__c record = [SELECT id, Sign_Up__r.Account__c FROM Sign_Up_Note__c WHERE id = :Trigger.new.get(0).id];
	String accountID =  record.Sign_Up__r.Account__c;
	system.debug('accountID = ' + accountID);
	Account myAccount =[SELECT id,TP_External_Product__c FROM Account WHERE id = :accountID] ;	
	if(myAccount.TP_External_Product__c!=null && myAccount.TP_External_Product__c.length()>0){
		List<String> externalIds = new List<String>();
		externalIds.add(myAccount.TP_External_Product__c);		
	    TigerPistolConnector.addCustomerOnProductFuture(externalIds);

	    myAccount.TP_External_Product__c = '';
	    update myAccount;
	    system.debug('dfsdfdf2');
	}
	
}