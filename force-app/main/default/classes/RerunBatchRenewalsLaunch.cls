public class RerunBatchRenewalsLaunch {
	@invocableMethod
    public static void reRunBatch(){
        RerunBatchCreateRenewals Batch = new RerunBatchCreateRenewals();
        ID batchProcessId = Database.executeBatch(Batch);
    }
}