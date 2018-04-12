public with sharing class eway {

	public ewayResponse response;
	public String xmlrequest		= '';
	public String xmlresponse		= '';
	public String errors 			= '';
	
	public void init() {
		try {
			ewayPayment eway = new ewayPayment();
			eway.setMode('test');
			eway.setewayTotalAmount('5600');
			eway.setewayCustomerFirstName('Bob');
			eway.setewayCustomerLastName('Hawk'); 
			eway.setewayCustomerEmail('chan@webactive.com.au');
			eway.setewayCustomerAddress('123 Sesame St');
			eway.setewayCustomerPostcode('4444');
			eway.setewayCustomerInvoiceDescription('');
			eway.setewayCustomerInvoiceRef('44445555');
			eway.setewayCardHoldersName('Bob Hawk');
			eway.setewayCardNumber('4444333322221111');
			eway.setewayCardExpiryMonth('04');
			eway.setewayCardExpiryYear('12');
			eway.setewayTrxnNumber('987654321');	
			eway.setewayOption1('Option1');	
			eway.setewayOption2('Option2');	
			eway.setewayOption3('Option3');			
			this.response = eway.makePayment();
			this.xmlrequest = eway.getxmldata();
		} catch (Exception e) {
			
		}
	}
	public ewayResponse getresponse() {
		return this.response;
	}
	public String getxmlrequest() {
		return this.xmlrequest;
	}
	public String getxmlresponse() {
		return this.response.getxmlString();
	}
	public String geterrors() {
		return this.response.getewayErrors();
	}
	
	public static testMethod void ewayTest() {
		eway e = new eway();
		e.init();
		e.getresponse();
		e.getxmlrequest();
		//e.getxmlresponse();
	}
}