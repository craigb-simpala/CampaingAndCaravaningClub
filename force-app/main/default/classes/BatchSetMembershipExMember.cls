global class BatchSetMembershipExMember implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        Date LastYear = Date.today().addyears(-1);
        String QUERY = 'select id,name from Account where Renewal_Date__c < :LastYear and (Membership_Status__c = \'Cancelled\' OR Membership_Status__c = \'Lapsed\' OR Membership_Status__c = \'DD Mandate Rejected\' OR Membership_Status__c = \'DD Payment Rejected\' ) ' ;
        
        if(Test.isRunningTest()) {
            return Database.getQueryLocator(QUERY + ' LIMIT 200');
        }
        
        return Database.getQueryLocator(QUERY);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {

        for(Account a : scope) {
            a.Membership_Status__c = 'Ex-Member';
        }
        
        update scope;

    }

    global void finish(Database.BatchableContext BC) {}

}