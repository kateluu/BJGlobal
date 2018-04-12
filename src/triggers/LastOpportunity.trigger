trigger LastOpportunity on SLXOpportunity__c (after insert) {
	try	{
		List<Id> accIds = new List<Id>();
		for(SLXOpportunity__c opp : Trigger.new) {
			accIds.add(opp.account__c);
		}
		Account[] accs = [select last_opportunity__c from account where id in : accIds];
		for(SLXOpportunity__c opp : Trigger.new) {
			for(account acc : accs) {
				if(opp.account__c == acc.id) {
					acc.last_opportunity__c = opp.id;
					break;
				}
			}
		}
		update accs;
	} catch (Exception e){
		general.sendAdminEmail('Last Opportunity Trigger Fail', e.getMessage());
	}
}