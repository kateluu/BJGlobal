global class InvoiceCreateIterator implements Iterable<Account_Product__c> {
	
	public InvoiceCreateIterator() {
		
	}

	global Iterator<Account_Product__c> Iterator() {
		return new InvoiceCreateIterable();
		
	}
	
	public static testMethod void testInvoiceCreateIterator() {
        Test.startTest();
        Account_Product__c ap = new Account_Product__c();
        ap.Last_Invoice_Date__c = Date.today();
        ap.Recurring_Frequency__c = 1;
        ap.Product_Price__c = 19.99;
        ap.activeat__c = Date.today();
        insert ap;
        
        InvoiceCreateIterator invoiceCreateIterator = new InvoiceCreateIterator();
        Iterator<Account_Product__c> aps = invoiceCreateIterator.Iterator();
        Test.stopTest();
    }
	
	
	
	
}