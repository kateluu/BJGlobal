global class xeroInvoiceMigration implements Database.batchable<Xero_Invoice__c>,Database.AllowsCallouts, Database.Stateful {
	
	private Date search_date = Date.today();
	global String emailBody= '';
	
	global xeroInvoiceMigration(Date search_date){
		this.search_date = search_date;
		
	}
	
	global Iterable<Xero_Invoice__c> start(Database.batchableContext info){
		return new xeroInvoiceIterator(this.search_date);
	}
	
	global void execute(Database.batchableContext info, List<Xero_Invoice__c> scope) {
		
		
	}
	
	
	 global void finish(Database.batchableContext info){
	 	
    }


    public static testMethod void testBatch() {
        Test.startTest();
        xeroInvoiceMigration scriptBatch = new xeroInvoiceMigration(Date.today().addDays(-1));
        ID batchprocessid = Database.executeBatch(scriptBatch,10);
        Test.stopTest();
    }
	public class myException extends Exception {}
		
	
	
}