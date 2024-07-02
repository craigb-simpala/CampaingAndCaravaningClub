global class BatchCRFix implements Database.Batchable<sObject> { 
    
    global String QUERY = 'select id,name,createddate,account.FreeSections__c,account.renewal_date__c,account.Payment_Method2__c,(select id,recordtypeid,Product__c,product__r.viclass__c, Product__r.SectionsAreFree__c from Line_Items__r ) from Opportunity where createddate=LAST_N_DAYS:5 and stagename=\'Due\''; 
    
    global Database.QueryLocator start(Database.BatchableContext BC) {

        return Database.getQueryLocator(QUERY);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> opps) {

        Map<id,Club_Product__c> cpMap = new Map<id,Club_Product__c>([select id,name,Product_Detail__c, SectionsAreFree__c, Renewable__c,viclass__c,recordtypeid,(select Price__c,start_date__c,end_date__c, Payment_Type__c from Prices__r order by Start_Date__c) from club_product__c ]);

		List<Club_Opportunity_Product__c> coptoupdate = new List<Club_Opportunity_Product__c>();

        constants sc = new constants();
	
        for(Opportunity o : opps) {
            Decimal OppPrice = 0;
			id mtprod;
            for(Club_Opportunity_Product__c c : o.Line_Items__r) {
            	if(c.recordtypeid==sc.mtsectRecordTypeId){
                	mtprod = c.product__c;
                }
            }

            for(Club_Opportunity_Product__c c : o.Line_Items__r) {
	            Decimal Price=0;
	            id prodtoget = c.product__c;

                for(Price__c p:cpMap.get(prodtoget).Prices__r){
                    if(p.Start_Date__c<=o.account.renewal_date__c && (p.end_date__c>= o.account.renewal_date__c || p.end_date__c==null) && ((c.recordtypeid==sc.mtsectRecordTypeId && o.account.Payment_Method2__c == p.Payment_Type__c) || c.recordtypeid==sc.amsectRecordTypeId || c.recordtypeid == sc.cpsectRecordTypeId)){
                        if(c.recordtypeid==sc.mtsectRecordTypeId || c.recordtypeid==sc.amsectRecordTypeId){
                        	system.debug('Membership or Associate Type');
                        	Price = p.Price__c;
                        	
                        }
                        else if((o.account.FreeSections__c != true && cpMap.get(mtprod).SectionsAreFree__c != true) && c.recordtypeid!=sc.mtsectRecordTypeId){
                        	system.debug('Non-free Section');
                        	Price = p.Price__c;
                        }
                       	else if((o.account.FreeSections__c == true || cpMap.get(mtprod).SectionsAreFree__c == true) && c.recordtypeid!=sc.mtsectRecordTypeId){
                       		 system.debug('Free Section');
                       		 Price = 0;
                       	}
                    }
                }
                OppPrice += Price; 
                c.Price__c = price;
                coptoupdate.add(c);
				
            }
            o.Amount = oppPrice;     	
        }
        
        update opps;
        update coptoupdate;

    	
    }


    global void finish(Database.BatchableContext BC) {}
    
}