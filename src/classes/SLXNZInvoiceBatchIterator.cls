global class SLXNZInvoiceBatchIterator implements Iterable<Invoice__c> {
	private String period = 'Today';

	public SLXNZInvoiceBatchIterator(String period) {
		this.period = period;
	}

	global Iterator<Invoice__c> Iterator() {
		return new SLXNZInvoiceBatchIterable(this.period);		
	}
}