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
private class BatchCreateDDTransactionsTest {

    static testMethod void batchCreateDDTransactionsTest() {
    	
          TestDataFactory.createTestRecords();
          Account a = [select Id, Renewal_Date__c from Account];
          a.Renewal_Date__c = system.today().addDays(-1);
          update a;
            
          Test.startTest();
          ID batchProcessId = Database.executeBatch(new BatchCreateDDTransactions(),200);
          Test.stopTest();
            
            list<Transaction__c> wars = [SELECT Id FROM Transaction__c];
            system.debug(wars.size());
            //System.assertEquals(2, wars.size());
    }
    
    @isTest static void batchCreateDDTransactionsSchedulerTest(){
    	
    	
        TestDataFactory.createTestRecords();

        String cronTime = '0 0 0 * * ? *';
        
        Test.startTest();
            
        // Schedule the test job
        String jobID = System.schedule('Create DD Transactions', cronTime, new BatchCreateDDTransactionsScheduler());
          
        Test.stopTest();
                
        // Get the information from the CronTrigger API object  
        list<CronTrigger> cts = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        
        // Verify the job has been scheduled
        System.assertEquals(1, cts.size());  
    }
}