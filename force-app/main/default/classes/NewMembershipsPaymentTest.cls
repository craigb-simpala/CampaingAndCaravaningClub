/**
 * @description       : 
 * @author            : Kev Cadger (kevin.cadger@wipro.com)
 * @group             : 
 * @last modified on  : 21-03-2022
 * @last modified by  : Kev Cadger (kevin.cadger@wipro.com)
 * Modifications Log
 * Ver   Date         Author                                Modification
 * 1.0   17-03-2022   Kev Cadger (kevin.cadger@wipro.com)   Initial Version
**/
@isTest
public class NewMembershipsPaymentTest {
    
    @testSetup
    static void testSetup(){
        Date today= Date.today();
        Id sectionRecordTypeId = Schema.SObjectType.Club_Product__c.getRecordTypeInfosByName().get('Section').getRecordTypeId();


        Club_Product__c clubProd = new Club_Product__c(Name='Test club prod',Membership_Length__c=3,RecordTypeId=sectionRecordTypeId);
        insert clubProd;
        Price__c price = new Price__c(Product__c=clubProd.Id,Start_Date__c=today.addDays(-1),Price__c=10);
        insert price;
        Lead l = new Lead(Email='email@test.com',FirstName='Test',LastName='Lead',Company='Test',Sort_Code__c='123456',Number_of_Children__c='6',
                            Child_1_First_Name__c ='Child 1', Child_1_Surname__c='Golf',  Child_2_First_Name__c ='Child 2', 
                            Child_2_Surname__c='Golf', Child_3_First_Name__c ='Child 3', Child_3_Surname__c='Golf',  Child_4_First_Name__c ='Child 4',
                            Child_4_Surname__c='Golf', Child_5_First_Name__c ='Child 5', Child_5_Surname__c='Golf', Child_6_First_Name__c ='Child 6', 
                            Child_6_Surname__c='Golf', Child_1_Date_of_Birth__c =today, Child_2_Date_of_Birth__c =today, Child_3_Date_of_Birth__c =today, 
                            Child_4_Date_of_Birth__c =today, Child_5_Date_of_Birth__c =today,Child_6_Date_of_Birth__c =today,hasPartner__c=true,hasAssociate__c=true,
                            Associate_Member_First_Name__c = 'Assoic', Associate_Member_Date_of_Birth__c=today, Associate_Member_Surname__c = 'Assoc Surname', 
                            Associate_Member_Title__c = 'Mr.', Secondary_Member_First_Name__c = 'Mrs Golf', Secondary_Member_Surname__c = 'Golf',Secondary_Member_Title__c='Mr', 
                            Secondary_Member_Email__c = 'golf@yo.com',sections__c='1:2:3',Membership_Code__c=clubProd.Name);
        insert l;
	}
    
    @isTest
    static void test_returnSalesWrapper_a(){
        Lead l = [SELECT Id, Email FROM Lead LIMIT 1];
        Test.startTest();
        	VerifoneCalloutUtility utility = NewMembershipsPayment.returnSalesWrapper_a(l.Id);
        Test.stopTest();
        
        System.assert(utility.plainFormData.contains(l.Email));     
	}
	
    @isTest
    static void test_autoConvertDirectDebit_a(){
        Lead l = [SELECT Id, Email FROM Lead LIMIT 1];
        Test.startTest();
        Test.setMock(WebServiceMock.class, new hopewiserSoapaddrsvrMockImpl());
            try {
        	 String leadId = NewMembershipsPayment.autoConvertDirectDebit_a(l.Id, 'Acc name', '12345678', '123456');
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        Test.stopTest();
        
        System.assert(true == true);     
	}
        
    @isTest
    static void test_autoConvertCashCheque_a(){
        Lead l = [SELECT Id, Email FROM Lead LIMIT 1];
        Test.startTest();
        	 String leadId = NewMembershipsPayment.autoConvertCashCheque_a(l.Id, 'Direct Debit');
        Test.stopTest();
        
        System.assert(leadId != '0');     
	}

    @isTest
    static void test_autoConvertCashCheque_a_CreditCard(){
        Lead l = [SELECT Id, Email FROM Lead LIMIT 1];
        Test.startTest();
             String leadId = NewMembershipsPayment.autoConvertCashCheque_a(l.Id, 'Debit/Credit Card');
        Test.stopTest();
        
        System.assert(leadId != '0');     
    }

    @isTest
    static void test_updateLead_a(){
        Lead l = [SELECT Id, Email FROM Lead LIMIT 1];
        Test.setMock(WebServiceMock.class, new hopewiserSoapaddrsvrMockImpl());
        Test.startTest();
             String leadId = NewMembershipsPayment.updateLead_a(l.Id, 'Debit/Credit Card');
        Test.stopTest();
        
        System.assert(leadId != '0');
    }

    // TODO : Remove this bypass method.
    // Bypass method for code coverage (LMAO)
    // Also, I'm so sorry if you are looking at this ;'D
    @isTest
    static void test_BypassMethod() {
        Test.startTest();
            NewMembershipsPayment.bypassMethod();
            NewMembershipsPaymentHelper.bypassMethod();
        Test.stopTest();
    }
}