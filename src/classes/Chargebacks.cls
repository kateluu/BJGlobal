public with sharing class Chargebacks {
	public List<Invoice__c> invoices = new List<Invoice__c>();
	public Account acc {get;set;}
	public boolean PageRefresh {get;set;}
	public String invoiceNumber {get;set;}
	public Decimal invoiceTotal {get;set;}
	public Decimal invoiceAmountDue {get;set;}
	public Decimal invoiceAmountPaid {get;set;}
	public Date invoiceDueDate {get;set;}
	public Date invoiceIssuedDate {get;set;}
	public Decimal amountPaid {get; set;}
	public String PaymentType {get;set;}
	public String PaymentReference {get;set;}
	public Decimal partialRefundAmount {get;set;}
	public Decimal paymentAmount {get;set;}
	public String invoiceId {get;set;}
	public Decimal  totalRefund {get;set;}
	public Integer  invoicesSelected {get;set;}
	public String message {get;set;}
	public Payment__c inputPayment = new Payment__c();
	public Payment__c inputPaymentPartial = new Payment__c();
	
	public Payment__c getinputPayment() {
		return this.inputPayment;
	}
	public void setinputPayment(Payment__c value){
		this.inputPayment = value;
	}
	public Payment__c getinputPaymentPartial() {
		return this.inputPaymentPartial;
	}
	public void setinputPaymentPartial(Payment__c value){
		this.inputPaymentPartial = value;
	}
	
	public List<Invoice__c> getinvoices() {
		return this.invoices;
	}
	public void setinvoices(list<Invoice__c> value) {
		this.invoices = value;
	}
	
	public List<SelectOption> getInvoiceNumbers() {
    	List<SelectOption> options = new List<SelectOption>();
    	if(this.invoices != null){
	        for(Invoice__c thisInvoice : this.invoices){
	        	options.add(new SelectOption(thisInvoice.Invoice_Number__c,thisInvoice.Invoice_Number__c));	
	        }
    	}
    	return options;
	}
	
	public Chargebacks(ApexPages.StandardController controller){
		this.acc = (Account)controller.getRecord();
		this.PageRefresh = false;
		this.message = '';
	}
	
	public PageReference updateInvoices(){
		//this.invoices = this.invoices;
		update this.invoices;
		this.totalRefund = 0;
		this.invoicesSelected = 0;
		for(Invoice__c invoice : this.invoices){
			if(invoice.Checked__c){
				this.totalRefund += invoice.Amount_Paid__c;
				this.invoicesSelected += 1;
			}
			
		}
		return null;
	}
	public PageReference PageLoad(){
			
		this.invoices = [
			SELECT 
				Id, 
				Name,
				Amount_Credited__c, 
				Account__r.Payment_Option__c,
				Account__r.Name_On_Card__c,
				Account__r.Card_Number__c, 
				Account__r.Card_CVN__c,
				Account__r.Card_Month_Expiry__c,
				Account__r.Card_Year_Expiry__c, 
				Account_Product__c, 
				Account_Product__r.Name,
				Account_Product__r.OwnerId,
				Account_Product__r.Payment_Option__c,
				Account_Product__r.Name_On_Card__c,
				Account_Product__r.Card_Number__c,
				Account_Product__r.Card_Month_Expiry__c,
				Account_Product__r.Card_Year_Expiry__c,
				Account_Product__r.Card_CVN__c, 
				Account_Product__r.SLX_Product__r.company_name__c,
				Account__c, 
				Checked__c, 
				Invoice_Number__c, 
				Invoice_Total__c, 
				Amount_Paid__c, 
				Amount_Due__c, 
				Due_Date__c, 
				Issue_Date__c, 
				Amount_Refunded__c,
				Payment_Response__c,
				CurrencyIsoCode
			FROM 
				Invoice__c 
			WHERE 
				Account__c=:acc.Id 
			AND 
				(Status__c = 'PAID')
			order by
        		Issue_Date__c
		];
		for(Invoice__c thisInvoice : this.invoices){
			thisInvoice.Checked__c = false;
			this.invoiceNumber = thisInvoice.Invoice_Number__c;
		}
		//try{
		updateInvoices();
		ChangeInvoiceNumber();
		//}
		//catch(Exception e){
			
		//}
		return null;
	
	}
	public pageReference SingleChargeback() {
		
		
		List<Invoice__c> SelectedInvoices = new List<Invoice__c>();
		for(Invoice__c invoice: this.invoices){
			if(invoice.Invoice_Number__c == this.invoiceNumber){
				SelectedInvoices.add(invoice);
			}
		}
		
		List<Payment__c> ChargebackPayments = new List<Payment__c>();
		List<Credit__c> RefundCredits = new List<Credit__c>();
		List<Invoice__c> updateInvoices = new List<Invoice__c>();
		for(Invoice__c invoice: SelectedInvoices){
			//process chargeback
			
			Payment__c ChargebackPayment = new Payment__c();
			
			Decimal ChargebackAmount = invoice.Amount_Paid__c;
			
			ChargebackPayment.Account__c = acc.Id;
			ChargebackPayment.Payment_Type__c = 'Chargeback';
			ChargebackPayment.Payment_Amount__c = -partialRefundAmount;
			ChargebackPayment.Invoice__c = invoice.Id;
			ChargebackPayment.Invoice_Number__c = invoice.Invoice_Number__c;
			ChargebackPayment.Notes__c = inputPayment.Notes__c;
			ChargebackPayment.Payment_Date__c = Date.today();
			ChargebackPayment.Payment_Option__c = invoice.Account_Product__r.Payment_Option__c;
			ChargebackPayment.CurrencyIsoCode = invoice.CurrencyIsoCode;
			ChargebackPayment.Account_Product__c = invoice.Account_Product__c;
			ChargebackPayment.Payment_Owner__c = invoice.Account_Product__r.OwnerId;
			ChargebackPayments.add(ChargebackPayment);
			
			if(invoice.Amount_Refunded__c == null) invoice.Amount_Refunded__c = 0;
			invoice.Amount_Refunded__c = invoice.Amount_Refunded__c + partialRefundAmount;
			system.debug(invoice.Invoice_Total__c);
			system.debug(invoice.Amount_Refunded__c);
			if(invoice.Invoice_Total__c == invoice.Amount_Refunded__c) invoice.Status__c = 'CHARGEBACK';
			invoice.Amount_Paid__c = invoice.Amount_Paid__c - partialRefundAmount;
			updateInvoices.add(invoice);
		}
		insert ChargebackPayments;
		update updateInvoices;
		
		this.invoices = [
			SELECT 
				Id, 
				Name,
				Amount_Credited__c, 
				Account__r.Payment_Option__c,
				Account__r.Name_On_Card__c,
				Account__r.Card_Number__c, 
				Account__r.Card_CVN__c,
				Account__r.Card_Month_Expiry__c,
				Account__r.Card_Year_Expiry__c, 
				Account_Product__c, 
				Account_Product__r.Name,
				Account_Product__r.Payment_Option__c,
				Account_Product__r.Name_On_Card__c,
				Account_Product__r.Card_Number__c,
				Account_Product__r.Card_Month_Expiry__c,
				Account_Product__r.Card_Year_Expiry__c,
				Account_Product__r.Card_CVN__c, 
				Account__c, 
				Checked__c, 
				Invoice_Number__c, 
				Invoice_Total__c, 
				Amount_Paid__c, 
				Amount_Due__c, 
				Due_Date__c, 
				Issue_Date__c, 
				Amount_Refunded__c,
				CurrencyIsoCode
			FROM 
				Invoice__c 
			WHERE 
				Account__c=:acc.Id 
			AND 
				(Status__c = 'PAID' OR Status__c = 'PARTIALLY PAID' OR Status__c = 'PARTIALLY REFUNDED')
			order by
        		Issue_Date__c
		];
		this.totalRefund = 0;
		this.invoicesSelected = 0;
		this.inputPayment = new Payment__c();
		this.inputPaymentPartial = new Payment__c();
		
		
		PageReference MakeARefundPage = new PageReference('/apex/Chargebacks');
        MakeARefundPage.getParameters().put('id',this.acc.id);
        MakeARefundPage.setRedirect(true);
        return MakeARefundPage;
	}
	
	public void ChangeInvoiceNumber() {
		for(Invoice__c thisInvoice : this.invoices){
			if (thisInvoice.Invoice_Number__c == this.invoiceNumber) {
				this.invoiceNumber 		= thisInvoice.Invoice_Number__c;
		  		this.invoiceTotal 		= thisInvoice.Amount_Due__c;
		  		this.paymentAmount 		= thisInvoice.Amount_Due__c;
		  		this.PaymentReference 	= thisInvoice.Invoice_Number__c;
		  		this.PaymentType 		= thisInvoice.Account_Product__r.Payment_Option__c;
		  		this.amountPaid         = thisInvoice.Amount_Paid__c;
		  		this.InvoiceId			= thisInvoice.Id;
		  		if(thisInvoice.Amount_Refunded__c == null){thisInvoice.Amount_Refunded__c = 0;}
		  		this.partialRefundAmount = thisInvoice.Invoice_Total__c - thisInvoice.Amount_Refunded__c;
		  		
		  		this.invoiceAmountDue 	= thisInvoice.Amount_Due__c;
				this.invoiceAmountPaid 	= thisInvoice.Amount_Paid__c;
				this.invoiceDueDate		= thisInvoice.Due_Date__c;
				this.invoiceIssuedDate 	= thisInvoice.Issue_Date__c;
		  	}
		}		
	}
	public PageReference returnToAccount() {
    	PageReference AccountPage = new ApexPages.StandardController(this.acc).view();
        AccountPage.setRedirect(true);
        return AccountPage;
    }
}