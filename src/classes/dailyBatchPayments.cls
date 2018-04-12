global class dailyBatchPayments implements iterable<Invoice__c> {
	private String period = 'Today';

	public dailyBatchPayments(String period) {
		this.period = period;
	}

	global Iterator<Invoice__c> Iterator() {
		return new dailyBatchPaymentsIterable(this.period);
	}
}