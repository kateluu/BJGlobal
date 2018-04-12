global class GMTDDInvoiceBatchIterator implements Iterable<Invoice__c> {
	private String period = 'Today';

	public GMTDDInvoiceBatchIterator(String period) {
		this.period = period;
	}

	global Iterator<Invoice__c> Iterator() {
		return new GMTDDInvoiceBatchIterable(this.period);
	}
}