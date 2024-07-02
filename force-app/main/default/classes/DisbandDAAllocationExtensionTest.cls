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


public with sharing class DisbandDAAllocationExtensionTest {
	
	static testMethod void DisbandDAAllocationExtensionTest (){
		
		Account a = new Account();
		DA_Postcode__c pc = new DA_Postcode__c();
		Association__c region = new Association__c();
		Association__c da = new Association__c();
		Association__c da2 = new Association__c();
		constants c = new constants();
		DA_Postcode__c p = new DA_Postcode__c();
		Correspondence__c cor = new Correspondence__c();
		RecordType rt = [Select Id from RecordType Where SobjectType = 'Contact' AND DeveloperName='Lead' limit 1 ];
		
		region.RecordTypeId = c.accRegionRecordTypeId;
	    region.Name = 'Testing Region';
	    region.Region_Code__c = '101';
	    region.Postcode_Part_1__c = 'M50';
	    region.Postcode_Part_2__c = '2YZ';
	    region.RecordTypeId = c.accRegionRecordTypeId;
	    insert region;
	    
	    da.RecordTypeId = c.accDaRecordTypeId;
	    da.Name = 'Test D A';
	    da.Parent_Region__c = region.Id;
	    da.Region_Code__c = region.Region_Code__c;
	    insert da;
	    
	    p.Association_Name__c = da.id;
	    p.Association_Code__c = '251';
	    p.Parent_Region_Name__c	= 'Yorkshire Region';
	    p.Postcode_Part_1__c = 'M50';
	    p.Postcode_Part_2__c = '2YZ';
	    
	    //Contact con = new Contact(FirstName = 'Tony', LastName = 'Golf', Phone = '01232324', RecordTypeId =rt.Id, Account = a, mobilephone='07985468888', email='tony@tony.com');
     	//insert con;
     	 
	    cor.Correspondence_Type__c='Disband DA';
	    
	    DisbandDAAllocationExtension disbandDa2 = new DisbandDAAllocationExtension(new ApexPages.StandardController(region));
	    PageReference page2 = disbandDa2.clearAllData();
	    
	    
    
	    
	    
	    
		DisbandDAAllocationExtension disbandDa = new DisbandDAAllocationExtension(new ApexPages.StandardController(da2));
	     PageReference page = disbandDa.saveData();	
	}
    
}