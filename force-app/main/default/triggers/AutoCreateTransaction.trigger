trigger AutoCreateTransaction on Payment_Method__c (after insert, after update) {
    List<Transaction__c> transactions = new List<Transaction__c>();
    List<Payment_Method__c> pmlist = new List<Payment_Method__c>();
    Constants sc = new Constants();
    
       
    //This trigger fires when a Payment Method is Created or updated AND If Rec Type is 'Direct Debit' 
    //If Create then creates a child transaction record with Status 0N
    //If Update and Cancelled then creates a child transaction record with Status 0C
    //Note that Trigger.New is a list of all the payment methods 
    //that are being updated/created. 
    if(GetProfileId.p.Name != 'Data Loader Sys Admin'){
        if(trigger.isInsert) {
            if(trigger.isAfter) {
                for (Payment_Method__c newPaymentMethod: Trigger.New) {
                    if (newPaymentMethod.RecordTypeid == sc.PaymentMethodDDRecordTypeId) {
                        transactions.add(new Transaction__c(
                            Transaction_Date__c = newPaymentMethod.Start_Date__c,
                            recordtypeid=sc.trddebitRecordTypeId,
                            Amount__c = newPaymentMethod.Mandate_Amount__c,
                            Status__c = 'Pending',
                            Transaction_Type__c = '0N',
                            Payment_Method__c = newPaymentMethod.Id)
                        );
                    }
                }
                insert transactions;
            }
        }
    
        if(trigger.isUpdate) {
            if(trigger.isAfter) {
                for (Payment_Method__c newPaymentMethod: Trigger.New) {
                    if (newPaymentMethod.RecordTypeid == sc.PaymentMethodDDRecordTypeId) {
                        if(newPaymentMethod.Status__c == 'Cancelled') {
                            transactions.add(new Transaction__c(
                                Transaction_Date__c = newPaymentMethod.Start_Date__c,
                                Amount__c = newPaymentMethod.Mandate_Amount__c,
                                Status__c = 'Pending',
                                recordtypeid=sc.trddebitRecordTypeId,
                                Transaction_Type__c = '0C',
                                Payment_Method__c = newPaymentMethod.Id)
                            );
                        }
    
                        if(newPaymentMethod.Status__c == 'Rejected') {
                            pmlist.add(newPaymentMethod);
                        }
                        
                        
    
    
                    }
                }
                if(pmlist.size()>0){
                    List<Transaction__c> deltrans = [select id from transaction__c where Status__c='Pending' and Payment_Method__c in :pmlist];
                    Set<id> accids = new Set<Id>();
                    for(Payment_Method__c pm:pmlist){
                        accids.add(pm.Membership__c);
                    }
                    List<Account> acs = [select id,Membership_Status__c from Account where id in :accids];
                    for(Account a : acs ){
                        a.Membership_Status__c='DD Rejected';
                    }
                    delete deltrans;
                    update acs;
                }
                insert transactions;
            }
        }
    }  
}