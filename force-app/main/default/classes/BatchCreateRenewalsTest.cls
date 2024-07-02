/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class BatchCreateRenewalsTest {

    static testMethod void CreateRenewalsTest() {
    	TestDataFactory.createAccWithSixWeeksRenewalDateTestRecords();

		Test.startTest();
		ID batchProcessId = Database.executeBatch(new BatchCreateRenewals(),200);
		Test.stopTest();

		//list<Account> acc1 = [SELECT Id FROM Account];
		//System.assertEquals(0, acc1.size());

    }
    static testMethod void CreateRenewalsReRunTest() {
    	TestDataFactory.createAccReRunWithSixWeeksRenewalDateTestRecords();

		Test.startTest();
		RerunBatchRenewalsLaunch.reRunBatch();
		Test.stopTest();

		//list<Account> acc1 = [SELECT Id FROM Account];
		//System.assertEquals(0, acc1.size());

    }

    @isTest static void batchCreateRenewalsSchedulerTest(){


        TestDataFactory.createTestRecords();

        String cronTime = '0 0 0 * * ? *';

        Test.startTest();

        // Schedule the test job
        String jobID = System.schedule('Create DD Transactions', cronTime, new BatchCreateRenewalsScheduler());

        Test.stopTest();

        // Get the information from the CronTrigger API object  
        list<CronTrigger> cts = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];

        // Verify the job has been scheduled
        System.assertEquals(1, cts.size());
    }

    @IsTest
    static void testYouthDigitalToYoungCamperRenewal() {
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

        Test.startTest();
        Database.executeBatch(new BatchCreateRenewals());
        Test.stopTest();

        System.assertEquals(2, [SELECT COUNT() FROM Club_Opportunity_Product__c WHERE Account__c =:accId], 'There should be 2 Club Opportunity Records : New Membership and Renewal!');
        System.assertEquals('Young Camper', [SELECT Id, Product__r.Name FROM Club_Opportunity_Product__c WHERE Opportunity__r.Name = 'Renewal' LIMIT 1].Product__r.Name, 'Young Camper should be renewal product!');
    }
    @IsTest
    static void testYouthDigitalToYoungCamperRenewalRerun() {
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
		Account a = [SELECT id,Re_run_Batch_Renewal__c from account where id = : accId];
        a.Re_run_Batch_Renewal__c = true;
        update a;
        Test.startTest();
        Database.executeBatch(new RerunBatchCreateRenewals());
        Test.stopTest();
 		Account aAfter = [SELECT id,Re_run_Batch_Renewal__c from account where id = : accId];
        System.assertEquals(2, [SELECT COUNT() FROM Club_Opportunity_Product__c WHERE Account__c =:accId], 'There should be 2 Club Opportunity Records : New Membership and Renewal!');
        System.assertEquals('Young Camper', [SELECT Id, Product__r.Name FROM Club_Opportunity_Product__c WHERE Opportunity__r.Name = 'Renewal' LIMIT 1].Product__r.Name, 'Young Camper should be renewal product!');
    	System.assertEquals(false, aAfter.Re_run_Batch_Renewal__c);
    }
    @IsTest
    static void testYouthDigitalToDigitalRenewal() {
        TestDataFactory.RenewalDataSetup dataSetup = new TestDataFactory.RenewalDataSetup();
        dataSetup.prodNameFrom = 'Youth - Digital';
        dataSetup.prodNameTo = 'Digital';
        dataSetup.memberBirthdate = Date.today().addYears(-18);
        dataSetup.renewalDate = Date.today().addMonths(2);
        dataSetup.youthTestDate = null;
        dataSetup.VIClass1 = 'Youth';
        dataSetup.VIClass2 = 'Digital';
        dataSetup.minAge1 = 12;
        dataSetup.minAge2 = 18;
        dataSetup.maxAge1 = 17;
        dataSetup.maxAge2 = null;

        Id accId = TestDataFactory.prepareRecordsForMembershipRenewal(dataSetup);

        Test.startTest();
        Database.executeBatch(new BatchCreateRenewals());
        Test.stopTest();

        System.assertEquals(2, [SELECT COUNT() FROM Club_Opportunity_Product__c WHERE Account__c =:accId], 'There should be 2 Club Opportunity Records : New Membership and Renewal!');
        System.assertEquals('Digital', [SELECT Id, Product__r.Name FROM Club_Opportunity_Product__c WHERE Opportunity__r.Name = 'Renewal' LIMIT 1].Product__r.Name, 'Young Camper should be renewal product!');
    }

    @IsTest
    static void testYoungCamperToDigitalRenewal() {
        TestDataFactory.RenewalDataSetup dataSetup = new TestDataFactory.RenewalDataSetup();
        dataSetup.prodNameFrom = 'Young Camper';
        dataSetup.prodNameTo = 'Digital';
        dataSetup.paymentMethod = 'Cash/Cheque';
        dataSetup.memberBirthdate = Date.today().addYears(-25);
        dataSetup.renewalDate = Date.today().addMonths(2);
        dataSetup.youthTestDate = null;
        dataSetup.VIClass1 = 'YoungCamper';
        dataSetup.VIClass2 = 'Digital';
        dataSetup.minAge1 = 18;
        dataSetup.minAge2 = 18;
        dataSetup.maxAge1 = 25;
        dataSetup.maxAge2 = null;

        Id accId = TestDataFactory.prepareRecordsForMembershipRenewal(dataSetup);

        Test.startTest();
        Database.executeBatch(new BatchCreateRenewals());
        Test.stopTest();

        System.assertEquals(2, [SELECT COUNT() FROM Club_Opportunity_Product__c WHERE Account__c =:accId], 'There should be 2 Club Opportunity Records : New Membership and Renewal!');
        System.assertEquals('Renewal', [SELECT Subject FROM Task WHERE WhatId =:accId LIMIT 1].Subject, 'There should be task with \'Renewal\' subject!');
        System.assertEquals('Digital', [SELECT Id, Product__r.Name FROM Club_Opportunity_Product__c WHERE Opportunity__r.Name = 'Renewal' LIMIT 1].Product__r.Name, 'Digital should be renewal product!');
    }
}