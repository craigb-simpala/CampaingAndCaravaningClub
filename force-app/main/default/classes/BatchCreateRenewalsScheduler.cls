global class BatchCreateRenewalsScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		BatchCreateRenewals Batch = new BatchCreateRenewals();
		ID batchProcessId = Database.executeBatch(Batch);
	}
}