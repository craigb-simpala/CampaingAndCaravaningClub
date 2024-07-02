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
private class LeadSectionsTests {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Date LMDob = Date.newInstance(1972, 1, 1);
     	Date SMDob = Date.newInstance(1970, 1, 1);
     	Date AMDob = Date.newInstance(1969, 1, 1);
     	Date C1Dob = Date.newInstance(2009, 1, 1);
     	Date C2Dob = Date.newInstance(2010, 1, 1);
     	Date C3Dob = Date.newInstance(2011, 1, 1);
     	Date C4Dob = Date.newInstance(2012, 1, 1);
     	Date C5Dob = Date.newInstance(2013, 1, 1);
     	Date C6Dob = Date.newInstance(2014, 1, 1);
     	Date sDate = Date.newInstance(2015, 1, 1);
     	Date eDate = Date.newInstance(2016, 12, 31);
     	Date jd = date.today();
        
         Lead lead = new Lead(LastName = 'Golf', Email = 'yo@yo.com', sections__c = 'Association of Lightweight Camper', Company='Testco', hasPartner__c =true,
      						Secondary_Member_First_Name__c = 'Mrs Golf', Secondary_Member_Surname__c = 'Golf', Secondary_Member_Email__c = 'golf@yo.com',
      						Number_of_Children__c = '6', Child_1_First_Name__c ='Child 1', Child_1_Surname__c='Golf',  Child_2_First_Name__c ='Child 2', 
      						Child_2_Surname__c='Golf', Child_3_First_Name__c ='Child 3', Child_3_Surname__c='Golf',  Child_4_First_Name__c ='Child 4',
      						Child_4_Surname__c='Golf', Child_5_First_Name__c ='Child 5', Child_5_Surname__c='Golf', Child_6_First_Name__c ='Child 6', 
      						Child_6_Surname__c='Golf', hasAssociate__c = true, Associate_Member_First_Name__c = 'Assoic',
      						Associate_Member_Surname__c = 'Assoc Surname', Associate_Member_Title__c = 'Mr.', Lead_Member_Age__c =43, 
      						Lead_Member_Date_of_Birth__c = LMDob, Secondary_Member_Date_of_Birth__c = SMDob, Child_1_Date_of_Birth__c = C1Dob,
      						Child_2_Date_of_Birth__c = C2Dob, Associate_Member_Date_of_Birth__c = AMDob, Child_3_Date_of_Birth__c = C3Dob, 
      						Child_4_Date_of_Birth__c = C4Dob, Child_5_Date_of_Birth__c = C5Dob, Child_6_Date_of_Birth__c = C6Dob, city='MAnchester',
      						state='U.K', PostalCode ='M502ZY', Country='United Kingdom', joining_date__c = jd, leadstep__c =3, Membership_Code__c='testing',
      						Max_LeadStep__c=4, Payment_Method__c='Direct Debit', street='Carolina Way, QuaysReach', Bank_Account_Number__c='2233445566', 
      						Sort_Code__c='111111', Secondary_Member_Title__c = 'Mr.' );
      insert lead;
      
      RecordType rt3 = [Select Id from RecordType Where SobjectType = 'Contact' AND DeveloperName='Associate' limit 1 ];
      //Contact con = new Contact(FirstName = 'Tony', LastName = 'Golf', Phone = '01232324', RecordTypeId =rt3.Id, Account = acc);
      //insert con;
      
      Section__c s = new Section__c();
      Test.setCurrentPage(Page.LeadSections);
       LeadSections controller = new LeadSections(new ApexPages.StandardController(lead));
     //  LeadSections.sectionSelectWrapper ssw = new Leadections.sectionSelectWrapper();
       
    }
}