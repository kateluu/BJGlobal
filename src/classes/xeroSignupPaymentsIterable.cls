global class xeroSignupPaymentsIterable implements Iterator<Signup_Payments__c> {
	
	List<Signup_Payments__c> signupPayment {get;set;} 
	Integer i {get;set;}
	
	public xeroSignupPaymentsIterable() {
		this.signupPayment = [SELECT Id,Name,Account__c,Sign_Up__c,Amount__c,CreatedDate,Last_Response__c FROM Signup_Payments__c];
		this.i = 0;		
	}
	global boolean hasNext() {
		if(this.i >= this.signupPayment.size()) 
        	return false; 
		else 
        	return true;	
	}
	global Signup_Payments__c next() {
   		return this.signupPayment[this.i++];	
	}
	
}