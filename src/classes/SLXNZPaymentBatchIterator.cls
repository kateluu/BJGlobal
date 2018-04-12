global class SLXNZPaymentBatchIterator implements iterable<Invoice__c> {
	private String period = 'Today';

	public SLXNZPaymentBatchIterator(String period) {
		this.period = period;
	}

	global Iterator<Invoice__c> Iterator() {
		return new SLXNZPaymentBatchIterable(this.period);
	}
}