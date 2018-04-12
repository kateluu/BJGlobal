global class infusionsoftBatch implements Database.batchable<Account>,Database.AllowsCallouts {
	global Iterable<Account> start(Database.batchableContext info) {    
    	return new infusionsoftIterator();  
  	}
  	
  		
  	global void execute(Database.batchableContext info, List<Account> scope){
  		System.debug('scope: '+scope);
  		String API_KEY = 'b03441a0ea854b5e0ab03dcaa461d8b6';
  		Date today = System.today();
		Date startOfWeek = today.toStartOfWeek();
		Integer dayOfWeek = today.day()-startOfWeek.day();
  		
  		for(Account account : scope){
  			try {
  				Contact contact = new Contact();
  				Contact contacttest = new Contact();
		        try{
		        	contact = [SELECT Id, Title, FirstName, LastName, Email, Birthdate, Phone, Fax, MobilePhone,MailingStreet,MailingCity,MailingState,MailingCountry  FROM Contact WHERE AccountId =: account.Id AND Title = 'Marketing' limit 1];
		        }
		        catch(Exception e){}
		        if(contact == contacttest){
		        	try {
		          		contact = [SELECT Id, Title, FirstName, LastName, Email, Birthdate, Phone, Fax, MobilePhone,MailingStreet,MailingCity,MailingState,MailingCountry  FROM Contact WHERE AccountId =: account.Id AND Title = 'Billing'];
		          	}
		          	catch(Exception e){}
		        }
		        System.debug('Contact Record: '+contact); 
		        
		        Boolean applyCancelledTag = false;
		        Map<String, String> infusionMap = new Map<String, String>();
		        
		        String company_name = account.Name;

				String specialChars = '&|^|@';   // in this string, write all the special chars you want to get ride of, pipe separated
				for(integer i=0; i<specialChars.split('|').size(); i++){
				   company_name = company_name.replace(specialChars.split('|')[i], '');
				}
				System.debug('Company Name is >>>>>>>>>>>>>>>>>>>>>>>>>>>>> ' + company_name);
		        
		        infusionMap.put('Website', 		   account.Website);
		        infusionMap.put('Company', 		   company_name);
		        infusionMap.put('_PaymentOption',  account.Payment_Option__c);
			    //infusionMap.put('Infusionsoft_Id', account.Infusionsoft_Id__c);
			    if(dayOfWeek == 6){
			    	infusionMap.put('_ClientManager0', account.Owner.Name); 
			    }
			    infusionMap.put('FirstName', 	   contact.FirstName);
			    infusionMap.put('LastName',  	   contact.LastName);
			    infusionMap.put('Email', 	 	   contact.Email);
			    infusionMap.put('Phone1', 	 	   contact.Phone);
			    infusionMap.put('Phone2Type',      'Mobile');
			    infusionMap.put('Phone2',          contact.MobilePhone);
			    infusionMap.put('Fax1',            contact.Fax);
			    if(contact.MailingStreet != null || contact.MailingState != null || contact.MailingCountry != null){
			    	infusionMap.put('StreetAddress1',  contact.MailingStreet);
			    	infusionMap.put('StreetAddress2',  contact.MailingState+', '+contact.MailingCountry);
			    }
			    infusionMap.put('Birthday',        String.valueOf(contact.Birthdate));
			    try {
					String productname = '';
					Boolean adsActive    = false;
					Boolean adsPaused    = false;
					Boolean adsCancelled = false;
					
					Boolean seoActive    = false;
					Boolean seoPaused    = false;
					Boolean seoCancelled = false;
					
					Boolean facebookActive    = false;
					Boolean facebookPaused    = false;
					Boolean facebookCancelled = false;
					
					Boolean convertoActive    = false;
					Boolean convertoPaused    = false;
					Boolean convertoCancelled = false;
					
					List<Date> cancelledDates = new List<Date>(); 
					
					String package_name = '';
					
					for(Account_Product__c product : [SELECT Id,Name,Product_Status__c, Monthly_Price__c, cancelat__c FROM Account_Product__c WHERE Account__c=:account.Id AND (Recurring_Period__c !='N/A' AND Recurring_Period__c != '')]) {
						System.debug('Product Record: '+product);
						productname = '';
						productname = product.Name.toLowerCase();
						if(productname.contains('adwords')) {
							if(product.Product_Status__c == 'Active'){
								adsActive = true;
								if(product.Monthly_Price__c <= 343 ){
									package_name = 'Standard';
								}else if(product.Monthly_Price__c <= 386){
									package_name = 'Optimised';
								}else if(product.Monthly_Price__c <= 429){
									package_name = 'Premium';
								}
							}else if(product.Product_Status__c == 'Paused'){
								adsPaused = true;
							}else if(product.Product_Status__c == 'Cancelled'){
								adsCancelled = true;
								cancelledDates.add(product.cancelat__c);
							}
							
						} else if(productname.contains('seo')) {
									if(product.Product_Status__c == 'Active'){
										seoActive = true;
									}else if(product.Product_Status__c == 'Paused'){
										seoPaused = true;
									}else if(product.Product_Status__c == 'Cancelled'){
										seoCancelled = true;
									}
									
								}
						else if(productname.contains('facebook')) {
									if(product.Product_Status__c == 'Active'){
										facebookActive = true;
									}else if(product.Product_Status__c == 'Paused'){
										facebookPaused = true;
									}else if(product.Product_Status__c == 'Cancelled'){
										facebookCancelled = true;
									}
							
						}else if(productname.contains('convertopages')) {
							System.debug('Product Name Contains ConvertoPages');
									if(product.Product_Status__c == 'Active'){
										convertoActive = true;
									}else if(product.Product_Status__c == 'Paused'){
										convertoPaused = true;
									}else if(product.Product_Status__c == 'Cancelled'){
										convertoCancelled = true;
									}
						}
							
							
					}	
					if(adsActive){
						infusionMap.put('_AdwordsProduct0','Active');
						infusionMap.put('_Package',package_name);
					}else if(adsPaused){
						infusionMap.put('_AdwordsProduct0', 'Paused');
					}else if(adsCancelled){
						infusionMap.put('_AdwordsProduct0', 'Cancelled');
						Integer i = 0;
						for(Date cancelledDate : cancelledDates){
							if(cancelledDate < date.today().addMonths(-6)){
								i++;
							}
						}
						if(i == cancelledDates.size()){
							// WinBack Campaign Paused, stop applying cancelled tags to Contacts
						//	applyCancelledTag= true;
						}
					}
					
					if(seoActive){
						infusionMap.put('_SEOProduct0','Active');
					}else if(seoPaused){
						infusionMap.put('_SEOProduct0', 'Paused');
					}else if(seoCancelled){
						infusionMap.put('_SEOProduct0', 'Cancelled');
					}
					
					if(facebookActive){
						infusionMap.put('_FacebookProduct','Active');
					}else if(facebookPaused){
						infusionMap.put('_FacebookProduct', 'Paused');
					}else if(facebookCancelled){
						infusionMap.put('_FacebookProduct', 'Cancelled');
					}
					
					if(convertoActive){
						infusionMap.put('_ConvertoPagesProduct','Active');
					}else if(convertoPaused){
						infusionMap.put('_ConvertoPagesProduct', 'Paused');
					}else if(convertoCancelled){
						infusionMap.put('_ConvertoPagesProduct', 'Cancelled');
					}
					
					if(adsActive || seoActive || facebookActive || convertoActive){
						account.Active__c = true;
					}else{
						account.Active__c = false;
					}
					
				} catch(Exception e) {
					System.debug('Error fetching product record');
					System.debug('EXCEPTION: '+e.getMessage());
				}
				infusionsoft_API infsoApi = new infusionsoft_API(API_KEY);
				
			    Map<String, String>  resultsId = new Map<String, String>();
		        resultsId = infsoApi.searchContact(infusionMap);
		        
		        system.debug('Result Set'+resultsId);
		        
		       	String id = resultsId.get('Infusionsoft_Id');
		        if(id != null){
		        	infusionMap.put('Infusionsoft_Id', id);
		            resultsId = infsoApi.updateContact(infusionMap);
		        }else{
		            resultsId = infsoApi.addContact(infusionMap);
		        }
		        id = resultsId.get('Infusionsoft_Id');
		        account.Infusionsoft_Id__c = id;
		     
		        
//		        if(applyCancelledTag){
//		        	infusionMap.clear();
//		        	infusionMap.put('email', contact.Email);
//		        	infusionMap.put('reason', 'Old customer who cancelled six months ago');
//		        	resultsId = infsoApi.optIn(infusionMap);
		        	
//		        	infusionMap.clear();
//		        	infusionMap.put('Infusionsoft_Id', id);
//		        	resultsId = infsoApi.applyWinBackTag(infusionMap);
//		        }
		      
		      
		      if(account.Psycho__c == true){
		      		infusionMap.clear();
		        	infusionMap.put('email', contact.Email);
		        	infusionMap.put('reason', 'Client marked as Psycho, no marketing emails');
		        	resultsId = infsoApi.optOut(infusionMap);   				
  				}
			  update account;
		      
		      } catch(Exception e) {
			        System.debug('Error fetching contact record');
			        System.debug('EXCEPTION: '+e.getMessage());
		      }
		}
  	}
  	
  	global void finish(Database.batchableContext info){
		
   	}
   	
   	public static testMethod void testBatch() {
        Test.startTest();
        infusionsoftBatch scriptBatch = new infusionsoftBatch();
        Account account = new Account();
		account.Name = 'Test Account11';
		account.Company__c = 'SponsoredLinX';
		account.username__c = 'test11d11@test.com';
		account.password__c = 'test';
		insert account;
		
		Contact testContact = new Contact();
    	testContact.AccountId = account.Id;
    	testContact.Title = 'Billing';
    	testContact.FirstName = 'test';
    	testContact.LastName = 'test';
    	testContact.MailingStreet = 'test';
    	insert testContact;
        
        Account_Product__c ap = new Account_Product__c();
        ap.Last_Invoice_Date__c = Date.today().addDays(-7);
        ap.Recurring_Frequency__c = 1;
        //ap.pauseat__c = Date.today();
        ap.Product_Price__c = 19.99;
        ap.Recurring_Period__c ='Weekly';
        ap.Payment_Option__c = 'Eway';
        ap.Product_Status__c = 'Paused';
        ap.Account__c = account.Id;
        insert ap;
        
        Account_Product__c ap1 = new Account_Product__c();
        ap1.Last_Invoice_Date__c = Date.today().addDays(-7);
        ap1.Recurring_Frequency__c = 1;
        ap1.Name = 'SEO';
        ap1.Product_Status__c = 'Active';
        ap1.Product_Price__c = 19.99;
        ap1.Recurring_Period__c ='Weekly';
        ap1.Payment_Option__c = 'Eway';
        ap1.Account__c = account.Id;
        insert ap1;
        
        Account_Product__c ap0 = new Account_Product__c();
        ap0.Last_Invoice_Date__c = Date.today().addDays(-7);
        ap0.Recurring_Frequency__c = 1;
        ap0.Name = 'SEO';
        ap0.Product_Status__c = 'Paused';
        ap0.Product_Price__c = 19.99;
        ap0.Recurring_Period__c ='Weekly';
        ap0.Payment_Option__c = 'Eway';
        ap0.Account__c = account.Id;
        insert ap0;
        
        Account_Product__c ap10 = new Account_Product__c();
        ap10.Last_Invoice_Date__c = Date.today().addDays(-7);
        ap10.Recurring_Frequency__c = 1;
        ap10.Name = 'SEO';
        ap10.Product_Status__c = 'Cancelled';
        ap10.Product_Price__c = 19.99;
        ap10.Recurring_Period__c ='Weekly';
        ap10.Payment_Option__c = 'Eway';
        ap10.Account__c = account.Id;
        insert ap10;
        
        Account_Product__c ap2 = new Account_Product__c();
        ap2.Last_Invoice_Date__c = Date.today().addDays(-7);
        ap2.Recurring_Frequency__c = 1;
        ap2.Name = 'Adwords';
        ap2.Product_Status__c = 'Cancelled';
        ap2.Product_Price__c = 19.99;
        ap2.Recurring_Period__c ='Weekly';
        ap2.Payment_Option__c = 'Eway';
        ap2.Account__c = account.Id;
        insert ap2;
       
        Database.batchableContext info;
        scriptBatch.start(info);
        List<Account> scope = [select Id, Name, Owner.Name, Website, infusionsoft_Id__c FROM Account limit 5];
        scriptBatch.execute(info, scope);
        scriptBatch.finish(info);
        
        
        
        
        Test.stopTest();
    }
    public static testMethod void testBatch1() {
        Test.startTest();
        infusionsoftBatch scriptBatch = new infusionsoftBatch();
        Account account = new Account();
		account.Name = 'Test Account11';
		account.Company__c = 'SponsoredLinX';
		account.username__c = 'test11d11@test.com';
		account.password__c = 'test';
		insert account;
		
		Contact testContact = new Contact();
    	testContact.AccountId = account.Id;
    	testContact.Title = 'Billing';
    	testContact.FirstName = 'test';
    	testContact.LastName = 'test';
    	testContact.MailingStreet = 'test';
    	insert testContact;
        
        
        
        Account_Product__c ap10 = new Account_Product__c();
        ap10.Last_Invoice_Date__c = Date.today().addDays(-7);
        ap10.Recurring_Frequency__c = 1;
        ap10.Name = 'Adwords';
        ap10.Product_Status__c = 'Cancelled';
        ap10.Product_Price__c = 19.99;
        ap10.Recurring_Period__c ='Weekly';
        ap10.Payment_Option__c = 'Eway';
        ap10.Account__c = account.Id;
        insert ap10;
        
        Account_Product__c ap2 = new Account_Product__c();
        ap2.Last_Invoice_Date__c = Date.today().addDays(-7);
        ap2.Recurring_Frequency__c = 1;
        ap2.Name = 'SEO';
        ap2.Product_Status__c = 'Cancelled';
        ap2.Product_Price__c = 19.99;
        ap2.Recurring_Period__c ='Weekly';
        ap2.Payment_Option__c = 'Eway';
        ap2.Account__c = account.Id;
        insert ap2;
       
        Database.batchableContext info;
        scriptBatch.start(info);
        List<Account> scope = [select Id, Name, Owner.Name, Website, infusionsoft_Id__c FROM Account limit 5];
        scriptBatch.execute(info, scope);
        scriptBatch.finish(info);
        
        Test.stopTest();
    }
    public static testMethod void testBatch2() {
        Test.startTest();
        infusionsoftBatch scriptBatch = new infusionsoftBatch();
        Account account = new Account();
		account.Name = 'Test Account11';
		account.Company__c = 'SponsoredLinX';
		account.username__c = 'test11d11@test.com';
		account.password__c = 'test';
		insert account;
		
		Contact testContact = new Contact();
    	testContact.AccountId = account.Id;
    	testContact.Title = 'Billing';
    	testContact.FirstName = 'test';
    	testContact.LastName = 'test';
    	testContact.MailingStreet = 'test';
    	insert testContact;
        
        
        
        Account_Product__c ap10 = new Account_Product__c();
        ap10.Last_Invoice_Date__c = Date.today().addDays(-7);
        ap10.Recurring_Frequency__c = 1;
        ap10.Name = 'Adwords';
        ap10.Product_Status__c = 'Active';
        ap10.Product_Price__c = 19.99;
        ap10.Recurring_Period__c ='Weekly';
        ap10.Payment_Option__c = 'Eway';
        ap10.Account__c = account.Id;
        insert ap10;
        
        Account_Product__c ap2 = new Account_Product__c();
        ap2.Last_Invoice_Date__c = Date.today().addDays(-7);
        ap2.Recurring_Frequency__c = 1;
        ap2.Name = 'SEO';
        ap2.Product_Status__c = 'Paused';
        ap2.Product_Price__c = 19.99;
        ap2.Recurring_Period__c ='Weekly';
        ap2.Payment_Option__c = 'Eway';
        ap2.Account__c = account.Id;
        insert ap2;
       
        Database.batchableContext info;
        scriptBatch.start(info);
        List<Account> scope = [select Id, Name, Owner.Name, Website, infusionsoft_Id__c FROM Account limit 5];
        scriptBatch.execute(info, scope);
        scriptBatch.finish(info);
        
        Test.stopTest();
    }
  	
  	


}