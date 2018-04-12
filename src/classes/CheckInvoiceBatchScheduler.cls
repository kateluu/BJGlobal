global class CheckInvoiceBatchScheduler implements Schedulable{
	global void execute(SchedulableContext SC) {
		String[] periods = new list<String> {'Today', '3 Day', '5 Day', '9 Day', '13 Day'};
		String[] prefixes = new list<String> {'SLX', 'SLX NZ', 'GMT', 'GMT NZ'};
		String emailBody = '';
		
		for (String period : periods) {
			for (String prefix : prefixes) {
				// Invoice batch
				String batchName = prefix + ' ' + DateTime.now().format('EEEE yyyy-MM-dd') + ' ' + period + ' Invoice Batch';
				Invoice_Batch__c[] batch = [SELECT Id FROM Invoice_Batch__c WHERE name =: batchName AND Batch_Date__c = Today AND status__c = 'Batch Approved' LIMIT 1];
				if(batch.size() == 0) {
					emailBody += prefix + ' ' + period + ' Invoice batch failed.<br>';
				}
				
				// Payment batch
				batchName = prefix + ' ' + DateTime.now().format('EEEE yyyy-MM-dd') + ' ' + period + ' Payment Batch';
				batch = [SELECT Id FROM Invoice_Batch__c WHERE name =: batchName AND Batch_Date__c = Today LIMIT 1];
				if(batch.size() == 0) {
					emailBody += prefix + ' ' + period + ' Payment batch failed.<br>';
				}
			}
		}
		
		if(emailBody.length() > 0) {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = new String[] { 'devteam@sponsoredlinx.com' };
			mail.setToAddresses(toAddresses);
			mail.setSenderDisplayName('InvoiceBatch ERROR');
			mail.setSubject('InvoiceBatch Failed!');
			mail.setUseSignature(false);
			mail.setHtmlBody(emailBody);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
	}
}