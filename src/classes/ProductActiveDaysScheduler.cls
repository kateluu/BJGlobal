global class ProductActiveDaysScheduler  implements Schedulable {
	global void execute(SchedulableContext sc) {
		ProductActiveDaysBatch active_days_batch = new ProductActiveDaysBatch();
		ID active_days_batch_id = Database.executeBatch(active_days_batch, 1);
		System.debug(active_days_batch);
		System.debug(active_days_batch_id);
	}

}