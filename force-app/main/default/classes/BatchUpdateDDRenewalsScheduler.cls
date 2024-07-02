global class BatchUpdateDDRenewalsScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		BatchUpdateDDRenewals Batch = new BatchUpdateDDRenewals();
		ID batchProcessId = Database.executeBatch(Batch);
	}
}