global class pardotAccountBatch implements Database.batchable<Account> {
	global Iterable<Account> start(Database.batchableContext info) {    
    	return new pardotAccountIterator();  
  	}
  	
  	global void execute(Database.batchableContext info, List<Account> scope){
  		for(Account account : scope){
  			try {
  				String productname = '';
  				
  				Decimal account_active_days  = 0;
  				Decimal adwords_active_days  = 0;
  				Decimal facebook_active_days = 0;
  				Decimal seo_active_days 	 = 0;
  				Decimal converto_active_days = 0;
  				
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
				
				Date cancelledDate        = null;
					
					
				List<Date> cancelledDates = new List<Date>(); 
					
				String package_name = '';
				
				Boolean first_record = true;
					
				for(Account_Product__c product : [SELECT Id, 
														 Name,
														 Product_Status__c, 
														 Monthly_Price__c, 
														 cancelat__c 
													FROM Account_Product__c 
													WHERE Account__c=:account.Id 
													AND (Recurring_Period__c !='N/A' AND Recurring_Period__c != '')
													AND (Name like '%Facebook%' or Name like '%Adwords%' or Name like '%SEO%' or Name Like '%Social%' or Name Like '%Converto%')
													ORDER BY
													cancelat__c Desc]) {
					System.debug('Product Record: '+product);
					productname = '';
					productname = product.Name.toLowerCase();
					if( first_record && product.cancelat__c != null){
						cancelledDate = product.cancelat__c;
						first_record = false;
					}
					
					Decimal product_active_days = 0;
					
					Client_History__c[] chs = [select 
													Lasting_Days__c 
										   		from 
										 			Client_History__c 
										   		where 
										 			Type__c = 'Active'
										   		and 
										 			Account_Product__c =: product.Id];
					if(chs.size() > 0 ){
						for(Client_History__c ch : chs){
							product_active_days += ch.Lasting_Days__c;
						}
					}
					system.debug(productname);	
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
						adwords_active_days += product_active_days;
						
					} else if(productname.contains('seo')) {
								if(product.Product_Status__c == 'Active'){
									seoActive = true;
								}else if(product.Product_Status__c == 'Paused'){
									seoPaused = true;
								}else if(product.Product_Status__c == 'Cancelled'){
									seoCancelled = true;
								}
								seo_active_days += product_active_days;
									
					} else if(productname.contains('facebook') || productname.contains('social media')) {
								system.debug(product.Product_Status__c);
								if(product.Product_Status__c == 'Active' || product.Product_Status__c == 'Pending Linking'){
									facebookActive = true;
								}else if(product.Product_Status__c == 'Paused'){
									facebookPaused = true;
								}else if(product.Product_Status__c == 'Cancelled'){
									facebookCancelled = true;
								}
							facebook_active_days += product_active_days;
					}else if(productname.contains('convertopages')) {
						System.debug('Product Name Contains ConvertoPages');
								if(product.Product_Status__c == 'Active'){
									convertoActive = true;
								}else if(product.Product_Status__c == 'Paused'){
									convertoPaused = true;
								}else if(product.Product_Status__c == 'Cancelled'){
									convertoCancelled = true;
								}
								converto_active_days += product_active_days;
					}
					
					product.Active_Days__c = product_active_days;
					try{
						update product;
					}catch(Exception e){
						system.debug(e.getMessage());
					}
				}
				system.debug('finished looping products');
				if(adsActive){
					account.Adwords_Product__c = 'Active';
				}else if(adsPaused){
					account.Adwords_Product__c = 'Paused';
				}else if(adsCancelled){
					account.Adwords_Product__c = 'Cancelled';
				}
					
				account.Package_Name__c = package_name;
				if(seoActive){
					account.SEO_Product__c = 'Active';
				}else if(seoPaused){
					account.SEO_Product__c = 'Paused';
				}else if(seoCancelled){
					account.SEO_Product__c = 'Cancelled';
				}
				
				if(facebookActive){
					account.Facebook_Product__c = 'Active';
				}else if(facebookPaused){
					account.Facebook_Product__c = 'Paused';
				}else if(facebookCancelled){
					account.Facebook_Product__c = 'Cancelled';
				}
					
				if(convertoActive){
					account.Converto_Product__c = 'Active';
				}else if(convertoPaused){
					account.Converto_Product__c = 'Paused';
				}else if(convertoCancelled){
					account.Converto_Product__c = 'Cancelled';
				}
					
				if(adsActive || seoActive || facebookActive || convertoActive){
					account.Active__c = true;
				}else{
					account.Active__c = false;
				}
				system.debug('converto'+ account.Converto_Product__c );
				system.debug('adwords'+ account.Adwords_Product__c );
				system.debug('seo'+ account.SEO_Product__c );
				system.debug('facebook'+ account.Facebook_Product__c );
				
				if((account.Converto_Product__c == null || account.Converto_Product__c == 'Cancelled')
					&&(account.Adwords_Product__c == null || account.Adwords_Product__c == 'Cancelled')
					&&(account.SEO_Product__c == null || account.SEO_Product__c == 'Cancelled')
					&&(account.Facebook_Product__c == null || account.Facebook_Product__c == 'Cancelled')
				){
					account.cancelled_date__c = cancelledDate;
				}
				
				
				account.Adwords_Active_Days__c  = adwords_active_days;
				account.SEO_Active_Days__c      = seo_active_days;
				account.Facebook_Active_Days__c = facebook_active_days;
				account.Converto_Active_Days__c = converto_active_days;
				
				account.Active_Days__c          = adwords_active_days + facebook_active_days + seo_active_days;

		 	    update account;
		      
		  } catch(Exception e) {
	   	       System.debug('Error fetching contact record');
	           System.debug('EXCEPTION: '+e.getMessage());
	      }
	}
		
	}
	global void finish(Database.batchableContext info){
		
   		}
}