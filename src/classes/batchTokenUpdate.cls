global class batchTokenUpdate implements Database.Batchable<sObject>,Database.AllowsCallouts {
	
	String query;
	
	global batchTokenUpdate(String q) {
		query = q;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Account> scope) {

   		List<Account> listUpdateAccount = new List<Account>();

        // Transact with the gateway
        paymentGateway pay = new paymentGateway();

		for(Account account : scope){
			system.debug('Updating account ' + account.id);

			// If the _masked field has not yet been used, copy the card number from the old card_number field and generate a token.
			if (String.isEmpty(account.Card_Number_Masked__c) && !String.isEmpty(account.Card_Number__c) ){
				// Generate a token (this also masks the card number)
				try{
					pay.updateAccountToken(account, account.Card_Number__c, account.Card_CVN__c);
					listUpdateAccount.add(account);
				} catch (Exception e) {
					string errorDetail = 'Error in batchPaymentsProcess: ' + e.getMessage() + '. On ' + e.getStackTraceString();
					//Utility.notifySysadmin('Error in pay.updateAccountToken', errorDetail);
					system.debug(errorDetail);
				}
			}
		}

		update listUpdateAccount;
	}
	
	global void finish(Database.BatchableContext BC) {}
}