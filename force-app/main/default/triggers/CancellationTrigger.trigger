trigger CancellationTrigger on Cancellation__c (after insert) {
    if(GetProfileId.p.Name != 'Data Loader Sys Admin'){
        TriggerFactory.createHandler(Cancellation__c.sObjectType);        
    } 
}