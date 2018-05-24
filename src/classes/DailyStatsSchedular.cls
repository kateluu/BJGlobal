global class DailyStatsSchedular implements Schedulable{
	global void execute(SchedulableContext SC) {
		DailyStats kpi = new DailyStats();
		Id batchJobId = Database.executeBatch(new AccountProductProcessor(''), 200);
	}
	
}