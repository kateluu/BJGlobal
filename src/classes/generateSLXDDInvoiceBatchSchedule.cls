global class generateSLXDDInvoiceBatchSchedule  implements Schedulable {

	global void execute(SchedulableContext sc) {
		SLXDDInvoiceBatch batch = new SLXDDInvoiceBatch('Today');
		ID batchId = Database.executeBatch(batch, 10);
		System.debug(batch);
		System.debug(batchId);

	}
}