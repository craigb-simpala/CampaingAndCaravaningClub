global class BatchAutoRenewMemberships implements Database.Batchable<sObject> {
    
	global Database.QueryLocator start(Database.BatchableContext BC) {
		
		Date tomorrow = Date.today().adddays(1);
		String QUERY = 'select id,name,account.name,closedate,accountid,(select id,price__c,product__c,product__r.auto_renew__c,product__r.membership_length__c,product__r.Name,recordtypeid from Line_Items__r) from opportunity where recordtype.name=\'Renewal\' and isclosed=false and iswon=false and amount=0 and stagename=\'Due\' and account.Renewal_Date__c <= :tomorrow AND account.Renewal_Date__c >= LAST_MONTH'; 
		if(Test.isRunningTest()) {
			return Database.getQueryLocator(QUERY + ' LIMIT 200');
		}
		

		return Database.getQueryLocator(QUERY);
	}

    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
		constants sc = new constants();

		Set<Id> accids = new Set<id>();
		
		for(Opportunity o:scope){
			for(Club_Opportunity_Product__c cop:o.line_items__r){
				if(cop.product__r.auto_renew__c){
					system.debug('found opp '+o.id+' product '+cop.product__r.Name);
					accids.add(o.accountid);
				}
			}
		}

		Map<id,Account> acclist = new Map<id,account>([select id,Renewal_Date__c from account where id in :accids]);

		List<Club_Opportunity_Product__c> cprods = [select id, recordtype.name,
													product__c,Member_Section__c,status__c,
													Opportunity__r.accountid 
													from Club_Opportunity_Product__c 
													where Opportunity__r.accountid in :accids
													and status__c = :sc.active];
    
		for(Club_Opportunity_Product__c c:cprods){
			c.status__c = sc.superseded;
		}

        List<Club_Opportunity_Product__c> coplist = new List<Club_Opportunity_Product__c>();

		for(Opportunity o:scope){
			o.StageName = sc.complete;
			for(Club_Opportunity_Product__c cop:o.line_items__r){
				cop.Status__c = sc.active;
				if(cop.product__r.auto_renew__c){
					acclist.get(o.accountid).Membership_Status__c='Paid'; 
                    acclist.get(o.accountid).Membership_Code__c=cop.product__c;
					acclist.get(o.accountid).Renewal_Date__c=acclist.get(o.accountid).Renewal_Date__c.addmonths(Integer.valueof(cop.product__r.membership_length__c));
				}
			}
			coplist.addall(o.line_items__r);
		}

        update acclist.values(); 
        
        update scope; 
        update cprods;
        update coplist; 
	}

    global void finish(Database.BatchableContext BC) {}
    

}