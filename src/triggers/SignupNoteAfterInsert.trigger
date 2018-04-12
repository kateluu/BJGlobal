trigger SignupNoteAfterInsert on Sign_Up_Note__c (after insert) {
	for (Sign_Up_Note__c signup_note: Trigger.new) {
		Sign_Up__c signup = [select Note_Created__c, Daily_budget__c from Sign_Up__c where id =: signup_note.Sign_Up__c];
		signup.Note_Created__c = true;
		signup.Daily_budget__c = signup_note.Agreed_Daily_Budget__c;
		update signup;
	}
}