trigger UpdateProjectRevenueOnProject on SFDC_Projects__c (before insert) {
	for(SFDC_Projects__c project : Trigger.new) {
		if(project.Account_Product__c != null && project.Contract_start_date__c != null) {
			//looking for the recurring invoices created before project creation
			Invoice__c[] invs = [select
									id,
									invoice_total__c
								from
									Invoice__c
								where
									account_product__c =: project.Account_Product__c
								and
									issue_date__c <=: project.Contract_start_date__c								
								];
								
			decimal revenue = 0;
			
			if(invs.size() > 0) {
				for (Invoice__c inv : invs) {
					revenue += inv.invoice_total__c;
				}
			}
			
			if(project.Total_Revenue__c == null) {
				project.Total_Revenue__c = revenue;
	        } else {
	        	project.Total_Revenue__c += revenue;
	        }
	        
	        //looking for the setup invoice
	        try {
		        Account_Product__c ap = [select id, Sign_Up_del__c from Account_Product__c where id =: project.Account_Product__c];
	        	Account_Product__c setup = [select id from Account_Product__c where Sign_Up_del__c =: ap.Sign_Up_del__c and id !=: ap.id and name like '%Setup%'];
		        invs = [select
							id,
							invoice_total__c
						from
							Invoice__c
						where
							account_product__c =: setup.id
						and
							issue_date__c <=: project.Contract_start_date__c								
						];
						
				revenue = 0;
				
				if(invs.size() > 0) {
					for (Invoice__c inv : invs) {
						revenue += inv.invoice_total__c;
					}
				}
				
				if(project.Total_Revenue__c == null) {
					project.Total_Revenue__c = revenue;
		        } else {
		        	project.Total_Revenue__c += revenue;
		        }
	        } catch (Exception e) {
	        	continue;
	        }
		}
	}
}