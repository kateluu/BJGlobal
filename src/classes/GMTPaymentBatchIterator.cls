// NOTE: this class is actually generic for all companies and payment types. It only has "GMT" in the title for historical reasons.
global class GMTPaymentBatchIterator implements iterable<Invoice__c> {
	private String period;
	private String companyName;
	private String paymentMethod;

	public GMTPaymentBatchIterator(String period, String companyName, String paymentMethod) {
		this.period = period;
		this.companyName = companyName;
		this.paymentMethod = paymentMethod;
	}

	global Iterator<Invoice__c> Iterator() {
		return new GMTPaymentBatchIterable(this.period, this.companyName, this.paymentMethod);
	}
}