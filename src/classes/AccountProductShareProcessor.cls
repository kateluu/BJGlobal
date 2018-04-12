/*
  created on 05/04/2018
  class do recaculate sharing on the account when ever a new account product is created
*/
public without sharing class  AccountProductShareProcessor {
	
	private list<Account_Product__c> products{get;set;}
	private list<Account_Product__c> oldproducts{get;set;}

	public AccountProductShareProcessor ( list<Account_Product__c> newProducts, list<Account_Product__c> oldProducts){
		this.products = newProducts;
		this.oldproducts = oldProducts;
	}

	public void recaculateAccountSharing(){
		list<Id> accs = new list<Id>();
		list<Id> owners = new list<Id>();

		system.debug('AccountProductShareProcessor: this.oldproducts ::' + this.products.size());
		Map<id, User> activeUsers = new Map<Id, User>([SELECT id,IsActive FROM User WHERE IsActive= true]);

		for(Account_Product__c item: this.products){
			//system.debug('AccountProductShareProcessor: this.oldproducts ::' + item.Account__c  + '/ ' + item.OwnerId);
			if((item.Account__c != null) && (item.OwnerID != null) ){
                accs.add(item.Account__c);
                owners.add(item.OwnerId);               
 			} 			
		}

		list<AccountShare> currentSharings = [SELECT id,IsDeleted,AccountId,UserOrGroupId  FROM AccountShare WHERE AccountId IN :accs AND UserOrGroupId in :owners];
		list<Account_Product__c> productNeedToShare = new list<Account_Product__c>();
		boolean isExist =false;
		for(Account_Product__c item: this.products){
			for( AccountShare child: currentSharings){
				if((child.UserOrGroupId == item.OwnerId) && (child.AccountId == item.Account__c) ){
					isExist = true;
					break;
				}
			}
			if (!isExist){
				productNeedToShare.add(item);
			}
		}

		
		//system.debug('AccountProductShareProcessor: this.products ::' + this.products.size());
		list<AccountShare> myAccountSharings = new list<AccountShare>();
		for(Account_Product__c item: productNeedToShare){
			//system.debug('AccountProductShareProcessor: this.products ::' + item.Account__c  + '/ ' + item.OwnerId);

			if((item.Account__c != null) && (item.OwnerId != null) && (activeUsers.containsKey(item.OwnerID))){
                AccountShare newSharing = new AccountShare();
                newSharing.AccountId = item.Account__c;
                newSharing.UserOrGroupId  = item.OwnerId; 
 
                newSharing.AccountAccessLevel = 'Edit';
                newSharing.ContactAccessLevel= 'Edit';
                newSharing.OpportunityAccessLevel= 'Edit';
                newSharing.RowCause = Schema.AccountShare.RowCause.Manual;
                myAccountSharings.add(newSharing);            
			}
		}

		if(myAccountSharings.size()>0){
			//system.debug('AccountProductShareProcessor: share product owner to the related account/ contact');
			insert myAccountSharings;
			//system.debug('AccountProductShareProcessor: share product owner to the related account/ contact');
		}
	}

	public void removeAccountSharing(){

		list<Id> accs = new list<Id>();
		list<Id> owners = new list<Id>();

		system.debug('AccountProductShareProcessor: this.oldproducts ::' + this.oldproducts.size());
		Map<id, User> activeUsers = new Map<Id, User>([SELECT id, IsActive FROM User WHERE IsActive= true]);
		for(Account_Product__c item: this.oldproducts){
			//system.debug('AccountProductShareProcessor: this.oldproducts ::' + item.Account__c  + '/ ' + item.OwnerId);
			if((item.Account__c != null) && (item.OwnerID != null)){
                accs.add(item.Account__c);
                owners.add(item.OwnerId);               
 			} 			
		}

		list<AccountShare> removeSharing = new List<AccountShare>();
		list<AccountShare> currentSharings = [SELECT id,IsDeleted,AccountId,UserOrGroupId  FROM AccountShare WHERE AccountId IN :accs AND UserOrGroupId in :owners AND RowCause= :Schema.AccountShare.RowCause.Manual ];
		for(Account_Product__c item: this.oldproducts){
			for( AccountShare child: currentSharings){
				if((child.UserOrGroupId == item.OwnerId) && (child.AccountId == item.Account__c)){
					removeSharing.add(child);
				}
			}
		}

		if(removeSharing.size()>0){
			//system.debug('AccountProductShareProcessor: remove access to account from old product owner');
			delete  removeSharing;
			//system.debug('AccountProductShareProcessor: remove access to account from old product owner');
		}

	}
	
}