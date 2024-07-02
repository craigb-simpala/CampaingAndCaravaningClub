@IsTest
private class RenewMembershipPaymentControllerTest {
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
        List<String> paymentOptions = RenewMembershipPaymentController.getPaymentOptions('Youth - Digital');
        Test.stopTest();

        System.assertEquals(3, paymentOptions.size());
        System.assert(paymentOptions.contains('Direct Debit'));
    }

    @IsTest
    static void createLeadTest() {

        List<Lead> leadsBefore = [SELECT Id FROM Lead];

        Lead lead = new Lead();
        lead.LastName = 'test';
        lead.Company = 'test';

        Test.startTest();
        RenewMembershipPaymentController.createLead(JSON.serialize(lead));
        Test.stopTest();

        List<Lead> leadsAfter = [SELECT Id FROM Lead];

        System.assertNotEquals(leadsBefore.size(), leadsAfter.size());
        System.assertEquals(1, leadsAfter.size());
    }
}