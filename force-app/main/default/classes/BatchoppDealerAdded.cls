global class BatchoppDealerAdded implements Database.Batchable<sObject> {
// query to get next start date Select Number,enddate From Period  Where type = 'Quarter' and enddate>today order by enddate
    global Database.QueryLocator start(Database.BatchableContext BC) {

        constants sc = new constants();     
        String QUERY =  'Select Id,name, (SELECT Id, name  from Opportunities__r WHERE CreatedDate  = THIS_FISCAL_QUARTER) FROM Dealer_Advert__c WHERE  RecordTypeId= \''+sc.dealerAdvertDealerRecordTypeId+'\'';
//SELECT count(id), Dealer_Ad_Code__c,CALENDAR_YEAR(CreatedDate),CALENDAR_quarter(CreatedDate)  FROM opportunity WHERE Dealer_Ad_Code__c != null group by CALENDAR_YEAR(CreatedDate),Dealer_Ad_Code__c,CALENDAR_quarter(CreatedDate)
        if(Test.isRunningTest()) {
            return Database.getQueryLocator(QUERY + ' LIMIT 200');
        }
        
        
        return Database.getQueryLocator(QUERY);
    }

    global void execute(Database.BatchableContext BC, List<Dealer_Advert__c> scope) {
        Set<Id> dealerAdIds = new Set<Id>();
        
        List<Dealer_Commission__c> dealerCommList = new List<Dealer_Commission__c>();
        
        for(Dealer_Advert__c d : scope){
            
            dealerAdIds.add(d.Id);
        }
        
        List<AggregateResult> dealeropps = [SELECT count(id) c, Dealer_Ad_Code__c,FISCAL_YEAR(CreatedDate) y,FISCAL_quarter(CreatedDate) q FROM opportunity WHERE Dealer_Ad_Code__c IN : dealerAdIds
                                                AND CreatedDate = THIS_FISCAL_YEAR
                                                group by FISCAL_YEAR(CreatedDate),Dealer_Ad_Code__c,FISCAL_quarter(CreatedDate)];
                                                
        List<AggregateResult> yearPayments = [select Dealer_Advert__c,sum(Value__c) payment from Dealer_Commission__c
                                                WHERE Dealer_Advert__c IN : dealerAdIds
                                                AND CreatedDate = THIS_FISCAL_YEAR
                                                group by Dealer_Advert__c];                                               
                                                
        Map<Id, Decimal> dealerpayments = new Map<Id,Decimal>();
        Map<Id, Map<Integer, Integer>> oppsYearlyAndQuarterMap = new Map<Id, Map<Integer, Integer>>();
        for(AggregateResult ar:yearPayments  ){
            dealerpayments.put((id)ar.get('Dealer_Advert__c') ,(Decimal)ar.get('payment'));    
        }        
        for(AggregateResult ar:dealeropps){
            if(!oppsYearlyAndQuarterMap.containsKey((Id)ar.get('Dealer_Ad_Code__c'))){
                Map<Integer, Integer> countAndQuarterMap = new Map<Integer, Integer>();
                countAndQuarterMap.put((Integer)ar.get('q'), (Integer)ar.get('c'));
                oppsYearlyAndQuarterMap.put((Id)ar.get('Dealer_Ad_Code__c'),countAndQuarterMap);
            }
            else{
                oppsYearlyAndQuarterMap.get((Id)ar.get('Dealer_Ad_Code__c')).put((Integer)ar.get('q'), (Integer)ar.get('c'));
            }   
            
        }

        Period p = [Select Number From Period  Where type = 'Quarter' and StartDate = THIS_FISCAL_QUARTER];
        Integer currentFiscalQuarter = p.Number;
        List<Dealer_Commission__c> newpayments = new List<Dealer_Commission__c>();
        for(Id dealerId : oppsYearlyAndQuarterMap.keySet()){
            Map<Integer, Integer> countMap = oppsYearlyAndQuarterMap.get(dealerId);
            Integer numpay=0;
            Decimal payvalue=0;
            for(Integer n:countMap.values())numpay+=n;
            if(numpay>=4)payvalue=4;
            if(numpay>10)payvalue=10;
            if(payvalue==0 && currentFiscalQuarter==4)payvalue=4;
            Decimal totalpay = numpay*payvalue;
            if(dealerpayments.containskey(dealerId)){
                totalpay-=dealerpayments.get(dealerId);
            }
            if(totalpay>0){
                newpayments.add(new Dealer_Commission__c(Dealer_Advert__c=dealerid,Value__c=totalpay));
            }
        }
        
        database.insert(newpayments);
        
    }

    global void finish(Database.BatchableContext BC) {}

}