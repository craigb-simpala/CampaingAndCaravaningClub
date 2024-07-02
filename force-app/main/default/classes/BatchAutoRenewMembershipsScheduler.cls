global class BatchAutoRenewMembershipsScheduler implements Schedulable {
  global void execute(SchedulableContext sc) {
    BatchAutoRenewMemberships Batch = new BatchAutoRenewMemberships();
    ID batchProcessId = Database.executeBatch(Batch);
  }
}