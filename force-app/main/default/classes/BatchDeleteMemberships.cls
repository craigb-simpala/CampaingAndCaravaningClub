global class BatchDeleteMemberships implements Database.Batchable<sObject> {
	
	//global String QUERY =  'select id,name  from Account where Renewal_Date__c < :twoYearsOld ';
    
	global Database.QueryLocator start(Database.BatchableContext BC) {

		
		Date twoYearsOld = Date.today().addDays(- 730);
		String QUERY = 'select id,name  from Account where Renewal_Date__c < :twoYearsOld' ;
		system.debug(QUERY + ' LIMIT 200');
		
		if(Test.isRunningTest()) {
			return Database.getQueryLocator(QUERY + ' LIMIT 200');
		}
		
		system.debug('QUERY twoYearsOld '+QUERY + ' ' + twoYearsOld);
		return Database.getQueryLocator(QUERY);
	}

    global void execute(Database.BatchableContext BC, List<Account> scope) {
		constants sc = new constants();

		Set<Id> accids = new Set<id>();

        for(Account o : scope) {
        	accids.add(o.Id);
        }
        
       List<Contact> memlist = new List<Contact>([select id,account.Renewal_Date__c, RecordTypeId, Salutation,FirstName,LastName, Post_nominal_Letters__c, Date_Joined__c from Contact where accountId in :accids and (RecordTypeId = :sc.leadContactRecordTypeId OR RecordTypeId = :sc.secondaryContactRecordTypeId)]);
       List<Opportunity> opplist = new List<Opportunity>([select id,account.Renewal_Date__c, RecordTypeId, StageName from Opportunity  where accountId in :accids]);
       List<Payment_Method__c> paymentlist = new List<Payment_Method__c>([select id,Membership__r.Renewal_Date__c, RecordTypeId from Payment_Method__c  where Membership__c in :accids]);
       List<Correspondence__c> correslist = new List<Correspondence__c>([select id,Membership__r.Renewal_Date__c from Correspondence__c  where Membership__c in :accids]);
        
       
		
		system.debug(opplist);
		system.debug(paymentlist);
		system.debug(correslist);
		system.debug(memlist);
		system.debug(accids);
		
		delete memlist;
		delete opplist;
		delete correslist;
		delete paymentlist;
		delete scope;
    }

    global void finish(Database.BatchableContext BC) {}
    

}

/* // Initialize setup variables
			String objectName = 'Contact';  // modify as needed
			String query = 'SELECT';
			Map<String, Schema.SObjectField> cobjectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
			
			// Grab the fields from the describe method and append them to the queryString one by one.
			for(String s : cobjectFields.keySet()) {
			   query += ' ' + s + ', ';
			}
			
			// Manually add related object's fields that are needed.
			query += 'Account.Name,'; // modify as needed
			
			// Strip off the last comma if it exists.
			if (query.subString(query.Length()-1,query.Length()) == ','){
			    query = query.subString(0,query.Length()-1);
			}
			
			// Add FROM statement
			query += ' FROM ' + objectName;
			
			// Add on a WHERE/ORDER/LIMIT statement as needed
			query += '  accountId in :accids and (RecordTypeId = :sc.leadContactRecordTypeId OR RecordTypeId = :sc.secondaryContactRecordTypeId)'; // modify as needed
			  
			try {
			        memlist = new Map<id,Contact>(query);
			} catch (QueryException e){
			        //perform exception handling
			}
        
        
        
		system.debug(memlist);
		
		Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap();
		system.debug(objectFields);
		for(Contact c:memlist.values())
		{
			
	    	for(String s : objectFields.keySet()) {
	    		if(s != 'salutation')
	    			if( s!= 'firstName')
	    				if( s !='lastName')
	    					if( s !='post_nominal_letters__c')
	    						if( s != 'date_joined__c') {
					    			//TODO set the field to null
					    			system.debug('In if '+ s + ' ' + c.get(s));
					    			//c.set(s) = null;
	    		}
	    	}
		}
		*/