global class BatchUpdateDDRenewals implements Database.Batchable<sObject> {

    //global String QUERY = 'select id,name,account.name,closedate,accountid,(select id,price__c,product__c,recordtypeid from Line_Items__r) from opportunity where account.payment_method__c=\'Direct Debit\' and recordtype.name=\'Renewal\' and isclosed=false and iswon=false and account.Renewal_Date__c = :tomorrow '; 


    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        Date tomorrow = Date.today().adddays(1);
        Date endRenewalDate = Date.today().addDays(-363);
        String QUERY = 'select id,name,amount, account.name,closedate,accountid,(select id,price__c,product__c,recordtypeid from Line_Items__r) from opportunity where account.payment_method2__c=\'Direct Debit\' and recordtype.name=\'Renewal\' and isclosed=false and iswon=false and account.Renewal_Date__c <= :tomorrow AND account.Renewal_Date__c >=: endRenewalDate'; 
        if(Test.isRunningTest()) {
            return Database.getQueryLocator(QUERY + ' LIMIT 200');
        }
        

        return Database.getQueryLocator(QUERY);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        constants sc = new constants();

        Set<Id> accids = new Set<id>();

        for(Opportunity o : scope) {
            accids.add(o.accountid);
        }

        Map<id,Account> acclist = new Map<id,account>([select id,Renewal_Date__c,membership_Status__c ,(select id,Mandate_Amount__c from DD_Mandates__r where recordtypeid=:sc.PaymentMethodDDRecordTypeId and status__c='Active') from account where id in :accids]);
        
        for(Account a:acclist.values())
        {
            if(acclist.get(a.id).DD_Mandates__r.size()>0 && a.membership_Status__c!='Non-Renewer'){
                a.Membership_Status__c='Paid';
            }
        }

        List<Club_Product__c> mtList = [select id,name,Product_Detail__c,Membership_Length__c,renewable__c from club_product__c where recordtype.name='Membership Code' order by name];

        List<Club_Opportunity_Product__c> cprods = [select id, recordtype.name,
                                                    product__c,Member_Section__c,status__c,
                                                    Opportunity__r.accountid 
                                                    from Club_Opportunity_Product__c 
                                                    where Opportunity__r.accountid in :accids
                                                    and status__c = :sc.active];
    
        for(Club_Opportunity_Product__c c:cprods){
            if(acclist.get(c.Opportunity__r.accountid).DD_Mandates__r.size()>0){
                c.status__c = sc.superseded;
            }
        }

        List<Club_Opportunity_Product__c> coplist = new List<Club_Opportunity_Product__c>();
        List<Payment_Method__c> pmethods = new List<Payment_Method__c>();

        /*  For each opp, if the membership status is not non-renewer and the payment method is DD, update Membership_Code__c,
            Renewal_Date__c */
        for(Opportunity o : scope) {
            if(acclist.get(o.accountid).membership_Status__c!='Non-Renewer'){
                if(acclist.get(o.accountid).DD_Mandates__r.size()>0){
                    o.StageName = sc.complete;
                    for(Club_Opportunity_Product__c c: o.line_items__r){
                        c.Status__c = sc.active;
                        if(c.recordtypeid == sc.mtRecordTypeId){
                            for(Club_Product__c m:mtList){
                                if(c.product__c == m.id){
                                    acclist.get(o.accountid).Membership_Code__c = m.id;
                                    acclist.get(o.accountid).Renewal_Date__c = acclist.get(o.accountid).Renewal_Date__c.addmonths(Integer.valueof(m.Membership_Length__c));
                                }
                            }   
                        }
                    }
                    system.debug(o.accountid);
                    Payment_Method__c pm = acclist.get(o.accountid).DD_Mandates__r[0];
                    pm.Mandate_Amount__c = o.Amount; 
                    pm.Allow_DDI_Alert__c = false;
                    pm.Renewal_Payment_Pending__c = true;
                    pmethods.add(pm);
                    o.Payment_Method__c = pm.id;
                    coplist.addall(o.line_items__r);
                }
            }
        }
        
        update acclist.values(); 
        
        update scope; 
        update cprods;
        update coplist; 

        // sett Boolean flag to prevent correspondence records being created in PaymentMethodTriggerHandler from batch context
        TriggerRecursionCheck.preventCorrespondenceCreation = true;
        update pmethods; 


    }

    global void finish(Database.BatchableContext BC) {}
    

}