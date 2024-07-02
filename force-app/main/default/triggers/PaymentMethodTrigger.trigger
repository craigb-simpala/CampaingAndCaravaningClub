trigger PaymentMethodTrigger on Payment_Method__c (after insert, after update, before insert) {
    if(GetProfileId.p.Name != 'Data Loader Sys Admin'){
        TriggerFactory.createHandler(Payment_Method__c.sObjectType);    
    }         
}