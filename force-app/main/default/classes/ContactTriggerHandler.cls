public with sharing class ContactTriggerHandler  extends TriggerHandler{

    public ContactTriggerHandler(){
        preventRecursiveTrigger(false);
    }
    
    public override void beforeUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id,SObject> oldMap, Map<Id,SObject> newMap){
        Set<id> accountids = new Set<id>();
        constants c = new constants();

        List<Contact> newContacts = (List<Contact>) newObjects;
        Map<Id,Contact> oldContactMap = (Map<Id,Contact>) oldmap;

        for (Contact cn: newContacts) {
            if(cn.email!=null && cn.email != oldContactMap.get(cn.id).email && !cn.email.contains('@example.com')){
                if(cn.RecordTypeId == c.leadContactRecordTypeId || cn.recordtypeid == c.secondaryContactRecordTypeId){
                    accountids.add(cn.accountid);
                }
            }
        }            

        List<id> contactrecids = new List<Id>();
        contactrecids.add(c.leadContactRecordTypeId);
        contactrecids.add(c.secondaryContactRecordTypeId);

        Map<Id,Account> accwithCons = new Map<Id,Account>([select id,(select id,email,recordtypeid from contacts where recordtypeid in :contactrecids) from account where id in :accountids]);

        for (Contact cn: newContacts) {
            if(cn.email!=null &&  cn.email != oldContactMap.get(cn.id).email && !cn.email.contains('@example.com')){
                if(cn.RecordTypeId == c.leadContactRecordTypeId || cn.recordtypeid == c.secondaryContactRecordTypeId){
                    for (Contact co: accwithCons.get(cn.accountid).contacts){
                        if(cn.id!= co.id && cn.email == co.email && cn.email!=null){
                            cn.adderror('Lead and Secondary members emails cannot be the same');
                        }
                    }
                }
            }
        }            
    }

    public override void afterUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id,SObject> oldMap, Map<Id,SObject> newMap){

        List<Contact> newContacts = (List<Contact>) newObjects;

        Set<id> accountids = new Set<id>();
        constants c = new constants();
        List<Correspondence__c> corrList = new List<Correspondence__c>();
        
        for(Contact cn:newContacts){
            accountids.add(cn.AccountId);       
        }
        
        system.debug('in ContactTrigger ' + accountids);
        
        Map<id,Account> accMap = new Map<id,Account>([select id, Renewal_Date__c, (Select Id, Salutation,FirstName,LastName, Date_Joined__c from Contacts where RecordTypeId = :c.leadContactRecordTypeId ) FROM Account WHERE Id in :accountids]);

        List<Account> memshipsToUpdate = new List<Account>(); 
        for (Contact cn: newContacts) {
            if(cn.RecordTypeId == c.leadContactRecordTypeId && cn.Status__c == 'Active' ){
                if(accMap.size() > 0){
                    system.debug(accMap.get(cn.AccountId).Id);
                    Account mem = new Account();
                    mem.Id = accMap.get(cn.AccountId).Id;
                    mem.Name = cn.LastName;
                    mem.Phone = cn.Phone;
                    mem.Mobile_Phone__c =cn.MobilePhone;
                    mem.Email__c = cn.Email;
                    mem.Date_Joined__c = cn.Date_Joined__c;
                    memshipsToUpdate.add(mem);
                  }
            }
        }
        
        update memshipsToUpdate;

    }

    public override void afterInsert(List<SObject> newObjects, Map<Id,SObject> newMap){
        List<Contact> newContacts = (List<Contact>) newObjects;
        
        Set<id> accountids = new Set<id>();
        constants c = new constants();
        List<Correspondence__c> corrList = new List<Correspondence__c>();
        
        for(Contact cn:newContacts){
        	system.debug(cn.accountId);
        	system.debug(cn);
            accountids.add(cn.AccountId);       
        }
        
        system.debug('in ContactTrigger ' + accountids);
        
        Map<id,Account> accMap = new Map<id,Account>([select id, Renewal_Date__c, Payment_Method2__c, (Select Id, Salutation,FirstName,LastName from Contacts where RecordTypeId = :c.leadContactRecordTypeId ) FROM Account WHERE Id in :accountids]);
        system.debug(accMap);
        for(Contact cn:newContacts){
            if(cn.RecordTypeId == c.associateContactRecordTypeId){
                Correspondence__c corr = new Correspondence__c();
                corr.Correspondence_Type__c = 'New Associate Member';
                corr.Correspondence_date__c =  system.today();
                corr.Renewal_Date__c = accMap.get(cn.AccountId).Renewal_Date__c;
                corr.Payment_Method__c = accMap.get(cn.AccountId).Payment_Method2__c;
                System.debug(cn);
                
                corr.Membership__c = cn.AccountId;
               // corr.Lead_Member__c = cn.Id;
                if(accMap.size() > 0){
                    system.debug(accMap.get(cn.AccountId).Contacts);
                    for(Contact lc: accMap.get(cn.AccountId).Contacts){
                        corr.Lead_Member__c = lc.id;
                        corr.Lead_Member_Salutation__c =  lc.Salutation;
                        corr.Lead_Member_First_Name__c =  lc.FirstName;
                        corr.Lead_Member_Last_Name__c =  lc.LastName;
                    }
                }
                corr.Associate_Member__c =  cn.id;
                corrList.add(corr);
            }      
        }
        
        insert corrList;
        
    
          //  Set<id> accids = new Set<id>();
        List <Contact> alist =  New List<Contact>();
        
          Map<id,Account> accMap2 = new Map<id,Account>([select id, (Select Id, Name,  Status__c, RecordTypeId from Contacts where RecordTypeId = :c.secondaryContactRecordTypeId) FROM Account WHERE  Id IN: accountids]);
      
    
        for(Contact cn: newContacts){
            if(accMap2.size() > 0){
                for (Contact co: accMap2.get(cn.AccountId).Contacts) {
                    Contact updateC = co;
                    if (co.RecordTypeId == c.secondaryContactRecordTypeId && co.Status__c == 'Active' && co.Id != cn.Id && cn.RecordTypeId == c.secondaryContactRecordTypeId){
                        updateC.Date_Ended__c = System.today();
                        alist.add(updateC);
                        }
                }
            
            }
            
        }
        
        
        
        update alist;
       
        
        
        
        
        
        
        
        
        
        
        
        //RecordType rt = [SELECT Id from RecordType WHERE SobjectType = 'Contact' AND Name = 'Lead' AND DeveloperName ='Lead'];
        /*constants c = new constants();
        
        for (contact con: Trigger.new) {
            
                system.debug(con.RecordTypeId);
            
                if (con.RecordTypeId == c.associateContactRecordTypeId)
                    con.addError('Associate Members should be added using the [Change Membership] button');
                if (con.RecordTypeId == c.leadContactRecordTypeId)
                    con.addError('New Lead Members cannot be added to the Membership');
                    system.debug(RecordType.Name);
                    break;
        }
        
     */

    }

}