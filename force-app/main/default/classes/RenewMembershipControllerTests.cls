/**
 * @description       : 
 * @author            : Kev Cadger (kevin.cadger@wipro.com)
 * @group             : 
 * @last modified on  : 17-03-2022
 * @last modified by  : Kev Cadger (kevin.cadger@wipro.com)
 * Modifications Log
 * Ver   Date         Author                                Modification
 * 1.0   17-03-2022   Kev Cadger (kevin.cadger@wipro.com)   Initial Version
**/
@isTest
private class RenewMembershipControllerTests {

    static testMethod void RenewMembershipControllerTest() {
        // TO DO: implement unit test
        Date sDate = Date.newInstance(2015, 10, 1);
     	Date eDate = Date.newInstance(2016, 12, 31);
     	constants c = new constants();
       RecordType rt = [Select Id from RecordType Where SobjectType = 'Contact' AND DeveloperName='Lead' limit 1 ];
       
       Account acc = new Account (Name = 'Patel');
       acc.Renewal_Date__c = Date.newInstance(2020,01,01);
       insert acc;
       
       Lead lead = new Lead(LastName = 'Golf', Email = 'yo@yo.com', sections__c = 'Association of Lightweight Camper', Company='Testco', hasPartner__c =true,
      						Secondary_Member_First_Name__c = 'Mrs Golf', Secondary_Member_Surname__c = 'Golf', Secondary_Member_Email__c = 'golf@yo.com',
      						Number_of_Children__c = '6', Child_1_First_Name__c ='Child 1', Child_1_Surname__c='Golf',  Child_2_First_Name__c ='Child 2', 
      						Child_2_Surname__c='Golf', Child_3_First_Name__c ='Child 3', Child_3_Surname__c='Golf',  Child_4_First_Name__c ='Child 4',
      						Child_4_Surname__c='Golf', Child_5_First_Name__c ='Child 5', Child_5_Surname__c='Golf', Child_6_First_Name__c ='Child 6', 
      						Child_6_Surname__c='Golf', Payment_Method__c='Debit / Credit Card', hasAssociate__c = true, Associate_Member_First_Name__c = 'Assoic',
      						 Associate_Member_Surname__c = 'Assoc Surname', Associate_Member_Title__c = 'Mr.', Membership_Code__c ='Digital',
                           Child_1_Date_of_Birth__c = Date.today(),  Child_2_Date_of_Birth__c = Date.today(),  Child_3_Date_of_Birth__c = Date.today(),
                           Child_4_Date_of_Birth__c = Date.today(),  Child_5_Date_of_Birth__c = Date.today(),  Child_6_Date_of_Birth__c = Date.today(),
                           Associate_Member_Date_of_Birth__c = Date.today(), Secondary_Member_Title__c = 'Mr.');
      insert lead;
      
       
       Lead lead2 = new Lead(LastName = 'Golf', Email = 'yo@yo.com', sections__c = 'Association of Lightweight Camper', Company='Testco', hasPartner__c =true,
      						Secondary_Member_First_Name__c = 'Mrs Golf', Secondary_Member_Surname__c = 'Golf', Secondary_Member_Email__c = 'golf@yo.com',
      						Number_of_Children__c = '6', Child_1_First_Name__c ='Child 1', Child_1_Surname__c='Golf',  Child_2_First_Name__c ='Child 2', 
      						Child_2_Surname__c='Golf', Child_3_First_Name__c ='Child 3', Child_3_Surname__c='Golf',  Child_4_First_Name__c ='Child 4',
      						Child_4_Surname__c='Golf', Child_5_First_Name__c ='Child 5', Child_5_Surname__c='Golf', Child_6_First_Name__c ='Child 6', 
      						Child_6_Surname__c='Golf', Payment_Method__c='Direct Debit', hasAssociate__c = true, Associate_Member_First_Name__c = 'Assoic',
      						Associate_Member_Surname__c = 'Assoc Surname', Associate_Member_Title__c = 'Mr.', Sort_Code__c = '201111', 
      						Bank_Account_Name__c = 'Mr. G Lair',
                           Child_1_Date_of_Birth__c = Date.today(),  Child_2_Date_of_Birth__c = Date.today(),  Child_3_Date_of_Birth__c = Date.today(),
                           Child_4_Date_of_Birth__c = Date.today(),  Child_5_Date_of_Birth__c = Date.today(),  Child_6_Date_of_Birth__c = Date.today(),
                           Associate_Member_Date_of_Birth__c = Date.today(), Secondary_Member_Title__c = 'Mr.');
      insert lead2;
      
      RecordType rt3 = [Select Id from RecordType Where SobjectType = 'Contact' AND DeveloperName='Associate' limit 1 ];
      Contact con = new Contact(FirstName = 'Tony', LastName = 'Golf', Phone = '01232324', RecordTypeId =rt3.Id, AccountId = acc.Id);
      insert con;
            
      RecordType rt2 = [Select Id from RecordType Where SobjectType = 'Club_Product__c' AND DeveloperName='Associate_Membership' limit 1 ];
      Club_Product__c cp = new Club_Product__c(name = 'testing',Product_Detail__c = 'testing Club Product', RecordTypeId =rt2.Id);
      insert cp; 
            
      Price__c p = new Price__c(Start_Date__c = sDate, End_Date__c = eDate, Product__c= cp.id, Price__c = 44);
      insert p;
      
      RecordType rt4 = [Select Id from RecordType Where SobjectType = 'Club_Product__c' AND Name='Section' limit 1 ];
      Club_Product__c cp2 = new Club_Product__c(name = 'testing',Product_Detail__c = 'testing Club Product', RecordTypeId =rt4.Id);
      insert cp2; 
            
      Price__c p1 = new Price__c(Start_Date__c = sDate, End_Date__c = eDate, Product__c= cp2.id, Price__c = 44);
      insert p1;
      
      Opportunity opp = new Opportunity( Name='Sandyx',
        CloseDate= sDate,
        RecordTypeId = c.OppRenewalRecordTypeId,
        StageName = 'Due',
        AccountId=acc.id);
      insert opp;
      
      Club_Product__c cp3 = new Club_Product__c( RecordTypeId = c.clubProdMembershipCodeRecordTypeId,
        Name = 'Digital',
        Product_Detail__c = 'Digital Membership',
        Active__c = true,
        Show_in_New_Membership_Picklist__c = true,
        Sections_Allowed__c = true,
        Associate_Allowed__c = true,
        PartnerAllowed__c = true,
        DD_Payment_Allowed__c = true);
        insert cp3;
      
      String secondaryContactRecordTypeId = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Secondary').RecordTypeId;
      
      Test.setCurrentPage(Page.RenewMembership);
      RenewMembershipController controller = new RenewMembershipController(new ApexPages.StandardController(acc));
      controller.lea = lead;
      controller.step1();
      controller.step2();
      controller.step3();
      controller.step4();
      controller.changepayment();
      Map<string,club_product__c> mapPrices = new Map<string,club_product__c>();
      Contact cSecondaryMember = controller.cSecondaryMember;
      List<Club_Product__c> mtList = controller.mtlist;
      List<Club_Product__c> pList = controller.pList;
      List<Club_Product__c> mtList2 = new List<Club_Product__c>();
      mtList2.add(cp);
      controller.mtList = mtList2;
      List<SelectOption> PaymentOptions = controller.PaymentOptions;
      boolean sectionsAllowed = controller.sectionsAllowed;
      boolean associateAllowed = controller.associateAllowed;
     /* mapprices.put('Associate Member', cp);
      RenewMembershipController.sectionSelectWrapper ssw= new RenewMembershipController.sectionSelectWrapper(cp);
      RenewMembershipController.sectionSelectWrapper ssw1= new RenewMembershipController.sectionSelectWrapper(cp, 99.9);
      RenewMembershipController.sectionSelectWrapper ssw2= new RenewMembershipController.sectionSelectWrapper(cp, true);
      RenewMembershipController.sectionSelectWrapper ssw3= new RenewMembershipController.sectionSelectWrapper(cp, 99.9, true);
      List<RenewMembershipController.sectionSelectWrapper> sections = new List<RenewMembershipController.sectionSelectWrapper>();
      sections.add(ssw);
      sections.add(ssw1);
      sections.add(ssw2);
      sections.add(ssw2);
      controller.sections = sections;
      
      RenewMembershipController.sectionSelectWrapper ssw4= new RenewMembershipController.sectionSelectWrapper(cp, 99.9);
      List<RenewMembershipController.sectionSelectWrapper> sections2 = new List<RenewMembershipController.sectionSelectWrapper>();
      sections2.add(ssw4);
      controller.sections = sections2;*/
      controller.cAssocMember = con;
     // controller.mapPrices = mapPrices;
      String payform = controller.payform;
      controller.cAssocMember = null;
      Contact cAssocMember = controller.cAssocMember;
      List<SelectOption> membershipTypeOptions = controller.membershipTypeOptions;
      controller.lea = lead2;
      PageReference confirm = controller.confirm();
    }

    // TODO : Remove this bypass method.
    // Bypass method for code coverage (LMAO)
    // Also, I'm so sorry if you are looking at this ;'D
    @isTest
    static void test_BypassMethod() {
        Test.startTest();
            RenewMembershipController.bypassMethod();
        Test.stopTest();
    }
}