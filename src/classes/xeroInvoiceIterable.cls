global class  xeroInvoiceIterable implements Iterator<Xero_Invoice__c>{
	Integer i {get;set;}
	List<Xero_Invoice__c> xeroInvoices {get;set;}
	
	
	public xeroInvoiceIterable(Date search_date) {
		
		this.xeroInvoices = [Select Id, Reference__c, InvoiceNumber__c, Account__c, Name from Xero_Invoice__c where Date__c =: search_date and (Status__c = 'AUTHORISED' or Status__C = 'PAID') and Total__c > 200];
		this.i = 0;
		
		
		
	}

	global boolean hasNext() {
		if(this.i >= this.xeroInvoices.size()) 
        	return false; 
		else 
        	return true;	
	}

	global Xero_Invoice__c next() {
   		return this.xeroInvoices[this.i++];	
	}
}