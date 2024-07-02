global class BatchCreateRenewals implements Database.Batchable<SObject> {
    
    global String query; 
    
    global BatchCreateRenewals(){
        query = 'SELECT Id, FreeSections__c, Membership_Renewal_Code__c, Tenure2__c, Renewal_Date__c, Payment_Method2__c, Membership_Type_Name__c, ';
       query +=     '(SELECT Id, Name, Birthdate, Youth_Test_Passed_Date__c FROM Contacts WHERE RecordType.Name=\'Lead\' LIMIT 1), ';
       query +=     '(SELECT Id, RecordTypeId, Product__c, Product__r.VIClass__c, Product__r.SectionsAreFree__c FROM Club_Opportunity_Products__r WHERE Status__c = \'Active\') ';
       query += 'FROM Account ';
       query += 'WHERE Renewal_Date__c = NEXT_N_MONTHS:2 AND Renewal_Date__c > NEXT_MONTH AND Membership_Status__c != \'Cancelled\' AND Membership_Status__c != \'Non-Renewer\''; 
       query += 'AND Membership_Status__c != \'DD Payment Rejected\' AND Membership_Status__c != \'DD Rejected\' AND Membership_Status__c != \'DD Mandate Rejected\''; 
    
    }
    
    global BatchCreateRenewals(Id membershipId){
        System.debug('[BatchCreateRenewals.constructor with param]');
        
        //query = 'SELECT Id FROM Membership__c WHERE Id = \'' + membershipId + '\'';
        query = 'SELECT Id, FreeSections__c, Membership_Renewal_Code__c, Tenure2__c, Renewal_Date__c, Payment_Method2__c, Membership_Type_Name__c, ';
       query +=     '(SELECT Id, Name, Birthdate, Youth_Test_Passed_Date__c FROM Contacts WHERE RecordType.Name=\'Lead\' LIMIT 1), ';
       query +=     '(SELECT Id, RecordTypeId, Product__c, Product__r.VIClass__c, Product__r.SectionsAreFree__c FROM Club_Opportunity_Products__r WHERE Status__c = \'Active\') ';
       query += 'FROM Account ';
       query += 'WHERE Id = \'' + membershipId + '\'  AND Membership_Status__c != \'Cancelled\''; 
       //query += 'AND Membership_Status__c != \'DD Rejected\' AND Membership_Status__c != \'DD Rejected\'';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('[BatchCreateRenewals.start]');

        if (Test.isRunningTest()) {
            return Database.getQueryLocator(query + ' LIMIT 200');
        }
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        System.debug('[BatchCreateRenewals.exe]');
        System.debug('[BatchCreateRenewals.execute] scope: ' +scope);

        Map<Id,Club_Product__c> cpMap = new Map<Id,Club_Product__c>( [ SELECT Id, Name, Product_Detail__c, SectionsAreFree__c, Renewable__c, VIClass__c, RecordTypeId, (SELECT Price__c, Start_Date__c, End_Date__c, Payment_Type__c FROM Prices__r ORDER BY Start_Date__c) FROM Club_Product__c ]);


        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.optAllOrNone = false; 
        
        constants sc = new constants();

        Set<Id> accids = new Set<Id>();
        List<Opportunity> newopps = new List<Opportunity>();
        Map<Integer,Opportunity> newoppMap = new Map<Integer,Opportunity>();
        
        Map<Integer,List<Club_Opportunity_Product__c>> newoppcpMap = new Map<Integer,List<Club_Opportunity_Product__c>>();
        
        Id opprenewalid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();  

        List<Account> accstoUpdate = new List<Account>();
        
        List<Club_Product_Change__c> cpclist = [SELECT Id,From__c,To__c FROM Club_Product_Change__c WHERE Allow_Auto_Switch__c = TRUE];

        Integer i = 0;

        for (Account a : scope) {
            Opportunity o = new Opportunity(AccountId=a.Id);
            o.Name = 'Renewal';
            o.RecordTypeId = opprenewalid;  
            o.StageName='Due';
            o.CloseDate = a.Renewal_Date__c;
            newopps.add(o);
            accids.add(a.Id);

            List<Club_Opportunity_Product__c> cop = new List<Club_Opportunity_Product__c>();
            
            Decimal OppPrice = 0;
            Boolean prodrenewable = false;
            Id mtprod;

            for (Club_Opportunity_Product__c c : a.Club_Opportunity_Products__r) {
                if (c.RecordTypeId == sc.mtsectRecordTypeId) {
                    Id prodtoget = c.Product__c;

                    if (a.membership_renewal_code__c!=null) {
                        prodtoget = a.membership_renewal_code__c;
                    }

                    mtprod = c.Product__c;
                    prodrenewable = cpMap.get(prodtoget).Renewable__c;
                }
            }
            if (prodrenewable) {
                for (Club_Opportunity_Product__c c : a.Club_Opportunity_Products__r) {
                    Club_Opportunity_Product__c cp = new Club_Opportunity_Product__c(Account__c = a.Id, RecordTypeId = c.RecordTypeId, Product__c = c.Product__c, Status__c = 'Pending');
                    Decimal Price=0;
                    Id prodtoget = cp.Product__c;

                    if (c.RecordTypeId == sc.mtsectRecordTypeId) {

                        if (a.membership_renewal_code__c!=null) {
                            prodtoget = a.membership_renewal_code__c;
                            cp.Product__c = a.membership_renewal_code__c;
                        }

                        for (Club_Product_Change__c cpc : cpclist) {

                            if (cpc.From__c==prodtoget) {
                                String viclass ='';
                                viclass = cpMap.get(cpc.To__c).VIClass__c;
                                System.debug(viclass);
                                Type t;
                                t = Type.forName('VI'+viclass);

                                if (t==null) {
                                    t = Type.forName('VIDefault');
                                }

                                ValidationInterface v = (ValidationInterface)t.newInstance();

                                if (!a.Contacts.isEmpty()) {
                                    Id newprod = v.autoswitch(a, a.Contacts[0], o, prodtoget, cpc.To__c);
                                    cp.Product__c = newprod;
                                    prodtoget = newprod;
                                    mtprod = newprod;
                                }
                            }
                        }
                    }
                    System.debug(cpMap.get(prodtoget));

                    for (Price__c p:cpMap.get(prodtoget).Prices__r) {
                        if (p.Start_Date__c <= a.Renewal_Date__c && (p.End_Date__c >= a.Renewal_Date__c || p.End_Date__c == null) && ((c.RecordTypeId == sc.mtsectRecordTypeId && a.Payment_Method2__c == p.Payment_Type__c) || c.RecordTypeId == sc.amsectRecordTypeId || c.RecordTypeId == sc.sectionRecordTypeId)) {
                            if (c.RecordTypeId == sc.mtsectRecordTypeId || c.RecordTypeId == sc.amsectRecordTypeId) {
                                System.debug('Membership or Associate Type');
                                Price = p.Price__c;
                            } else if ((a.FreeSections__c != true && cpMap.get(mtprod).SectionsAreFree__c != true) && c.RecordTypeId != sc.mtsectRecordTypeId) {
                                System.debug('Non-free Section');
                                Price = p.Price__c;
                            } else if ((a.FreeSections__c == true || cpMap.get(mtprod).SectionsAreFree__c == true) && c.RecordTypeId != sc.mtsectRecordTypeId) {
                                 System.debug('Free Section');
                                 Price = 0;
                            }
                            break;
                        }
                    }

                    OppPrice += Price; 
                    cp.Price__c = Price;
                    cop.add(cp);
                
                }
                if (a.membership_renewal_code__c != null) {
                    Account au = new Account(Id = a.Id);
                    au.membership_renewal_code__c = null;
                    accstoUpdate.add(au);
                }
                
                o.Amount = OppPrice;
                newoppMap.put(i,o);
                
                newoppcpMap.put(i,cop);
                i++;
            }
        }

        if (accstoUpdate.size() > 0) {
            Database.update(accstoUpdate, dmo);
        }

        if (!newoppMap.values().isEmpty()) {
            Database.insert(newoppMap.values(), dmo);
        }

        List<Club_Opportunity_Product__c> cops = new List<Club_Opportunity_Product__c>();

        for (Integer i1:newoppMap.keySet()) {

            for(Club_Opportunity_Product__c cop: newoppcpMap.get(i1)) {
                cop.Opportunity__c = newoppMap.get(i1).Id;
            }
            
            cops.addAll(newoppcpMap.get(i1));
        }

        if (!cops.isEmpty()) {
            Database.insert(cops, dmo);
        }

        List<Club_Opportunity_Product__c > activeprods = [SELECT Id, Name, Account__c, Product__c, Product__r.Name, Status__c, (SELECT Id, Name, Member__c FROM Members_Sections__r) FROM Club_Opportunity_Product__c WHERE Status__c = 'Active' AND Account__c IN :accids];

        List<Member_Section__c> ms = new List<Member_Section__c>();
        
        for (Club_Opportunity_Product__c c: activeprods) {
            for (Club_Opportunity_Product__c pendingprod: cops) {
                if (pendingprod.Account__c == c.Account__c && c.Product__c == pendingprod.Product__c) {
                    for (Member_Section__c m : c.Members_Sections__r) {
                        Member_Section__c nms = new Member_Section__c(Club_Opportunity_Product__c = pendingprod.Id, Member__c= m.Member__c);
                        ms.add(nms);
                    }
                    
                }
            }
        }

        if (!ms.isEmpty()) {
            Database.insert(ms, dmo);
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        BatchUpdateCorrRenewals Batch = new BatchUpdateCorrRenewals();
        Id batchProcessId = Database.executeBatch(Batch);
    }
}