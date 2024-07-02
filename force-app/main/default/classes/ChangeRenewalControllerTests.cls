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
private class ChangeRenewalControllerTests {

    static testMethod void ChangeRenewalTest() {
        // TO DO: implement unit test
        Date sDate = Date.newInstance(2015, 10, 1);
     	Date eDate = Date.newInstance(2016, 12, 31);
       RecordType rt = [Select Id from RecordType Where SobjectType = 'Contact' AND DeveloperName='Lead' limit 1 ];
       
       RecordType rt5 = [Select Id from RecordType Where SobjectType = 'Club_Product__c' AND DeveloperName='Membership_Code' limit 1 ];
       Club_Product__c cp2 = new Club_Product__c(name = 'testing2',Product_Detail__c = 'testing Club Product', RecordTypeId =rt5.Id);
       insert cp2;
       
       Account acc = new Account (Name = 'Patel', Membership_Code__c = cp2.Id, Renewal_Date__c = Date.newInstance(2018,01,29));
       insert acc;
       
       Lead lead = new Lead(LastName = 'Golf', Email = 'yo@yo.com', sections__c = 'Association of Lightweight Camper', Company='Testco', hasPartner__c =true,
      						Secondary_Member_First_Name__c = 'Mrs Golf', Secondary_Member_Surname__c = 'Golf', Secondary_Member_Email__c = 'golf@yo.com',
      						Number_of_Children__c = '6', Child_1_First_Name__c ='Child 1', Child_1_Surname__c='Golf',  Child_2_First_Name__c ='Child 2', 
      						Child_2_Surname__c='Golf', Child_3_First_Name__c ='Child 3', Child_3_Surname__c='Golf',  Child_4_First_Name__c ='Child 4',
      						Child_4_Surname__c='Golf', Child_5_First_Name__c ='Child 5', Child_5_Surname__c='Golf', Child_6_First_Name__c ='Child 6', 
      						Child_6_Surname__c='Golf', Payment_Method__c='Debit / Credit Card', hasAssociate__c = true, Associate_Member_First_Name__c = 'Assoic',
      						 Associate_Member_Surname__c = 'Assoc Surname', Associate_Member_Title__c = 'Mr.',
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
      						 Associate_Member_Surname__c = 'Assoc Surname', Associate_Member_Title__c = 'Mr.',
                           Child_1_Date_of_Birth__c = Date.today(),  Child_2_Date_of_Birth__c = Date.today(),  Child_3_Date_of_Birth__c = Date.today(),
                           Child_4_Date_of_Birth__c = Date.today(),  Child_5_Date_of_Birth__c = Date.today(),  Child_6_Date_of_Birth__c = Date.today(),
                           Associate_Member_Date_of_Birth__c = Date.today(), Secondary_Member_Title__c = 'Mr.');
      insert lead2;
      
      RecordType rt3 = [Select Id from RecordType Where SobjectType = 'Contact' AND DeveloperName='Associate' limit 1 ];
      Contact con = new Contact(FirstName = 'Tony', LastName = 'Golf', Phone = '01232324', RecordTypeId =rt3.Id, AccountId = acc.Id);
      insert con;
            
      RecordType rt2 = [Select Id from RecordType Where SobjectType = 'Club_Product__c' AND DeveloperName='Membership_Code' limit 1 ];
      Club_Product__c cp = new Club_Product__c(name = 'testing',Product_Detail__c = 'testing Club Product', RecordTypeId =rt2.Id);
      insert cp; 
            
      Price__c p = new Price__c(Start_Date__c = sDate, End_Date__c = eDate, Product__c= cp.id, Price__c = 44);
      insert p;
      
      //Date sDate = Date.newInstance(2015, 10, 15);
      RecordType rt4 = [Select Id from RecordType Where SobjectType = 'Opportunity' AND Name='Renewal' limit 1 ];
      Opportunity opp = new Opportunity(Name='testing2', CloseDate= sDate,StageName='Closed Won', Account=acc, RecordTypeId=rt4.Id);
      insert opp;
      
      Test.setCurrentPage(Page.ChangeRenewal);
     /* ChangeRenewalController controller = new ChangeRenewalController(new ApexPages.StandardController(opp));
      controller.lea = lead;
      controller.step1();
      controller.step2();
      controller.step3();
      controller.step4();
     // controller.changepayment();
      Map<string,club_product__c> mapPrices = new Map<string,club_product__c>();
      mapprices.put('Associate Member', cp);
      //ChangeRenewalController.sectionSelectWrapper ssw= new ChangeRenewalController.sectionSelectWrapper(cp);
      //ChangeRenewalController.sectionSelectWrapper ssw1= new ChangeRenewalController.sectionSelectWrapper(cp, 99.9);
      //ChangeRenewalController.sectionSelectWrapper ssw2= new ChangeRenewalController.sectionSelectWrapper(cp, true);
      //ChangeRenewalController.sectionSelectWrapper ssw3= new ChangeRenewalController.sectionSelectWrapper(cp, 99.9, true);
      //List<ChangeRenewalController.sectionSelectWrapper> sections = new List<ChangeRenewalController.sectionSelectWrapper>();
      //sections.add(ssw);
     // sections.add(ssw1);
     // sections.add(ssw2);
      //sections.add(ssw2);
      //controller.sections = sections;
      
     // ChangeRenewalController.sectionSelectWrapper ssw4= new ChangeRenewalController.sectionSelectWrapper(cp, 99.9);
      //List<ChangeRenewalController.sectionSelectWrapper> sections2 = new List<ChangeRenewalController.sectionSelectWrapper>();
      //sections2.add(ssw4);
      //controller.sections = sections2;
      controller.cAssocMember = con;
     // controller.mapPrices = mapPrices;
//      String payform = controller.payform;
      controller.cAssocMember = null;
      Contact cAssocMember = controller.cAssocMember;
      List<SelectOption> membershipTypeOptions = controller.membershipTypeOptions;
      controller.lea = lead2;
      PageReference confirm = controller.confirm();*/
    }
}