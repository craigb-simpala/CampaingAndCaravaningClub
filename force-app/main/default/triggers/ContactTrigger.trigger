trigger ContactTrigger on Contact (before update,after update,after insert) {
    if(GetProfileId.p.Name != 'Data Loader Sys Admin'){
        TriggerFactory.createHandler(Contact.sObjectType); 
    }            
}