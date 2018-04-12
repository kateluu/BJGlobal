trigger updateCaseClientManager on Cases__c (before insert) {
	for(Cases__c c : trigger.new){
	    if(c.Account__c != null){
	    	Account acc = [SELECT OwnerId FROM Account WHERE Id=:c.Account__c][0];	
	    	c.Client_Manager__c = acc.OwnerId;
	    }
	}	
}