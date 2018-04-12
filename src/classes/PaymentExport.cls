public with sharing class PaymentExport {
	public String soql {get; set;}
	public List<Payment__c> payments;
	
	public PaymentExport(){
		this.soql = ApexPages.currentPage().getParameters().get('soql');
		try{
			this.payments = Database.Query(this.soql);
		}catch(Exception e){
			System.debug(e.getMessage());
		}
	
	}
	
	public List<Payment__c> getPayments(){
		return this.payments;
	}
	
	
	
	public static testMethod void testPayment4(){
		PaymentExport payment = new PaymentExport();	
		payment.getPayments();
	}
	
	
	

}