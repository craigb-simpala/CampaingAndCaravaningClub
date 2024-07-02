/*
 * @Who   Alasdair Leggat <alasdair.leggat@weare4c.com>
 * @What  Test class for OpportunityPaymentHandler
 * @When  2019-08-29
 */

@isTest
public class OpportunityPaymentHandlerTest {

    @testSetup
    static void setup(){
        // test membership
        Account membership = new Account(
            Name = 'Test Membership',
            Renewal_Date__c = Date.today()
        );
        
        insert membership;
        
        // test payment method
		Payment_Method__c paymentMethod = new Payment_Method__c(
			RecordTypeId = Schema.SObjectType.Payment_Method__c.getRecordTypeInfosByName().get('Direct Debit').getRecordTypeId(),
			Membership__c = membership.Id,
            Status__c = 'Active'
		);
        
        insert paymentMethod;
        
        // test opp
        Opportunity opp = new Opportunity(
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId(),
            Name = 'Test Opp',
            AccountId = membership.Id,
            Payment_Method__c  = paymentMethod.Id,
            CloseDate = Date.today(),
            StageName = 'Prospecting'
        );
        
        insert opp;
        
        // test club product
        Club_Product__c clubProduct = new Club_Product__c(
            RecordTypeId = Schema.SObjectType.Club_Product__c.getRecordTypeInfosByName().get('Section').getRecordTypeId(),
            Name = 'Test Club Product'
        );
        
        insert clubProduct;
        
        // test club opp product
        Club_Opportunity_Product__c clubOppProduct = new Club_Opportunity_Product__c(
            RecordTypeId = Schema.SObjectType.Club_Opportunity_Product__c.getRecordTypeInfosByName().get('Section').getRecordTypeId(),
            Opportunity__c = opp.Id,
            Product__c = clubProduct.Id,
            Account__c  = membership.Id
        );
        
        insert clubOppProduct;
        
    }
    
    @isTest
    static void testOppsAndProductsReopened(){
        // update membership
        Account membership = [SELECT Id, Renewal_Date__c, Membership_Status__c FROM Account LIMIT 1].get(0);
        membership.Membership_Status__c = 'DD Rejected';
        update membership;
        
        // test memerbsip renewal date pushed back a year
        membership = [SELECT Id, Renewal_Date__c FROM Account LIMIT 1].get(0);
        System.assertEquals(Date.today().addDays(-365), membership.Renewal_Date__c);
        
        // test opportunity stage set to Due
        Opportunity opp = [SELECT Id, StageName FROM Opportunity LIMIT 1].get(0);
        System.assertEquals('Due', opp.StageName);
        
        // test club product status set to Pending
        Club_Opportunity_Product__c clubProduct = [SELECT Id, Status__c FROM Club_Opportunity_Product__c LIMIT 1].get(0);
        System.assertEquals('Pending', clubProduct.Status__c);
		
    }
}