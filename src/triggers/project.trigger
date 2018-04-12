trigger project on SFDC_Projects__c (after insert, after update) {
	if(Trigger.isInsert) {
		for(SFDC_Projects__c project : trigger.new) {
			if(project.Contract_End_Date__c != null) {
				try {
					Account acc = [Select Id, OwnerId, Name From Account Where Id =:project.Account__c];
					Contact con = [Select Id, Name, Email From Contact Where AccountId =:project.Account__c And Title = 'Billing'][0];
					Task task 			= new Task();
					if(project.Account_Product__c != null) {
						Account_Product__c ap = [select OwnerId from Account_Product__c where id =: project.account_product__c];
						task.OwnerId	= ap.OwnerId;}
					else{
						task.OwnerId	= acc.OwnerId;
					}
					task.WhoId 			= con.Id;
					task.WhatID 		= project.Id;
					task.Subject 		= acc.Name+' ('+project.Name+') contract is ending on '+project.Contract_End_Date__c.format();
					task.Description 	= acc.Name+' ('+project.Name+') contract is ending on '+project.Contract_End_Date__c.format();
					task.Type 			= 'Status';
					task.ActivityDate 	= project.Contract_End_Date__c.addMonths(-1);
					insert task;
				} catch(Exception e) {
					System.debug('TASK:'+e);
					ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: There was a problem creating the contract end date task');
	        		ApexPages.addMessage(myMsg);
				}		
			}
		}
	} else {
		for(SFDC_Projects__c project : trigger.new) {
			if(project.Contract_End_Date__c != null && project.Contract_End_Date__c != trigger.oldmap.get(project.id).Contract_End_Date__c) {
				try {
					Account acc = [Select Id, OwnerId, Name From Account Where Id =:project.Account__c];
					Contact con = [Select Id, Name, Email From Contact Where AccountId =:project.Account__c And Title = 'Billing'][0];
					Task task 			= new Task();
					if(project.Account_Product__c != null) {
						Account_Product__c ap = [select OwnerId from Account_Product__c where id =: project.account_product__c];
						task.OwnerId	= ap.OwnerId;}
					else{
						task.OwnerId	= acc.OwnerId;
					}
					task.WhoId 			= con.Id;
					task.WhatID 		= project.Id;
					task.Subject 		= acc.Name+' ('+project.Name+') contract is ending on '+project.Contract_End_Date__c.format();
					task.Description 	= acc.Name+' ('+project.Name+') contract is ending on '+project.Contract_End_Date__c.format();
					task.Type 			= 'Status';
					task.ActivityDate 	= project.Contract_End_Date__c.addMonths(-1);
					insert task;
				} catch(Exception e) {
					System.debug('TASK:'+e);
					ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: There was a problem creating the contract end date task');
	        		ApexPages.addMessage(myMsg);
				}		
			}
			
			if(trigger.oldmap.get(project.id).Project_Stage__c == 'Pending 1st Contact' && project.Project_Stage__c == 'Pending Project Info') {
				try {
					Account_Product__c ap = [select Sign_Up_del__c from Account_Product__c where id =: project.Account_Product__c];
					
					Sign_Up__c su = [select Status__c from Sign_Up__c where id =: ap.Sign_Up_del__c];
					
					su.Status__c = 'Completed';
					update su;
				} catch(Exception e) { 
					
				}
			}
		}
	}
}