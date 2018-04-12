global class xeroInvoiceIterator implements Iterable<Xero_Invoice__c> {
	private Date search_date = date.today();
	
	public xeroInvoiceIterator(Date search_date ) {
		this.search_date = search_date;
	}

	global Iterator<Xero_Invoice__c> Iterator() {
		return new xeroInvoiceIterable(this.search_date);
		
	}
}