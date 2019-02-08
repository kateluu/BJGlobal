global class cancelProductStatusIterable implements Iterator<Account_Product__c> {
	
	List<Account_Product__c> cancelProducts {get;set;} 
	Integer i {get;set;}
	
	public cancelProductStatusIterable() {
		this.cancelProducts = [SELECT Id,Name,Account__c,Product_Number__c,Product_Status__c,  Last_Paid_Date__c , From_Last_Paid_Date__c, cancelat__c, TP_Record_Id__c FROM Account_Product__c WHERE cancelat__c = today and Product_Status__c != 'Cancelled'];
		this.i = 0;		
	}
	global boolean hasNext() {
		if(this.i >= this.cancelProducts.size()) 
        	return false; 
		else 
        	return true;	
	}
	global Account_Product__c next() {
   		return this.cancelProducts[this.i++];	
	}
	
	public static testMethod void testcancelProductStatusIterable() {
        Test.startTest();
        Account_Product__c ap = new Account_Product__c();
        ap.Last_Invoice_Date__c = Date.today();
        ap.Recurring_Frequency__c = 1;
        ap.activeat__c = Date.today();
        ap.Product_Price__c = 19.99;
        insert ap;
        
        cancelProductStatusIterable testIteratble = new cancelProductStatusIterable();
        Test.stopTest();
    }
}