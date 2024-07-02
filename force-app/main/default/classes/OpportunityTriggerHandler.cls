public with sharing class OpportunityTriggerHandler  extends TriggerHandler{

    public OpportunityTriggerHandler(){
        preventRecursiveTrigger(false);
    }

	public override void afterInsert(List<SObject> newObjects, Map<Id,SObject> newMap){
	    Map<ID, Schema.RecordTypeInfo> opprtMap = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
	    Map<ID, Schema.RecordTypeInfo> coprtMap = Schema.SObjectType.Club_Opportunity_Product__c.getRecordTypeInfosById();
	
	    Database.DMLOptions dmo = new Database.DMLOptions();
	    dmo.optAllOrNone = false;

        Set<id> accountids = new Set<id>();
        Set<id> oppids = new Set<id>();
        Map<id, String> accPaymentMethod= new Map<id, String>();
        constants c = new constants();
        List<Correspondence__c> corrList = new List<Correspondence__c>();
		List<Opportunity> newOpps = (List<Opportunity>) newObjects;	       
        
        for(Opportunity cn:newOpps){
            accountids.add(cn.AccountId);
            oppIds.add(cn.Id);    
            accPaymentMethod.put(cn.AccountId, cn.Account.Payment_Method2__c);   
        }
            
        Map<id,Account> leadAccMap = new Map<id,Account>([select id, Renewal_Date__c,Payment_Method2__c, 
        (Select Id, Salutation,FirstName,LastName,Youth_Test_Passed_Date__c,Tenure2__c from Contacts where RecordTypeId = :c.leadContactRecordTypeId )
        FROM Account WHERE Id in :accountids]);
            
        Map<id,Account> secAccMap = new Map<id,Account>([select id, Renewal_Date__c,
        (Select Id, Salutation,FirstName,LastName, Tenure2__c from Contacts where RecordTypeId = :c.secondaryContactRecordTypeId AND Status__c = 'Active') 
        FROM Account WHERE Id in :accountids]);
        
        
        Map<id,Opportunity> purchasedPorductList = new Map<id,Opportunity>([SELECT Id , (select id, Hybrid_Membership_Number__c, Member_Section__c,
                                        Non_Renewer_flag__c, Opportunity__c, Member_Section__r.name, account__r.Renewal_Date__c,
                                        Product__c, product__r.Name, Price__c, account__r.Membership_Code__c, Status__c
                                        from Line_Items__r 
                                        WHERE RecordTypeId = :c.sectionRecordTypeId)
                                        FROM Opportunity
                                        WHERE  Id IN :oppIds]);
        
        List<Correspondence__c> amendCorr = new List<Correspondence__c>([SELECT Id, name, Amendment_Renewal__c, Renewal_Date__c, Payment_Method__c FROM Correspondence__c WHERE Amendment_Renewal__c IN  :Trigger.new
                        AND Correspondence_Type__c = 'Renewal']);
                        
        List<Price__c> priceList = new List<Price__c>([SELECT id, Price__c, Payment_Type__c, Product__r.RecordTypeId FROM Price__c WHERE Product__r.RecordTypeId =: c.clubProdAssociateRecordTypeId AND End_Date__c = null ]);
        
        
        String sections = null;
        double sectionsPrice = 0;
        
        for(Opportunity cn:newOpps){
            if(cn.RecordTypeId == c.OppRenewalRecordTypeId){
                Correspondence__c corr = new Correspondence__c();
                corr.Amendment_Renewal__c = cn.id;  
                //corr.Renewal_Date__c = cn.Account.Renewal_Date__c;
                
                
        system.debug('getting purchasedPorductList sections' + purchasedPorductList.size());
        for(Club_Opportunity_Product__c cop : purchasedPorductList.get(cn.Id).Line_Items__r){
            //if(cop.Status__c == 'Active'){
            //corr.Renewal_Date__c = cop.account__r.Renewal_Date__c;
                if(sections != null){
                    sections += cop.product__r.Name + ',';
                } else {
                    if(purchasedPorductList.size() > 1){
                        sections = cop.product__r.Name + ',';
                    } else if (purchasedPorductList.size()== 1){
                        sections = cop.product__r.Name;                     
                    }
                }
                if(sectionsPrice != 0){
                    sectionsPrice += cop.Price__c;
                } else {
                    sectionsPrice = cop.Price__c;                   
                }
                system.debug('getting cop.product__r.Name Status__c ' + cop.product__r.Name + ' '+ cop.Status__c);
            }
            system.debug('sections Status__c ' + sections);
            system.debug('getting purchasedPorductList ' + purchasedPorductList.size());    
            corr.Correspondence_Type__c = 'Renewal';
            corr.Correspondence_date__c =  system.today();
            if(leadAccMap.size() > 0){
                system.debug(leadAccMap.get(cn.AccountId).Contacts);
                for(Contact lc: leadAccMap.get(cn.AccountId).Contacts){
                    corr.Lead_Member__c = lc.Id;
                    corr.Lead_Member_Salutation__c =  lc.Salutation;
                    corr.Lead_Member_First_Name__c =  lc.FirstName;
                    corr.Lead_Member_Last_Name__c =  lc.LastName;
                    corr.Youth_Test_Passed_Date__c = lc.Youth_Test_Passed_Date__c;
                    corr.Renewal_Date__c = leadAccMap.get(cn.AccountId).Renewal_Date__c;
                    corr.Payment_Method__c = leadAccMap.get(cn.AccountId).Payment_Method2__c;
                    if(lc.Tenure2__c == null){
                        corr.Tenure__c =1;
                    } else {
                        corr.Tenure__c = lc.Tenure2__c +1;
                    }
                }
            }
                
                if(secAccMap.size() > 0){
                    system.debug(secAccMap.get(cn.AccountId).Contacts);
                    for(Contact sc: secAccMap.get(cn.AccountId).Contacts){
                        corr.Secondary_Member__c =  sc.Id;
                        corr.Second_Member_Salutation__c =  sc.Salutation;
                        corr.Second_Member_First_Name__c =  sc.FirstName;
                        corr.Second_Member_Last_Name__c =  sc.LastName;
                        if(sc.Tenure2__c == null ){
                            corr.Tenure_Secondary__c = 1;
                        } else {
                            corr.Tenure_Secondary__c = sc.Tenure2__c + 1;
                        }
                    }
                }
                
                corr.Membership__c = cn.AccountId;
                if(amendCorr.size() > 0){
                    corr.Amendment_Renewal__c =  amendCorr[0].Amendment_Renewal__c;
                }
                for(Price__c p: priceList){
                    if(p.Payment_Type__c == cn.Account.Payment_Method2__c)
                    corr.Associate_Member_Fee__c = p.Price__c;
                }
                
                corr.Membership_Subscription_Fee__c =cn.Amount;
               // system.debug('getting paymentMethod ' + accPaymentMethod.get(cn.AccountId));
                //corr.Payment_Method__c = accPaymentMethod.get(cn.AccountId);
                
                corr.Sections__c = sections;
                system.debug('getting sectionsPrice ' + sectionsPrice);
                corr.Sections_fee__c = sectionsPrice;
                //system.debug('getting membershipFee ' + membershipFee);*/
                corrList.add(corr);
            }      
        }
        
        insert corrList;
/*
        Set<id> resoppaccids = new Set<id>();
        List<Club_Opportunity_Product__c> cprodstorestore = new List<Club_Opportunity_Product__c>();
        Map<id,id> accoppmap = new Map<id,id>();

        for (Opportunity o : Trigger.new) {
            if(opprtMap.get(o.RecordTypeId).getName() =='Reinstatement'){
                resoppaccids.add(o.accountid);  
                accoppmap.put(o.accountid,o.id);                    
            }
        }

        List<Club_Opportunity_Product__c> cprods = [select id, Account__c,Price__c,recordtypeid,
                                                    product__c,Member_Section__c,status__c,
                                                    Opportunity__r.accountid 
                                                    from Club_Opportunity_Product__c 
                                                    where Opportunity__r.accountid in :resoppaccids
                                                    and status__c = 'Cancelled'];

        for(Club_Opportunity_Product__c c:cprods){
            Club_Opportunity_Product__c newcp = c.clone(false,true,false,false);
            newcp.price__c=0;
            newcp.status__c='Pending';
            newcp.Opportunity__c = accoppmap.get(newcp.Opportunity__r.accountid);
            cprodstorestore.add(newcp); 
        }
        
        Database.insert(cprodstorestore, dmo);

        List<Club_Opportunity_Product__c > cancelledprods = [select id,name,Account__c,product__c,product__r.name,status__c,(select id,name,Member__c from Members_Sections__r) from club_opportunity_product__c where status__c='Cancelled' and Account__c in :resoppaccids];

        List<Member_Section__c> ms = new List<Member_Section__c>();
        
        for(Club_Opportunity_Product__c c: cancelledprods){
            for(Club_Opportunity_Product__c pendingprod: cprodstorestore){
                if(pendingprod.account__c == c.account__c && c.product__c == pendingprod.product__c){
                    for(Member_Section__c m : c.Members_Sections__r){
                        Member_Section__c nms = new Member_Section__c(Club_Opportunity_Product__c = pendingprod.id, Member__c= m.member__c);
                        ms.add(nms);
                    }
                    
                }
            }
        }

        Database.insert(ms, dmo);
*/        
	}

	public override void afterUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id,SObject> oldMap, Map<Id,SObject> newMap){
	    Map<ID, Schema.RecordTypeInfo> opprtMap = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
	    Map<ID, Schema.RecordTypeInfo> coprtMap = Schema.SObjectType.Club_Opportunity_Product__c.getRecordTypeInfosById();
	
	    Database.DMLOptions dmo = new Database.DMLOptions();
	    dmo.optAllOrNone = false;

        
        Set<id> renoppaccids = new Set<id>();
        Set<id> chgoppaccids = new Set<id>();
        Set<id> oppids = new Set<id>();
        List<Club_Opportunity_Product__c> cprodstoupdate = new List<Club_Opportunity_Product__c>();
        List<Club_Opportunity_Product__c> cprodstodelete = new List<Club_Opportunity_Product__c>();

		List<Opportunity> newOpps = (List<Opportunity>) newObjects;	       
		Map<Id,Opportunity> oldOppsMap = (Map<Id,Opportunity>)oldMap;

        
        for (Opportunity o : newOpps) {
            oppids.add(o.id);
            if(opprtMap.get(o.RecordTypeId).getName() =='Renewal' && o.isClosed && o.isWon && !oldOppsMap.get(o.Id).isClosed && !oldOppsMap.get(o.Id).isWon) {
                    renoppaccids.add(o.accountid);
            }
            if(opprtMap.get(o.RecordTypeId).getName() =='Change' && o.isClosed && o.isWon && !oldOppsMap.get(o.Id).isClosed && !oldOppsMap.get(o.Id).isWon) {
                    chgoppaccids.add(o.accountid);
            }
        }
        
        system.debug(renoppaccids);
    
        Map<id,Opportunity> newoppsprods = new map<id,opportunity>([select id,(select id, recordtype.name,
                                                        product__c,Member_Section__c,status__c,
                                                        Opportunity__r.accountid,account__c 
                                                        from Line_Items__r)
                                                        from opportunity 
                                                        where id in :oppids]);
        
            
	}

}