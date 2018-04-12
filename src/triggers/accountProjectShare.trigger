trigger accountProjectShare on SFDC_Projects__c (after insert) {
	
	AccountShare accountShr;
	
	for(SFDC_Projects__c project : trigger.new){
		accountShr = new AccountShare();
		accountShr.AccountId = project.Account__c;
		accountShr.UserOrGroupId = '00G90000000pUWjEAM';
		accountShr.AccountAccessLevel = 'read';
		accountShr.OpportunityAccessLevel = 'none';
		try {
			insert accountShr;
		}catch(Exception e){
			project.Account__c.addError('Unable to grant sharing access due to following exception: ' + e.getMessage());	
		}		
	}	
}