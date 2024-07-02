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
private class TransactionTriggerTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit testDate joinedDate = System.today();
       	RecordType rt = [Select Id from RecordType Where SobjectType = 'Contact' AND DeveloperName='Lead' limit 1 ];
       	RecordType rt1 = [Select Id from RecordType Where SobjectType = 'Club_Product__c' AND DeveloperName='Membership_Code' limit 1 ];
       	RecordType rt2 = [Select Id from RecordType Where SobjectType = 'Club_Opportunity_Product__c' AND DeveloperName='Membership_Code' limit 1 ];
		RecordType rt3 = [Select Id from RecordType Where SobjectType = 'Opportunity' AND Name='New Membership' limit 1 ];
		RecordType rt4 = [Select Id from RecordType Where SobjectType = 'Transaction__c' AND Name='Direct Debit' limit 1 ];
       
	    Account acc = new Account();
	    Association__c da = new Association__c();
	    Association__c region = new Association__c();
	    DA_Postcode__c pc = new DA_Postcode__c();
	    Club_Product__c cp = new Club_Product__c();
	    Price__c p = new Price__c();
	    Club_Opportunity_Product__c cop = new Club_Opportunity_Product__c();
	    Member_Section__c memSec = new Member_Section__c();
        Payment_Method__c pm =  new Payment_Method__c();
        Transaction__c t = new Transaction__c();
        Date pStartDate = Date.newInstance(2016, 09, 24);
	    constants c = new constants();
	    
	   	acc.Name = 'Test Membership';
	    acc.District_Association__c = da.Id;
	    acc.BillingPostalCode = 'TE1 0YZ';
	    acc.Date_Joined__c = system.today();
	    acc.Membership_Code__c = cp.Id;
	    //acct.Renewal_Date__c = 
	    insert acc;
   
	    
	    	    
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
   
	    p.Product__c = cp.Id;
	    p.Price__c = 36.00;
	    p.Start_Date__c =  pStartDate;
	    insert p;
	    
	    
		Date sDate = Date.newInstance(2016, 10, 06);
		Opportunity opp = new Opportunity(Name='Santosh', CloseDate= sDate,StageName='Closed Won', Account=acc, RecordTypeId=rt3.Id);
		insert opp;	    
	    
      	Contact con = new Contact(FirstName = 'Tony', LastName = 'Golf', Phone = '01232324', RecordTypeId =rt.Id, Account = acc, mobilephone='07985468888', email='tony@tony.com');
      	insert con;
      
        Lead lead = new Lead(LastName = 'Golf', Email = 'yo@yo.com', sections__c = 'Association of Lightweight Camper', Company='Testco', hasPartner__c =true,
      						Secondary_Member_First_Name__c = 'Mrs Golf', Secondary_Member_Surname__c = 'Golf', Secondary_Member_Email__c = 'golf@yo.com',
      						Number_of_Children__c = '6', Child_1_First_Name__c ='Child 1', Child_1_Surname__c='Golf',  Child_2_First_Name__c ='Child 2', 
      						Child_2_Surname__c='Golf', Child_3_First_Name__c ='Child 3', Child_3_Surname__c='Golf',  Child_4_First_Name__c ='Child 4',
      						Child_4_Surname__c='Golf', Child_5_First_Name__c ='Child 5', Child_5_Surname__c='Golf', Child_6_First_Name__c ='Child 6', 
      						Child_6_Surname__c='Golf', Payment_Method__c='Direct Debit', hasAssociate__c = true, Associate_Member_First_Name__c = 'Assoic',
      						 Associate_Member_Surname__c = 'Assoc Surname', Associate_Member_Title__c = 'Mr.', Sort_Code__c='202020', Bank_Account_Name__c = 'Test Account',
      						 Bank_Account_Number__c = '41111111', Bank_Name__c='Test', Membership_Code__c ='Online',
							Child_1_Date_of_Birth__c = Date.today(),  Child_2_Date_of_Birth__c = Date.today(),  Child_3_Date_of_Birth__c = Date.today(),
							Child_4_Date_of_Birth__c = Date.today(),  Child_5_Date_of_Birth__c = Date.today(),  Child_6_Date_of_Birth__c = Date.today(),
							Associate_Member_Date_of_Birth__c = Date.today(), Secondary_Member_Title__c = 'Mr.');
       insert lead;
       
       
       
       pm.Membership__c = acc.Id;
       pm.Mandate_Amount__c =37.00;
       pm.Bank_Account_Name__c = 'Test Account';
       pm.Bank_Account_Number__c ='41111111';
       pm.Bank_Name__c='Test';
       pm.Sort_Code__c='202020';
       pm.Status__c='Active';
       pm.Start_Date__c=system.today();
       insert pm;
       
       t.Payment_Method__c = pm.Id;
       t.Transaction_Date__c = system.today();
       t.Transaction_Type__c = '0N';
       t.Amount__c = 0.00;
       t.Status__c = 'Pending';
       t.RecordTypeId = rt4.Id;
       insert t;
       
       Transaction__c tUpdate = [Select Id, Status__c, Transaction_Type__c FROM Transaction__c WHERE Payment_Method__c =: pm.Id AND Transaction_Type__c = '0N' and RecordTypeId = : rt4.Id LIMIT 1];
       tUpdate.Status__c = 'Complete';
       update tUpdate;
       
      	
    }
}