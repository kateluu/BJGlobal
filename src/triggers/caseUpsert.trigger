trigger caseUpsert on Cases__c (after insert, after update) {
	Set<ID> caseIDs = Trigger.newMap.keyset();
	//List<Cases__c> cases = [
	//	SELECT
	//		id,
	//		name,
	//		OwnerId,
	//		Account_Resolution__c,
	//		Status__c,
	//		Cancellation_Date__c
	//	FROM
	//		Cases__c
	//	WHERE
	//		Id IN: caseIDs
	//];

	//for(Cases__c mycase : cases) {
	//	System.debug('CURRENT CASE:' + mycase);
	//	if(mycase.Account_Resolution__c == 'Cancellation' && mycase.Status__c == 'Unresolved' && mycase.Cancellation_Date__c == NULL) {
	//		mycase.Cancellation_Date__c = date.today();	
	//		System.debug('UPDATE CASE:' + mycase);
	//		try {
	//			update mycase;
	//		} catch(Exception e) {
	//			mycase.Cancellation_Date__c.addError('Unable to add cancellation date to this record: ' + e.getMessage());
	//		}
	//	}
	//}
	
	Account_Product__c[] updateProducts = new List<Account_Product__c>();
	Account[] updateAccounts = new List<Account>();
	if (Trigger.isInsert) {
		for (Cases__c newCase : Trigger.new) {
			if(newCase.Client_Manager_Reassign__c == true && newCase.Reassign_To__c != null) {
				Account_Product__c[] aps = [
					SELECT
						id,
						ownerId
					FROM
						Account_Product__c
					WHERE
						Account__c =: newCase.Account__c
					AND
						ownerId =: newCase.ownerId
					AND
						Product_Status__c = 'Active'
					AND
						Recurring_Period__c != 'N/A'
					AND
						Recurring_Period__c != null
				];
				
				for(Account_Product__c ap : aps) {
					ap.ownerId = newCase.Reassign_To__c;
					updateProducts.add(ap);
				}
				
				Account[] acc = [Select ownerId from Account where id =: newCase.Account__c and ownerId =: newCase.ownerId];
				if(acc.size() > 0) {
					acc[0].ownerId = newCase.Reassign_To__c;
					updateAccounts.add(acc[0]);
				}
			}
		}
	} else {
		for (Cases__c newCase : Trigger.new) {
			Cases__c oldCase = Trigger.oldMap.get(newCase.ID);
			if(newCase.Client_Manager_Reassign__c == true && newCase.Reassign_To__c != null && newCase.Reassign_To__c != oldCase.Reassign_To__c) {
				Account_Product__c[] aps = [
					SELECT
						id,
						ownerId
					FROM
						Account_Product__c
					WHERE
						Account__c =: newCase.Account__c
					AND
						ownerId =: newCase.ownerId
					AND
						Product_Status__c = 'Active'
					AND
						Recurring_Period__c != 'N/A'
					AND
						Recurring_Period__c != null
				];
				
				for(Account_Product__c ap : aps) {
					ap.ownerId = newCase.Reassign_To__c;
					updateProducts.add(ap);
				}
				
				Account[] acc = [Select ownerId from Account where id =: newCase.Account__c and ownerId =: newCase.ownerId];
				if(acc.size() > 0) {
					acc[0].ownerId = newCase.Reassign_To__c;
					updateAccounts.add(acc[0]);
				}
			}
		}
	}
	
	if(updateProducts.size() > 0) {
		update(updateProducts);
	}
	
	if(updateAccounts.size() > 0) {
		update(updateAccounts);
	}

}