trigger downgrade_upgrade_product on Account_Product__c (before insert) {
	for (Account_Product__c product : Trigger.new) {
		if(product.name != null && product.name.contains('Adwords')){
			try {
                Account_Product__c[] aps = [SELECT Id, 
                								   OwnerId, 
                								   Adwords_Id__c 
                						    FROM Account_Product__c 
                						    WHERE Account__c =:product.Account__c 
                						    and (Product_Status__c = 'Downgrade' 
                						    	or Product_Status__c = 'Upgrade')
                						    and CreatedDate = today 
                						    order by CreatedDate 
               						    desc];
               	system.debug(aps);
                if(aps.size()>0){
                	system.debug(aps[0]);
                	product.Adwords_ID__c = aps[0].Adwords_Id__c;
                	product.OwnerId = aps[0].OwnerId;
                }
            } catch(Exception e) {
                System.debug('Update Account Product Error(Before Insert): ' + e);
            }
			
		}else{
			// do nothing
		}
		
	}

}