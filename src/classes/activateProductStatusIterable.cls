global class activateProductStatusIterable implements Iterator<Account_Product__c> {
    
    List<Account_Product__c> activateProducts {get;set;} 
    Integer i {get;set;}
    
    public activateProductStatusIterable() {
        this.activateProducts = [SELECT Id,Name,Account__c,Product_Number__c,Product_Status__c, activeat__c, Sold_to_Pause__c, last_invoice_date__c , Last_Paid_Date__c , From_Last_Paid_Date__c, TP_Record_Id__c
                                FROM Account_Product__c 
                                WHERE activeat__c=today and Product_Status__c != 'Active'];
        this.i = 0;
    }
    global boolean hasNext() {
        if(this.i >= this.activateProducts.size()) 
            return false; 
        else 
            return true;    
    }
    global Account_Product__c next() {
        return this.activateProducts[this.i++]; 
    }
    
    public static TestMethod void test() {
        Account_Product__c ap1 = new Account_Product__c();
	 	ap1.Product_Status__c = 'Paused';
	 	ap1.name = 'ap1';
	 	ap1.activeat__c = Date.today();
	 	ap1.Product_Price__c = 55.0;
	 	insert ap1;
	 		 	
	 	Account_Product__c ap2 = new Account_Product__c();
	 	ap2.Product_Status__c = 'Paused';
	 	ap2.activeat__c = Date.today();
	 	ap2.Product_Price__c = 55.0;
	 	insert ap2;
	 	
	 	Account_Product__c ap3 = new Account_Product__c();
	 	ap3.Product_Status__c = 'Paused';
	 	ap3.activeat__c = Date.today();
	 	ap3.Product_Price__c = 55.0;
	 	insert ap3;
        
        Test.startTest();
        
        activateProductStatusIterable iter = new activateProductStatusIterable();
        iter.i = 2;
        List<Account_Product__c> aps = new List<Account_Product__c>();
        if (iter.hasNext()) {
			aps.add(iter.next());        	
        }

        Test.stopTest();
    }
    
     public static TestMethod void test1() {
        Test.startTest();
        
        activateProductStatusIterable iter = new activateProductStatusIterable();
        iter.i = 5;
        List<Account_Product__c> aps = new List<Account_Product__c>();
        if (iter.hasNext()) {
			aps.add(iter.next());        	
        }

        Test.stopTest();
    }
}