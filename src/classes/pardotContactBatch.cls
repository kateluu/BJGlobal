global class pardotContactBatch implements Database.batchable<Account> {
	global Iterable<Account> start(Database.batchableContext info) {    
    	return new pardotContactIterator();  
  	}
  	
  	global void execute(Database.batchableContext info, List<Account> scope){
  		for(Account account : scope){
  			try {
  				Contact contact = new Contact();
  				Contact contacttest = new Contact();
		        try{
		        	contact = [SELECT Id, Adwords_Product__c, Facebook_Product__c, SEO_Product__c, Converto_Product__c, Social_Media_Product__c, Title, FirstName, LastName, Email, Birthdate, Phone, Fax, MobilePhone,MailingStreet,MailingCity,MailingState,MailingCountry  FROM Contact WHERE AccountId =: account.Id AND Title = 'Marketing' limit 1];
		        }
		        catch(Exception e){
		        	system.debug(e);
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
					
					Boolean socialActive    = false;
					Boolean socialPaused    = false;
					Boolean socialCancelled = false;
					
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
						else if(productname.contains('social media')) {
							System.debug('Product Name Contains Social Media');
									if(product.Product_Status__c == 'Active'){
										socialActive = true;
									}else if(product.Product_Status__c == 'Paused'){
										socialPaused = true;
									}else if(product.Product_Status__c == 'Cancelled'){
										socialCancelled = true;
									}
						}
							
					}	
					if(adsActive){
						contact.Adwords_Product__c = 'Active';
					}else if(adsPaused){
						contact.Adwords_Product__c = 'Paused';
					}else if(adsCancelled){
						contact.Adwords_Product__c = 'Cancelled';
					}
					
					contact.Package_Name__c = package_name;
					if(seoActive){
						contact.SEO_Product__c = 'Active';
					}else if(seoPaused){
						contact.SEO_Product__c = 'Paused';
					}else if(seoCancelled){
						contact.SEO_Product__c = 'Cancelled';
					}
					
					if(facebookActive){
						contact.Facebook_Product__c = 'Active';
					}else if(facebookPaused){
						contact.Facebook_Product__c = 'Paused';
					}else if(facebookCancelled){
						contact.Facebook_Product__c = 'Cancelled';
					}
					
					if(convertoActive){
						contact.Converto_Product__c = 'Active';
					}else if(convertoPaused){
						contact.Converto_Product__c = 'Paused';
					}else if(convertoCancelled){
						contact.Converto_Product__c = 'Cancelled';
					}
					
					if(socialActive){
						contact.Social_Media_Product__c = 'Active';
					}else if(socialPaused){
						contact.Social_Media_Product__c = 'Paused';
					}else if(socialCancelled){
						contact.Social_Media_Product__c = 'Cancelled';
					}
					
					if(adsActive || seoActive || facebookActive || convertoActive || socialActive){
						account.Active__c = true;
					}else{
						account.Active__c = false;
					}
					
				} catch(Exception e) {
					System.debug('Error fetching product record');
					System.debug('EXCEPTION: '+e.getMessage());
				}
				

			  update account;
			  update contact;
		      
		      } catch(Exception e) {
			        System.debug('Error fetching contact record');
			        System.debug('EXCEPTION: '+e.getMessage());
		      }
		}
		
	}
	global void finish(Database.batchableContext info){
		
   		}
}