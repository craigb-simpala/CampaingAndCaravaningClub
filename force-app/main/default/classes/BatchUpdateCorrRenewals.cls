global class BatchUpdateCorrRenewals implements Database.Batchable<sObject> { 
    
    global String QUERY = 'select id,name,createddate,Amendment_Renewal__c,amendment_renewal__r.accountid from correspondence__c where correspondence_type__c=\'Renewal\' and Amendment_Renewal__c!=null and createddate=LAST_N_DAYS:5'; 
    
    global Database.QueryLocator start(Database.BatchableContext BC) {

        return Database.getQueryLocator(QUERY);
    }
    
    global void execute(Database.BatchableContext BC, List<Correspondence__c> corrs) {

		Set<id> oppids = new set<id>();
		Set<id> accountids = new Set<id>();

		constants sc = new constants();


		for (correspondence__c c: corrs){
			oppids.add(c.Amendment_Renewal__c);
			accountids.add(c.Amendment_Renewal__r.accountid);
		}


		Map<id,Account> leadAccMap = new Map<id,Account>([select id, Renewal_Date__c, (Select Id, Salutation,FirstName,LastName, Youth_Test_Passed_Date__c, Tenure2__c,RecordTypeId,status__c,date_ended__c  from Contacts where  RecordTypeId = :sc.leadContactRecordTypeId AND Status__c = 'Active')  FROM Account WHERE Id in :accountids]);

		Map<id,Account> secAccMap = new Map<id,Account>([select id, Renewal_Date__c, (Select Id, Salutation,FirstName,LastName, Youth_Test_Passed_Date__c, Tenure2__c,RecordTypeId,status__c,date_ended__c  from Contacts where  RecordTypeId = :sc.secondaryContactRecordTypeId AND Status__c = 'Active')  FROM Account WHERE Id in :accountids]);

		Map<id,Account> assAccMap = new Map<id,Account>([select id, Renewal_Date__c, (Select Id, Salutation,FirstName,LastName, Youth_Test_Passed_Date__c, Tenure2__c,RecordTypeId,status__c,date_ended__c  from Contacts where  RecordTypeId = :sc.associateContactRecordTypeId AND Status__c = 'Active')  FROM Account WHERE Id in :accountids]);


 		Map<id,Opportunity> purchasedProductList = new Map<id,Opportunity>([SELECT Id , (select id, Hybrid_Membership_Number__c, Member_Section__c,
        									                                			Non_Renewer_flag__c, Opportunity__c, 
                                        												Member_Section__r.name, account__r.Renewal_Date__c,
                                        												Product__c, product__r.Name, Price__c, 
                                        												account__r.Membership_Code__c, Status__c,recordtypeid
                                        												from Line_Items__r)
                                        									FROM Opportunity
                                        									WHERE  Id IN :oppIds]);

		for(correspondence__c corr: corrs){

    		corr.date_processed__c=null;
    
    		string sections='';
    		decimal memprice=0;
    		decimal secprice=0;
    		decimal assprice=0;

        	for(Club_Opportunity_Product__c cop : purchasedProductList.get(corr.Amendment_Renewal__c).Line_Items__r){

				if(cop.recordtypeid==sc.cpsectRecordTypeId){sections+=cop.product__r.Name+' ';secprice+=cop.Price__c;}
				if(cop.recordtypeid==sc.mtsectRecordTypeId){corr.Renewal_Product_Code__c=cop.product__r.Name;memprice+=cop.Price__c;}
				if(cop.recordtypeid==sc.amsectRecordTypeId){assprice+=cop.Price__c;}
			}

			system.debug(corr.name+'---'+corr.amendment_renewal__r.accountid);
			system.debug('mem price---'+memprice);
			system.debug('sec price---'+secprice);
			system.debug('as price---'+assprice);

			corr.Associate_Member_Fee__c = assprice;
			corr.Sections_fee__c = secprice;corr.Sections__c=sections;
			corr.Membership_Subscription_Fee__c = memprice;
			corr.Total_Fee__c = memprice+secprice+assprice;

			for(Contact lc: leadAccMap.get(corr.Amendment_Renewal__r.AccountId).Contacts){
    			if(lc.status__c=='Active'){
					corr.Lead_Member__c = lc.Id;
/*                    corr.Lead_Member_Salutation__c =  lc.Salutation;
                    corr.Lead_Member_First_Name__c =  lc.FirstName;
                    corr.Lead_Member_Last_Name__c =  lc.LastName;
                    corr.Youth_Test_Passed_Date__c = lc.Youth_Test_Passed_Date__c;
*/
                    corr.Renewal_Date__c = leadAccMap.get(corr.Amendment_Renewal__r.AccountId).Renewal_Date__c.addmonths(12);
                    if(lc.Tenure2__c == null){
                        corr.Tenure__c =1;
                    } else {
                        corr.Tenure__c = lc.Tenure2__c+1;
                    }
                }
			}

			for(Contact sec: secAccMap.get(corr.Amendment_Renewal__r.AccountId).Contacts){
    			if(sec.status__c=='Active'){
					corr.Secondary_Member__c =  sec.Id;
/*                        corr.Second_Member_Salutation__c =  sc.Salutation;
                        corr.Second_Member_First_Name__c =  sc.FirstName;
                        corr.Second_Member_Last_Name__c =  sc.LastName;
*/
					if(sec.Tenure2__c == null ){
						corr.Tenure_Secondary__c = 1;
					} else {
						corr.Tenure_Secondary__c = sec.Tenure2__c+1;
					}
				}
			}

			for(Contact sec: assAccMap.get(corr.Amendment_Renewal__r.AccountId).Contacts){
				if(sec.status__c=='Active'){
					corr.Associate_Member__c =  sec.Id;
				}
			}
		}
		update corrs;        
    }
    
    global void finish(Database.BatchableContext BC) {}
}