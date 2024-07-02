trigger AccountTrigger on Account (before update, after update, after undelete) {
    if(GetProfileId.p.Name != 'Data Loader Sys Admin'){
        TriggerFactory.createHandler(Account.sObjectType);
    }             
}