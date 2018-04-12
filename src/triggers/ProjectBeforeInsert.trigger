trigger ProjectBeforeInsert on SFDC_Projects__c (before insert) {
	for(SFDC_Projects__c project : trigger.new) {
		try{
			Account acc = [select Id, username__c, password__c, Relationship__c, ROI__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Client_Background__c from Account where Id =: project.Account__c limit 1];
			
			if(project.Billing_Address__c == null){
				if(acc.BillingStreet!=null && acc.BillingCity != null && acc.BillingState!= null && acc.BillingPostalCode != null ){
					project.Billing_Address__c = acc.BillingStreet+' '+acc.BillingCity+' '+acc.BillingState+' '+acc.BillingPostalCode+' '+acc.BillingCountry;
				}
			}
			
			if(project.Client_Panel_Username__c == null && project.Client_Panel_Password__c ==null){
				project.Client_Panel_Username__c = acc.username__c;
				project.Client_Panel_Password__c = acc.password__c;
			}
			
			if(project.Client_Relationship__c == null || project.Client_Relationship__c == ''){
				project.Client_Relationship__c = acc.Relationship__c;
			}
			
			if(project.Client_Background__c == null || project.Client_Background__c == ''){
				project.Client_Background__c = acc.Client_Background__c;
			}
			
			if(project.ROI__c == null || project.ROI__c == '' ){
				project.ROI__c = acc.ROI__c;
			}
			
			project.Contract_start_date__c = date.today();
			if(project.Contract_Period__c == '6 (+1) Months'){
				project.Contract_end_Date__c = project.Contract_start_date__c.addMonths(7);
			}else if(project.Contract_Period__c == '12 (+1) Months' ){
				project.Contract_end_Date__c = project.Contract_start_date__c.addMonths(13);
			}else if(project.Contract_Period__c == '6 Months' ){
				project.Contract_end_Date__c = project.Contract_start_date__c.addMonths(6);
			}else if(project.Contract_Period__c == '12 Months' ){
				project.Contract_end_Date__c = project.Contract_start_date__c.addMonths(12);
			}
			
		}catch(Exception e){
			System.debug(e.getMessage());
			
		}
	}
	
}