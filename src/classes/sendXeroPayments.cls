global class sendXeroPayments implements iterable<Invoice_Payments__c> {
	private String period = 'Today';

	public sendXeroPayments(String period) {
		this.period = period;
	}

	global Iterator<Invoice_Payments__c> Iterator(){
		return new sendXeroPaymentsIterable(this.period);
	}
}