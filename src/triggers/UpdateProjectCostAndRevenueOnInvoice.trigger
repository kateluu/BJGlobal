trigger UpdateProjectCostAndRevenueOnInvoice on Invoice__c (after insert) {
	Invoice__c[] invs = [select 
								id, 
								Account_Product__r.name,
								issue_date__c,
								Invoice_Total__c 
						 from 
								Invoice__c 
						 where 
								id 
						 IN 
								:Trigger.newMap.keyset()];
								
	for (Invoice__c inv : invs) {
		if(inv.account_product__r.name != null && inv.account_product__r.name.containsIgnoreCase('SEO')) {
			try {
			    SFDC_Projects__c project = [select 
			    								Current_Month_Cost__c,
			    								Current_Month_Revenue__c,
			    								Total_Revenue__c
			    							from 
			    								SFDC_Projects__c 
			    							where 
			    								Account_Product__c =: inv.Account_Product__c
			    							order by
			    								createdDate desc
			    							limit 1
			    							];
			    
			    if(project.Total_Revenue__c == null) {
			    	project.Total_Revenue__c = inv.Invoice_Total__c;
			    } else {
					project.Total_Revenue__c += inv.Invoice_Total__c;
			    }
				
				update project;
			} catch (Exception e) {
			    continue;
			}
		}
	}
}