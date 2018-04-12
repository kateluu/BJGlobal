global class ProductActiveDaysBatch implements Database.batchable<Account>,Database.AllowsCallouts, Database.Stateful {
	
	global Iterable<Account> start(Database.batchableContext info) {
		System.debug('Start getting Account!');
		return new ProductActiveDaysIterator();
	}
	
	
	global void execute(Database.batchableContext info, List<Account> scope) {
		System.debug('Scope: ' + scope);
		for(Account account : scope){
			
			Decimal account_active_days = 0;
			
			Account_Product__c[] aps = [select
											Id,
											Active_Days__c
									  from
									  		Account_Product__c
									  where
									  		(Name like '%Adwords%' 
	                                        or Name like '%Facebook%' 
	                                        or Name like '%Yahoo%' 
	                                        or Name like '%Admob%'
	                                        or Name like '%Converto%')
									  and 
									   		(Recurring_Period__c != null and Recurring_Period__c!='N/A')
									  and 
									  		Product_Status__c != 'Paused'
									  and 
									  		Account__c =: account.Id];
			if(aps.size() > 0 ){
				for(Account_Product__c ap : aps){
					Decimal product_active_days = 0;
					
					Client_History__c[] chs = [select 
													Lasting_Days__c 
											   from 
											 		Client_History__c 
											   where 
											 		Type__c = 'Active'
											   and 
											 		Account_Product__c =: ap.Id];
					if(chs.size() > 0 ){
						for(Client_History__c ch : chs){
							product_active_days += ch.Lasting_Days__c;
						}
					}
					ap.Active_Days__c = product_active_days;
					try{
						update ap;
					}catch(Exception e){
						system.debug(e.getMessage());
					}
					//if(!ap.Name.contains('ConvertoPages')){
						account_active_days += product_active_days;
				//	}
				}
			}
			account.Active_Days__c = account_active_days;
			//account.Phone          = account.Contacts[0].Phone;
			update account;
		}
		
	}
	
	global void finish(Database.batchableContext info){
		
	}

}