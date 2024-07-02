/*
 * @Who   Alasdair Leggat <alasdair.leggat@weare4c.com>
 * @What  Class to reopen Opps and Club Products when Direct Debit payments rejected
 * @When  2019-08-29
 */

public class OpportunityPaymentHandler {
    private static final String REJECTED_STATUS = 'DD Rejected';

    /*
     *    reopenOppsAndProducts
     *    Method to reopen Opps and Club Products with Rejected Payment Methods
     *    Return void
     */
    public static void reopenOppsAndProducts(Map<Id, Account> oldMemberships, List<Account> updatedMemberships){
        // get rejected payment methods
        List<Account> rejectedMemberships = getRejectedMemberships(oldMemberships, updatedMemberships);
        
        if(rejectedMemberships.isEmpty()){
            return;
        }
        
        // get opportunities
        List<Opportunity> opps = getOpportunities(rejectedMemberships);
        
        if(opps.isEmpty()){
            return;
        }
        
        // get club opportunity products
        List<Club_Opportunity_Product__c> clubOppProducts = getOpportunityProducts(rejectedMemberships);
        
        if(clubOppProducts.isEmpty()){
            return;
        }
        
        // update opportunities stage
        updateOpportunitiesStage(opps);
        
        // update club opportunity products status
        updateClubOppProductsStatus(clubOppProducts);
        
        // update membership renewal dates
        updateMembershipRenewalDates(rejectedMemberships);
          
    }
    
    
    /*
     *    getRejectedMemberships
     *    Method to filter Memberships with Status changed to DD Rejected and return them
     *    Return List<Account>
     */
    private static List<Account> getRejectedMemberships(Map<Id, Account> oldMemberships, List<Account> updatedMemberships){
        Set<Id> rejectedMembershipIds = new Set<Id>();
        
        // loop over new memberhips
        for(Account updatedMembership: updatedMemberships){
            
            // get old payment method
            Account oldMembership = oldMemberships.get(updatedMembership.Id);
            
            // check if status changed to DD Rejected
            if(updatedMembership.Membership_Status__c  == REJECTED_STATUS && oldMembership.Membership_Status__c  != REJECTED_STATUS){
                rejectedMembershipIds.add(updatedMembership.Id);
            }
        }
        
        // set which opp record types to filter on
        List<String> oppRecordTypes = new List<String>{
            'Renewal',
            'New Membership',
            'Reinstatement'
        };
		
        // get payment methods
        List<Account> memberships = [SELECT Id, Renewal_Date__c,
                                     (
                                         SELECT Id, StageName
                                         FROM Opportunities
                                         WHERE RecordTypeId IN :getOppRecordTypeIds(oppRecordTypes)
                                         ORDER BY CreatedDate DESC
                                         LIMIT 1
                                     ),
                                     (
                                         SELECT Id, Status__c
                                         FROM Club_Opportunity_Products__r
                                         ORDER BY CreatedDate DESC
                                         LIMIT 1
                                     )
                                     FROM Account 
                                     WHERE Id IN :rejectedMembershipIds];
        
        return memberships;
        
    }
    
    
    /*
     *    getOppRecordTypeIds
     *    Method to get record type ids
     *    Return List<Id>
     */
    private static List<Id> getOppRecordTypeIds(List<String> recordTypes){
        List<Id> recordTypeIds = new List<Id>();
        
        // get opp record type ids
        for(String recordType: recordTypes){
            recordTypeIds.add(
            	Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(recordType).getRecordTypeId()
            );
        }
        
        return recordTypeIds;
    }
    
    
    /*
     *    getOpportunities
     *    Method to get club opportunities
     *    Return List<Opportunity>
     */
    private static List<Opportunity> getOpportunities(List<Account> memberships){
        List<Opportunity> opps = new List<Opportunity>();
        
        // loop over memberships
        for(Account membership: memberships){
            opps.addAll(membership.Opportunities);
        }
        
        return opps;
    }
    
    /*
     *    getOpportunityProducts
     *    Method to get club opportunity products
     *    Return List<Club_Opportunity_Product__c>
     */
    private static List<Club_Opportunity_Product__c> getOpportunityProducts(List<Account> memberships){
        List<Club_Opportunity_Product__c> clubOppProducts = new List<Club_Opportunity_Product__c>();
        
        // loop over memberships
        for(Account membership: memberships){
            clubOppProducts.addAll(membership.Club_Opportunity_Products__r);
        }
        
        return clubOppProducts;
    }
    
    
    /*
     *    updateMembershipRenewalDates
     *    Method to update parent Memberships renewal date field back by 1 year
     *    Return void
     */
    private static void updateMembershipRenewalDates(List<Account> memberships){            
		// loop over memberships
        for(Account membership: memberships){
            // get renewal date value
            Date renewalDate = membership.Renewal_Date__c;
            
            // put renewal date back 1 year
            membership.Renewal_Date__c = renewalDate.addDays(-365);
        }    
        
        System.debug('memberships: ' + memberships);
        
        // update membership
        try{
            update memberships;
        } catch(DMLException e){
            System.debug('[OpportunityPaymentHandler] Error updating Memberships: ' + e.getMessage());
        }
        
    }
    

	/*
     *    updateOpportunitiesStage
     *    Method to update Opportunities stages to Due 
     *    Return void
     */    
    private static void updateOpportunitiesStage(List<Opportunity> opps){
        
        // loop over payment methods
        for(Opportunity opp: opps){
            opp.StageName = 'Due';
        }
        
        // update opp
        try{
            update opps;
        } catch(DMLException e){
            System.debug('[OpportunityPaymentHandler] Error updating Opportunities: ' + e.getMessage());
        }
    }
    

	/*
     *    updateClubOppProductsStatus
     *    Method to update club opportunity products statuses to Pending
     *    Return void
     */     
    private static void updateClubOppProductsStatus(List<Club_Opportunity_Product__c> clubOppProducts){
        // loop over club opp products and update status field
        for(Club_Opportunity_Product__c clubOppProduct: clubOppProducts){
            clubOppProduct.Status__c = 'Pending';
        }
        
        // update club opp products
        try{
            update clubOppProducts;
        } catch(DMLException e){
            System.debug('[OpportunityPaymentHandler] Error updating Club Opportunity Products: ' + e.getMessage());
        }
    }
    

}