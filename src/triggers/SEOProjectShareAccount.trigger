trigger SEOProjectShareAccount on SFDC_Projects__c (after insert) {
	List<Account> accs = new List<Account>();
	for (SFDC_Projects__c newPro : Trigger.new) {
		if (newPro.Project_Type__c.containsIgnoreCase('SEO')) {
			Account acc = [select HasSEOProject__c from account where id = :newPro.Account__c limit 1];
			acc.HasSEOProject__c = true;
			acc.SEO_Account_Manager__c = (newPro.SEO_Account_Manager__c!= null)?newPro.SEO_Account_Manager__c:newPro.ownerId;
			accs.add(acc);
		}else if (newPro.Project_Type__c.containsIgnoreCase('Google+')) {
			Account acc = [select HasGooglePlusProject__c from account where id = :newPro.Account__c limit 1];
			acc.HasGooglePlusProject__c = true;
			accs.add(acc);
		}
	}
	update accs;
}