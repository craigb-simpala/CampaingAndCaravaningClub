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

private class ChangeRenewalControllerTest {
	
	static Opportunity opp;
	static ChangeRenewalController changeRenwal;
	static PageReference page;
	
    static void init() {
        TestDataFactory.createRenewalTestRecords();
    	opp = [Select Id, AccountId,IsClosed, Renewal_Date__c, IsWon, RecordTypeId FROM Opportunity];
		changeRenwal = new ChangeRenewalController(new ApexPages.StandardController(opp)); 
    }
    
    static testMethod void ChangeRenewalStepsTest() {      
	    init();
	    
	    changeRenwal.lea = TestDataFactory.lead;
	    changeRenwal.step1();
	    changeRenwal.step2();
	    changeRenwal.step3();
	    changeRenwal.step4();	
	    Contact cAssocMember = changeRenwal.cAssocMember;
	    Contact cSecondaryMember = changeRenwal.cSecondaryMember;
	    List<Club_Opportunity_Product__c> oppli = changeRenwal.oppli;
	    List<SelectOption> membershipTypeOptions = changeRenwal.membershipTypeOptions;
	    Decimal mtCost = changeRenwal.mtCost;
	    List<Club_Product__c> mtList = changeRenwal.mtList;
	    List<Club_Product__c> pList= changeRenwal.pList;
	   // Decimal amCost = changeRenwal.amCost;
	    //Decimal costTotal = changeRenwal.costTotal;
	    //Map<string,club_product__c> mapPrices = changeRenwal.mapPrices;
//	    PageReference confirm = changeRenwal.confirm();
	    
    }
      /* Date sDate = Date.newInstance(2015, 10, 1);
       Date eDate = Date.newInstance(2016, 12, 31);
       Date joinDate = Date.newInstance(2016, 09, 24);
       Date assocdb =  Date.newInstance(1954, 09, 24);

        Account acc = new Account();
        Association__c da = new Association__c();
        Association__c region = new Association__c();
        DA_Postcode__c pc = new DA_Postcode__c();
        Club_Product__c cp = new Club_Product__c();
        Price__c p = new Price__c();
        Opportunity renewalOpp = new Opportunity();
        Date pStartDate = Date.newInstance(2016, 09, 24);
        constants c = new constants();
        
                
        acc.Name = 'Test Membership';
        acc.District_Association__c = da.Id;
        acc.BillingPostalCode = 'TE1 0YZ';
        acc.Date_Joined__c = joinDate;
        acc.payment_method2__c = 'Direct Debit';
        //acc.Opted_In__c = true;
        insert acc;
        
    

       RecordType rt = [Select Id from RecordType Where SobjectType = 'Contact' AND DeveloperName='Lead' limit 1 ];
       Contact con3 = new Contact(FirstName = 'Tony', LastName = 'Golf', Phone = '01232324', RecordTypeId =rt.Id, Account = acc);
       insert con3;
       RecordType rt1 = [Select Id from RecordType Where SobjectType = 'Club_Product__c' AND DeveloperName='Membership_Code' limit 1 ];
       
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
       
       cp = new Club_Product__c();
       
        cp.RecordTypeId = c.clubProdAssociateRecordTypeId;
        cp.Name = 'Online';
        cp.Product_Detail__c = 'Online Membership';
        cp.Active__c = true;
        cp.Show_in_New_Membership_Picklist__c = true;
        cp.Sections_Allowed__c = true;
        cp.Associate_Allowed__c = true;
        cp.PartnerAllowed__c = true;
        cp.DD_Payment_Allowed__c = true;
        insert cp;
       
       p = new Price__c();
       
        p.Product__c = cp.Id;
        p.Price__c = 36.00;
       p.Start_Date__c =  pStartDate;
       insert p;
       
         renewalOpp.Name = 'Test Opp';
      renewalOpp.Amount = 44;
      renewalopp.CloseDate = system.Today();
      renewalopp.AccountId = acc.Id; 
      renewalopp.RecordTypeId = c.OppRenewalRecordTypeId;
      renewalopp.StageName = 'Due';
      //renewalopp.IsClosed = false;
      //renewalopp.IsWon = false;
      insert renewalopp;
       

       
       
       Lead lead = new Lead(LastName = 'Golf', Email = 'yo@yo.com', sections__c = 'Association of Lightweight Camper', Company='Testco', hasPartner__c =true,
                            Secondary_Member_First_Name__c = 'Mrs Golf', Secondary_Member_Surname__c = 'Golf', Secondary_Member_Email__c = 'golf@yo.com',
                            Number_of_Children__c = '6', Child_1_First_Name__c ='Child 1', Child_1_Surname__c='Golf',  Child_2_First_Name__c ='Child 2', 
                            Child_2_Surname__c='Golf', Child_3_First_Name__c ='Child 3', Child_3_Surname__c='Golf',  Child_4_First_Name__c ='Child 4',
                            Child_4_Surname__c='Golf', Child_5_First_Name__c ='Child 5', Child_5_Surname__c='Golf', Child_6_First_Name__c ='Child 6', 
                            Child_6_Surname__c='Golf', Payment_Method__c='Debit / Credit Card', hasAssociate__c = true, Associate_Member_First_Name__c = 'Assoic',
                             Associate_Member_Surname__c = 'Assoc Surname', Associate_Member_Title__c = 'Mr.',Sort_Code__c='20-20-20', Bank_Account_Name__c = 'Test Account',
                             Bank_Account_Number__c = '41111111', Bank_Name__c='Test', street='Hello', PostalCode='ID1 0TT', City='Annoying City', Country='Testing', 
                             State='Hidden land', Associate_Member_Date_of_Birth__c = assocdb);
      insert lead;
      
       
       Lead lead2 = new Lead(LastName = 'Golf', Email = 'yo@yo.com', sections__c = 'Association of Lightweight Camper', Company='Testco', hasPartner__c =true,
                            Secondary_Member_First_Name__c = 'Mrs Golf', Secondary_Member_Surname__c = 'Golf', Secondary_Member_Email__c = 'golf@yo.com',
                            Number_of_Children__c = '6', Child_1_First_Name__c ='Child 1', Child_1_Surname__c='Golf',  Child_2_First_Name__c ='Child 2', 
                            Child_2_Surname__c='Golf', Child_3_First_Name__c ='Child 3', Child_3_Surname__c='Golf',  Child_4_First_Name__c ='Child 4',
                            Child_4_Surname__c='Golf', Child_5_First_Name__c ='Child 5', Child_5_Surname__c='Golf', Child_6_First_Name__c ='Child 6', 
                            Child_6_Surname__c='Golf', Payment_Method__c='Direct Debit', hasAssociate__c = true, Associate_Member_First_Name__c = 'Assoic',
                             Associate_Member_Surname__c = 'Assoc Surname', Associate_Member_Title__c = 'Mr.',  Membership_Code__c ='Online', street='Hello', 
                             PostalCode='ID1 0TT', City='Annoying City', Country='Testing',  Associate_Member_Date_of_Birth__c = assocdb, 
                             State='Hidden land');
      insert lead2;
      
      
        RecordType rt6 = [Select Id from RecordType Where SobjectType = 'Contact' AND DeveloperName='Lead' limit 1 ];
      Contact con4 = new Contact(FirstName = 'Bony', LastName = 'Wolf', Phone = '01232324', RecordTypeId =rt6.Id, Account = acc);
      insert con4;
      
      RecordType rt3 = [Select Id from RecordType Where SobjectType = 'Contact' AND DeveloperName='Associate' limit 1 ];
      Contact con = new Contact(FirstName = 'Tony', LastName = 'Golf', Phone = '01232324', RecordTypeId =rt3.Id, Account = acc);
      insert con;   
            
      RecordType rt2 = [Select Id from RecordType Where SobjectType = 'Club_Product__c' AND DeveloperName='Associate_Membership' limit 1 ];
      Club_Product__c cp2 = new Club_Product__c(name = 'testing',Product_Detail__c = 'testing Club Product', RecordTypeId =rt2.Id);
      insert cp2;
      
      
      RecordType rt4 = [Select Id from RecordType Where SobjectType = 'Contact' AND DeveloperName='Secondary' limit 1 ];
      Contact con1 = new Contact(FirstName = 'Bony', LastName = 'Wolf', Phone = '01232324', RecordTypeId =rt4.Id, Account = acc);
      insert con1;
      
      RecordType rt5 = [Select Id from RecordType Where SobjectType = 'Contact' AND DeveloperName='Child' limit 1 ];
      Contact con2 = new Contact(FirstName = 'Bony', LastName = 'Wolf', Phone = '01232324', RecordTypeId =rt5.Id, Account = acc);
      insert con2;
      
       Price__c p2 = new Price__c(Start_Date__c = sDate, End_Date__c = eDate, Product__c= cp2.id, Price__c = 44);
      insert p2;
      
      renewalOpp.Name = 'Test Opp';
      renewalOpp.Amount = 44;
      renewalopp.CloseDate = system.Today();
      renewalopp.AccountId = acc.Id; 
      renewalopp.RecordTypeId = c.OppRenewalRecordTypeId;
      renewalopp.StageName = 'Due';
      //upsert renewalopp;
      
      Test.setCurrentPage(Page.ChangeRenewal);
      ChangeRenewalController controller = new ChangeRenewalController(new ApexPages.StandardController(renewalOpp));
      //controller.lea = lead;
      controller.step1();
      controller.step2();
      controller.step3();
      controller.step4();
     
        Map<string,club_product__c> mapPrices = new Map<string,club_product__c>();
      mapprices.put('Associate Member', cp2);
      controller.cAssocMember = con;
    
      controller.cAssocMember = null;
      Contact cAssocMember = controller.cAssocMember;
      
      system.debug(lead2);

     controller.lea = lead2;
     
     PageReference confirm = controller.confirm();
     
     

       
    }*/
}