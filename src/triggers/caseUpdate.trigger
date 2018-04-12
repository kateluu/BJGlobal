trigger caseUpdate on Cases__c (after update) {
    Set<ID> caseIDs = Trigger.newMap.keyset();
    //List<Cases__c> cases = [SELECT id, name, OwnerId, Account_Resolution__c, Status__c, Cancellation_Date__c FROM Cases__c WHERE Id IN: caseIDs];
    
    //for(Cases__c mycase : cases) {
    //    System.debug('CURRENT CASE:'+mycase);
    //    if(mycase.Account_Resolution__c == 'Cancellation' && mycase.Status__c == 'Unresolved' && mycase.Cancellation_Date__c == NULL) {
    //        mycase.Cancellation_Date__c = date.today(); 
    //        System.debug('UPDATE CASE:'+mycase);
    //        try {
    //            update mycase;
    //        } catch(Exception e) {
    //            mycase.Cancellation_Date__c.addError('Unable to add cancellation date to this record: ' + e.getMessage());
    //        }
    //    }       
    //}
    
    //System.debug(cases);
}