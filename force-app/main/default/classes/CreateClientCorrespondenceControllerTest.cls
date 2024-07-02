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
private class CreateClientCorrespondenceControllerTest {
	
	static Account acc;
	static Contact con;
	static CreateClientCorrespondenceController correspondence;
	static PageReference page;
	
	static void init(){
	    
        TestDataFactory.createRenewalOppTestRecords();
    	acc = [Select Id, Renewal_Date__c, Membership_Code__c, Payment_Method2__c FROM Account];
    	con = [Select Id, accountid FROM Contact limit 1];
		correspondence = new CreateClientCorrespondenceController(new ApexPages.StandardController(con));  
		
	}

    static testMethod void CreateClientCorrespondenceControllerTestsaveCorr() {
        init();
	    page = correspondence.saveCorr();
    }
    
    static testMethod void CreateClientCorrespondenceControllerTestGetOpp(){
    	init();
    	Opportunity opp = correspondence.opp;
    }
    
    static testMethod void CreateClientCorrespondenceControllerTestGetCanclist(){
    	init();
        Cancellation__c can = new Cancellation__c(Cancellation_Type__c = 'Cancelled', Membership__c = acc.id, Stop_Communication__c =  true);
        insert can;
        List<Cancellation__c> canclist = correspondence.canclist;
    	
    }
}