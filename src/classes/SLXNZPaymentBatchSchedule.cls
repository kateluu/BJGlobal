global class SLXNZPaymentBatchSchedule implements Schedulable{
    
    global void execute(SchedulableContext sc) {
        String[] periods = new list<String> {'Today', '3 Day', '5 Day', '9 Day', '13 Day'};
        String[] companies = new list<String> {'SponsoredLinX New Zealand', 'Get More Traffic New Zealand'};
        
        for(string company : companies) {
            for(string period : periods) {
                batchPaymentsProcess batch = new batchPaymentsProcess(period, company);
                ID batchId = Database.executeBatch(batch, 1);
                System.debug(batch);
                System.debug(batchId);
    		}
        }
    }

}