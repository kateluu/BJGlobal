trigger closedCases on Cases__c (before update) {
	for (Cases__c new_case : Trigger.new) {
			if (Trigger.old[0].Status__c == 'Closed') {
				User user = [select UserRole.Name, Name , id from User where Id =: UserInfo.getUserId()][0];
				if (user.UserRole.Name != 'BJB Global Accounts & Admin' && user.UserRole.Name != 'BJB Global CEO' && UserInfo.getUserId() != new_case.Owner_Manager__c){
					if(new_case.Latest__c == Trigger.old[0].Latest__c){
						new_case.addError('You can\'t alter this closed case, please contact accounts department or the case owner\'s manager for assistant' );
					}
	            }
	        }
    	}
}