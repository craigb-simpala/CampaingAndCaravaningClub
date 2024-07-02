/*
 * @Who   Alasdair Leggat <alasdair.leggat@weare4c.com>
 * @What  Test class for MembershipRenewalFilterController 
 * @When  2019-09-05
 */

@isTest
public class MembershipRenewalFilterControllerTest {

    @testSetup
    static void setup(){
        List<Account> memberships = new List<Account>();
        
        // test cancelled membership
        Account cancelledMembership = new Account(
            Name = 'Cancelled',
            Membership_Status__c = 'Cancelled'
        );
        memberships.add(cancelledMembership);
        
        // test non renewer, renewal over 2 months from today
        Account nonRenewerOutsideRenewalPeriod = new Account(
            Name = 'Non Renewer, Outside Renewal Period',
            Membership_Status__c = 'Non-Renewer',
            Renewal_Date__c = Date.today().addDays(90)
        );
        memberships.add(nonRenewerOutsideRenewalPeriod);
        
        // test non renewer, renewal within 2 months of today
        Account nonRenewerWithinRenewalPeriod = new Account(
            Name = 'Non Renewer, Within Renewal Period',
            Membership_Status__c = 'Non-Renewer',
            Renewal_Date__c = Date.today().addDays(30)
        );
        memberships.add(nonRenewerWithinRenewalPeriod);
        
        insert memberships;
    }
    
    @isTest
    static void testCancelledStatus(){
        Id membershipId = [SELECT Id FROM Account WHERE Name='Cancelled' LIMIT 1].get(0).Id;
        
        // run filter method
        String returnMessage = MembershipRenewalFilterController.doFilterMembership(membershipId);
        
        // check return message is the cancelled one
        System.assertEquals(MembershipRenewalFilterController.CANCELLED_MSG, returnMessage);
    }
    
    @isTest
    static void testNonRenewerOutsideRenewalPeriod(){
        // membership not in renewal period yet
        Id membershipId = [SELECT Id FROM Account WHERE Name='Non Renewer, Outside Renewal Period' LIMIT 1].get(0).Id;
        
        // run filter method
        String returnMessage = MembershipRenewalFilterController.doFilterMembership(membershipId);
        
        // check return message is the cancelled one
        System.assertEquals(MembershipRenewalFilterController.RENEWAL_MSG, returnMessage);
    }
    
    @isTest
    static void testNonRenewerWithinRenewalPeriod(){
        // membership in renewal period 
        Account membership = [SELECT Id FROM Account WHERE Name='Non Renewer, Within Renewal Period' LIMIT 1].get(0);
        
        // run filter method
        String returnMessage = MembershipRenewalFilterController.doFilterMembership(membership.Id);
        
        // check return message is the cancelled one
        System.assertEquals(MembershipRenewalFilterController.NON_RENEWER_MSG, returnMessage);
        
        MembershipRenewalFilterController.doNonRenewalContinue(membership.Id);
        
        // check membership status updated
        membership = [SELECT Id, Membership_Status__c FROM Account WHERE Name='Non Renewer, Within Renewal Period' LIMIT 1].get(0);
        
        System.assertEquals('Paid', membership.Membership_Status__c);
    }

    @isTest
    static void testNonRenewerWithinRenewalPeriodRenewableProduct(){
        Club_Product__c productFrom = new Club_Product__c(Renewable__c=true);
        Club_Product__c productTo = new Club_Product__c(Renewable__c=true);
        insert new List<Club_Product__c>{productTo,productFrom};

        Opportunity opp = new Opportunity(Name='Test opp',StageName='Prospecting',CloseDate=Date.today());
        insert opp;
        // membership in renewal period 
        Account membership = [SELECT Id FROM Account WHERE Name='Non Renewer, Within Renewal Period' LIMIT 1].get(0);

        Contact contact = new Contact(AccountId=membership.Id, LastName='Test con');
        insert contact;

        Id sectionRecordTypeId = Schema.SObjectType.Club_Opportunity_Product__c.getRecordTypeInfosByName().get('Membership Code').getRecordTypeId();
        Club_Opportunity_Product__c oppProduct = new Club_Opportunity_Product__c(Status__c='Active',Account__c=membership.Id, Product__c = productFrom.Id, Opportunity__c=opp.Id,RecordTypeId=sectionRecordTypeId);
        insert oppProduct;

        Club_Product_Change__c productChange = new Club_Product_Change__c(Allow_Auto_Switch__c=true, From__c=productFrom.Id, To__c=productTo.Id);
        insert productChange;
        // run filter method
        String returnMessage = MembershipRenewalFilterController.doFilterMembership(membership.Id);
        
        // check return message is the cancelled one
        System.assertEquals(MembershipRenewalFilterController.NON_RENEWER_MSG, returnMessage);
        
        MembershipRenewalFilterController.doNonRenewalContinue(membership.Id);
        
        // check membership status updated
        membership = [SELECT Id, Membership_Status__c FROM Account WHERE Name='Non Renewer, Within Renewal Period' LIMIT 1].get(0);
        
        System.assertEquals('Paid', membership.Membership_Status__c);
    }
}