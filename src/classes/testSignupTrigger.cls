public with sharing class testSignupTrigger {
	static testMethod void testSignupTrigger(){
		Test.startTest();
		List<Sign_Up__c> s = [Select Id,Account__c from Sign_Up__c Where Account__c != null Order By CreatedDate DESC Limit 1];

		if(s.size() > 0) {
			Sign_Up__c actual_s = s[0];
			Sign_Up__c s2 = actual_s.clone(false,true);
			insert s2;
		}
		Test.stopTest();
	}
}