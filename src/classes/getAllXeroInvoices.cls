global class getAllXeroInvoices implements Database.batchable<sfxero.XeroInvoice>,Database.AllowsCallouts {
	public static boolean isTest = false;
	global final Boolean batchCreated;
	global final Integer TotalBatchRecords;
	global final ID TodaysBatchID;
	global final Integer scriptLimit = 50;
	getNextXeroInvoice invoicecls = new getNextXeroInvoice();
	
	global getAllXeroInvoices(){
		
		Invoice_Batch__c batch = new Invoice_Batch__c();
    	batch.name = DateTime.now().format('EEEE') + ' Invoice Batch';
    	batch.Batch_Date__c = Date.today();
	 	if(this.invoicecls.records()>0) {
			batch.status__c = 'New Batch';
    	} else {
    		System.debug('Xero API returned no invoices');
    		batch.status__c = 'Empty Batch';
    	}
    	batch.Batch_Records__c = this.invoicecls.records();
    	insert batch;
    	this.batchCreated = true;
    	this.TodaysBatchID = batch.id;
    	this.TotalBatchRecords = this.invoicecls.records();
	 }

	 global Iterable<sfxero.XeroInvoice> start(Database.batchableContext BC){	 	
		return new xeroInvoiceIterator();
	 }
	 
	 global void execute(Database.BatchableContext BC, List<sfxero.XeroInvoice> scope){
	 	System.debug('Scope:'+scope);
	 	System.debug('batchCreated:'+this.batchCreated);
	 	System.debug('TodaysBatchID:'+TodaysBatchID);
	 	
		if(this.batchCreated==true) {
			//sfxero.XeroInvoice inv;			
			List<Invoice__c> newBatchInvoices = new List<Invoice__c>();
			//for(Integer i = 0; i < this.scriptLimit; i++) {
			for(sfxero.XeroInvoice inv : scope){
	 			//inv = scope[0];
	 			List<Signup_Payments__c> payments = [SELECT Id FROM Signup_Payments__c WHERE Name=:inv.InvoiceNumber];
	 			if(payments.size() == 0) {
		        	if (inv.InvoiceNumber!=null) { //strip out repeating templates
			        	System.debug('XERO Invoice: '+inv);
			        	Invoice__c newinv = new Invoice__c(); 
			        	newinv.Invoice_Batch__c     = this.TodaysBatchID;
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
			        	String paymentOption = '';
			        	String paymentMethod = '';
	
						//List<Invoice_Exclude__c> invoices_exclude;
						//invoices_exclude = [SELECT Id, Invoice_Number__c FROM Invoice_Exclude__c WHERE Invoice_Number__c =: inv.InvoiceNumber];
						//if(invoices_exclude.size() > 0) {
						//	newinv.Exclude_Invoice__c = true;
						//}
	
			        	try {
			        		Account account = [SELECT Payment_Option__c FROM Account WHERE Xero_Sync_ID__c=:inv.Contact.ContactID][0]; 
			        		newinv.Account__c = account.Id;
			        		paymentOption = account.Payment_Option__c;	
			        		paymentMethod = 'Ready For Payment';
			        	}catch(Exception e) {
			        		paymentOption = 'Unknown';
			        		paymentMethod = 'Unable to attach Payment Option';
			        	}
			        	newinv.Payment_Option__c	= paymentOption;
			        	newinv.Process_Message__c 	= paymentMethod;
			        	System.debug('SF New Invoice: '+newinv);
			        	//insert newinv;
			        	newBatchInvoices.add(newinv);
		        	}
	 			}		
	        }
	        System.debug('Inserting batch of invoices');
	        insert newBatchInvoices;
		}
	 }
	 
	 global void finish(Database.BatchableContext BC){
	 	String batchName = DateTime.now().format('EEEE') + ' Invoice Batch';
		Invoice_Batch__c todaysBatch;
		List<Invoice_Batch__c> todaysBatches = [SELECT Id,Name,Batch_Date__c,Batch_Number__c,Batch_Processed__c,status__c,Batch_Type__c FROM Invoice_Batch__c WHERE Batch_Type__c = 'Invoices' and Batch_Date__c =: Date.today() and Name=:batchName];
		if(todaysBatches.size() > 0) {
			todaysBatch = todaysBatches[0];
		 	todaysBatch.status__c = 'Pending Approval';
		    update todaysBatch;
		}
	 }
	 global class xeroInvoiceIterator implements Iterable<sfxero.XeroInvoice> {
	   global Iterator<sfxero.XeroInvoice> iterator(){
	      return new getNextXeroInvoice();
	   }
	}
	 public static testMethod void testBatch() {
	 	Test.startTest();
	 	getAllXeroInvoices.isTest = true;
	 	getNextXeroInvoice.isTest = true;
		getAllXeroInvoices scriptBatch = new getAllXeroInvoices();
		ID batchprocessid = Database.executeBatch(scriptBatch);
		Test.stopTest();
	 }	
}