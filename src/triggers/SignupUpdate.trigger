trigger SignupUpdate on Sign_Up__c (after update) {

	if (System.trigger.new.size() == 1){
		
		String signup_id = System.trigger.new[0].Id;
		if(System.trigger.new[0].Product_Family__c == 'Adwords' && System.trigger.new[0].Status__c == 'Completed') {
			//String signup_id = System.trigger.new[0].Id;
			String adwords_id = System.trigger.new[0].Adwords_ID__c;
			String adwords_email = System.trigger.new[0].Adwords_Email__c;
			completeSignup cs = new completeSignup();
			cs.saveAdwordsDetails(signup_id, adwords_id, adwords_email);
			/*
			try {
				if(System.trigger.old[0].Status__c != 'Completed') {
					Datetime dt = System.now();
					Date d = Date.newInstance(dt.year(), dt.month(), dt.day());
					Sign_Up__c signup = [SELECT Id,Completed_Date__c FROM Sign_Up__c WHERE Id=:signup_id];
					signup.Completed_Date__c = d;
					update signup;	
				}	
			} catch(exception e){
			
			}
			*/
			
			
		}
//		try {
			//if(System.trigger.new[0].Product_Family__c == 'Adwords' && System.trigger.old[0].Status__c != 'Completed') {
//			if(System.trigger.old[0].Status__c != 'Completed' && System.trigger.new[0].Status__c == 'Completed') {
//				Datetime dt = System.now();
//				Date d = Date.newInstance(dt.year(), dt.month(), dt.day());
//				Sign_Up__c signup = [SELECT Id,Completed_Date__c FROM Sign_Up__c WHERE Id=:signup_id];
//				signup.Completed_Date__c = d;
//				update signup;	
//			}	
//		} catch(exception e){
//			
//		}
		
		
		
		
		
	}
	
	

}