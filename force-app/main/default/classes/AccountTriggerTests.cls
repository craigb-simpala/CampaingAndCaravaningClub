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
private class AccountTriggerTests {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Account a = new Account();
        Association__c da = new Association__c();
        Association__c region = new Association__c();
        DA_Postcode__c pc = new DA_Postcode__c();
        constants c = new constants();
        
        region.RecordTypeId = c.accRegionRecordTypeId;
        region.Name = 'Testing Region';
        region.Region_Code__c = '101';
        insert region;
        
        da.RecordTypeId = c.accDaRecordTypeId;
        da.Name = 'Test D A';
        da.Parent_Region__c = region.Id;
        da.Region_Code__c = region.Region_Code__c;
        insert da;
        
        pc.Association_Name__c = da.Id;
        pc.Association_Code__c = da.Region_Code__c;
        pc.Parent_Region_Name__c = region.Name;
        pc.Postcode_Part_1__c = 'TE1';
        insert pc;
        
        a.Name = 'Test Membership';
        a.District_Association__c = da.Id;
        a.BillingPostalCode = 'TE1 0YZ';
        insert a;
        
    }
}