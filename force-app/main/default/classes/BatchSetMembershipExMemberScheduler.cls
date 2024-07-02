global class BatchSetMembershipExMemberScheduler implements Schedulable {
  global void execute(SchedulableContext sc) {
    BatchSetMembershipExMember Batch = new BatchSetMembershipExMember();
    ID batchProcessId = Database.executeBatch(Batch);
  }
}