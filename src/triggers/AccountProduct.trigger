trigger AccountProduct on Account_Product__c (before update, after insert, after update) {

    AccountProductShareProcessor myAccountShare = new AccountProductShareProcessor(Trigger.new, Trigger.old);

    if(Trigger.isBefore && Trigger.isUpdate){
        /*
        for (Account_Product__c product : Trigger.new) {
            if (product.Product_Status__c == 'Paused' && Trigger.oldMap.get(product.Id).Product_Status__c != 'Paused') {
                try {
                    Account acc = [SELECT Id, OwnerId, Name FROM Account WHERE Id =:product.Account__c][0];
                    Contact con = [SELECT Id, Name, firstName, lastName, Email FROM Contact WHERE AccountId =:product.Account__c AND Title = 'Billing'][0];
                    User owner = [SELECT Id, Name, IsActive FROM User WHERE Id =:product.OwnerId][0];
                    
                    if (product.pauseat__c == null) {
                        product.addError('Please enter a pauseat date.');
                    } else if (product.activeat__c == null) {
                        product.addError('Please enter an activeat date.');
                    } else {
                        // Tasks cannot be assigned to inactive operators 
                        if (owner.IsActive == true){
                            Task task           = new Task();
                            task.OwnerId        = product.OwnerId;
                            task.WhoId          = con.Id;
                            task.WhatID         = product.Account__c;
                            task.Subject        = acc.Name+' ('+product.Name+') was paused at '+product.pauseat__c.format()+' and will reactivate on '+product.activeat__c.format();
                            task.Description    = acc.Name+' ('+product.Name+') was paused at '+product.pauseat__c.format()+' and will reactivate on '+product.activeat__c.format();
                            task.Type           = 'Status';
                            task.ActivityDate   = product.activeat__c.addDays(-7);
                            System.debug('TASK: ' + task);
                            insert task;
                        } else {
                            System.debug('Could not assign task to inactive user: ' + owner.Name);
                        }
                    }
                } catch(Exception e) {
                    System.debug('Create Task Error: ' + e + '. line ' + e.getLineNumber());
                    product.addError('AccountProductTrigger: Failed to create task. ' + e);
                }
            }
        }
        */
        list<Account_Product__c> oldProducts = new list<Account_Product__c>();
        for(Integer i=0;i<Trigger.new.size();i++){
            Account_Product__c oldItem = Trigger.old.get(i);
            Account_Product__c newItem = Trigger.new.get(i);
            if( (oldItem.ownerID != newItem.ownerID) || (oldItem.Account__c != newItem.Account__c) ){
                oldProducts.add(oldItem);
            }
        }
        AccountProductShareProcessor myAccountShare = new AccountProductShareProcessor(Trigger.new, oldProducts);
        //remove sharing on accounts which link to updated products
        system.debug('accountProductTrigger :: Trigger.isBefore ' );
        myAccountShare.removeAccountSharing();
        system.debug('accountProductTrigger :: Trigger.isBefore ' + myAccountShare);
    }

    if (Trigger.isAfter){
        AccountProductShareProcessor myAccountShare = new AccountProductShareProcessor(Trigger.new,null);
        system.debug('accountProductTrigger :: Trigger.isAfter ');
        myAccountShare.recaculateAccountSharing();
        system.debug('accountProductTrigger :: Trigger.isAfter ' + myAccountShare);
    }
}