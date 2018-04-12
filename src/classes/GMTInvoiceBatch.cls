// No longer used. Use batchInvoiceCreateBatch.
global class GMTInvoiceBatch implements Database.batchable<Invoice__c>,Database.AllowsCallouts {
  
	private String period = 'Today';
	private String companyName = 'Get More Traffic';
	private String batch_name = '';
	private Boolean batch_exist = false;
	private ID todays_batch_id;
	private Date batch_date = Date.today();

	global GMTInvoiceBatch(String period, String companyName) {
		this.period = period;
		this.companyName = companyName;
		System.debug('Period: ' + period); 

		String companyAbbr = companyName.replace('Get More Traffic', 'GMT').replace('SponsoredLinX', 'SLX').replace('New Zealand', 'NZ');

		this.batch_name = companyAbbr + ' ' + DateTime.now().format('EEEE yyyy-MM-dd') + ' ' + this.period + ' Invoice Batch';
		System.debug('Batch Name: ' + this.batch_name);

		try {
			List<Invoice_Batch__c> todaysbatch = [SELECT Id FROM Invoice_Batch__c WHERE name =: this.batch_name AND Batch_Date__c =: this.batch_date];
			System.debug('Todays Batch:' + todaysbatch);
			if (todaysbatch.size() == 0) {
				System.debug('Creating New Invoice Batch');
				Invoice_Batch__c batch = new Invoice_Batch__c();
				batch.name = this.batch_name;
				batch.Batch_Date__c = Date.today();
				batch.Batch_Period__c = this.period;
				System.debug('New Invoice Batch:' + batch);
				insert batch;

				this.todays_batch_id = batch.Id;
			} else {
				this.todays_batch_id = todaysbatch[0].Id;
			}
 
			this.batch_exist = true;
		} catch(Exception e) {
			System.debug('Failed creating a new invoice batch:' + e);
			this.batch_exist = false;
		}
	}

	global Iterable<Invoice__c> start(Database.batchableContext info) {
		return new batchInvoiceCreateIterator(this.period, this.companyName);
	}

	global void execute(Database.batchableContext info, List<Invoice__c> scope) {
		System.debug('Scope: ' + scope);
		System.debug('Batch Exist: ' + this.batch_exist);

		if(this.batch_exist == true) {
			List<Invoice__c> newBatchInvoices = new List<Invoice__c>();
			for(Invoice__c inv : scope){
				List<Signup_Payments__c> payments = [SELECT Id FROM Signup_Payments__c WHERE Name =: inv.Invoice_Number__c];
				if(payments.size() == 0) {
					if (inv.Invoice_Number__c != null) { //strip out repeating templates
						String paymentOption		= '';
						String paymentMethod		= '';
						inv.Invoice_Batch__c = this.todays_batch_id;
						try {
							
							Account_Product__c accountproduct = [SELECT Payment_Option__c, Id FROM Account_Product__c WHERE Id =: inv.Account_Product__c][0];
							paymentOption = accountproduct.Payment_Option__c;
							
							inv.Payment_Batch__c = null;
							inv.Processed__c = false;
							paymentMethod = 'Ready For Payment';
							inv.Payment_Response__c = '';
							inv.Payment_Message__c = '';
							
							
						} catch(Exception e) {
							paymentOption = 'Unknown';
							paymentMethod = 'Unable to attach Payment Option';
						}
						inv.Payment_Option__c	= paymentOption;
						inv.Process_Message__c 	= paymentMethod;
						newBatchInvoices.add(inv);
					}
				}
			}
			System.debug('Inserting batch of invoices');
			update newBatchInvoices;
		}
	}

	global void finish(Database.batchableContext info){
		Invoice_Batch__c todaysBatch;
		List<Invoice_Batch__c> todaysBatches = [SELECT Id,Name,Batch_Date__c,Batch_Number__c,Batch_Processed__c,status__c,Batch_Type__c FROM Invoice_Batch__c WHERE Batch_Type__c = 'Invoices' and Batch_Date__c =: Date.today() and Name =: this.batch_name];
		if(todaysBatches.size() > 0) {
			todaysBatch = todaysBatches[0];
			todaysBatch.status__c = 'Batch Approved';
			update todaysBatch;
		}
	}
}