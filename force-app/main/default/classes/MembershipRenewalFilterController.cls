/*
 * @Who   Alasdair Leggat <alasdair.leggat@weare4c.com>
 * @What  Class to filter Memberships on renewal
 * @When  2019-09-04
 */

public class MembershipRenewalFilterController {
    private final static String CANCELLED_STATUS = 'Cancelled';
    private final static String NON_RENEWER_STATUS = 'Non-Renewer';
    @TestVisible private final static String CANCELLED_MSG = 'This membership has been cancelled. Please use Reinstate button to reinstate the membership.';
    @TestVisible private final static String RENEWAL_MSG = 'This membership is not yet within the renewal period. Please use Reinstate button to reinstate the membership.';
    @TestVisible private final static String NON_RENEWER_MSG = 'This membership has been set to Non-Renewer. In order to proceed, a new Renewal record will need to be created. Continue?';
    @TestVisible private final static String CONTINUE_RENEWAL = 'Please, click the "Continue" button to renew this membership.';

    @AuraEnabled
    public static String doFilterMembership(Id recordId){
        System.debug('[doFilterMembership]');
        // get membership
        Account membership = getMembership(recordId);

        // apply filters
        return membershipStatusFilter(membership);
    }
    
    @AuraEnabled
    public static void doNonRenewalContinue(Id recordId){
        System.debug('[doNonRenewalContinue]');
        // get membership
        Account membership = new Account(
            Id = recordId
        );
        
        // set membership status to paid
        updateMembershipStatus(membership);
        
        // call BatchCreateRenewals
        executeBatchCreateRenewals(membership.Id);

        // redirect to existing membership renewal page
        renewMembershipPageRedirect();
    }

     @AuraEnabled
    public static void redirect(){
        renewMembershipPageRedirect();
    }
    
    /*
     *    getMembership
     *    Method to get membership based on passed in id
     *    Return Account
     */
    private static Account getMembership(Id recordId){
        List<Account> accounts = [SELECT Id, Membership_Status__c, Renewal_Date__c FROM Account WHERE Id = :recordId LIMIT 1];
        
        if(accounts.isEmpty()){
            return null;
        }
        return accounts.get(0);
        
    }
    
    /*
     *    membershipStatusFilter
     *    Method to filter on membership status
     *    Return Account
     */
    private static String membershipStatusFilter(Account membership){
        System.debug('[membershipStatusFilter]');
        
        // check membership status
        if(membership.Membership_Status__c == CANCELLED_STATUS){
            return CANCELLED_MSG;
        } else if(membership.Membership_Status__c == NON_RENEWER_STATUS){
            return renewalDateFilter(membership);  
        }
        
        return CONTINUE_RENEWAL;
    }
    
    /*
     *    renewalDateFilter
     *    Method to filter on renewal date
     *    Return String
     */
    private static String renewalDateFilter(Account membership){
        System.debug('[renewalDateFilter] '+membership.Renewal_Date__c.monthsBetween(Date.today()));
        
        // check renewal date within 2 months from today
        Date today = Date.today();
        Integer monthsBetween = today.monthsBetween(membership.Renewal_Date__c);
        if(monthsBetween >= 0 && monthsBetween <= 2){
            return NON_RENEWER_MSG;
        }
            
        return RENEWAL_MSG;
    }
    
    /*
     *    updateMembershipStatus
     *    Method to update membership status
     *    Return void
     */
    private static void updateMembershipStatus(Account membership){
        System.debug('[updateMembershipStatus]: membership' + membership);
        membership.Membership_Status__c = 'Paid';
        
        try{
            update membership;
        } catch(DMLException e){
            System.debug('[MembershipRenewalFilterController] Problem updating membership status: ' + e.getMessage());
        }
    }
    
    /*
     *    executeBatchCreateRenewals
     *    Method to run BatchCreateRenewals batch class
     *    Return void
     */
    private static void executeBatchCreateRenewals(Id membershipId){
        System.debug('[executeBatchCreateRenewals]');
        BatchCreateRenewals createRenewals = new BatchCreateRenewals(membershipId);
        Database.executeBatch(createRenewals);
    }
    
    /*
     *    renewMembershipPageRedirect
     *    Method to redirect to existing renew membership page
     *    Return void
     */
    private static void renewMembershipPageRedirect(){
        System.debug('[doNonRenewalContinue]');

        PageReference renewMembershipPage = Page.RenewMembership;
        renewMembershipPage.setRedirect(true);
    }

}