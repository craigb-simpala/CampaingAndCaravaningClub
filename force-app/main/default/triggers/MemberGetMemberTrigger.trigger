trigger MemberGetMemberTrigger on Member_Get_Member__c (after insert) {
    if(GetProfileId.p.Name != 'Data Loader Sys Admin'){
        TriggerFactory.createHandler(Member_Get_Member__c.sObjectType); 
    }          
}