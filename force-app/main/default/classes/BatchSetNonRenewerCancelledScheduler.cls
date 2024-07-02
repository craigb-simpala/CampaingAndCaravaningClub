global class BatchSetNonRenewerCancelledScheduler implements Schedulable {
  global void execute(SchedulableContext sc) {
    BatchSetNonRenewerCancelled Batch = new BatchSetNonRenewerCancelled();
    ID batchProcessId = Database.executeBatch(Batch);
  }
}