@isTest
public class ewayRefundTestClass {
	public static testMethod void ewayRefundTestClass() {
		ewayRefund eway = new ewayRefund();
		eway.setMode('Get More Traffic');
		eway.setewayTotalAmount('23');
		eway.setewayCardExpiryMonth('12'); 
		eway.setewayCardExpiryYear('2018');
		eway.setewayOriginalTrxnNumber('121212');	
		eway.setewayOption1('');	
		eway.setewayOption2('');	
		eway.setewayOption3('');
		eway.makeRefund();
		eway.getxmldata();
	}
}