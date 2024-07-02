@IsTest
private class BatchAutoRenewMembershipsTest {
    @IsTest
    static void testBatchAutoRenewMembershipsScheduler() {
        TestDataFactory.createTestRecords();

        String cronTime = '0 0 0 * * ? *';

        Test.startTest();
        String jobId = System.schedule('Create Auto Renew Memberships', cronTime, new BatchAutoRenewMembershipsScheduler());
        Test.stopTest();

        // Get the information from the CronTrigger API object
        List<CronTrigger> cts = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];

        // Verify the job has been scheduled
        System.assertEquals(1, cts.size());
    }

    @IsTest
    static void testYouthDigitalToYoungCamperRenewMembership() {
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

        Id accId = TestDataFactory.prepareRecordsForMembershipRenewal(dataSetup);

        Id opportunityRenewalRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Renewal' LIMIT 1].Id;
        Id membershipCodeRecordTypeId2 = [SELECT Id FROM RecordType WHERE SobjectType = 'Club_Opportunity_Product__c' AND DeveloperName = 'Membership_Code' LIMIT 1].Id;
        Id clubProductToId = [SELECT Id FROM Club_Product__c WHERE Name = 'Young Camper' LIMIT 1].Id;

        Opportunity opp = new Opportunity(
                RecordTypeId = opportunityRenewalRecordType,
                Name = 'Renewal',
                StageName = 'Due',
                Amount = 0,
                AccountId = accId,
                CloseDate = Date.today()
        );
        insert opp;

        Club_Opportunity_Product__c clubOpportunityProduct = new Club_Opportunity_Product__c(
                RecordTypeId = membershipCodeRecordTypeId2,
                Status__c = 'Pending',
                Price__c = 0,
                Account__c = accId,
                Product__c = clubProductToId,
                Opportunity__c = opp.Id
        );
        insert clubOpportunityProduct;

        update new Account(Id = accId, Renewal_Date__c = Date.today());

        Test.startTest();
        Database.executeBatch(new BatchAutoRenewMemberships());
        Test.stopTest();

        System.assertEquals('Young Camper', [SELECT Id, Membership_Code__r.Name FROM Account WHERE Id = :accId].Membership_Code__r.Name, 'Membership Type should be changed to Young Camper!');
    }
}