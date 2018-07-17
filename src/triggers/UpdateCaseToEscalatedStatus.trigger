trigger UpdateCaseToEscalatedStatus on Cases__c (before update) {    
    CasesProcessor cp = new CasesProcessor();
    // update for SP-69
    if (((Cases__c)Trigger.old.get(0)).Status__c != ((Cases__c)Trigger.new.get(0)).Status__c){
    	cp.assignEscalatedCase(Trigger.new,Trigger.newMap.keySet());
	}
}