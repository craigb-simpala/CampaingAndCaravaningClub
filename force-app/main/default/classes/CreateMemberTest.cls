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
@IsTest
private class CreateMemberTest {
    //Test a regular use case (NOT with Young Camper membership type)
    @IsTest
    static void testCreateMembershipFromLead() {
        Date joinedDate = System.today();
        Id membershipCodeRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Club_Product__c' AND DeveloperName = 'Membership_Code' LIMIT 1].Id;

        String productName = 'Online';

        Club_Product__c clubProduct = new Club_Product__c(
                RecordTypeId = membershipCodeRecordTypeId,
                Name = productName,
                Product_Detail__c = 'Online Membership',
                Active__c = true,
                Show_in_New_Membership_Picklist__c = true,
                Sections_Allowed__c = true,
                Associate_Allowed__c = true,
                PartnerAllowed__c = true,
                DD_Payment_Allowed__c = true,
                Membership_Length__c = 24
        );
        insert clubProduct;

        Lead theLead = new Lead(LastName = 'Golf', Email = 'yo@yo.com', sections__c = 'Association of Lightweight Camper', Company = 'Testco', hasPartner__c = true,
                Secondary_Member_First_Name__c = 'Mrs Golf', Secondary_Member_Surname__c = 'Golf', Secondary_Member_Email__c = 'golf@yo.com', Joining_Fee_Waived__c = false,
                Number_of_Children__c = '6', Child_1_First_Name__c = 'Child 1', Child_1_Surname__c = 'Golf', Child_2_First_Name__c = 'Child 2',
                Child_2_Surname__c = 'Golf', Child_3_First_Name__c = 'Child 3', Child_3_Surname__c = 'Golf', Child_4_First_Name__c = 'Child 4',
                Child_4_Surname__c = 'Golf', Child_5_First_Name__c = 'Child 5', Child_5_Surname__c = 'Golf', Child_6_First_Name__c = 'Child 6',
                Child_6_Surname__c = 'Golf', Payment_Method__c = 'Direct Debit', hasAssociate__c = true, Associate_Member_First_Name__c = 'Assoic',
                Associate_Member_Surname__c = 'Assoc Surname', Associate_Member_Title__c = 'Mr.', Sort_Code__c = '202020', Bank_Account_Name__c = 'Test Account',
                Bank_Account_Number__c = '41111111', Bank_Name__c = 'Test', Membership_Code__c = 'Online', Joining_Date__c = joinedDate, PostalCode = 'TE1 0YZ',
                Child_1_Date_of_Birth__c = Date.today(), Child_2_Date_of_Birth__c = Date.today(), Child_3_Date_of_Birth__c = Date.today(),
                Child_4_Date_of_Birth__c = Date.today(), Child_5_Date_of_Birth__c = Date.today(), Child_6_Date_of_Birth__c = Date.today(),
                Associate_Member_Date_of_Birth__c = Date.today(), Secondary_Member_Title__c = 'Mr.');
        insert theLead;

        new CreateMember().createMembershipfromLead(theLead, '', '');

        System.assertEquals(1, [SELECT COUNT() FROM Account], 'There should be only one Account record!');
        System.assertEquals(9, [SELECT COUNT() FROM Contact], 'There should be only nine Contact records (Member, Second Member, Associate Member and 6 children!)!');
        System.assertEquals(1, [SELECT COUNT() FROM Lead WHERE IsConverted = TRUE], 'There should be only one Lead record with IsConverted = TRUE');

        Account convertedAccount = [SELECT Id, Name, Membership_Type_Name__c FROM Account LIMIT 1];
        System.assertEquals(productName, convertedAccount.Membership_Type_Name__c, 'Membership Type Name should be ' + productName + '!');
        System.assertEquals(theLead.LastName, convertedAccount.Name, 'Lead\'s LastName and Account\'s Name should be the same!');
    }

    // Test createMembershipfromLead using a Lead record of 'Young Camper' Membership Type
    @IsTest
    static void testCreateMembershipFromLead2() {
        Id membershipCodeRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Club_Product__c' AND DeveloperName = 'Membership_Code' LIMIT 1].Id;

        Club_Product__c clubProduct = new Club_Product__c(
                RecordTypeId = membershipCodeRecordTypeId,
                Name = 'Young Camper',
                Product_Detail__c = 'Young Camper',
                Active__c = true,
                Show_in_New_Membership_Picklist__c = true,
                Auto_Renew__c = true,
                Min_Age_for_Membership__c = 18,
                Max_Age_for_Membership__c = 25,
                Sections_Allowed__c = true,
                Associate_Allowed__c = true,
                PartnerAllowed__c = true,
                DD_Payment_Allowed__c = true,
                Cash_Payment_Allowed__c = true,
                Membership_Length__c = 12,
                Renewable__c = true,
                Allowed_Payment_Types__c = 'Cash/Cheque'
        );
        insert clubProduct;

        Price__c price = new Price__c(
                Product__c = clubProduct.Id,
                Price__c = 0,
                Start_Date__c = Date.today().addDays(-10),
                Joining_Fee__c = 0,
                Payment_Type__c = 'Cash/Cheque'
        );
        insert price;

        Date memberBirthday = Date.today().addYears(-20).addMonths(-2);

        Lead theLead = new Lead(
                FirstName = 'John', LastName = 'Smith', Company = 'Smith',
                Age_Concession__c = false, Amount__c = 0, Application_Source__c = 'Telephone',
                Email = 'john.smith@test.com', Membership_Code__c = 'Young Camper', Membership_Type__c = clubProduct.Id,
                Street = 'Green Str.', City = 'London', State = 'Fullham', PostalCode = '452462', Country = 'UK',
                Camping_Unit__c = 'Tent', Length__c = 1, Width__c = 1, Height__c = 1,
                Lead_Member_Date_of_Birth__c = memberBirthday
        );
        insert theLead;

        new CreateMember().createMembershipfromLead(theLead, '', '');

        System.assertEquals(1, [SELECT COUNT() FROM Account], 'There should be only one Account record!');
        System.assertEquals(1, [SELECT COUNT() FROM Contact], 'There should be only one Contact record!');
        System.assertEquals(1, [SELECT COUNT() FROM Lead WHERE IsConverted = TRUE], 'There should be only one Lead record with IsConverted = TRUE');

        Account convertedAccount = [SELECT Id, Name, Renewal_Date__c FROM Account LIMIT 1];

        System.debug('memberBirthday = ' + memberBirthday);
        System.debug('convertedAccount.Renewal_Date__c = ' + convertedAccount.Renewal_Date__c);

        System.assertEquals(theLead.LastName, convertedAccount.Name, 'Lead\'s LastName and Account\'s Name should be the same!');
        System.assert(convertedAccount.Renewal_Date__c.month() == memberBirthday.month()
                        && convertedAccount.Renewal_Date__c.day() == memberBirthday.day(),
                'Renewal Date for members with Young Camper membership type should be equal to the next member\'s birthday!');
    }

//    static testMethod void CreateMemberTest() {
//        // TO DO: implement unit test
//        Date joinedDate = System.today();
//        RecordType rt = [Select Id from RecordType Where SobjectType = 'Contact' AND DeveloperName = 'Lead' limit 1];
//        RecordType rt1 = [Select Id from RecordType Where SobjectType = 'Club_Product__c' AND DeveloperName = 'Membership_Code' limit 1];
//
//        Account acc = new Account();
//        Association__c da = new Association__c();
//        Association__c region = new Association__c();
//        DA_Postcode__c pc = new DA_Postcode__c();
//        Club_Product__c cp = new Club_Product__c();
//        Price__c p = new Price__c();
//        Date pStartDate = Date.newInstance(2016, 09, 24);
//        constants c = new constants();
//
//
//        region.RecordTypeId = c.accRegionRecordTypeId;
//        region.Name = 'Testing Region';
//        region.Region_Code__c = '101';
//        insert region;
//
//
//        pc.Association_Name__c = da.Id;
//        pc.Association_Code__c = da.Region_Code__c;
//        pc.Parent_Region_Name__c = region.Name;
//        pc.Postcode_Part_1__c = 'TE1';
//        insert pc;
//
//        cp.RecordTypeId = rt1.Id;
//        cp.Name = 'Online';
//        cp.Product_Detail__c = 'Online Membership';
//        cp.Active__c = true;
//        cp.Show_in_New_Membership_Picklist__c = true;
//        cp.Sections_Allowed__c = true;
//        cp.Associate_Allowed__c = true;
//        cp.PartnerAllowed__c = true;
//        cp.DD_Payment_Allowed__c = true;
//        cp.Membership_Length__c = 24;
//        insert cp;
//
//
//        acc.Name = 'Test Membership';
//        acc.District_Association__c = da.Id;
//        acc.BillingPostalCode = 'TE1 0YZ';
//        acc.Date_Joined__c = system.today();
//        acc.Membership_Code__c = cp.Id;
//        //acct.Renewal_Date__c =
//        insert acc;
//
//        p.Product__c = cp.Id;
//        p.Price__c = 36.00;
//        p.Start_Date__c = pStartDate;
//        p.Payment_Type__c = 'Direct Debit';
//        p.Joining_Fee__c = 15.50;
//        insert p;
//        // Account acc = new Account (Name = 'Patel', Date_Joined__c = system.today());
//        //insert acc;
//
//        //Contact con = new Contact(FirstName = 'Tony', LastName = 'Golf', Phone = '01232324', RecordTypeId = rt.Id, Account = acc, mobilephone = '07985468888', email = 'tony@tony.com');
//        //insert con;
//        //SalesProcess process = new
//        Lead lead = new Lead(LastName = 'Golf', Email = 'yo@yo.com', sections__c = 'Association of Lightweight Camper', Company = 'Testco', hasPartner__c = true,
//                Secondary_Member_First_Name__c = 'Mrs Golf', Secondary_Member_Surname__c = 'Golf', Secondary_Member_Email__c = 'golf@yo.com', Joining_Fee_Waived__c = false,
//                Number_of_Children__c = '6', Child_1_First_Name__c = 'Child 1', Child_1_Surname__c = 'Golf', Child_2_First_Name__c = 'Child 2',
//                Child_2_Surname__c = 'Golf', Child_3_First_Name__c = 'Child 3', Child_3_Surname__c = 'Golf', Child_4_First_Name__c = 'Child 4',
//                Child_4_Surname__c = 'Golf', Child_5_First_Name__c = 'Child 5', Child_5_Surname__c = 'Golf', Child_6_First_Name__c = 'Child 6',
//                Child_6_Surname__c = 'Golf', Payment_Method__c = 'Direct Debit', hasAssociate__c = true, Associate_Member_First_Name__c = 'Assoic',
//                Associate_Member_Surname__c = 'Assoc Surname', Associate_Member_Title__c = 'Mr.', Sort_Code__c = '202020', Bank_Account_Name__c = 'Test Account',
//                Bank_Account_Number__c = '41111111', Bank_Name__c = 'Test', Membership_Code__c = 'Online', Joining_Date__c = joinedDate, postalcode = 'TE1 0YZ',
//                Child_1_Date_of_Birth__c = Date.today(), Child_2_Date_of_Birth__c = Date.today(), Child_3_Date_of_Birth__c = Date.today(),
//                Child_4_Date_of_Birth__c = Date.today(), Child_5_Date_of_Birth__c = Date.today(), Child_6_Date_of_Birth__c = Date.today(),
//                Associate_Member_Date_of_Birth__c = Date.today(), Secondary_Member_Title__c = 'Mr.');
//        insert lead;
//
//        CreateMember cm = new CreateMember();
//
//        Database.LeadConvertResult lc = cm.createMembershipfromLead(lead, '', '');
//
//        //cm.createMembershipfromLead(lead, 'Paid');
//
//        // Database.LeadConvert lc = new database.LeadConvert();
//
//
//        //Database.LeadConvertResult lcr = cm.createMembershipfromLead(lead,'000111','hello');
//
//
//    }

    /*static testMethod void CreateMemberTestWithDD() {
          // TO DO: implement unit test

          RecordType rt = [Select Id from RecordType Where SobjectType = 'Contact' AND DeveloperName='Lead' limit 1 ];

          Account acc = new Account (Name = 'Patel', Date_Joined__c = system.today());
          insert acc;

         Contact con = new Contact(FirstName = 'Tony', LastName = 'Golf', Phone = '01232324', RecordTypeId =rt.Id, Account = acc);
         insert con;

         Lead lead = new Lead(LastName = 'Golf', Email = 'yo@yo.com', sections__c = 'Association of Lightweight Camper', Company='Testco', hasPartner__c =true,
                                 Secondary_Member_First_Name__c = 'Mrs Golf', Secondary_Member_Surname__c = 'Golf', Secondary_Member_Email__c = 'golf@yo.com',
                                 Number_of_Children__c = '6', Child_1_First_Name__c ='Child 1', Child_1_Surname__c='Golf',  Child_2_First_Name__c ='Child 2',
                                 Child_2_Surname__c='Golf', Child_3_First_Name__c ='Child 3', Child_3_Surname__c='Golf',  Child_4_First_Name__c ='Child 4',
                                 Child_4_Surname__c='Golf', Child_5_First_Name__c ='Child 5', Child_5_Surname__c='Golf', Child_6_First_Name__c ='Child 6',
                                 Child_6_Surname__c='Golf', Payment_Method__c='Direct Debit', hasAssociate__c = true, Associate_Member_First_Name__c = 'Assoic',
                                  Associate_Member_Surname__c = 'Assoc Surname', Associate_Member_Title__c = 'Mr.');
         insert lead;

         CreateMember cm = new CreateMember();
         cm.createMembershipfromLead(lead, 'paid');


       }

    static testMethod void CreateMemberTestWithCC() {
          // TO DO: implement unit test

          RecordType rt = [Select Id from RecordType Where SobjectType = 'Contact' AND DeveloperName='Lead' limit 1 ];

          Account acc = new Account (Name = 'Patel', Date_Joined__c = system.today());
          insert acc;

         Contact con = new Contact(FirstName = 'Tony', LastName = 'Golf', Phone = '01232324', RecordTypeId =rt.Id, Account = acc);
         insert con;

         Lead lead = new Lead(LastName = 'Golf', Email = 'yo@yo.com', sections__c = 'Association of Lightweight Camper', Company='Testco', hasPartner__c =true,
                                 Secondary_Member_First_Name__c = 'Mrs Golf', Secondary_Member_Surname__c = 'Golf', Secondary_Member_Email__c = 'golf@yo.com',
                                 Number_of_Children__c = '6', Child_1_First_Name__c ='Child 1', Child_1_Surname__c='Golf',  Child_2_First_Name__c ='Child 2',
                                 Child_2_Surname__c='Golf', Child_3_First_Name__c ='Child 3', Child_3_Surname__c='Golf',  Child_4_First_Name__c ='Child 4',
                                 Child_4_Surname__c='Golf', Child_5_First_Name__c ='Child 5', Child_5_Surname__c='Golf', Child_6_First_Name__c ='Child 6',
                                 Child_6_Surname__c='Golf', Payment_Method__c='Cash / Cheque', hasAssociate__c = true, Associate_Member_First_Name__c = 'Assoic',
                                  Associate_Member_Surname__c = 'Assoc Surname', Associate_Member_Title__c = 'Mr.');
         insert lead;

         CreateMember cm = new CreateMember();
         cm.createMembershipfromLead(lead, 'Paid');


       }*/

}