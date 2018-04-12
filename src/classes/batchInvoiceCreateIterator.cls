global class batchInvoiceCreateIterator implements Iterable<Invoice__c> {
	private String period = 'Today';
	private String companyName = '';

	public batchInvoiceCreateIterator(String period, String companyName) {
		this.period = period;
		this.companyName = companyName;
	}

	global Iterator<Invoice__c> Iterator() {
		return new batchInvoiceCreateIterable(this.period, this.companyName);		
	}
}