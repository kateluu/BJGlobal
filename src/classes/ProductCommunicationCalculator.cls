global class ProductCommunicationCalculator implements Schedulable {
    global void execute(SchedulableContext sc) {        
        Id batchJobId = Database.executeBatch(new AccountProductProcessor(''), 100);
    }
}