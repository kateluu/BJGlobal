global class pauseProductStatus implements iterable<Account_Product__c> {
	global Iterator<Account_Product__c> Iterator(){
		return new pauseProductStatusIterable();
	}
}