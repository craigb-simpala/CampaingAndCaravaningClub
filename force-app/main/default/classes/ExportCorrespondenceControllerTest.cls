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
private class ExportCorrespondenceControllerTest {
	
	static ExportCorrespondenceController correspondence;
	static PageReference page;
	static Correspondence__c cor;
	
	static void init(){
	    
        TestDataFactory.createCorrespondenceRecord();
    	//cor = [Select Id, Correspondence_Type__c, Cancellation__c FROM Correspondence__c];
		correspondence = new ExportCorrespondenceController();  
		
	}

    static testMethod void ExportCorrespondenceControllerTestsearch() {
        // TO DO: implement unit test
        init();
        page = correspondence.search();
        
    }

    static testMethod void ExportCorrespondenceControllerTestGetTransactions() {
        // TO DO: implement unit test
        init();
        List<ExportCorrespondenceController.corrSelectWrapper> transactions = correspondence.transactions;
        
    }

    static testMethod void ExportCorrespondenceControllerTestGetCon() {
        // TO DO: implement unit test
        init();
        ApexPages.StandardSetController con = correspondence.con;        
    }

    static testMethod void ExportCorrespondenceControllerTestGetVariable() {
        // TO DO: implement unit test
        init();
        Boolean hasNext = correspondence.hasNext;  
        Boolean hasPrevious = correspondence.hasPrevious;  
        Integer numResults = correspondence.numResults;  
        Integer numstart = correspondence.numstart;  
        Integer numend = correspondence.numend;  
        Integer pageNumber = correspondence.pageNumber;  
        long batchId = correspondence.batchId;  
       	List<Correspondence__c> transToAdd = correspondence.transToAdd;        
    }

    static testMethod void ExportCorrespondenceControllerTestVoidFunction() {
        // TO DO: implement unit test
        init();
        correspondence.first(); 
        correspondence.last(); 
        correspondence.previous(); 
        correspondence.next();        
    }

    static testMethod void ExportCorrespondenceControllerTestExport() {
        // TO DO: implement unit test
        init();
        page = correspondence.export();        
    }
}