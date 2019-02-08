global class  InvoiceCreateIterable implements Iterator<Account_Product__c>{
	Integer i {get;set;}
	List<Account_Product__c> accountproducts {get;set;}
	
	
	public InvoiceCreateIterable() {
		
		this.accountproducts = [Select 
									   a.pauseat__c,
									   a.cancelat__c, 
									   a.activeat__c,
									   a.Trial_End_Date__c,
									   a.Start_Date__c,
									   a.End_Date__c, 
									   a.SLX_Product__r.product_recurring__c,
									   a.Send_Invoice__c, 
									   a.SLX_Product__c, 
									   a.Recurring_Period__c, 
									   a.Account__r.ID, 
									   a.Account__r.Payment_Option__c,
									   a.Account__r.Unique_Id__c,
									   a.Account__r.Name,
									   a.Recurring_Frequency__c, 
									   a.Product_Status__c, 
									   a.Product_Price__c,
									   a.Product_Package__c, 
									   a.Product_Number__c,
									   a.Product_Category__c, 
									   a.OwnerId,
									   a.Name_On_Card__c, 
									   a.Name, 
									   a.Account__r.Amex__c,
									   a.Last_Invoice_Number__c, 
									   a.Last_Invoice_Date__c,
									   a.LastModifiedDate, 
									   a.Id, 
									   a.CurrencyIsoCode,
									   a.Description__c,
									   a.Create_Invoice__c,
									   a.Company__c, 
									   a.Account__c, 
									   a.Payment_Option__c, 
									   a.No_Charge__c,
									   a.Account__r.website

								From 
									   Account_Product__c a
								Where 
									   a.Product_Status__c = 'Active' 
								and 
									   a.Account__c!=null 
      							and 
      								   (a.Recurring_Period__c != null and a.Recurring_Period__c!='N/A')
      							// Added on 19/04/2017, STOP $0 Converto Invoice Being Raised
      							and
      									(NOT ((Name Like '%ConvertoPages%' or Name Like 'GO%') and Product_Price__c = 0))];
      								

	
		this.i = 0;
	}

	global boolean hasNext() {
		if(this.i >= this.accountproducts.size()) 
        	return false; 
		else 
        	return true;	
	}

	global Account_Product__c next() {
   		return this.accountproducts[this.i++];	
	}
	
	
	
	public static testMethod void testInvoiceCreateIterable() {
        Test.startTest();
        Account_Product__c ap = new Account_Product__c();
        ap.Last_Invoice_Date__c = Date.today();
        ap.Recurring_Frequency__c = 1;
        ap.Product_Price__c = 19.99;
        ap.activeat__c = Date.today();
        insert ap;
        
        InvoiceCreateIterable testIteratble = new InvoiceCreateIterable();
        if(testIteratble.hasNext()){
        	Account_Product__c accountproduct = testIteratble.next();
        }
        Test.stopTest();
    }
}