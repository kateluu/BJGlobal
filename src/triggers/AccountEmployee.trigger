trigger AccountEmployee on Account (after insert, after update) {
	for (Account account : Trigger.new) {
		System.debug('Account trigger. type: ' + account.type );

		if (account.Employee_Department__c == 'Sales' && account.Type == 'Employee' && account.Active__c == true && account.BJB_Company__c != null) {
			//Insert Conventional Promocodes for new Salesperson
			try {
				// Get the company object for this account
				Company__c accountCompany = [SELECT Id, Name FROM Company__c WHERE Id = :account.BJB_Company__c];

	    		// Get the firstname and lastname from the account
	    		List<String> nameBits = account.name.split(' ', 2);

				if (nameBits.size() < 2) {
					account.adderror('First and last name are required');
					return;
				}

			    string fn = nameBits[0].replaceAll('[^a-zA-Z]', '');
			    string ln = nameBits[1].replaceAll('[^a-zA-Z]', '');

				// The following promos should be applied. {ACC} will be replaced with the salesperson's abbreviation
				Map<String, String> descriptionMap = new Map<String, String>();
				if (accountCompany.Name == 'Get More Traffic') {
					descriptionMap.put('{ACC}200', '20% discount off setup');
					descriptionMap.put('{ACC}402', '40% discount off setup');
					descriptionMap.put('{ACC}101', '$100 discount');
					descriptionMap.put('{ACC}', 'Referral Only');
				} else {
					descriptionMap.put('PFW{ACC}', 'Free Week 99 Off Setup Fee');
					descriptionMap.put('PSO{ACC}', 'Discounted Adwords Premium');
					descriptionMap.put('OFW{ACC}', 'Free Week 89 Off Setup Fee');
					descriptionMap.put('OSS{ACC}', 'Discounted Adwords Optimised');
					descriptionMap.put('SFW{ACC}', 'Free Week 79 Off Setup Fee');
					descriptionMap.put('SDW{ACC}', '$10 off management');
					descriptionMap.put('MWS{ACC}', 'Discounted Adwords Standard');
					descriptionMap.put('REF{ACC}', 'Referral Only');
				}

				// The 4-letter code to use in the promocodes for this account
				// We try a different accountCode if this already belongs to a different account.
			    string nameCheck;
			    string accountCode;
				Integer count = 0;
				Map<String, String> myPromosMap = new Map<String, String>();
			    do {
			    	count++;

			    	// Try adding additional letters from the first name until we find a spare code
 					if (count < fn.length()){
						nameCheck = fn.substring(0,count).toUpperCase() + ln.substring(0,3).toUpperCase();
					}else{
						// As a last resort, just use a random 4-character string
						nameCheck = Utility.generateRandomString(4).toUpperCase();
					}

					// Create the new promocodes
					myPromosMap = new Map<String, String>();

					for (String promoname : descriptionMap.keyset()) {
						String mypromoname = promoname.replace('{ACC}', nameCheck);

						if (mypromoname.length() > 0){
							myPromosMap.put(mypromoname, descriptionMap.get(promoname));
						}
					}

					// Check if the promocodes already belong to someone else
				    List<Promocode__c> conflictingPromocodes = [SELECT id, name FROM Promocode__c WHERE name IN :myPromosMap.keyset() AND account__c != :account.id LIMIT 1];

				    if (conflictingPromocodes.size() == 0){
				    	accountCode = nameCheck;
				    }
				} while( String.isEmpty(accountCode));


				// Create the new promocodes
				Map<String, sObject> promocodeMap = Utility.getSObjectMap('name', [SELECT name, Account__c FROM Promocode__c WHERE account__c != null AND name = :myPromosMap.keyset()]);

	    		// Get the promotions that we want to generate promocodes for.
	            Map<String, sObject> promotionsMap = Utility.getSObjectMap('name', [SELECT name, id, IsActive__c FROM Promotions__c WHERE name = :myPromosMap.values()]);

	            List<Promocode__c> newPcodes = new list<promocode__c>();
				for (String promoname : myPromosMap.keyset()) {
					String description = myPromosMap.get(promoname);
					Promotions__c promotion = (Promotions__c) promotionsMap.get(description);

					if (promotion == null) {
						system.debug('Could not find promotion for ' + description);
						continue;
					}

					// If the promocode doesn't alreaady exist for this account, create it now.
					if (promocodeMap.get(promoname) != null){
						System.debug('Promocode ' + promoname + ' already exists on account ' + promocodeMap.get(promoname).get('Account__c'));
						continue;
					}

					System.debug('Creating promocode: ' + promoname);

					Promocode__c pc 			= new Promocode__c();
					pc.name 					= promoname;
					pc.Account__c 				= account.id;
					pc.isActive__c 				= true;
					pc.Promocode_Description__c = description;
					pc.Promotions__c 			= promotion.id;
					newPcodes.add(pc);
				}
				
				if (newPcodes.size() > 0) {
					insert newPcodes;
				}

			} catch(Exception e) {
				System.debug('Employee Account error: ' + e + ' on ' + e.getStackTraceString());
        		account.addError('AccountEmployee trigger: Failed to create promocodes. ' + e);
			}
		}
	}
}