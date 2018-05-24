global class AccountProcessor implements Database.Batchable<sObject>, Database.Stateful {
//	global class AccountProductProcessor implements Database.Batchable<Account_Product__c> {
	
	global String query;
	global list<Account> accounts;
	global Long processingTime;
	global String subCondition;

	
	
	global AccountProcessor(String numOfRecords) {

		//set limit num of records
		if (numOfRecords<>null && numOfRecords.length()>0){
			this.subCondition =  numOfRecords;
		}else this.subCondition ='';
		processingTime = 0;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
        query = ' SELECT Id, Card_Number__c,Card_CVN__c, Card_Number_Masked__c '
         		+ ' FRoM  Account '
         		+ ' WHERE Type <> \'Employee\' '
         		+  this.subCondition;
        // tracking processing time
        processingTime = DateTime.now().getTime();

		//fetching data
		return Database.getQueryLocator(query);
	}

	

   	global void execute(Database.BatchableContext BC, List<Account> scope) {
   			List<Account> updateAccounts = new List<Account>();
   			boolean isChange = false;
   			for(Account item:scope){
   				if((item.Card_CVN__c != NULL) &&(item.Card_CVN__c !='')){
	   				item.Card_CVN__c = '';
	   				isChange = true;
	   				
   				}

   				if((item.Card_Number__c != NULL) &&(item.Card_Number__c !='')){
	   				item.Card_Number__c = '';
	   				isChange = true;
   				}
   				
   				if(isChange){
   					updateAccounts.add(item);
   				}
   			}

   			try{
				update updateAccounts;	
			}catch(Exception ex){
				System.debug('AccountProcessor :: Exception :: ' + ex.getMessage() + ' : ' + ex.getStackTraceString());
			}
	}
	
	global void finish(Database.BatchableContext BC) {
		system.debug('finish');
		processingTime = DateTime.now().getTime() - processingTime;
        
		AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
					      FROM AsyncApexJob WHERE Id = :BC.getJobId()];

	   // Send an email to the Apex job's submitter notifying of job completion.
	   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	   String[] toAddresses = new String[] {'salesforce@sponsoredlinx.com'};
	   mail.setToAddresses(toAddresses);
	   mail.setSubject('AccountProcessor is : ' + a.Status);
	   mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +   ' batches with '+ a.NumberOfErrors + ' failures.' +' and JobItemsProcessed = ' + a.JobItemsProcessed + ' With processing time in milisecond is ' + processingTime);
	   Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
	
}