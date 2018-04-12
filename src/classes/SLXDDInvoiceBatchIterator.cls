global class SLXDDInvoiceBatchIterator implements Iterable<Invoice__c> {
	private String period = 'Today';

	public SLXDDInvoiceBatchIterator(String period) {
		this.period = period;
	}

	global Iterator<Invoice__c> Iterator() {
		return new SLXDDInvoiceBatchIterable(this.period);
	}
}