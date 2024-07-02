global class BatchCreateDDTransactionsScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		BatchCreateDDTransactions Batch = new BatchCreateDDTransactions();
		ID batchProcessId = Database.executeBatch(Batch);
	}
}