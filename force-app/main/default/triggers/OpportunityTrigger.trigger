trigger OpportunityTrigger on Opportunity (after update,after insert) {
    if(GetProfileId.p.Name != 'Data Loader Sys Admin'){
        TriggerFactory.createHandler(Opportunity.sObjectType);    
    }         
}