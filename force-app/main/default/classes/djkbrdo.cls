global class djkbrdo implements Database.Batchable<sObject> {

	global String QUERY = 'select id from opportunity where recordtype.name=\'Renewal\' and stagename=\'Due\' '; 
    
	global Database.QueryLocator start(Database.BatchableContext BC) {

		return Database.getQueryLocator(QUERY);
	}

    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        delete scope; 
    }

    global void finish(Database.BatchableContext BC) {}

}