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
private class ClubOppProdTriggerTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Date joinedDate = System.today();
       	RecordType rt = [Select Id from RecordType Where SobjectType = 'Contact' AND DeveloperName='Lead' limit 1 ];
       	RecordType rt1 = [Select Id from RecordType Where SobjectType = 'Club_Product__c' AND DeveloperName='Membership_Code' limit 1 ];
       	RecordType rt2 = [Select Id from RecordType Where SobjectType = 'Club_Opportunity_Product__c' AND DeveloperName='Membership_Code' limit 1 ];
		RecordType rt3 = [Select Id from RecordType Where SobjectType = 'Opportunity' AND Name='New Membership' limit 1 ];
       
	    Account acc = new Account();
	    Association__c da = new Association__c();
	    Association__c region = new Association__c();
	    DA_Postcode__c pc = new DA_Postcode__c();
	    Club_Product__c cp = new Club_Product__c();
	    Price__c p = new Price__c();
	    Club_Opportunity_Product__c cop = new Club_Opportunity_Product__c();
	    Member_Section__c memSec = new Member_Section__c();
        Date pStartDate = Date.newInstance(2016, 09, 24);
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
	    
	    cp.RecordTypeId = rt1.Id;
	    cp.Name = 'Online';
	    cp.Product_Detail__c = 'Online Membership';
	    cp.Active__c = true;
	    cp.Show_in_New_Membership_Picklist__c = true;
	    cp.Sections_Allowed__c = true;
	    cp.Associate_Allowed__c = true;
	    cp.PartnerAllowed__c = true;
	    cp.DD_Payment_Allowed__c = true;
	    insert cp;
	    
	    
	    acc.Name = 'Test Membership';
	    acc.District_Association__c = da.Id;
	    acc.BillingPostalCode = 'TE1 0YZ';
	    acc.Date_Joined__c = system.today();
	    acc.Membership_Code__c = cp.Id;
	    //acct.Renewal_Date__c = 
	    insert acc;
   
	    p.Product__c = cp.Id;
	    p.Price__c = 36.00;
	    p.Start_Date__c =  pStartDate;
	    insert p;
	    
	    
		Date sDate = Date.newInstance(2016, 10, 06);
		Opportunity opp = new Opportunity(Name='Santosh', CloseDate= sDate,StageName='Closed Won', Account=acc, RecordTypeId=rt3.Id);
		insert opp;	    
	    
      	Contact con = new Contact(FirstName = 'Tony', LastName = 'Golf', Phone = '01232324', RecordTypeId =rt.Id, Account = acc, mobilephone='07985468888', email='tony@tony.com');
      	insert con;
      	
      	memSec.Member__c = con.Id;
      	insert memSec;
	    
	    cop.Account__c =acc.Id;
	    cop.Product__c = cp.Id;
	    cop.Opportunity__c = opp.Id;
	    cop.RecordTypeId = rt2.Id;
	    insert cop;
    }
}