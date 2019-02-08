global class Statement {
	public Account acc {get;set;}
	public Invoice__c invoice1 {get; set;}
	public Invoice__c invoice2 {get; set;}
	public List<TransactionWrapper> transactions {get; set;} 
	public Decimal due {get;set;}
	public Decimal total_amount {get; set;}
	public Decimal total_paid {get; set;}
	public Decimal total_credit {get; set;}
	public Decimal total_paid_by_client {get; set;}
	public Decimal total_refund {get; set;}
	
	public Statement(ApexPages.StandardController controller){
		Account a = (Account)controller.getRecord();
		this.acc = [select Id, Name, Unique_Id__c from Account where Id=:a.Id];
		invoice1 = new Invoice__c();
		invoice2 = new Invoice__c();
	}
	
	public void showResult(){
		transactions = new List<TransactionWrapper>();
		total_amount = 0;
		total_paid = 0;
		due = 0;
		total_credit = 0;
		total_paid_by_client = 0;
		total_refund = 0;
		
		List<Invoice__c> invoices = new List<Invoice__c>();
		Date invoice_from = this.invoice1.Issue_Date__c;
		
		Transaction__c opening = new Transaction__c();
		opening.Activity__c          = 'Opening Balance';
		opening.Due__c               = 0;
		try{
			if(this.invoice1.Issue_Date__c==null) invoice_from = date.newinstance(2012, 7, 1);
			invoices = [Select 
							Id, 
							Amount_Due__c 
						from 
							Invoice__c 
						where 
							Account__c =:acc.Id 
						and 
							(Status__c = 'AUTHORISED' or Status__c = 'PARTIALLY PAID' or Status__c = 'PARTIALLY CREDITED') 
						and 
							Issue_Date__c <: invoice_from
						];
			for(Invoice__c invoice : invoices){
				opening.Due__c += invoice.Amount_Due__c;			
			}
		}catch(Exception e){
			System.debug(e.getMessage());
		}
		opening.Total__c = opening.Due__c;
		TransactionWrapper open = new TransactionWrapper(opening);
		this.transactions.add(open);
		set<String> invList = new set<String>();
		
		try{
			List<Invoice__c> invs = [select 
										Id, 
										CreatedDate, 
										Issue_Date__c, 
										Invoice_Number__c, 
										Reference__c, 
										Due_Date__c,
										Invoice_Total__c 
									from 
										Invoice__c 
									where 
										Account__c =: acc.Id 
									and 
										Issue_Date__c >=: this.invoice1.Issue_Date__c 
									and 
										Issue_Date__c <=: this.invoice2.Issue_Date__c 
									and 
										Status__c != null 
									and 
										Status__c != 'VOID'
									and
										Status__c != 'NO CHARGE'
									];	
			List<Payment__c> payments = [select Id,Payment_Date__c,Payment_Type__c, Invoice_Number__c, Payment_Amount__c, CreatedDate from Payment__c where Account__c =: acc.Id and Payment_Date__c  >=: this.invoice1.Issue_Date__c and Payment_Date__c <=: this.invoice2.Issue_Date__c];
			
			for(Invoice__c inv : invs){
				total_amount += inv.Invoice_Total__c;
				invList.add(inv.Invoice_Number__c+'');
				
				Transaction__c trans = new Transaction__c();
				trans.Link__c        = inv.Id;
				trans.Date__c        = inv.Issue_Date__c;
				trans.Activity__c    = 'Invoice #'+inv.Invoice_Number__c;
				trans.Reference__c   = inv.Reference__c;
				trans.Due_Date__c    = inv.Due_Date__c;
				trans.Total__c       = inv.Invoice_Total__c;
				trans.Due__c         = 0;
				TransactionWrapper transwrapper = new TransactionWrapper(trans);
				this.transactions.add(transwrapper);
			}
			
			for(Payment__c payment : payments){
				Transaction__c trans = new Transaction__c();
				trans.Link__c        = payment.Id;
				trans.Date__c        = payment.Payment_Date__c;
				trans.Due__c         = 0;
				
				if(payment.Payment_Type__c == 'Credit'){
					trans.Activity__c    	= 'Credit Note on Invoice #'+payment.Invoice_Number__c;
					trans.Credit__c 		= payment.Payment_Amount__c;
					total_credit 			+= payment.Payment_Amount__c;
					total_paid 				+= payment.Payment_Amount__c;
				}else if(payment.Payment_Type__c == 'Refund'){
					trans.Activity__c    	= 'Refund on Invoice #'+payment.Invoice_Number__c;
					trans.Refund__c     	= payment.Payment_Amount__c;
					total_refund 			+= payment.Payment_Amount__c;
				}else{
					trans.Activity__c    	= 'Payment on Invoice #'+payment.Invoice_Number__c;
					trans.Payment__c 		= payment.Payment_Amount__c;
					total_paid_by_client 	+=  payment.Payment_Amount__c;
					total_paid 				+= payment.Payment_Amount__c;
				}
				if(!(invList.contains(payment.Invoice_Number__c))){
					opening.Due__c += payment.Payment_Amount__c;
					opening.Total__c += payment.Payment_Amount__c;
					total_amount += payment.Payment_Amount__c;
				}
				TransactionWrapper transwrapper = new TransactionWrapper(trans);
				this.transactions.add(transwrapper);
			}
			
			transactions.sort();
			
			// calcuate balance due after sorting transactions by date desc
			for(TransactionWrapper transwrapper: transactions){
				if(transwrapper.trans.Activity__c == 'Opening Balance'){
					this.due = transwrapper.trans.Due__c;
				} else if(transwrapper.trans.Total__c == null){ //payments
					//if transaction is payment or credit, deduct the amount from due. If it is refund, do nothing.
					if (transwrapper.trans.Activity__c.contains('Credit')) {
						this.due -= transwrapper.trans.Credit__c;
					} else if (transwrapper.trans.Activity__c.contains('Payment')) {
						this.due -= transwrapper.trans.Payment__c;
					}
					transwrapper.trans.Due__c = due;
				} else { //invoices
					this.due += transwrapper.trans.Total__c;
					transwrapper.trans.Due__c = due;
				}
			}
		}catch(Exception e){
			System.debug(e.getMessage());
		}
	}
	
	public PageReference sendEmail(){
		PageReference sendStatement = new pageReference('/apex/SendStatement');
		sendStatement.getParameters().put('acc_id',this.acc.Id);	
 		sendStatement.getParameters().put('acc_name',this.acc.Name);
 		sendStatement.getParameters().put('acc_number',this.acc.Unique_Id__c);
 		sendStatement.getParameters().put('statement_from',String.valueOf(this.invoice1.Issue_Date__c));
 		sendStatement.getParameters().put('statement_to',String.valueOf(this.invoice2.Issue_Date__c));
 		sendStatement.setRedirect(false);
        return sendStatement; 
	}
	
	public PageReference printPDF(){
		PageReference statement = new PageReference('/apex/StatementPDF');
		statement.getParameters().put('acc_id',this.acc.Id);	
 		statement.getParameters().put('acc_name',this.acc.Name);
 		statement.getParameters().put('acc_number',this.acc.Unique_Id__c);
 		statement.getParameters().put('statement_from',String.valueOf(this.invoice1.Issue_Date__c));
 		statement.getParameters().put('statement_to',String.valueOf(this.invoice2.Issue_Date__c));
 		statement.setRedirect(false);
        return statement; 
	}
		
	public static testMethod void testPayment(){
		
		Test.startTest();
		
	    Account acc = new Account(Name ='TestAccount1', username__c='TestAccount1', password__c='TestAccount1', CurrencyIsoCode ='AUD', Phone='78456213',Active__c= true , card_number__c ='3413551010014590', Card_Number_Masked__c ='34XX-XXXX-XXXX-4590' );
	    insert acc;

	    List<Account_Product__c> testProducts = new List<Account_Product__c>();
	    for(Integer i=0;i<1;i++) {                              
	        Account_Product__c item = new Account_Product__c(Name ='Social Engage '+1, Product_Status__c ='Active', Product_Price__c=1000, CurrencyIsoCode ='AUD', Account__c = acc.id , 
	                      recordTypeId =Schema.SObjectType.Account_Product__c.getRecordTypeInfosByName().get('Traditional Products').getRecordTypeId());
	        testProducts.add(item);
	    }
	    insert testProducts; 

		Contact con = new Contact(FirstName='test',LastName='test',Title='Billing',AccountId=acc.id);
		con.MailingStreet='sdfsadfsa\r\ndfsafa\r\nsfsdfsdfs\r\ndfsdfs\r\ndfsdf';
		con.MailingCity='Brisbane';
		con.MailingState='queensland';
		con.MailingPostalCode='4444';
		con.MailingCountry='Australia';
		insert con;
		
		Invoice__c invoice1 = new Invoice__c( Account__c = acc.Id, Account_Product__c = testProducts.get(0).Id, Issue_Date__c = Date.today(), Invoice_Total__c = 10);
		insert invoice1;
		
		Invoice__c invoice2 = new Invoice__c( Account__c = acc.Id, Account_Product__c = testProducts.get(0).Id, Issue_Date__c = Date.today(),Invoice_Total__c = 10);
		insert invoice2;
		
		Invoice__c invoice3 = new Invoice__c( Account__c = acc.Id, Account_Product__c = testProducts.get(0).Id, Issue_Date__c = Date.today().addDays(-2),Invoice_Total__c = 10, Status__c = 'AUTHORISED');
		insert invoice3;
		
		
		Payment__c testpayment1 = new Payment__c( Account__c = acc.Id, Payment_Option__c = 'Eway', Payment_Date__c = Date.today(), Payment_Amount__c = 2.0);
		insert testpayment1;
		
		Payment__c testpayment2 = new Payment__c( Account__c = acc.Id, Payment_Option__c = 'Eway', Payment_Date__c = Date.today().addDays(100), Payment_Amount__c = 2.0);
		insert testpayment2;
		
		
		ApexPages.standardController controller = new ApexPages.standardController(acc);
		Statement statement = new Statement(controller);
		statement.showResult();
		statement.printPDF();
		statement.sendEmail();
		Test.stopTest();
		
	}
}