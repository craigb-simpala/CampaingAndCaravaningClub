public with sharing class AccountTriggerHandler extends TriggerHandler {
    
    public AccountTriggerHandler(){
        preventRecursiveTrigger(false);
    }
    
    public override void beforeUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id,SObject> oldMap, Map<Id,SObject> newMap){
        
        List<DA_Postcode__c> dap = [select Association_Name__c,Postcode_Part_1__c,Postcode_Part_2__c from DA_Postcode__c];
        for(Account acct :(List<Account>) newObjects){
            if(acct.BillingPostalCode!=null && acct.District_Association__c !=null){
                Boolean found =false;
                List<String> parts = acct.BillingPostalCode.split(' ');
                if(parts.size()>1){
                    String pcodeout = parts[0];
                    String pcodein = parts[1].substring(0, 1); 
                    
                    for(DA_Postcode__c da: dap){
                        if (pcodeout == da.Postcode_Part_1__c && (pcodein == da.Postcode_Part_2__c || da.Postcode_Part_2__c == null) && acct.District_Association__c == da.Association_Name__c){
                            found = true;
                            system.debug(found);
                            break;
                        } 
                    } 
                    acct.Opted_In__c = !found;
                }
            }
        }
        
    }
    
    public override void afterUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id,SObject> oldMap, Map<Id,SObject> newMap){
        Map<Id, Account> oldAccountMap = (Map<Id, Account>) oldMap;
        List<Account> newAccountList = (List<Account>)newObjects;
        
        // reopen opps and club products when DD is rejected
        // WARNING - this method updates memberships (Account), Opp and Club Opp Product records
        OpportunityPaymentHandler.reopenOppsAndProducts(oldAccountMap, newAccountList);
        
        
        List<Cancellation__c> cancellationList = new List<Cancellation__c>(); 
        Map<Id, Account> oldAcct = (Map<Id, Account>) oldMap;
        for(Account acct :(List<Account>) newObjects){
            if(acct.Membership_Status__c == 'Ex-Member' &&
               oldAcct.get(acct.Id).Membership_Status__c != 'Ex-Member'){
                   system.debug(oldAcct.get(acct.Id).Membership_Status__c);
                   Cancellation__c cn = new Cancellation__c();
                   cn.Membership__c =  acct.Id;
                   cn.Cancellation_Type__c = 'Ex-Member';
                   cn.Cancellation_Date__c = system.today();
                   cancellationList.add(cn);
               }
        }
        insert cancellationList;
        
        
        
    }

    public override void afterUndelete(List<SObject> newObjects) {
        List<Account> newAccountList = (List<Account>)newObjects;
        if (!System.isBatch() && !System.isFuture()) {
            restoreOpportunities(new Map<Id, Account>(newAccountList).keySet());
        }
    }

    @Future
    public static void restoreOpportunities(Set<Id> accountIds) {
        List<Opportunity> oppys = [
                SELECT Id, Stage_Before_Deletion__c, StageName
                FROM Opportunity
                WHERE AccountId IN :accountIds
        ];
        for (Opportunity oppy: oppys) {
            if (String.isNotBlank(oppy.Stage_Before_Deletion__c)) {
                oppy.StageName = oppy.Stage_Before_Deletion__c;
            }
        }
        update oppys;
    }
    
}