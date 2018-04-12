trigger UpdateCaseToEscalatedStatus on Cases__c (before update) {    
    CasesProcessor cp = new CasesProcessor();
    cp.assignEscalatedCase(Trigger.new,Trigger.newMap.keySet());    
}