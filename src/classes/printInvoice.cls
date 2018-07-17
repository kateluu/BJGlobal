public with sharing class printInvoice {
	public Invoice__c invoice {set;get;}
	public List<tran> trans {set; get;}
	public boolean isNewZealand {set; get;}
	public String dateRange {set; get;}
	public String priceBreakDown {set; get;}
	public Company__c company {set;get;}
	
	public printInvoice(ApexPages.StandardController controller){
		Invoice__c inv = (Invoice__c)controller.getRecord();
		this.invoice   = [select 
								Id, 
								Account__c, 
								Reference__c, 
								Payment_Option__c, 
								Account_Product__r.Name, 
								Account_Product__r.Product_Number__c, 
								Account_Product__r.Description__c, 
								Account_Product__r.recurring_period__c, 
								Account_Product__r.SLX_Product__r.company_name__c,
								Account__r.Name, 
								Account__r.website, 
								Account__r.BillingStreet, 
								Account__r.BillingCity, 
								Account__r.BillingState, 
								Account__r.BillingPostalCode, 
								Account__r.BillingCountry, 
								Invoice_Number__c, 
								Issue_Date__c, 
								Amount_Due__c, 
								Amount_Refunded__c, 
								Amount_Credited__c,
								Due_Date__c,
								Amount_Paid__c,
								Invoice_Total__c, 
								Amex__c 
							from 
								Invoice__c 
							where 
								Id=:inv.Id
							];
							
		this.invoice.Account__r.Name = this.invoice.Account__r.Name.removeStart('GetMoreTraffic - ');					
							
		this.company = [select
                            Id,
                            Name,
                            Address__c,
                            Business_Name__c,
                            Email__c,
                            Logo_Code__c,
                            Phone__c,
                            ABN__c,
                            term_page__c,
                            Account_Name__c,
                            Account_Number__c,
                            BSB__c,
                            Display_Invoice_Direct_Debit__c,
                            Display_Invoice_Pay_By_Phone__c,
                            Display_Invoice_Direct_Bank_Deposit__c,
                            Display_Invoice_Client_Panel__c
                        FROM 
                        	Company__c
                        WHERE 
                        	Name =: this.invoice.Account_Product__r.SLX_Product__r.company_name__c
						];
							
		Payment__c[] payments = [select 
							Id,
							Payment_Date__c, 
							Payment_Type__c,
							Payment_Option__c, 
							Payment_Amount__c 
					from 
							Payment__c
					where 
							invoice__c =: invoice.Id
					Order By
							Payment_Date__c DESC
					];
		
		trans = new List<tran>();
		for(Payment__c p : payments) {
			String payDate = p.Payment_Date__c.format();
			Decimal payAmount = p.Payment_Amount__c;
			String payType;
			if(p.Payment_Type__c == 'Eway') {
				payType = 'Credit Card';
			} else if (p.Payment_Type__c == 'Payment' && p.Payment_Option__c == 'Eway') {
				payType = 'Credit Card';
			} else if (p.Payment_Type__c == 'Payment' && p.Payment_Option__c != 'Eway') {
				payType = p.Payment_Option__c;
			} else if (p.Payment_Type__c == 'Credit') {
				payType = 'Credit Note';
			} else {
				payType = p.Payment_Type__c;
			}
			tran t = new tran(payDate, payType, payAmount);
			trans.add(t);
		}
							
		if ((invoice.Account__r.website != null && invoice.Account__r.website.endsWithIgnoreCase('.nz') == true) || this.company.name.containsIgnoreCase('New Zealand')) {
			isNewZealand = true;
		} else {
			isNewZealand = false;
		}
		
		if(isNewZealand){
			priceBreakDown = 'There is no GST included in the invoice amount';
		}else{
			priceBreakDown = 'Tax breakdown: $' + (invoice.Invoice_Total__c*10/11).setScale(2, RoundingMode.HALF_UP) + ' Price + $'
							+ (invoice.Invoice_Total__c/11).setScale(2, RoundingMode.HALF_UP) + ' GST = $' 
							+ invoice.Invoice_Total__c + ' Total';
		}


		if (invoice.Account_Product__r.recurring_period__c == 'Weekly') {
			Date endDate = invoice.Issue_Date__c.addDays(-1);
			Date startDate = endDate.addDays(-6);
			dateRange = startDate.format() + ' - ' + endDate.format();
		} else if (invoice.Account_Product__r.recurring_period__c == 'Fortnightly') {
			Date startDate = invoice.Issue_Date__c;
			Date endDate = startDate.addDays(13);
			dateRange = startDate.format() + ' - ' + endDate.format();			
		} else if (invoice.Account_Product__r.recurring_period__c == 'Monthly') {
			Date startDate = invoice.Issue_Date__c;
			Date endDate = startDate.addMonths(1).addDays(-1);
			dateRange = startDate.format() + ' - ' + endDate.format();
		} else if (invoice.Account_Product__r.recurring_period__c == 'Quarterly') {
			Date startDate = invoice.Issue_Date__c;
			Date endDate = startDate.addMonths(3).addDays(-1);
			dateRange = startDate.format() + ' - ' + endDate.format();
		} else if (invoice.Account_Product__r.recurring_period__c == 'Half Yearly') {
			Date startDate = invoice.Issue_Date__c;
			Date endDate = startDate.addMonths(6).addDays(-1);
			dateRange = startDate.format() + ' - ' + endDate.format();
		} else if (invoice.Account_Product__r.recurring_period__c == 'Yearly') {
			Date startDate = invoice.Issue_Date__c;
			Date endDate = startDate.addYears(1).addDays(-1);
			dateRange = startDate.format() + ' - ' + endDate.format();
		} else if (invoice.Account_Product__r.recurring_period__c == '2 Yearly') {
			Date startDate = invoice.Issue_Date__c;
			Date endDate = startDate.addYears(2).addDays(-1);
			dateRange = startDate.format() + ' - ' + endDate.format();
		} else {
			dateRange = '';
		}
	}
	
	public class tran {
		public String tranDate {get; set;}
    	public String tranType {get; set;}
    	public Decimal tranAmount {get; set;}
    	
    	public tran(String d, String t, Decimal a) {
            this.tranDate = d;
            this.tranType = t;
            this.tranAmount = a;
        }
	}
		
	public static testMethod void testprintInvoice(){
		Test.startTest();
		Account acc = new Account(name='test',company__c='test',username__c='test',password__c='test');
		insert acc;
		Contact con = new Contact(FirstName='test',LastName='test',Title='Billing',AccountId=acc.id);
		con.MailingStreet='sdfsadfsa\r\ndfsafa\r\nsfsdfsdfs\r\ndfsdfs\r\ndfsdf';
		con.MailingCity='Brisbane';
		con.MailingState='queensland';
		con.MailingPostalCode='4444';
		con.MailingCountry='Australia';
		insert con;
		
		Company__c com = new Company__c();
		com.name = 'test company';
		insert com;
		
		SLX_Product__c product = new SLX_Product__c();
		product.company_name__c = com.name;
		product.product_price__c = 10;
		insert product;
				
		Account_Product__c ap1 = new Account_Product__c(name = 'test', product_price__c=50, Account__c = acc.Id,recurring_period__c='Weekly', SLX_Product__c=product.id);
		insert ap1;
		
		Invoice__c invoice1 = new Invoice__c( Account__c = acc.Id, Issue_Date__c = Date.today(), Invoice_Total__c = 10, account_product__c=ap1.Id);
		insert invoice1;
		
		Account_Product__c ap2 = new Account_Product__c(name = 'test', Account__c = acc.Id, product_price__c=50, recurring_period__c='Fortnightly', SLX_Product__c=product.id);
		insert ap2;
		
		Invoice__c invoice2 = new Invoice__c( Account__c = acc.Id, Issue_Date__c = Date.today(), Invoice_Total__c = 10, account_product__c=ap2.Id);
		insert invoice2;
		
		Account_Product__c ap3 = new Account_Product__c(name = 'test', Account__c = acc.Id, product_price__c=50, recurring_period__c='Monthly', SLX_Product__c=product.id);
		insert ap3;
		
		Invoice__c invoice3 = new Invoice__c( Account__c = acc.Id, Issue_Date__c = Date.today(), Invoice_Total__c = 10, account_product__c=ap3.Id);
		insert invoice3;
		
		Account_Product__c ap4 = new Account_Product__c(name = 'test', Account__c = acc.Id, product_price__c=50, recurring_period__c='Quarterly', SLX_Product__c=product.id);
		insert ap4;
		
		Invoice__c invoice4 = new Invoice__c( Account__c = acc.Id, Issue_Date__c = Date.today(), Invoice_Total__c = 10, account_product__c=ap4.Id);
		insert invoice4;
		
		Account_Product__c ap5 = new Account_Product__c(name = 'test', Account__c = acc.Id, product_price__c=50, recurring_period__c='Yearly', SLX_Product__c=product.id);
		insert ap5;
		
		Invoice__c invoice5 = new Invoice__c( Account__c = acc.Id, Issue_Date__c = Date.today(), Invoice_Total__c = 10, account_product__c=ap5.Id);
		insert invoice5;
		
		Account_Product__c ap6 = new Account_Product__c(name = 'test', Account__c = acc.Id, product_price__c=50, recurring_period__c='2 Yearly', SLX_Product__c=product.id);
		insert ap6;
		
		Invoice__c invoice6 = new Invoice__c( Account__c = acc.Id, Issue_Date__c = Date.today(), Invoice_Total__c = 10, account_product__c=ap6.Id);
		insert invoice6;
		
		Payment__c payment1 = new Payment__c(Account__c=acc.Id, payment_Amount__c=60, Payment_Date__c=date.today(), Invoice__c = invoice1.Id, payment_type__c='Eway');
		insert payment1;
		Payment__c payment2 = new Payment__c(Account__c=acc.Id, payment_Amount__c=60,Payment_Date__c=date.today(), Invoice__c = invoice2.Id, payment_type__c='Payment', payment_Option__c='Eway');
		insert payment2;
		Payment__c payment3 = new Payment__c(Account__c=acc.Id, payment_Amount__c=60,Payment_Date__c=date.today(), Invoice__c = invoice3.Id, payment_type__c='Payment');
		insert payment3;
		Payment__c payment4 = new Payment__c(Account__c=acc.Id, payment_Amount__c=60,Payment_Date__c=date.today(), Invoice__c = invoice4.Id, payment_type__c='Payment');
		insert payment4;
		Payment__c payment5 = new Payment__c(Account__c=acc.Id, payment_Amount__c=60,Payment_Date__c=date.today(), Invoice__c = invoice5.Id, payment_type__c='Payment');
		insert payment5;
		Payment__c payment6 = new Payment__c(Account__c=acc.Id, payment_Amount__c=60,Payment_Date__c=date.today(), Invoice__c = invoice6.Id, payment_type__c='Payment');
		insert payment6;
		ApexPages.standardController controller1 = new ApexPages.standardController(invoice1);
		printInvoice printInv1 =  new printInvoice(controller1);
		
		ApexPages.standardController controller2 = new ApexPages.standardController(invoice2);
		printInvoice printInv2 =  new printInvoice(controller2);
		
		ApexPages.standardController controller3 = new ApexPages.standardController(invoice3);
		printInvoice printInv3 =  new printInvoice(controller3);
		
		ApexPages.standardController controller4 = new ApexPages.standardController(invoice4);
		printInvoice printInv4 =  new printInvoice(controller4);
		
		ApexPages.standardController controller5 = new ApexPages.standardController(invoice5);
		printInvoice printInv5 =  new printInvoice(controller5);
		
		ApexPages.standardController controller6 = new ApexPages.standardController(invoice6);
		printInvoice printInv6 =  new printInvoice(controller6);
		
		Test.stopTest();
	}
	
	
	
	
	
}