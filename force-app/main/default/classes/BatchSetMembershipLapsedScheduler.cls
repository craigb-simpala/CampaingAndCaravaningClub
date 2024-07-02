global class BatchSetMembershipLapsedScheduler implements Schedulable  {
  global void execute(SchedulableContext sc) {
    BatchSetMembershipLapsed Batch = new BatchSetMembershipLapsed();
    ID batchProcessId = Database.executeBatch(Batch);
  }
}