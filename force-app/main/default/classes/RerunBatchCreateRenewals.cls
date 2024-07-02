global class RerunBatchCreateRenewals implements Database.Batchable<sObject> { 
    
    global String query; 
    
    global RerunBatchCreateRenewals(){
        query = 'SELECT Id, FreeSections__c, Membership_Renewal_Code__c, Tenure2__c, Renewal_Date__c, Payment_Method2__c, Membership_Type_Name__c, ';
       query +=     '(SELECT Id, Name, Birthdate, Youth_Test_Passed_Date__c FROM Contacts WHERE RecordType.Name=\'Lead\' LIMIT 1), ';
       query +=     '(SELECT Id, RecordTypeId, Product__c, Product__r.VIClass__c, Product__r.SectionsAreFree__c FROM Club_Opportunity_Products__r WHERE Status__c = \'Active\') ';
       query += 'FROM Account ';
       query += 'WHERE Re_run_Batch_Renewal__c = true  AND Membership_Status__c != \'Cancelled\' AND Membership_Status__c != \'Non-Renewer\''; 
       query += 'AND Membership_Status__c != \'DD Payment Rejected\' AND Membership_Status__c != \'DD Rejected\' AND Membership_Status__c != \'DD Mandate Rejected\''; 
    
    }  
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('[BatchCreateRenewals.start]');
        if(Test.isRunningTest()) {
            return Database.getQueryLocator(query + ' LIMIT 200');
        }
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        System.debug('[BatchCreateRenewals.exe]');
        System.debug('[BatchCreateRenewals.execute] scope: ' +scope);

        Map<id,Club_Product__c> cpMap = new Map<id,Club_Product__c>([select id,name,Product_Detail__c, SectionsAreFree__c, Renewable__c,viclass__c,recordtypeid,(select Price__c,start_date__c,end_date__c, Payment_Type__c from Prices__r order by Start_Date__c) from club_product__c ]);


        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.optAllOrNone = false; 
        
        constants sc = new constants();

        Set<Id> accids = new Set<id>();
        List<Opportunity> newopps = new List<Opportunity>();
        Map<Integer,Opportunity> newoppMap = new Map<Integer,Opportunity>();
        
        Map<Integer,List<Club_Opportunity_Product__c>> newoppcpMap = new Map<Integer,List<Club_Opportunity_Product__c>>();
        
        Id opprenewalid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();  

        List<Account> accstoUpdate = new List<Account>();
        
        List<Club_Product_Change__c> cpclist = [select id,From__c,To__c from Club_Product_Change__c where Allow_Auto_Switch__c=TRUE];

        Integer i = 0;      
        for(Account a : scope) {
            Opportunity o = new Opportunity(accountid=a.id); 
            o.name = 'Renewal';
            o.RecordTypeId = opprenewalid;  
            o.StageName='Due';
            o.CloseDate = a.Renewal_Date__c;
            newopps.add(o);
            accids.add(a.id);
            List<Club_Opportunity_Product__c> cop = new List<Club_Opportunity_Product__c>();
            
            Decimal OppPrice = 0;
            boolean prodrenewable=false;
            id mtprod;
            for(Club_Opportunity_Product__c c : a.Club_Opportunity_Products__r) {
                if(c.recordtypeid==sc.mtsectRecordTypeId){
                    id prodtoget = c.product__c;
                    if(a.membership_renewal_code__c!=null){                     
                        prodtoget = a.membership_renewal_code__c;
                    }
                    mtprod = c.product__c;
                    prodrenewable = cpMap.get(prodtoget).Renewable__c;
                }
            }
            if(prodrenewable){
                for(Club_Opportunity_Product__c c : a.Club_Opportunity_Products__r) {
                    Club_Opportunity_Product__c cp = new Club_Opportunity_Product__c(Account__c=a.id,recordtypeid=c.recordtypeid,Product__c=c.Product__c,status__c='Pending');
                    Decimal Price=0;
                    id prodtoget = cp.product__c;
                    if(c.recordtypeid==sc.mtsectRecordTypeId){
                        if(a.membership_renewal_code__c!=null){
                            prodtoget = a.membership_renewal_code__c;
                            cp.Product__c = a.membership_renewal_code__c;
                        }
                        for(Club_Product_Change__c cpc : cpclist){
                            if(cpc.From__c==prodtoget){ 
                                String viclass ='';
                                viclass = cpmap.get(cpc.to__c).viclass__c;
                                system.debug(viclass);
                                Type t;
                                t = Type.forName('VI'+viclass);
                                if(t==null)t = Type.forName('VIDefault');
                                ValidationInterface v = (ValidationInterface)t.newInstance();
                                ID newprod = v.autoswitch(a,a.contacts[0],o,prodtoget,cpc.to__c);
                                cp.Product__c = newprod;
                                prodtoget = newprod;
                                mtprod = newprod;
                            }
                        }
                    }
                    system.debug(cpMap.get(prodtoget));
                    for(Price__c p:cpMap.get(prodtoget).Prices__r){
                        if(p.Start_Date__c<=a.renewal_date__c && (p.end_date__c>= a.renewal_date__c || p.end_date__c==null) && ((c.recordtypeid==sc.mtsectRecordTypeId && a.Payment_Method2__c == p.Payment_Type__c) || c.recordtypeid==sc.amsectRecordTypeId || c.recordtypeid == sc.sectionRecordTypeId)){
                            if(c.recordtypeid==sc.mtsectRecordTypeId || c.recordtypeid==sc.amsectRecordTypeId){
                                system.debug('Membership or Associate Type');
                                Price = p.Price__c;
                            }
                            else if((a.FreeSections__c != true && cpMap.get(mtprod).SectionsAreFree__c != true) && c.recordtypeid!=sc.mtsectRecordTypeId){
                                system.debug('Non-free Section');
                                Price = p.Price__c;
                            }
                            else if((a.FreeSections__c == true || cpMap.get(mtprod).SectionsAreFree__c == true) && c.recordtypeid!=sc.mtsectRecordTypeId){
                                 system.debug('Free Section');
                                 Price = 0;
                            }
                            break;
                        }
                    }
                    OppPrice += Price; 
                    cp.Price__c = price;
                    cop.add(cp);
                
                }
                if(a.membership_renewal_code__c!=null){
                    Account au = new Account(id=a.id);
                    au.membership_renewal_code__c = null;
                    accstoUpdate.add(au);
                }
                
                o.amount = OppPrice;
                newoppMap.put(i,o);
                
                newoppcpMap.put(i,cop);
                i++;
            }
        }
        
        if(accstoUpdate.size()>0)Database.update(accstoUpdate, dmo);
        Database.insert(newoppMap.values(), dmo);

        List<Club_Opportunity_Product__c> cops = new List<Club_Opportunity_Product__c>();

        for(integer i1:newoppMap.keySet()){
            for(Club_Opportunity_Product__c cop: newoppcpMap.get(i1)){
                cop.Opportunity__c = newoppMap.get(i1).id;
            }
            
            cops.addall(newoppcpMap.get(i1));
        }

        Database.insert(cops, dmo);
        
        List<Club_Opportunity_Product__c > activeprods = [select id,name,Account__c,product__c,product__r.name,status__c,(select id,name,Member__c from Members_Sections__r) from club_opportunity_product__c where status__c='Active' and Account__c in :accids];

        List<Member_Section__c> ms = new List<Member_Section__c>();
        
        for(Club_Opportunity_Product__c c: activeprods){
            for(Club_Opportunity_Product__c pendingprod: cops){
                if(pendingprod.account__c == c.account__c && c.product__c == pendingprod.product__c){
                    for(Member_Section__c m : c.Members_Sections__r){
                        Member_Section__c nms = new Member_Section__c(Club_Opportunity_Product__c = pendingprod.id, Member__c= m.member__c);
                        ms.add(nms);
                    }
                    
                }
            }
        }

        Database.insert(ms, dmo);
        for(Account a : scope){
            a.Re_run_Batch_Renewal__c = false;
        }
        update scope;
        
    }
    
    global void finish(Database.BatchableContext BC) {
        BatchUpdateCorrRenewals Batch = new BatchUpdateCorrRenewals();
        ID batchProcessId = Database.executeBatch(Batch);
    }
}