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
@isTest(SeeAllData=true)
private class MemberGetMemberTriggerTest {

        static testMethod void myUnitTest() {
        
       
       system.debug('inside the myUnitTest');
       
        Account acc = new Account();
       // Contact con = new Contact();
        contact con2 = new Contact();
        //Contact con3 = new Contact();
        Constants c = new constants();
        Lead lea = new Lead();
        Correspondence__c corr = new Correspondence__c();
        Member_Get_Member__c mgm = new Member_Get_Member__c();
        
        
       lea.FirstName = 'Test First';
       lea.LastName = 'Test Last';
       lea.Company = 'Test Co';
       system.debug('inserting lead');
       insert lea;  
       system.debug('inserted lead ' + lea.Id);  
            
        acc.Name = 'Paul';
        acc.Renewal_Date__c = date.parse('19/01/2017');
        acc.Payment_Method2__c = 'Direct Debit';
       system.debug('inserting Account');
        insert acc;
       system.debug('inserted Account ' + acc.Id);
            
            
  
        
        con2.AccountId = acc.Id;
        con2.RecordTypeId = c.leadContactRecordTypeId;
        con2.Salutation = 'Mr';
        con2.FirstName = 'Test';
        con2.LastName = 'Testing';
        insert con2;

        mgm.existing_member__c = con2.id;        
        mgm.Gift__c = 'Medium Fleece';
        mgm.Introduced_Membership__c = acc.id;
        insert mgm;
        
       corr.id = mgm.name;
       corr.Membership__c = acc.id;
       corr.gift_code__c = mgm.Gift__c;
       corr.Correspondence_Type__c = 'Member Get Member';
       corr.Correspondence_date__c =  system.today(); 
       corr.Lead_Member_Salutation__c =  con2.Salutation;
       corr.Lead_Member_First_Name__c =  con2.FirstName;
       corr.Lead_Member_Last_Name__c =  con2.LastName;
       insert corr;
        
        
            
        
        
    }
}