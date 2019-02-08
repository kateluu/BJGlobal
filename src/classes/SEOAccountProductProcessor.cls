global class SEOAccountProductProcessor implements Database.Batchable<sObject>, Database.Stateful {
//  global class AccountProductProcessor implements Database.Batchable<Account_Product__c> {
    
    global String query;
    global list<Account_Product__c> activeProducts;
    global Map<String, Integer> com7emails; 
    global Map<String, Integer> com7calls;
    global Map<String, Integer> com14emails;
    global Map<String, Integer> com14calls;
    global Map<String, Integer> com21emails;
    global Map<String, Integer> com21calls;
    
    global List<String> accList;

    global List<String> ownerList;
    global DateTime days7 ;
    global DateTime days14 ;
    global String subCondition;
    global Long processingTime;

    
    
    global SEOAccountProductProcessor(String numOfRecords) {

        //init calculation params
        com7emails = new Map<String, Integer>();
        com7calls = new Map<String, Integer>(); 
        com14calls = new Map<String, Integer>();    
        com14emails = new Map<String, Integer>();   
        com21calls = new Map<String, Integer>();    
        com21emails = new Map<String, Integer>();   

        //init days7 datetime
        Datetime currentDate = system.today();
        Integer d = currentDate.day();
        Integer mo = currentDate.month();
        Integer yr = currentDate.year();
        Datetime currentDatetime = DateTime.newInstance(yr, mo, d);
        days7 = currentDatetime.addDays(-7);
        days14 = currentDatetime.addDays(-14);
        System.debug('Last 7 days = ' + days7.format());

        //set limit num of records
        if (numOfRecords<>null && numOfRecords.length()>0){
            this.subCondition =  numOfRecords;
        }else this.subCondition ='';        
        processingTime = 0;


        query = ' SELECT Id, Product_Status__c, Account__c, OwnerId, Last_14_days_num_of_calls__c, Last_14_days_num_of_emails__c,Last_7_days_num_of_calls__c,Last_7_days_num_of_emails__c '
                + ' FROM  Account_Product__c '
                + ' WHERE ( Product_Status__c = \'Active\' ) '
                + ' AND Account__r.Active__c= true '
                + ' AND Recurring_Period__c <> \'N/A\' '
                + ' AND (NAME like \'%SEO%\') '
                +  this.subCondition;
        // tracking processing time
        processingTime = DateTime.now().getTime();

        system.debug('query string = ' + query);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query = ' SELECT Id, Product_Status__c, Account__c, OwnerId, Last_14_days_num_of_calls__c, Last_14_days_num_of_emails__c,Last_7_days_num_of_calls__c,Last_7_days_num_of_emails__c '
                + ' FROM  Account_Product__c '
                + ' WHERE ( Product_Status__c = \'Active\' ) '
                + ' AND Account__r.Active__c= true '
                + ' AND Recurring_Period__c <> \'N/A\' '
                + ' AND ( NAME like \'%SEO%\' ) '
                +  this.subCondition;
        // tracking processing time
        processingTime = DateTime.now().getTime();

        system.debug('query string = ' + query);

        //fetching data
        return Database.getQueryLocator(query);
    }


    //global Iterable<Account_Product__c>  start(Database.BatchableContext BC) {        
    //  return new CustomActivityHistoryIterable();
    //}

    global void execute(Database.BatchableContext BC, List<Account_Product__c> scope) {
            Integer calls, emails , calls21, emails21;
            accList = new List<String>();
            ownerList = new List<String>();
            String accounts = '';
            String owners = '';

            for(Account_Product__c itemproduct:scope){
            	try{
	            	// get the SEO project which still active and the same owner to product
	            	List<SFDC_Projects__c> projects = [SELECT Id , OwnerId, owner.NAME
	            								FROM SFDC_Projects__c 
	            								WHERE Account_Product__c  = :itemproduct.Id
	        	                                    AND Project_Type__c LIKE '%SEO%'
	        	                                    AND ( Project_Stage__c <> 'Cancelled' OR Project_Stage__c <> 'Completed' ) ORDER BY CreatedDate DESC];

	                if ((projects!= null) && (projects.size()>0)){
	                	SFDC_Projects__c project = projects.get(0);
		                // build SQL string
		                List<Task> processingTasks = [ SELECT id, AccountId, OwnerId ,WhatId, Subject , LastModifiedDate , TaskSubtype FROM Task
		                                                WHERE IsClosed = true
		                                                AND ( (TaskSubtype = 'Email') OR (calltype = 'Outbound') )
		                                                AND LastModifiedDate= LAST_N_DAYS:21 
		                                                AND WhatId = :project.id
		                                                AND OwnerId = :project.OwnerId ];
		                system.debug('processingTasks = ' +processingTasks.size())  ;
		                for(Task item: processingTasks){
		                    String key = item.WhatId  + ':' + item.OwnerId;
		                    emails = 0;
		                    calls =0;
		                    emails21 = 0;
		                    calls21= 0;

		                    if (item.TaskSubtype =='Email'){
		                        //within 7days
		                        if(item.LastModifiedDate>= days7){
		                            if(com7emails.get(key) == null){
		                                emails = 1;                 
		                            }else{
		                                emails =  com7emails.get(key);
		                                system.debug('result.Last_7_days_num_of_emails = ' + emails);
		                                emails += 1;
		                            }                   
		                            com7emails.put(key, emails);
		                        }
		                        if(item.LastModifiedDate>= days14){
		                            if(com14emails.get(key) == null){
		                                emails = 1;                 
		                            }else{
		                                emails =  com14emails.get(key);
		                                system.debug('result.Last_14_days_num_of_emails = ' + emails);
		                                emails += 1;
		                            }                   
		                            com14emails.put(key, emails);
		                        }


		                        if(com21emails.get(key) == null){
		                            emails21 = 1;                   
		                        }else{
		                            emails21 =  com21emails.get(key);
		                            system.debug('result.Last_21_days_num_of_emails = ' + emails);
		                            emails21 += 1;
		                        }                   
		                        com21emails.put(key, emails21);
		                    
		                    } else{
		                        // for outbound calls
		                        //within 7days
		                        if(item.LastModifiedDate>= days7){
		                            if(com7calls.get(key) == null){
		                                calls = 1;                  
		                            }else{
		                                calls =  com7calls.get(key);
		                                system.debug('result.Last_7_days_num_of_calls = ' + calls);
		                                calls += 1;
		                            }                   
		                            com7calls.put(key, calls);
		                            system.debug('com7calls = ' + calls);
		                        }

		                        if(item.LastModifiedDate>= days14){
		                            if(com14calls.get(key) == null){
		                                calls = 1;                  
		                            }else{
		                                calls =  com14calls.get(key);
		                                system.debug('result.Last_14_days_num_of_calls = ' + calls);
		                                calls += 1;
		                            }                   
		                            com14calls.put(key, calls);
		                            system.debug('com7calls = ' + calls);
		                        }

		                        if(com21calls.get(key) == null){
		                            calls21 = 1;                    
		                        }else{
		                            calls21 =  com21calls.get(key);
		                            system.debug('result.Last_21_days_num_of_calls = ' + calls);
		                            calls21 += 1;
		                        }                   
		                        com21calls.put(key, calls21);
		                        system.debug('com21calls = ' + calls21);
		                        
		                    }
	    	            }   
	    	        }
                }catch (System.QueryException ex) {
                    	system.debug(ex.getMessage());
	            }

            }
            
            List<Account_Product__c> updateProducts = new List<Account_Product__c>();
            for(Account_Product__c item: scope){
            	try{
					List<SFDC_Projects__c> project = [SELECT Id , OwnerId, owner.NAME
			            								FROM SFDC_Projects__c 
			            								WHERE Account_Product__c  = :item.Id
			        	                                    AND Project_Type__c LIKE '%SEO%'
			        	                                    AND ( Project_Stage__c <> 'Cancelled' OR Project_Stage__c <> 'Completed' ) 
			        	                                    ORDER BY CreatedDate DESC ]  ;          	

	                String key = (project !=null) ? (project.get(0).Id  + ':' + project.get(0).OwnerId):'';
	                if(key != ''){
		                item.Last_7_days_num_of_emails__c = (com7emails.get(key) == null)? 0:com7emails.get(key);
		                item.Last_7_days_num_of_calls__c = (com7calls.get(key)== null)? 0:com7calls.get(key);
		                item.Last_14_days_num_of_emails__c = (com14emails.get(key)== null)? 0:com14emails.get(key);
		                item.Last_14_days_num_of_calls__c = (com14calls.get(key)== null)? 0:com14calls.get(key);
		                item.Last_21_days_num_of_emails__c = (com21emails.get(key)== null)? 0:com21emails.get(key);
		                item.Last_21_days_num_of_calls__c = (com21calls.get(key)== null)? 0:com21calls.get(key);
	            	}
	            }catch(Exception ex){
	            	System.debug(ex.getMessage());
					item.Last_7_days_num_of_emails__c = -1;
	                item.Last_7_days_num_of_calls__c = -1;
	                item.Last_14_days_num_of_emails__c = -1;
	                item.Last_14_days_num_of_calls__c = -1;
	                item.Last_21_days_num_of_emails__c = -1;
	                item.Last_21_days_num_of_calls__c = -1; 
	            }
                updateProducts.add(item);
            }
            update updateProducts;  
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
       mail.setSubject('Communication Calculation is : ' + a.Status);
       mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +   ' batches with '+ a.NumberOfErrors + ' failures.' +' and JobItemsProcessed = ' + a.JobItemsProcessed + ' With processing time in milisecond is ' + processingTime);
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}