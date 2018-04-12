global class SLXNZInvoiceBatchSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {
		//SLX NZ Invoice Batch
        String[] periods = new list<String> {'Today', '3 Day', '5 Day', '9 Day', '13 Day'};
        
        for(string period : periods) {
		    batchInvoiceCreateBatch batch = new batchInvoiceCreateBatch(period, 'SponsoredLinX New Zealand');
		    ID batchprocessid = Database.executeBatch(batch, 10);
		    System.debug(batch);
		    System.debug(batchprocessid);
		}
	}
	
}