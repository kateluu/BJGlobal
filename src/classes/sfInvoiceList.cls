public with sharing class sfInvoiceList {
	public List<InvRow> irs {get; set;}
	
	/*
	#33ccff DIFM
	#FFFF66 social
	#71D08E seo
	#BCBAE8 adwords
	#D2EBC2 facebook
	#E7B6C7 yahoo
	#4FC4C4 web
	#D5B581 hosting
	#FCFCF7 other
	*/
	
	
	public sfInvoiceList(ApexPages.StandardController controller){
		Account acc = (Account)controller.getRecord();		
		List<Invoice__c>invoices = [select Id, 
						Name, 
						Invoice_Number__c, 
						Amount_Credited__c, 
						Amount_Due__c,
						Amount_Paid__c, 
						Amount_Refunded__c, 
						Due_Date__c, 
						Invoice_Total__c,
						Issue_Date__c,
						Account_Product__r.Name,
						Account_Product__c,
						Reference__c,
						Status__c,
						Account_Product__r.description__c							
				   from Invoice__c
				   where Status__c != ''
				   and  Issue_Date__c >= 2011-01-01
				   and  Account__c =: acc.Id
				   order by Issue_Date__c DESC];
				   
		irs = new List<InvRow>();

		integer i = 0;				   
		for(Invoice__c inv : invoices) {
			i++;
			system.debug(i);
			InvRow ir = new InvRow();
			ir.invoice = inv;
			if(inv.Account_Product__c == null || inv.Account_Product__r.Name == null) {
				ir.color = '#FCFCF7';
			} else {
				if(inv.Account_Product__r.Name.containsIgnoreCase('DIFM')) {
					ir.color = '#33ccff';
				}else if(inv.Account_Product__r.Name.containsIgnoreCase('social')) {
					ir.color = '#FFFF66';
				}else if(inv.Account_Product__r.Name.containsIgnoreCase('seo')) {
					ir.color = '#71D08E';
				} else if(inv.Account_Product__r.Name.containsIgnoreCase('adwords')) {
					ir.color = '#BCBAE8';
				} else if(inv.Account_Product__r.Name.containsIgnoreCase('facebook')) {
					ir.color = '#D2EBC2';
				} else if(inv.Account_Product__r.Name.containsIgnoreCase('yahoo')) {
					ir.color = '#E7B6C7';
				} else if(inv.Account_Product__r.Name.containsIgnoreCase('web')) {
					ir.color = '#4FC4C4';
				} else if(inv.Account_Product__r.Name.containsIgnoreCase('hosting') || inv.Account_Product__r.Name.containsIgnoreCase('domain')) {
					ir.color = '#D5B581';	
				} else {
					ir.color = '#FCFCF7';
				}
			}
			irs.add(ir);
		}
		
		system.debug(irs);
	}
	
	public class InvRow {
		public Invoice__c invoice {get; set;}
		public string color {get; set;}
	}
	
	public static testMethod void accountExtTest() {
		Account acc = new Account();
		acc.name = 'acc1';
		insert acc;
		
		Account_product__c ap = new Account_product__c();
		ap.Account__c = acc.id;
        ap.Product_Price__c = 69;
        ap.Last_Invoice_Date__c = Date.today().addMonths(-1);
        ap.Recurring_Period__c ='Weekly';
        ap.Payment_Option__c = 'Cheque';
        ap.Name = 'Adwords Standard Management';
		insert ap;
		
		Invoice__c inv = new Invoice__c();
		inv.name = 'test invoice';
		inv.Status__c = 'PAID';
		inv.Issue_Date__c = date.today();
		inv.Payment_Option__c = 'Other';
		inv.Invoice_Number__c = 'test--001';
		inv.Invoice_Batch__c = null;
		inv.Payment_Batch__c = null;
		inv.Account__c = acc.Id;
		inv.account_product__c = ap.id;
		inv.Amount_Due__c = 4.50;
		inv.Exclude_Invoice__c = true;
		inv.Exclude_Reminder__c = true;
		insert inv;
		
		Account_product__c ap1 = new Account_product__c();
		ap1.Account__c = acc.id;
        ap1.Product_Price__c = 69;
        ap1.Last_Invoice_Date__c = Date.today().addMonths(-1);
        ap1.Recurring_Period__c ='Weekly';
        ap1.Payment_Option__c = 'Cheque';
        ap1.Name = 'SEO Management';
		insert ap1;
		
		Invoice__c inv1 = new Invoice__c();
		inv1.name = 'test invoice';
		inv1.Payment_Option__c = 'Other';
		inv1.Invoice_Number__c = 'test--001';
		inv1.Status__c = 'PAID';
		inv1.Issue_Date__c = date.today();
		inv1.Invoice_Batch__c = null;
		inv1.Payment_Batch__c = null;
		inv1.Account__c = acc.Id;
		inv1.account_product__c = ap1.id;
		inv1.Amount_Due__c = 4.50;
		inv1.Exclude_Invoice__c = true;
		inv1.Exclude_Reminder__c = true;
		insert inv1;
		
		Account_product__c ap2 = new Account_product__c();
		ap2.Account__c = acc.id;
        ap2.Product_Price__c = 69;
        ap2.Last_Invoice_Date__c = Date.today().addMonths(-1);
        ap2.Recurring_Period__c ='Weekly';
        ap2.Payment_Option__c = 'Cheque';
        ap2.Name = 'Facebook Management';
		insert ap2;
		
		Invoice__c inv2 = new Invoice__c();
		inv2.name = 'test invoice';
		inv2.Payment_Option__c = 'Other';
		inv2.Invoice_Number__c = 'test--001';
		inv2.Status__c = 'PAID';
		inv2.Issue_Date__c = date.today();
		inv2.Invoice_Batch__c = null;
		inv2.Payment_Batch__c = null;
		inv2.Account__c = acc.Id;
		inv2.account_product__c = ap2.id;
		inv2.Amount_Due__c = 4.50;
		inv2.Exclude_Invoice__c = true;
		inv2.Exclude_Reminder__c = true;
		insert inv2;
		
		Account_product__c ap3 = new Account_product__c();
		ap3.Account__c = acc.id;
        ap3.Product_Price__c = 69;
        ap3.Last_Invoice_Date__c = Date.today().addMonths(-1);
        ap3.Recurring_Period__c ='Weekly';
        ap3.Payment_Option__c = 'Cheque';
        ap3.Name = 'Yahoo Standard Management';
		insert ap3;
		
		Invoice__c inv3 = new Invoice__c();
		inv3.name = 'test invoice';
		inv3.Payment_Option__c = 'Other';
		inv3.Invoice_Number__c = 'test--001';
		inv3.Status__c = 'PAID';
		inv3.Issue_Date__c = date.today();
		inv3.Invoice_Batch__c = null;
		inv3.Payment_Batch__c = null;
		inv3.Account__c = acc.Id;
		inv3.account_product__c = ap3.id;
		inv3.Amount_Due__c = 4.50;
		inv3.Exclude_Invoice__c = true;
		inv3.Exclude_Reminder__c = true;
		insert inv3;
		
		Account_product__c ap4 = new Account_product__c();
		ap4.Account__c = acc.id;
        ap4.Product_Price__c = 69;
        ap4.Last_Invoice_Date__c = Date.today().addMonths(-1);
        ap4.Recurring_Period__c ='Weekly';
        ap4.Payment_Option__c = 'Cheque';
        ap4.Name = 'Web';
		insert ap4;
		
		Invoice__c inv4 = new Invoice__c();
		inv4.name = 'test invoice';
		inv4.Payment_Option__c = 'Other';
		inv4.Invoice_Number__c = 'test--001';
		inv4.Status__c = 'PAID';
		inv4.Issue_Date__c = date.today();
		inv4.Invoice_Batch__c = null;
		inv4.Payment_Batch__c = null;
		inv4.Account__c = acc.Id;
		inv4.account_product__c = ap4.id;
		inv4.Amount_Due__c = 4.50;
		inv4.Exclude_Invoice__c = true;
		inv4.Exclude_Reminder__c = true;
		insert inv4;
		
		Account_product__c ap5 = new Account_product__c();
		ap5.Account__c = acc.id;
        ap5.Product_Price__c = 69;
        ap5.Last_Invoice_Date__c = Date.today().addMonths(-1);
        ap5.Recurring_Period__c ='Weekly';
        ap5.Payment_Option__c = 'Cheque';
        ap5.Name = 'Hosting';
		insert ap5;
		
		Invoice__c inv5 = new Invoice__c();
		inv5.name = 'test invoice';
		inv5.Payment_Option__c = 'Other';
		inv5.Invoice_Number__c = 'test--001';
		inv5.Status__c = 'PAID';
		inv5.Issue_Date__c = date.today();
		inv5.Invoice_Batch__c = null;
		inv5.Payment_Batch__c = null;
		inv5.Account__c = acc.Id;
		inv5.account_product__c = ap5.id;
		inv5.Amount_Due__c = 4.50;
		inv5.Exclude_Invoice__c = true;
		inv5.Exclude_Reminder__c = true;
		insert inv5;
		
		ApexPages.standardController controller = new ApexPages.standardController(acc);
        sfInvoiceList ext = new sfInvoiceList(controller);
    }
    
    
    
    
    
    
	
	

}