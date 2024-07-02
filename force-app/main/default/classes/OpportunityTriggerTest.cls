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
private class OpportunityTriggerTest {

    static testMethod void afterInsertTest() {
        // TO DO: implement unit test

               
		RecordType rt = [Select Id from RecordType Where SobjectType = 'Contact' AND DeveloperName='Lead' limit 1 ];
		Account acc = new Account (Name = 'Patel');
		insert acc;        
        
		Date sDate = Date.newInstance(2015, 10, 15);
		    
		RecordType rt3 = [Select Id from RecordType Where SobjectType = 'Opportunity' AND Name='New Membership' limit 1 ];
		Opportunity opp = new Opportunity(Name='Santosh', CloseDate= sDate,StageName='Closed Won', Account=acc, RecordTypeId=rt3.Id);
		insert opp;
		    
		RecordType rt1 = [Select Id from RecordType Where SobjectType = 'Opportunity' AND Name='Reinstatement' limit 1 ];
		Opportunity opp1 = new Opportunity(Name='Santosh', CloseDate= sDate,StageName='Closed Won', Account=acc, RecordTypeId=rt1.Id);
		insert opp1;
        
        RecordType secRt = [Select Id from RecordType Where SobjectType = 'Club_Product__c' AND DeveloperName='Section' limit 1 ];
        Club_Product__c seccp = new Club_Product__c(name = 'testing',Product_Detail__c = 'testing Club Product', RecordTypeId =secRt.Id);
     	insert seccp;
        
		RecordType rt2 = [Select Id from RecordType Where SobjectType = 'Club_Opportunity_Product__c' AND Name='Section' limit 1 ];
        Club_Opportunity_Product__c cprods = new Club_Opportunity_Product__c(status__c = 'Cancelled',Account__c = acc.Id, RecordTypeId =rt2.Id, Opportunity__c = opp1.Id, Product__c =seccp.Id);
        
        
        
        
        
        
        
    }
}