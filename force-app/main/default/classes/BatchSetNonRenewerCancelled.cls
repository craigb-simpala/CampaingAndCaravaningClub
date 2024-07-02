global class BatchSetNonRenewerCancelled implements Database.Batchable<sObject> { 
    
    global String QUERY = 'SELECT Id FROM Account WHERE  renewal_date__c <= TODAY and membership_status__c = \'Non-Renewer\' '; 
    
    global Database.QueryLocator start(Database.BatchableContext BC) {

        if(Test.isRunningTest()) {
            return Database.getQueryLocator(QUERY + ' LIMIT 200');
        }

        return Database.getQueryLocator(QUERY);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {


        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.optAllOrNone = false; 
        
        constants sc = new constants();
        List<Cancellation__c> cancs = new List<Cancellation__c>();

        for(Account a : scope) {
            Cancellation__c c = new Cancellation__c(Membership__c=a.id); 
            c.Cancellation_Date__c = date.today();
            c.Comments__c = 'Auto Cancelled Non-Renewer';
            c.Stop_Communication__c=true;
            c.Cancellation_Type__c='Cancelled';
            cancs.add(c);
        }

        Database.insert(cancs, dmo);
        
    }
    
    global void finish(Database.BatchableContext BC) {}
}