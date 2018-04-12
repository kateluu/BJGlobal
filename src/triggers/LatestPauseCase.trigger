trigger LatestPauseCase on Cases__c (after insert) {
	for (Cases__c ca : Trigger.new ){
		if(ca.CaseType__c.containsIgnoreCase('Pause')) {
			Cases__c[] otherCases = [select id, Latest__c from cases__c where Account__c = :ca.Account__c and CaseType__c includes('Pause') and Latest__c = true];
			
			if(otherCases.size() > 0) {
				for(Cases__c c : otherCases) {
					c.Latest__c = false;
					update c;
				}
			}
			
			Cases__c newCase = [select id, Latest__c from cases__c where id = :ca.id];
			newCase.Latest__c = true;
			update newCase;
		}
	}
}