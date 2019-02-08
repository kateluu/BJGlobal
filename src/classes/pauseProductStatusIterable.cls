global class pauseProductStatusIterable implements Iterator<Account_Product__c> {
	
	List<Account_Product__c> pausedProducts {get;set;} 
	Integer i {get;set;}
	
	public pauseProductStatusIterable() {
		this.pausedProducts = [SELECT Id,Name,Account__c,Product_Number__c,Product_Status__c, Last_Paid_Date__c , From_Last_Paid_Date__c, pauseat__c , TP_Record_Id__c FROM Account_Product__c WHERE pauseat__c=today and Product_Status__c = 'Active'];
		this.i = 0;		
	}
	
	global boolean hasNext() {
		if(this.i >= this.pausedProducts.size()) 
        	return false; 
		else 
        	return true;	
	}
	
	global Account_Product__c next() {
   		return this.pausedProducts[this.i++];	
	}
	
	public static testMethod void testpauseProductStatusIterable() {
        Test.startTest();
        Account_Product__c ap = new Account_Product__c();
        ap.Last_Invoice_Date__c = Date.today();
        ap.Recurring_Frequency__c = 1;
        ap.activeat__c = Date.today();
        ap.Product_Price__c = 19.99;
        insert ap;
        
        pauseProductStatusIterable testIteratble = new pauseProductStatusIterable();
        Test.stopTest();
    }
}