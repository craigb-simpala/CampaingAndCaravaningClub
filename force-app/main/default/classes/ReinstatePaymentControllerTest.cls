@IsTest
private class ReinstatePaymentControllerTest {

    @IsTest
    static void getMembershipInfoNoSelectedSectionsTest(){
        TestDataFactory.createTestRecords();

        Account account = [SELECT Id FROM Account ORDER BY CreatedDate DESC LIMIT 1];

        Test.startTest();
        ReinstatePaymentController.MembershipInfo membershipInfo = ReinstatePaymentController.getMembershipInfo(account.Id);
        Test.stopTest();

        System.assertEquals(0, membershipInfo.associateMemberCost);
        System.assertEquals(144, membershipInfo.membershipCost);
        System.assertEquals(144, membershipInfo.totalCost);
        System.assert(membershipInfo.selectedSections.isEmpty());
    }


    @IsTest
    static void getMembershipInfoSelectedSectionsTest(){
        TestDataFactory.createTestRecords();

        constants sc = new constants();

        Account account = [SELECT Id FROM Account ORDER BY CreatedDate DESC LIMIT 1];

        List<Club_Opportunity_Product__c> opportunityProducts = [SELECT Account__c, Status__c, RecordType.DeveloperName, Product__r.Product_Detail__c, Product__r.Name FROM Club_Opportunity_Product__c LIMIT 1];

        for(Club_Opportunity_Product__c opportunityProduct : opportunityProducts) {
            opportunityProduct.Status__c = 'Cancelled';
            opportunityProduct.RecordTypeId = sc.sectionRecordTypeId;
        }

        update opportunityProducts;

        Test.startTest();
        ReinstatePaymentController.MembershipInfo membershipInfo = ReinstatePaymentController.getMembershipInfo(account.Id);
        Test.stopTest();

        System.assertEquals(0, membershipInfo.associateMemberCost);
        System.assertEquals(144, membershipInfo.membershipCost);
        System.assertEquals(288, membershipInfo.totalCost);
        System.assertEquals(1, membershipInfo.selectedSections.size());
    }

}