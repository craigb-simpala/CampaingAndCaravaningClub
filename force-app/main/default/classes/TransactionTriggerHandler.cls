public with sharing class TransactionTriggerHandler  extends TriggerHandler{

    public TransactionTriggerHandler(){
        preventRecursiveTrigger(false);
    }

    static Long days7Milliseconds = 604800000;  
    List<Correspondence__c> correspondences = new List<Correspondence__c>();

    public override void afterInsert(List<SObject> newObjects, Map<Id,SObject> newMap){
        
        Set<Id> pmids = new Set<Id>();
        Set<Id> accids = new Set<Id>(); 
        constants c = new constants();
        List<Transaction__c> newTrans = (List<Transaction__c>)newObjects;
           
        for (Transaction__c newPaymentMethod: newTrans) {
            pmids.add(newPaymentMethod.Payment_Method__c);
        }
        
        Map<id, Payment_Method__c> pmlist =new Map<id,Payment_Method__c>([select id,Status__c,Membership__c from Payment_Method__c where id in :pmids]);
        
        for(Payment_Method__c p: pmlist.values()){
            accids.add(p.Membership__c);
        }
        
        Map<id, Account> leadMemMap = new Map<id, Account>([select id, Renewal_Date__c, 
        (Select Id, Salutation,FirstName,LastName, Youth_Test_Passed_Date__c, Tenure2__c from Contacts where RecordTypeId = :c.leadContactRecordTypeId )
        FROM Account WHERE Id in :accids ]);
            
        /*for(Transaction__c cn:newTrans){
            if(cn.Transaction_Type__c == '01'){
                Correspondence__c corr = new Correspondence__c();
                corr.Correspondence_Type__c='Auddis Letter';
                corr.Bank_Account_Name__c = cn.Customer_Account_Name__c;
                corr.Bank_Account_Number__c = cn.Customer_Account_Number__c;
                corr.Sort_Code__c = cn.Customer_Sort_Code__c;
                corr.Total_Fee__c = cn.Amount__c;
                corr.Membership__c = pmList.get(cn.Payment_Method__c).Membership__c;
                for(Contact lc: leadMemMap.get((pmList.get(cn.Payment_Method__c)).Membership__c).Contacts){
                        corr.Lead_Member_Salutation__c =  lc.Salutation;
                        corr.Lead_Member_First_Name__c =  lc.FirstName;
                        corr.Lead_Member_Last_Name__c =  lc.LastName;                       
                }
                corr.Correspondence_date__c = system.today();
                corr.Date_Monies_to_be_Taken__c = cn.Transaction_Date__c;
                correspondences.add(corr);
                
            }
        }
        if(correspondences.size()>0)
        insert correspondences;*/

    }

    public override void afterUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id,SObject> oldMap, Map<Id,SObject> newMap){
        Set<Id> pmids = new Set<Id>(); 
        Set<Id> pm2ids = new Set<Id>(); 
        Set<Id> accids = new Set<Id>();
        List<Transaction__c> trans01list = new List<Transaction__c>(); 
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];

        List<Transaction__c> newTrans = (List<Transaction__c>)newObjects;
        Map<Id,Transaction__c> oldTransMap = (Map<Id,Transaction__c>)oldMap;
    
        for(Transaction__c t : newTrans){ 
            if(t.status__c =='Complete' && t.transaction_type__c == '0N' && oldTransMap.get(t.id).status__c=='Pending' && t.Amount__c > 0){
                trans01list.add(new Transaction__c(
                        
//                  Customer_Sort_Code__c = t.Customer_Sort_Code__c,
//                  Customer_Account_Name__c = t.Customer_Account_Name__c,
//                  Customer_Account_Number__c = t.Customer_Account_Number__c,
                    Transaction_Date__c = BusinessHours.add(bh.id, system.now(), days7Milliseconds).date(),
                    recordtypeid=t.RecordTypeId,
                    Amount__c = t.Amount__c,
                    Status__c = 'Pending',
                    Transaction_Type__c = '01',
                    Payment_Method__c = t.Payment_Method__c)
                );
            }
            // System.debug('transaction: ' + t);
            if(t.Transaction_Type__c=='0N' && t.status__c =='Rejected' && oldTransMap.get(t.id).status__c!='Rejected'){
                pmids.add(t.Payment_Method__c);
            }
            if((t.Transaction_Type__c=='01' || t.Transaction_Type__c=='17') && t.status__c =='Rejected' && oldTransMap.get(t.id).status__c!='Rejected'){
                pm2ids.add(t.Payment_Method__c);
            }
        }
        
               
        List<Payment_Method__c> pmlist =[select id,Status__c from Payment_Method__c where id in :pmids AND Status__c != 'Rejected'];
        
        for(Payment_Method__c pm: pmlist){
            pm.Status__c = 'Rejected';
        }
        
        update pmlist; 
        
        
        Map<id,Payment_Method__c> pm2map = new Map<id,Payment_Method__c> ([select id, Membership__c from Payment_Method__c where id in :pm2ids]);
        For(Payment_Method__c pm2: pm2map.values()){
            accids.add(pm2.Membership__c);
        }
       
        
        List<Account> acclist =[select id,Membership_Status__c from Account where id in :accids];
        
        for(Account acc : acclist){
             acc.Membership_Status__c='DD Rejected';
        }
        
        update acclist; 
        
        if(trans01list.size()>0)insert trans01list;
        
        
        pmids = new Set<Id>();  
        accids = new Set<Id>();
        for(Transaction__c t : newTrans){ 
            if(t.status__c =='Complete' && (t.transaction_type__c == '01' || t.transaction_type__c == '17') && oldTransMap.get(t.id).status__c=='Pending'){
                 pmids.add(t.Payment_Method__c);
            }            
        }
        List<Payment_Method__c> pmlist2 =[select id, Membership__c from Payment_Method__c where id in :pmids];
        for(Payment_Method__c pm: pmlist2){
            accids.add(pm.Membership__c);
        }           
        List<Account> acclist2 =[select id,Membership_Status__c from Account where id in :accids];
                
        for(Account acc : acclist2){
             acc.Membership_Status__c='Paid';
        }
        
        update acclist2;
    }

}