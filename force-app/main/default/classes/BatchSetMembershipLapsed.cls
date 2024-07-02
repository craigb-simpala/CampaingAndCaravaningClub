global class BatchSetMembershipLapsed implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        Date LapsedDate = Date.today().adddays(-56);
        String QUERY = 'select id,name  from Account where Renewal_Date__c < :LapsedDate and Membership_Status__c=\'Paid\'' ;
        
        if(Test.isRunningTest()) {
            return Database.getQueryLocator(QUERY + ' LIMIT 200');
        }
        
        return Database.getQueryLocator(QUERY);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {

        for(Account a : scope) {
            a.Membership_Status__c = 'Lapsed';
        }
        
        update scope;

    }

    global void finish(Database.BatchableContext BC) {
	    BatchSetMembershipExMember Batch = new BatchSetMembershipExMember();
	    ID batchProcessId = Database.executeBatch(Batch);
    }

}