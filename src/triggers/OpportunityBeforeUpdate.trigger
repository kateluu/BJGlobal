trigger OpportunityBeforeUpdate on SLXOpportunity__c (before update) { 
	SLXOpportunity__c new_opp = Trigger.new[0];
	if(new_opp.Status__c == 'Closed Won' || new_opp.Status__c == 'Closed Lost'){
		new_opp.Close_Date__c = Date.today();
		
	}
}