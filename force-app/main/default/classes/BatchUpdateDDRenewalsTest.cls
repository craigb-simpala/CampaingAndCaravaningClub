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
private class BatchUpdateDDRenewalsTest {

    static testMethod void UpdateDDRenewalsTest() {
        // TO DO: implement unit test
		TestDataFactory.createAccWithTomorrowRenewalDateTestRecords();
		
		Test.startTest();
		ID batchProcessId = Database.executeBatch(new BatchUpdateDDRenewals(),200);
		Test.stopTest();
		/*
		TestDataFactory.createRenewalOppTestRecords();
		
		
		Test.startTest();
		ID batchProcessId = Database.executeBatch(new BatchUpdateDDRenewals(),200);
		Test.stopTest();*/
    }
    
    @isTest static void batchUpdateDDRenewalsSchedulerTest(){
    	
    	
        TestDataFactory.createAccWithTomorrowRenewalDateTestRecords();

        String cronTime = '0 0 0 * * ? *';
        
        Test.startTest();
            
        // Schedule the test job
        String jobID = System.schedule('Create DD Transactions', cronTime, new BatchUpdateDDRenewalsScheduler());
          
        Test.stopTest();
                
        // Get the information from the CronTrigger API object  
        list<CronTrigger> cts = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        
        // Verify the job has been scheduled
        System.assertEquals(1, cts.size());  
    }

    @IsTest
    static void testYoungCamperToDigitalRenewal() {
        // Young Camper to Digital
        TestDataFactory.RenewalDataSetup dataSetup = new TestDataFactory.RenewalDataSetup();
        dataSetup.prodNameFrom = 'Young Camper';
        dataSetup.prodNameTo = 'Digital';
        dataSetup.paymentMethod = 'Direct Debit';
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

        Id opportunityRenewalRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Renewal' LIMIT 1].Id;
        Id membershipCodeRecordTypeId2 = [SELECT Id FROM RecordType WHERE SobjectType = 'Club_Opportunity_Product__c' AND DeveloperName = 'Membership_Code' LIMIT 1].Id;
        Id clubProductToId = [SELECT Id FROM Club_Product__c WHERE Name = 'Digital' LIMIT 1].Id;

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

        Payment_Method__c paymentMethod = new Payment_Method__c(
                Membership__c = accId,
                Start_Date__c = Date.today(),
                Active__c = true,
                Allow_DDI_Alert__c = true,
                Status__c = 'Active',
                Bank_Account_Name__c = 'John Smith',
                Bank_Account_Number__c = '12345678',
                Bank_Name__c = 'UKBank',
                Sort_Code__c = '121212'
        );
        insert paymentMethod;

        update new Account(Id = accId, Renewal_Date__c = Date.today());

        Test.startTest();
        Database.executeBatch(new BatchUpdateDDRenewals());
        Test.stopTest();

        System.assertEquals('Digital', [SELECT Id, Membership_Code__r.Name FROM Account WHERE Id = :accId].Membership_Code__r.Name, 'Membership Type should be changed to Digital!');
    }
}