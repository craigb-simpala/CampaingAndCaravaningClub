@IsTest
private class ChangeMembershipPaymentControllerTest {

    @IsTest
    static void getPaymentOptionsTest() {
        TestDataFactory.RenewalDataSetup dataSetup = new TestDataFactory.RenewalDataSetup();
        dataSetup.prodNameFrom = 'Youth - Digital';
        dataSetup.prodNameTo = 'Young Camper';
        dataSetup.paymentMethod = 'Direct Debit';
        dataSetup.memberBirthdate = Date.today().addYears(-18);
        dataSetup.renewalDate = Date.today().addMonths(2);
        dataSetup.youthTestDate = Date.today();
        dataSetup.VIClass1 = 'Youth';
        dataSetup.VIClass2 = 'YoungCamper';
        dataSetup.minAge1 = 12;
        dataSetup.minAge2 = 18;
        dataSetup.maxAge1 = 17;
        dataSetup.maxAge2 = 25;

        TestDataFactory.prepareRecordsForMembershipRenewal(dataSetup);

        Test.startTest();
        List<String> paymentOptions = ChangeMembershipPaymentController.getPaymentOptions('Youth - Digital');
        Test.stopTest();

        System.assertEquals(3, paymentOptions.size());
        System.assert(paymentOptions.contains('Direct Debit'));
    }

    @IsTest
    static void updateLeadTest() {

        Lead lead = new Lead();
        lead.LastName = 'test';
        lead.Company = 'test';
        insert lead;

        List<Lead> leadsBefore = [SELECT Id FROM Lead];

        lead.Payment_Method__c = 'Direct Debit';

        Test.startTest();
        ChangeMembershipPaymentController.updateLead(JSON.serialize(lead));
        Test.stopTest();

        List<Lead> leadsAfter = [SELECT Payment_Method__c FROM Lead];

        System.assertEquals(leadsBefore.size(), leadsAfter.size());
        System.assertEquals(1, leadsAfter.size());
        System.assertEquals('Direct Debit', leadsAfter.get(0).Payment_Method__c);
    }
}