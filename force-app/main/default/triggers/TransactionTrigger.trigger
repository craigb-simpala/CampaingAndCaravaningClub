trigger TransactionTrigger on Transaction__c (after update,after insert) {
    if(GetProfileId.p.Name != 'Data Loader Sys Admin'){
        TriggerFactory.createHandler(Transaction__c.sObjectType);   
    }          
}