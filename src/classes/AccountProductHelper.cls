public class AccountProductHelper {

	//Define the method signature to be implemented in classes that implements the interface
	//Example method


	public  AccountProductHelper(){
		fetchDailyData();
	}

	public void fetchDailyData(){
		// select active products for each active account
		// get the product owner
		// lookup all completed activies which name contains email or outbound call , calculate the num records with 7 days and 14 days timeframes
		list<Account_Product__c> activeProducts = [SELECT Id, Product_Status__c, Account__c, OwnerId, 
														  Last_14_days_num_of_calls__c, Last_14_days_num_of_emails__c,Last_7_days_num_of_calls__c,Last_7_days_num_of_emails__c 
													FRoM  Account_Product__c 
													WHERE Product_Status__c = 'Active' AND Account__r.Active__c= true 
													      AND (NAME like '%Adword%' OR NAME like '%Facebook%' ) ]; 

		List<Id> accList = new List<Id>();
		List<Id> ownerList = new List<Id>();
		for(Account_Product__c item:activeProducts){
			accList.add(item.Account__c);
			ownerList.add(item.OwnerId);
		}
		System.debug('AccList' + accList);
		System.debug('OwnerList' + ownerList);


		List<Account> days7_emails = [ SELECT  Id, ownerId, 
											(SELECT OwnerId, Id
											FROM ActivityHistories 
											WHERE 
													(Subject LIKE '→ Email:%' OR Subject LIKE '%← Email:%' OR ActivityType='Email') 
													AND ( EndDateTime = LAST_N_DAYS:7  OR LastModifiedDate= LAST_N_DAYS:7)
													AND OwnerId in :ownerList													
											) 
										FROM Account WHERE id in :accList AND Active__c= true ] ;

	    System.debug('days7_emails' + days7_emails);

		List<Account> days7_calls = [ SELECT  Id, ownerId, 
											(SELECT OwnerId, Id
											FROM ActivityHistories 
											WHERE  
													(Subject LIKE '%Outbound call%' OR ActivityType ='Call') 
													AND ( EndDateTime = LAST_N_DAYS:7  OR LastModifiedDate= LAST_N_DAYS:7)
													AND OwnerId in :ownerList
													
											)		
										FROM Account WHERE id in :accList AND Active__c= true] ;
		System.debug('days7_calls' + days7_calls);

		List<Account> days14_emails = [SELECT  Id, OwnerId,
								(SELECT OwnerId,Id
								FROM ActivityHistories 
								WHERE  (Subject LIKE '→ Email:%' OR Subject LIKE '%← Email:%' OR ActivityType='Email' )
										AND (EndDateTime = LAST_N_DAYS:14  OR LastModifiedDate= LAST_N_DAYS:14)
										AND OwnerId in :ownerList										
								)
						    FROM Account WHERE id in :accList AND  Active__c= true];


		List<Account> days14_calls = [SELECT  Id, OwnerId,
								(SELECT OwnerId,Id
								FROM ActivityHistories 
								WHERE ( Subject LIKE '%Outbound call%'  OR ActivityType ='Call')
										AND (EndDateTime = LAST_N_DAYS:14  OR LastModifiedDate= LAST_N_DAYS:14)
										AND OwnerId in :ownerList										
								)
						    FROM Account WHERE id in :accList AND Active__c= true];


		Map<String, Integer> com7emails = new Map<String, Integer>();		
		for( Account item:days7_emails){			
			List<ActivityHistory > productActivities = item.ActivityHistories;
			Integer emails;
			if( productActivities.size()>0){
				for(ActivityHistory aitem :productActivities ){
					emails = 0;
					String key = item.Id + ':' + aitem.OwnerId;
					if(com7emails.get(key) == null){
						emails = 1;					
					}else{
						emails =  com7emails.get(key);
						system.debug('result.Last_7_days_num_of_emails = ' + emails);
						emails += 1;
					}					
					com7emails.put(key, emails);
					system.debug('Key = ' + key + 'result = ' + emails);
				}
			}
			
		}

		Map<String, Integer> com7calls = new Map<String, Integer>();		
		for( Account item:days7_calls){			
			List<ActivityHistory> productActivities = item.ActivityHistories;
			if( productActivities.size()>0){
				for(ActivityHistory aitem :productActivities ){
					String key = item.Id + ':' + aitem.OwnerId;
					Integer calls = 0;
					if(com7calls.get(key) == null){
						calls =1;
					}else{
						calls =  com7calls.get(key);
						system.debug('result.Last_7_days_num_of_calls = ' + calls);
						calls += 1;
					}
					com7calls.put(key, calls);
					system.debug('Key = ' + key);
				}
			}
			
		}
		
		Map<String, Integer> com14emails = new Map<String, Integer>();		
		for( Account item:days14_emails){		
			List<ActivityHistory > productActivities = item.ActivityHistories;

			if(productActivities.size()>0){
				for(ActivityHistory aitem :productActivities ){
					String key = item.Id + ':' + aitem.OwnerId;
					Integer emails14 = 0;
					if(com14emails.get(key) == null){
						emails14 = 1;
					}else{
						emails14 =  com14emails.get(key);	
						system.debug('result.Last_14_days_num_of_emails = ' + emails14);
						emails14 += 1;					
						
					}
					com14emails.put(key, emails14);
					system.debug('Key = ' + key);
				}

			}
		}
		
		Map<String, Integer> com14calls = new Map<String, Integer>();		
		for( Account item:days14_calls){			
			List<ActivityHistory > productActivities = item.ActivityHistories;
			if(productActivities.size()>0){
				for(ActivityHistory aitem :productActivities ){
					String key = item.Id + ':' + aitem.OwnerId;
					Integer calls14 = 0;
					if(com14calls.get(key) == null){
						calls14 = 1;
					}else{
						calls14 =  com14calls.get(key);
						system.debug('result.Last_14_days_num_of_calls = ' + calls14);						
						calls14 += 1;
					}
					com14calls.put(key, calls14);
					system.debug('Key = ' + key);
				}
			}
		}
		

		for(Account_Product__c item: activeProducts){
			String key= item.Account__c + ':' + item.OwnerId;
			
			item.Last_7_days_num_of_emails__c = (com7emails.get(key) == null)? 0:com7emails.get(key);
			item.Last_7_days_num_of_calls__c = (com7calls.get(key)== null)? 0:com7calls.get(key);
			item.Last_14_days_num_of_emails__c = (com14emails.get(key)== null)? 0:com14emails.get(key);
			item.Last_14_days_num_of_calls__c = (com14calls.get(key)== null)? 0:com14calls.get(key);
		}
		update activeProducts;
		system.debug(activeProducts);
	}


}