global class generateGMTDDInvoiceBatchSchedule  implements Schedulable {
	global void execute(SchedulableContext sc) {
		GMTDDInvoiceBatch batch = new GMTDDInvoiceBatch('Today');
		ID batchId = Database.executeBatch(batch, 10);
		System.debug(batch);
		System.debug(batchId);

	}
}