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
private class CloneTransactionControllerTest {
	
	static CloneTransactionController transa;
	static PageReference page;
	static Transaction__c t;
	
	static void init(){
	    
        TestDataFactory.createTransactionRecord();
    	t = [Select Id, Transaction_Date__c, Transaction_Type__c, Amount__c, Status__c, Payment_Method__c, Payment_Method__r.Membership__c FROM Transaction__c WHERE Status__c = 'Rejected'];
		transa = new CloneTransactionController(new ApexPages.StandardController(t));  
		
	}

    static testMethod void CloneTransactionControllerTestdmlOperation() {
	    init();
	    page = transa.dmlOperation();
        
    }
}