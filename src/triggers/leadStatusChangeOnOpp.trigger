trigger leadStatusChangeOnOpp on SLXOpportunity__c (after insert) { 
	List<Lead__c> leads = new List<Lead__c>();
	List<Id> leadIds = new List<Id>();

	try{
		for(SLXOpportunity__c opp : trigger.new) {
				leadIds.add(opp.SLX_Lead__c);
		}
		List<Lead__c> oppLeads = [SELECT Id,Lead_Status__c FROM Lead__c WHERE Id in :leadIds];
		for(Lead__c item : oppLeads){
			item.Lead_Status__c = 'Opportunity';
			leads.add(item);
		}
		update leads;
	} catch(Exception e) {
		general.sendAdminEmail('LeadOpportunityTrigger','LeadOpportunityTrigger Error Exception :'+e.getMessage());
	}

}