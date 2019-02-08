global class StatementPDF {
	public String acc_name {get;set;}
	public String acc_id {get;set;}
	public String acc_number { get;set;}
	public String statement_from { get;set;}
	public String statement_to {get; set;}
	public Date to_date {get; set;}
	public Date from_date {get; set;}
	public List<TransactionWrapper> transactions {get; set;}
	public Decimal due {get;set;}
	public Decimal total_amount {get; set;}
	public Decimal total_paid {get; set;}
	public Decimal total_refund {get; set;}
	public Decimal total_credit {get; set;}
	public Company__c company {get;set;}
	public boolean isNewZealand {set; get;}
		
	public StatementPDF(){
		this.acc_id         = ApexPages.currentPage().getParameters().get('acc_id');
		this.acc_name       = ApexPages.currentPage().getParameters().get('acc_name');
		this.acc_number     = ApexPages.currentPage().getParameters().get('acc_number');
		this.statement_from = ApexPages.currentPage().getParameters().get('statement_from');
		this.statement_to   = ApexPages.currentPage().getParameters().get('statement_to');
		
		Account acc = [select CreatedDate, BJB_Company__r.Name from Account where id = :this.acc_id limit 1];
		if(this.statement_to == null) {
			to_date = Date.today();
		} else {
			to_date = Date.valueOf(this.statement_to);
		}
		if(this.statement_from == null) {
			from_date = acc.CreatedDate.date();
		} else {
			from_date = Date.valueOf(this.statement_from);
		}
		
		total_amount = 0;
		total_paid = 0;
		total_refund = 0;
		total_credit = 0;
		due = 0;
		
//		if(this.acc_name.startsWith('GetMoreTraffic')) {
//			this.company = [select
//                           Id,
//                            Name,
//                            Address__c,
//                            Business_Name__c,
//                            Email__c,
//                            Logo_Code__c,
//                            Phone__c,
//                            ABN__c,
//                            term_page__c,
//                            BSB__c,
//                            Account_Number__c
//                        FROM 
//                        	Company__c
//                        WHERE 
//                        	Name = 'Get More Traffic'
//						];
//		} else {
//			this.company = [select
//                            Id,
//                            Name,
//                            Address__c,
//                            Business_Name__c,
//                            Email__c,
//                            Logo_Code__c,
//                            Phone__c,
//                            ABN__c,
//                            term_page__c,
//                            BSB__c,
//                            Account_Number__c
//                        FROM 
//                        	Company__c
//                        WHERE 
//                        	Name = 'SponsoredLinx'
//						];
//		}
		if(acc.BJB_Company__r.Name != null && acc.BJB_Company__r.Name != ''){
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
                            BSB__c,
                            Account_Number__c
                        FROM 
                        	Company__c
                        WHERE 
                        	Name =: acc.BJB_Company__r.Name
						];
		}else{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'BJB Company field cannot be empty!'));
    	}

		if (acc.BJB_Company__r.Name == 'SponsoredLinX New Zealand'){
			isNewZealand = true;
		} else {
			isNewZealand = false;
		}
		
						
		this.acc_name = this.acc_name.removeStart('GetMoreTraffic - ');			
		
		this.transactions = new List<TransactionWrapper>();
		List<Invoice__c> invoices = new List<Invoice__c>();
		Transaction__c opening = new Transaction__c();
		opening.Activity__c = 'Opening Balance';
		opening.Due__c = 0;
		try{
			invoices = [Select 
							Id, 
							Amount_Due__c 
						from 
							Invoice__c 
						where 
							Account__c =:this.acc_id 
						and 
							(Status__c = 'AUTHORISED' or Status__c = 'PARTIALLY PAID' or Status__c = 'PARTIALLY CREDITED')  
						and 
							Issue_Date__c <: from_date
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
										Account__c =: this.acc_id 
									and 
										Issue_Date__c >=: from_date 
									and 
										Issue_Date__c <=: to_date 
									and 
										Status__c != null 
									and 
										Status__c != 'VOID'
									and
										Status__c != 'NO CHARGE'
									];	
			List<Payment__c> payments = [select Id,Payment_Date__c, Payment_Type__c,Invoice_Number__c, Payment_Amount__c, CreatedDate from Payment__c where Account__c =: this.acc_id and Payment_Date__c  >=: from_date and Payment_Date__c <=: to_date];

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
				}else if(payment.Payment_Type__c == 'Refund'){
					trans.Activity__c    	= 'Refund on Invoice #'+payment.Invoice_Number__c;
					trans.Refund__c     	= payment.Payment_Amount__c;
					total_refund 			+= payment.Payment_Amount__c;
				}else{
					trans.Activity__c    	= 'Payment on Invoice #'+payment.Invoice_Number__c;
					trans.Payment__c 		= payment.Payment_Amount__c;
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
			
			this.transactions.sort();
			
			// calcuate balance due after sorting transactions by date desc
			for(TransactionWrapper transwrapper: this.transactions){
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
		
		Company__c com = new Company__c();
		com.name = 'SponsoredLinx';
		insert com;
				
		Invoice__c invoice1 = new Invoice__c( Account__c = acc.Id, Account_Product__c = testProducts.get(0).Id,Issue_Date__c = Date.today(), Invoice_Total__c = 10);
		insert invoice1;
		
		Invoice__c invoice2 = new Invoice__c( Account__c = acc.Id, Account_Product__c = testProducts.get(0).Id,Issue_Date__c = Date.today(),Invoice_Total__c = 10);
		insert invoice2;
		
		Invoice__c invoice3 = new Invoice__c( Account__c = acc.Id, Account_Product__c = testProducts.get(0).Id,Issue_Date__c = Date.today().addDays(-2),Invoice_Total__c = 10, Status__c = 'AUTHORISED');
		insert invoice3;
		
		
		Payment__c testpayment1 = new Payment__c( Account__c = acc.Id, Payment_Option__c = 'Eway', Payment_Date__c = Date.today(), Payment_Amount__c = 2.0);
		insert testpayment1;
		
		Payment__c testpayment2 = new Payment__c( Account__c = acc.Id, Payment_Option__c = 'Eway', Payment_Date__c = Date.today().addDays(100), Payment_Amount__c = 2.0);
		insert testpayment2;
		
		PageReference statementpdf = ApexPages.currentPage();
		statementpdf.getParameters().put('acc_id',acc.Id);	
 		statementpdf.getParameters().put('acc_name',acc.Name);
 		statementpdf.getParameters().put('statement_from','2012-01-01 00:00:00');
 		statementpdf.getParameters().put('statement_to','2012-09-01 00:00:00');
 		 		
		StatementPDF statement = new StatementPDF();
		statement.statement_from = '2012-01-01';
		statement.statement_to = '2012-01-21';
		
		Test.stopTest();
		
	}

}