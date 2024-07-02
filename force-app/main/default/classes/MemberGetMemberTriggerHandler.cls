public with sharing class MemberGetMemberTriggerHandler  extends TriggerHandler{

    public MemberGetMemberTriggerHandler(){
        preventRecursiveTrigger(false);
    }

    public override void afterInsert(List<SObject> newObjects, Map<Id,SObject> newMap){
    
        List<Member_Get_Member__c> newRecords = (List<Member_Get_Member__c>) newObjects;
        Set<id> accountids = new Set<id>();
        Set<id> mgmIds = new Set<id>();
        constants c = new constants();
        List<Correspondence__c> corrList = new List<Correspondence__c>();
        
        for(Member_Get_Member__c cn:newRecords){
            accountids.add(cn.Introduced_Membership__c);
            mgmIds.add(cn.Id);     
        }
            
        Map<id,Account> accMap = new Map<id,Account>([select id, Renewal_Date__c, BillingStreet, BillingCountry, Payment_Method2__c, BillingState, Organisation_Name__c, BillingPostalCode, BillingCity, (Select Id, Salutation,FirstName,LastName from Contacts where RecordTypeId = :c.leadContactRecordTypeId ) FROM Account WHERE Id in :accountids]);
        List<Member_Get_Member__c> mgmList = new List<Member_Get_Member__c>([SELECT Id, Existing_Member__c, Existing_Member__r.Salutation,Existing_Member__r.FirstName, Existing_Member__r.AccountId,
                                                                        Existing_Member__r.LastName, Existing_Member__r.Account.BillingStreet, Existing_Member__r.Account.BillingCountry,
                                                                        Existing_Member__r.Account.BillingState, Existing_Member__r.Account.Organisation_Name__c,
                                                                        Existing_Member__r.Account.BillingCity, Existing_Member__r.Account.BillingPostalCode
                                                                         FROM  Member_Get_Member__c WHERE Id = : mgmIds]);
        for(Member_Get_Member__c cn:newRecords){ 
            //if(cn.RecordTypeId == c.associateContactRecordTypeId){
                Correspondence__c corr = new Correspondence__c();
                corr.Correspondence_Type__c = 'Member Get Member';
                corr.Correspondence_date__c =  system.today();
                corr.Lead_Member__c = cn.Existing_Member__c;
                //corr.Renewal_Date__c = accMap.get(cn.AccountId).Renewal_Date__c;
                corr.Gift_Code__c = cn.Gift__c;
                if(mgmList.size() > 0){
                    //system.debug(mgmList.get(cn.Introduced_Membership__r.Id).Contacts);
                    for(Member_Get_Member__c lc: mgmList){
                        if(lc.Id == cn.Id){
                            corr.Lead_Member_Salutation__c =  lc.Existing_Member__r.Salutation;
                            corr.Lead_Member_First_Name__c =  lc.Existing_Member__r.FirstName;
                            corr.Lead_Member_Last_Name__c =  lc.Existing_Member__r.LastName;    
                            corr.MGM_Street__c = lc.Existing_Member__r.Account.BillingStreet;
                            corr.MGM_Country__c = lc.Existing_Member__r.Account.BillingCountry;
                            corr.MGM_County__c = lc.Existing_Member__r.Account.BillingState;
                            corr.MGM_Organisation_Name__c = lc.Existing_Member__r.Account.Organisation_Name__c;
                            corr.MGM_Postcode__c = lc.Existing_Member__r.Account.BillingPostalCode;
                            corr.MGM_Town_City__c = lc.Existing_Member__r.Account.BillingCity;   
                            corr.Membership__c = lc.Existing_Member__r.AccountId; 
                            //corr.Payment_Method__c = accMap.get(lc.Existing_Member__r.AccountId).Payment_Method2__c;                                                                    
                    }
                }
                if(accMap.size() > 0){
                   // system.debug(accMap.get(cn.AccountId).Contacts);
                   /* for(Account am: accMap.get(cn.AccountId)){
                        corr.MGM_Street__c = am.BillingStreet;
                        corr.MGM_Country__c = am.BillingCountry;
                        corr.MGM_County__c = am.BillingState;
                        corr.MGM_Organisation_Name__c = am.Organisation_Name__c;
                        corr.MGM_Postcode__c = am.BillingPostalCode;
                        corr.MGM_Town_City__c = am.BillingCity;
                        
                        
                    }*/
                }
        
                if((cn.Gift__c).contains('Voucher')){
                    corr.Voucher_Expiry_Date__c = system.today().addMonths(18);
                }
                corrList.add(corr);
            }      
        }
        
        insert corrList;

    }

}