trigger changeAccountOwner on Account (after update) {
	AccountShare[] shares = new List<AccountShare>();
	
	for (Account newAcc : Trigger.new) {
		Account oldAcc = Trigger.oldMap.get(newAcc.Id);
		if(newAcc.OwnerId != oldAcc.OwnerId) {
			// Step 1: transfer active or paused products
			Account_Product__c[] aps = [select 
											OwnerId,
											Name
										from 
											Account_Product__c 
										where 
											account__c = :newAcc.id 
										and 
											(product_status__c = 'Active'
											or 
											product_status__c = 'Paused')
										and
											recurring_period__c != null
										and
											recurring_period__c != 'N/A'];
			if(!aps.isEmpty()) {
				for(Account_Product__c ap : aps) {
					if(ap.Name.contains('Adwords')){
						ap.OwnerId = newAcc.OwnerId;
					}else{
						AccountShare share = new AccountShare();
						share.userorgroupid = ap.OwnerId;
						share.accountid = newAcc.Id;
						share.accountaccesslevel = 'Read';
						share.OpportunityAccessLevel = 'None';
						share.CaseAccessLevel = 'None';
						shares.add(share);
					}
				}
				update aps;
			}
			// Step 2: give read only access to product owners
			try{
				insert(shares);
			}catch(Exception e){
				system.debug('Unable to grant sharing access due to following exception: ' + e.getMessage());	
			}		
			
			// Step 3: Give read only access to the cases
			cases__c[] cases = [select Id from Cases__c where account__c =: newAcc.Id];
			List<Cases__Share> caseShrs = new List<Cases__Share>();
			Cases__Share caseShr;
			for(Cases__c ca : cases){
				caseShr = new Cases__Share();
				caseShr.parentid = ca.Id;
				caseShr.UserOrGroupId = newAcc.OwnerId;
				caseShr.AccessLevel = 'Read';
				caseShrs.add(caseShr);
			}
			if(caseShrs.size() != 0){
				Database.insert(caseShrs,false);
			}
			
		}
	}
}