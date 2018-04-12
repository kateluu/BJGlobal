global class automaticallyApproveBatch implements Schedulable {

    global void execute(SchedulableContext sc) {
        Date batchdate = Date.today();

        try {
            List<Invoice_Batch__c> todaysBatches = [SELECT Id,Name,Batch_Date__c,Batch_Number__c,Batch_Processed__c,status__c,Batch_Type__c FROM Invoice_Batch__c WHERE Batch_Type__c = 'Invoices' and Batch_Processed__c = 'No' and Batch_Date__c =: Date.today()];
            System.debug('todaysBatches: ' + todaysBatches);
            if (todaysBatches.size() > 0) {
                for(Invoice_Batch__c batch : todaysBatches) {
                    batch.status__c = 'Batch Approved';
                }
                update todaysBatches;
            } else {
                System.debug('There were no pending batches to approve this time');
            }
        } catch(Exception e) {
            System.debug('Exception: '+e);
        }
    }

    public static testMethod void automaticallyApproveBatchTest() {
        Test.startTest();
        
        Invoice_Batch__c batch = new Invoice_Batch__c();
        batch.Name = DateTime.now().format('EEEE') + ' Invoice Batch';
        batch.Batch_Date__c = Date.today();
        batch.status__c = 'New Batch';
        batch.Batch_Type__c = 'Invoices';
        batch.Batch_Processed__c = 'No';

        insert batch;

        datetime time1 = Datetime.now();
        datetime time2 = time1.addSeconds(5);
        String seconds = String.valueOf(time2.second());
        String minutes = String.valueOf(time2.minute());
        String hours = String.valueOf(time2.hour());

        String sch = seconds + ' ' + minutes + ' ' + hours + ' ? * MON-SUN';
        System.debug('sch:'+sch);
        System.schedule('automaticallyApproveBatchTest', sch, new automaticallyApproveBatch());
        
        Test.stopTest();
    }
}