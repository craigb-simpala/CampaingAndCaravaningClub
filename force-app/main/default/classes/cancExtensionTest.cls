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
public with sharing class cancExtensionTest {

    static testMethod void cancTestFull() {
        // TO DO: implement unit test
        
    
       Account acc = new Account (Name = 'Patel');
       insert acc;
       
       Cancellation__c can = new Cancellation__c(Membership__c = acc.Id, Cancellation_Type__c='Cancelled');
       insert can;
         
       Test.setCurrentPageReference(new PageReference('Cancellations'));
       System.currentPageReference().getParameters().put('Membership__c', acc.Id);
       cancExtension ce = new cancExtension(new ApexPages.StandardController(can));
       
       PageReference p = ce.back();        
       
        //ApexPages.StandardController sc = new ApexPages.StandardController();
        
            
         
        
    }
}