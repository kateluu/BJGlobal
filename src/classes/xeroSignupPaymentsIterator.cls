global class xeroSignupPaymentsIterator implements iterable<Signup_Payments__c> {
	global Iterator<Signup_Payments__c> Iterator(){
		return new xeroSignupPaymentsIterable();
	}
}