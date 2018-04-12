global class batchXeroInvoiceCreateBatch implements Database.batchable<sfxero.XeroInvoice>,Database.AllowsCallouts {

	private String period = 'Today';
	private String batch_name = '';
	private Boolean batch_exist = false;
	private ID todays_batch_id;
	private Date batch_date = Date.today();

	global batchXeroInvoiceCreateBatch(String period) {
		this.period = period;
		System.debug('Period: ' + period);

		this.batch_name = DateTime.now().format('EEEE yyyy-MM-dd') + ' ' + this.period + ' Invoice Batch';
		System.debug('Batch Name: ' + this.batch_name);

		try {
			List<Invoice_Batch__c> todaysbatch = [SELECT Id FROM Invoice_Batch__c WHERE name =: this.batch_name AND Batch_Date__c =: this.batch_date];
			System.debug('Todays Batch:' + todaysbatch);
			if (todaysbatch.size() == 0) {
//				getNextXeroInvoice invoicecls = new getNextXeroInvoice(this.period);
//				System.debug('invoicecls:' + invoicecls);
//				System.debug('Creating New Invoice Batch');
//				Invoice_Batch__c batch = new Invoice_Batch__c();
//				batch.name = this.batch_name;
//				batch.Batch_Date__c = Date.today();
//				if(invoicecls.records() > 0) {
//					batch.status__c = 'New Batch';
//				} else {
//					System.debug('Xero API returned no invoices');
//					batch.status__c = 'Empty Batch';
//				}
//				batch.Batch_Records__c = invoicecls.records();
//				batch.Batch_Period__c = this.period;
//				System.debug('New Invoice Batch:' + batch);
//				insert batch;

	//			this.todays_batch_id = batch.Id;
			} 
				
			else {
				this.todays_batch_id = todaysbatch[0].Id;
			}

			//this.batch_exist = true;
		} catch(Exception e) {
			System.debug('Failed creating a new invoice batch:' + e);
			this.batch_exist = false;
		}
	}

	global Iterable<sfxero.XeroInvoice> start(Database.batchableContext info) {
		return new batchXeroInvoiceCreateIterator(this.period);
	}

	global void execute(Database.batchableContext info, List<sfxero.XeroInvoice> scope) {
		/*
		System.debug('Scope: ' + scope);
		System.debug('Batch Exist: ' + this.batch_exist);

		if(this.batch_exist == true) {
			List<Invoice__c> newBatchInvoices = new List<Invoice__c>();
			for(sfxero.XeroInvoice inv : scope){
				List<Signup_Payments__c> payments = [SELECT Id FROM Signup_Payments__c WHERE Name =: inv.InvoiceNumber];
				if(payments.size() == 0) {
					if (inv.InvoiceNumber != null) { //strip out repeating templates
						System.debug('XERO Invoice: ' + inv);
						Invoice__c newinv			= new Invoice__c();
						newinv.Invoice_Batch__c     = this.todays_batch_id;
						newinv.Xero_Contact_Id__c	= inv.Contact.ContactID;
						newinv.Xero_Invoice_Id__c	= inv.InvoiceID;
						newinv.Name				 	= inv.Contact.OrgName;
						newinv.Invoice_Number__c 	= inv.InvoiceNumber;
						newinv.Reference__c			= inv.Reference;
						newinv.Issue_Date__c		= inv.issuedDate;
						newinv.Due_Date__c			= inv.dueDate;
						newinv.Amount_Credited__c	= inv.AmountCredited;
						newinv.Amount_Due__c		= inv.AmountDue;
						newinv.Amount_Paid__c		= inv.AmountPaid;
						newinv.Invoice_Total__c		= inv.Total;

						String paymentOption		= '';
						String paymentMethod		= '';

						try {
							Account account = [SELECT Payment_Option__c FROM Account WHERE Xero_Sync_ID__c =: inv.Contact.ContactID][0];
							newinv.Account__c = account.Id;
							paymentOption = account.Payment_Option__c;	
							paymentMethod = 'Ready For Payment';
						} catch(Exception e) {
							paymentOption = 'Unknown';
							paymentMethod = 'Unable to attach Payment Option';
						}
						newinv.Payment_Option__c	= paymentOption;
						newinv.Process_Message__c 	= paymentMethod;
						System.debug('SF New Invoice: ' + newinv);
						newBatchInvoices.add(newinv);
					}
				}
			}
			System.debug('Inserting batch of invoices');
			insert newBatchInvoices;
		}
		*/
	}

	global void finish(Database.batchableContext info){
		/*
		Invoice_Batch__c todaysBatch;
		List<Invoice_Batch__c> todaysBatches = [SELECT Id,Name,Batch_Date__c,Batch_Number__c,Batch_Processed__c,status__c,Batch_Type__c FROM Invoice_Batch__c WHERE Batch_Type__c = 'Invoices' and Batch_Date__c =: Date.today() and Name =: this.batch_name];
		if(todaysBatches.size() > 0) {
			todaysBatch = todaysBatches[0];
			todaysBatch.status__c = 'Pending Approval';
			update todaysBatch;
		}
		*/
	}


   	public static testMethod void testBatch() {
		Test.startTest();
		batchXeroInvoiceCreateBatch scriptBatch = new batchXeroInvoiceCreateBatch('Today');
		ID batchprocessid = Database.executeBatch(scriptBatch);
		Test.stopTest();
	}
}